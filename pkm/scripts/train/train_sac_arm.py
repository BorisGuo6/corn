#!/usr/bin/env python3

import numpy as np
if not hasattr(np, 'float'):
    np.float = np.float32
from isaacgym import gymtorch

from typing import Optional, Iterable, Dict
from dataclasses import replace
from icecream import ic
import torch as th
from gym import spaces
import d3rlpy

from pkm.util.hydra_cli import hydra_cli
from pkm.util.torch_util import dcn
from pkm.env.env.wrap.base import ObservationWrapper

from train_ppo_arm import Config, setup, set_seed, load_env


class WrapD3RL(ObservationWrapper):
    def __init__(self, env, keys: Optional[Iterable[str]] = None):
        super().__init__(env, self._to_tensor)
        if keys is None:
            assert (isinstance(env.observation_space, spaces.Dict))
            keys = sorted(list(env.observation_space.keys()))
        self._keys = list(keys)
        lo = np.concatenate([env.observation_space[k].low
                             for k in self._keys], axis=0)
        hi = np.concatenate([env.observation_space[k].high
                             for k in self._keys], axis=0)
        self._observation_space = spaces.Box(lo, hi)

    def __len__(self):
        return self.num_env

    @property
    def action_space(self):
        return self.env.action_space

    @property
    def observation_space(self):
        return self._observation_space

    def _to_tensor(self, obs: Dict[str, th.Tensor]) -> th.Tensor:
        return th.cat([obs[k] for k in self._keys], dim=-1)

    def reset(self):
        obs = super().reset()
        return dcn(obs).squeeze(axis=0), None

    def step(self, act: th.Tensor):
        act = th.as_tensor(act, device=self.device)[None]
        obs, rew, don, inf = super().step(act)
        trunc = inf['timeout']
        inf_out = [{} for _ in range(self.num_env)]
        out = (dcn(obs).squeeze(axis=0),
               dcn(rew).squeeze(axis=0),
               dcn(don).squeeze(axis=0),
               dcn(trunc).squeeze(axis=0),
               inf_out[0])
        return out


@hydra_cli(
    config_path='../../src/pkm/data/cfg/',
    config_name='train_rl')
def main(cfg: Config):
    # path, writer = setup(cfg)
    path = setup(cfg)
    seed = set_seed(cfg.env.seed)
    ic.configureOutput(includeContext=True)
    cfg = replace(cfg, finalize=True)
    cfg, env = load_env(cfg, path, freeze_env=True)
    env = WrapD3RL(env)

    # prepare algorithm
    # sac = d3rlpy.algos.SAC(use_gpu=True)
    sac = d3rlpy.algos.SACConfig().create(device="cuda:0")

    sac.fit_online(
        env,
        n_steps=1_000_000,
        eval_env=None,
    )


if __name__ == '__main__':
    main()
