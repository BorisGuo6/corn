#!/usr/bin/env python3

from isaacgym import gymtorch

from typing import Mapping
from dataclasses import dataclass, replace
from pathlib import Path
import torch as th
import pickle
from gym import spaces
from icecream import ic
from d3rlpy.dataset import create_fifo_replay_buffer

from pkm.util.hydra_cli import hydra_cli
from pkm.util.torch_util import dcn
from pkm.env.env.wrap.base import WrapperEnv

from show_ppo_arm import (Config, load_env, set_seed, map_struct, load_agent)


@dataclass
class MyConfig(Config):
    data_size: int = 1_000_000


class SerializeEpisodes(WrapperEnv):
    """
    Run environments in parallel and save episodes in the order of completion.
    """

    def __init__(self, env):
        super().__init__(env)
        keys = sorted(list(env.observation_space.keys()))
        self._keys = list(keys)

        self.data = [[] for _ in range(self.num_env)]

        self.out_path = Path('/tmp/data/')
        self.out_path.mkdir(parents=True, exist_ok=True)
        # NOTE(ycho): start the index from previous export results
        self.eps_count = len(self.out_path.glob('*.pkl'))

        self.prev_obs = None
        self.prev_done = None
        self.buf = None
        self.count = th.zeros(self.num_env, device=self.device,
                              dtype=th.long)

    def add(self,
            obsn, actn, rewd,
            term, tout, done):

        # == Initialize buffers at the beginning ==
        if self.prev_obs is None:
            self.prev_obs = obsn.clone()
            self.prev_done = done.clone()
            self.buf = dict(
                obsn=obsn[None].expand(self.timeout, *obsn.shape).contiguous(),
                actn=actn[None].expand(self.timeout, *actn.shape).contiguous(),
                rewd=rewd[None].expand(self.timeout, *rewd.shape).contiguous(),
                term=term[None].expand(self.timeout, *term.shape).contiguous(),
                tout=tout[None].expand(self.timeout, *tout.shape).contiguous()
            )
            return

        # == Add entry to buffer ==
        self.buf['obsn'][self.count] = obsn
        self.buf['actn'][self.count] = actn
        self.buf['rewd'][self.count] = rewd
        self.buf['term'][self.count] = term
        self.buf['tout'][self.count] = tout

        # ==  Export episode ==
        count = dcn(self.count)
        for i in dcn(th.argwhere(done).ravel()):
            # NOTE(ycho): offset `obsn` by -1 since
            # we're actually processing "previous" observation.
            n = int(count[i])
            eps_i = {k: (
                dcn(v[:, i][:n]) if k == 'obsn' else
                dcn(v[:, i][1:n + 1])
            )
                for (k, v) in self.buf.items()
            }
            eps_file = F'{self.out_path}/{self.eps_count:05d}.pkl'
            with open(eps_file, 'wb') as fp:
                pickle.dump(eps_i, fp)
            self.eps_count += 1

        # == Increment (or reset) step counts ==
        self.count = th.where(done,
                              th.zeros_like(self.count),
                              self.count + 1)

    def step(self, act):
        obs, rew, done, info = super().step(act)
        # "termination" is "done but not timeout"
        tout = info['timeout']
        term = th.logical_and(done, th.logical_not(tout))

        obs_ = dict(obs)
        obs_['icp_emb'] = obs_['icp_emb'].flatten(start_dim=-2)
        obs_flat = th.cat([obs_[k] for k in self._keys], dim=-1)
        self.add(obs_flat, act, rew, term, tout, done)
        return obs, rew, done, info


@hydra_cli(config_name='show')
def main(cfg: MyConfig):
    ic.configureOutput(includeContext=True)
    cfg = replace(cfg, finalize=True)
    ic(cfg)

    # Maybe it's related to jit
    if cfg.global_device is not None:
        th.cuda.set_device(cfg.global_device)
    path, writer = None, None
    _ = set_seed(cfg.env.seed)
    if (cfg.use_nvdr_record_episode or cfg.use_nvdr_record_viewer):
        cfg.env.track_debug_lines = True
    cfg, env = load_env(cfg,
                        path,
                        freeze_env=True,
                        check_viewer=False)
    env = SerializeEpisodes(env)

    # Update cfg elements from `env`.
    obs_space = map_struct(
        env.observation_space,
        lambda src, _: src.shape,
        base_cls=spaces.Box,
        dict_cls=(Mapping, spaces.Dict)
    )
    if cfg.state_net_blocklist is not None:
        for key in cfg.state_net_blocklist:
            obs_space.pop(key, None)
    dim_act = (
        env.action_space.shape if isinstance(
            env.action_space,
            spaces.Box) else env.action_space.n)
    cfg = replace(cfg, net=replace(cfg.net,
                                   obs_space=obs_space,
                                   act_space=dim_act
                                   ))

    # Load Agent
    agent = load_agent(cfg, env, None, None)
    agent.eval()

    try:
        steps: int = (cfg.data_size + env.num_env - 1) // env.num_env
        for (act, obs, rew, done, info) in agent.test(
                sample=cfg.sample_action,
                steps=steps):
            if cfg.sync_frame_time:
                env.gym.sync_frame_time(env.sim)
    finally:
        pass


if __name__ == '__main__':
    main()
