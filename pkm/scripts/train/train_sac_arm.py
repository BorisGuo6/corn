import numpy as np
if not hasattr(np, 'float'):
    np.float = np.float32
from isaacgym import gymtorch

import d3rlpy
import gym
from icecream import ic

from pkm.util.hydra_cli import hydra_cli
from train_ppo_arm import Config, setup, set_seed, recursive_replace_map, load_env
from pkm.env.env.wrap.dict_to_tensor import DictToTensor, ObservationWrapper

@hydra_cli(
    config_path='../../src/pkm/data/cfg/',
    config_name='train_rl')
def main(cfg: Config):
    # path, writer = setup(cfg)
    path = setup(cfg)
    seed = set_seed(cfg.env.seed)
    ic.configureOutput(includeContext=True)
    cfg = recursive_replace_map(cfg, {'finalize': True})
    cfg, env = load_env(cfg, path)
    print('obs_space', env.observation_space)
    env = DictToTensor(env)

    # prepare algorithm
    sac = d3rlpy.algos.SAC(use_gpu=True)

    # prepare replay buffer
    buffer = d3rlpy.online.buffers.BatchReplayBuffer(maxlen=1000, env=env)

    # start training
    # sac.fit_batch_online(env, buffer, n_steps=1000000, eval_env=None)
    sac.fit_batch_online(
        env,
        buffer,
        n_epochs=1000,
        n_steps_per_epoch=1000,
        n_updates_per_epoch=1,
        eval_env=None,
        logdir="test_data",
    )

if __name__ == '__main__':
    main()
