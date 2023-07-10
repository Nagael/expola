#!/usr/bin/env python3
import sys
import os
import subprocess
import random
import argparse

mydir = os.path.dirname(sys.argv[0])

parser = argparse.ArgumentParser("Run all MGS experiments")
parser.add_argument("--algo", help="Choose algorithm", choices=["mgs", "a2v", "v2q"], default="mgs")
parser.add_argument("--exec", default=None)
parser.add_argument("--batch", default=None, type=int, nargs="+")
parser.add_argument("--mvalues", default=None, type=int, nargs="+")
parser.add_argument("--nvalues", default=None, type=int, nargs="+")
parser.add_argument("--all", action="store_true")
parser.add_argument("other", nargs="*")
clargs = parser.parse_args()

executable = clargs.exec
if executable is None:
    if clargs.algo == "mgs":
        executable = os.path.join(os.path.join(mydir, "../pola/gs/"), "main_qr__time.exe")
    elif clargs.algo == "a2v":
        executable = os.path.join(os.path.join(mydir, "../pola/hh/"), "main_a2v__time.exe")
    elif clargs.algo == "v2q":
        executable = os.path.join(os.path.join(mydir, "../pola/hh/"), "main_v2q__time.exe")

if clargs.algo == "a2v":
    if clargs.all:
        base_methods = ["hh_a2v_ll_blas", "hh_a2v_rec_blas", "hh_a2v_rl_blas", "geqr2", "geqrf"]
        batched_methods = ["hh_a2v_ll_tiled_blas", "hh_a2v_rl_tiled_blas"]
    else:
        base_methods = ["hh_a2v_ll_blas", "geqr2", "geqrf"]
        batched_methods = ["hh_a2v_ll_tiled_blas"]

elif clargs.algo == "v2q":
    if clargs.all:
        base_methods = ["hh_v2q_ll_blas", "hh_v2q_rl_blas", "hh_v2q_rec_blas", "org2r", "orgqr"]
        batched_methods = ["hh_v2q_ll_tiled_blas", "hh_v2q_rl_tiled_blas"]
    else:
        base_methods = ["hh_v2q_ll_blas", "org2r", "orgqr"]
        batched_methods = ["hh_v2q_ll_tiled_blas"]
else:
    if clargs.all:
        base_methods = ["mgs_ll_blas", "mgs_rl_blas", "mgs_rec_blas"]
        batched_methods = ["mgs_ll__tiled_blas", "mgs_rl__tiled_blas"]
    else:
        base_methods = ["mgs_ll_blas" ]
        batched_methods = ["mgs_ll__tiled_blas"]

batch_sizes = clargs.batch
if batch_sizes is None:
    batch_sizes = [1, 2, 3, 4, 5, 8, 10, 16, 20, 25, 30, 32, 40, 50, 64, 75, 100, 128, 200]
# cases = [(5000, 500), (1000, 1000), (256, 256), (10000, 100), (100000, 100), (10000, 200), (100000, 200), (10000, 400), (100000, 400)]
mvalues = clargs.mvalues
if mvalues is None:
    mvalues = [1000, 5000, 10000, 50000, 100000]

nvalues = clargs.nvalues
if nvalues is None:
    nvalues =  [100, 200, 400]

cases = [ (m, n) for m in mvalues for n in nvalues ]
repetitions = 5

class Experiment:
    idx = 0
    order = 0
    def __init__(self, method, bsize, m, n):
        self.method = method
        self.bsize = bsize
        self.m = m
        self.n = n
        self.idx = Experiment.idx
        Experiment.idx += 1
        self.result = None
        self.order = None

    def run(self):
        self.order = Experiment.order
        Experiment.order += 1
        args = [executable, "-method", self.method, "-m", str(self.m), "-n", str(self.n), *clargs.other]
        if self.bsize:
            args += ["-b", str(self.bsize)]
        print("Running", *args, file=sys.stderr, flush=True)
        result = subprocess.run(args, universal_newlines=True, stdout=subprocess.PIPE)
        self.result = result.stdout.strip()
        return self.result

def make_experiments():
    result = []
    for (m, n) in cases:
        for method in base_methods:
            for _ in range(repetitions):
                result.append(Experiment(method, None, m, n))
        for method in batched_methods:
            for b in batch_sizes:
                if b < n:
                    for _ in range(repetitions):
                        result.append(Experiment(method, b, m, n))
    random.shuffle(result)
    return result


if __name__ == "__main__":
    # import argparse
    exps = make_experiments()
    for exp in exps:
        exp.run()
        print(exp.order, exp.result, flush=True)
