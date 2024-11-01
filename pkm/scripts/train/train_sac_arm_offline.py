#!/usr/bin/env python3

from typing import Optional, Iterable, Dict
from dataclasses import replace
import numpy as np
from icecream import ic
import torch as th
from gym import spaces
from pathlib import Path
from tqdm.auto import tqdm
import d3rlpy
import pickle
from pkm.util.torch_util import dcn


def get_dataset():
    out = dict()
    for pkl in tqdm(Path('/tmp/data/').glob('*.pkl')):
        with open(pkl, 'rb') as fp:
            episode = pickle.load(fp)
            for k, v in episode.items():
                if k not in out:
                    out[k] = v
                    continue
                out[k] = np.concatenate([out[k], v], axis=0)
    dataset = d3rlpy.dataset.MDPDataset(
        out['obsn'],
        out['actn'],
        out['rewd'],
        out['term'],
        out['tout']
    )
    return dataset


def main():
    sac = d3rlpy.algos.SACConfig().create(device="cuda:0")
    dataset = get_dataset()
    sac.fit(dataset, n_steps=1_000_000)


if __name__ == '__main__':
    main()
