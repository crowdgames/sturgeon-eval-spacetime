import os, sys
import util_common, util_solvers

if __name__ == '__main__':
    if len(sys.argv) > 1:
        solvers_to_test = sys.argv[1:]
    else:
        solvers_to_test = list(sorted(set(util_solvers.SOLVER_LIST) - set(util_solvers.SOLVER_NOTEST_LIST)))

    os.environ['STG_MUTE_TIME'] = '1'
    os.environ['STG_MUTE_PORT'] = '1'

    tests = []

    def setup(solver, wt, a, b):
        solver.cnstr_count([a], False, 1, 1, wt)
        solver.cnstr_implies_disj(a, False, [b], False, wt)
    tests.append((setup, [False, False]))

    def setup(solver, wt, a, b, c):
        solver.cnstr_implies_disj(a, True, [b], True, wt)
        solver.cnstr_implies_disj(b, True, [c], True, wt)
        solver.cnstr_count([a, b, c], True, 2, 2, wt)
    tests.append((setup, [False, True, True]))

    def setup(solver, wt, a, b, c):
        solver.cnstr_count([a, b, c], True, 3, 3, wt)
    tests.append((setup, [True, True, True]))

    def setup(solver, wt, a, b, c):
        solver.cnstr_count([a, b, c], False, 3, 3, wt)
    tests.append((setup, [False, False, False]))

    def setup(solver, wt, a, b, c):
        solver.cnstr_count([a, b], True, 1, 1, wt)
        solver.cnstr_count([b], True, 0, 0, wt)
        solver.cnstr_implies_disj(a, True, [b, c], True, wt)
    tests.append((setup, [True, False, True]))

    def setup(solver, wt, a, b, c):
        j = solver.make_conj([a, b, c], [True, False, True])
        solver.cnstr_count([j], True, 1, 1, wt)
    tests.append((setup, [True, False, True]))

    def setup(solver, wt, a, b, c):
        j = solver.make_conj([a, b, c], False)
        solver.cnstr_count([b], False, 1, 1, wt)
        solver.cnstr_count([c], True, 0, 0, wt)
        solver.cnstr_count([j], False, 1, 1, wt)
    tests.append((setup, [True, False, False]))

    def setup(solver, wt, a, b, c, d):
        solver.cnstr_count([a, b, c, d], False, 3, 4, wt)
        solver.cnstr_count([a], True, 1, 1, wt)
    tests.append((setup, [True, False, False, False]))

    def setup(solver, wt, a, b, c, d):
        solver.cnstr_count([a, b], True, 1, 1, wt)
        solver.cnstr_count([b], False, 1, 1, wt)
        solver.cnstr_count([d], False, 1, 1, wt)
        solver.cnstr_count([a, b, c, d], [True, True, False, False], 2, 2, wt)
    tests.append((setup, [True, False, True, False]))

    def setup(solver, wt, a):
        solver.cnstr_implies_disj(a, True, [], [], wt)
    tests.append((setup, [False]))

    def setup(solver, wt, a):
        solver.cnstr_implies_disj(a, False, [], [], wt)
    tests.append((setup, [True]))

    def setup(solver, wt, a):
        j = solver.make_conj([a], True)
        solver.cnstr_count([j], True, 1, 1, wt)
    tests.append((setup, [True]))

    def setup(solver, wt, a):
        j = solver.make_conj([a], False)
        solver.cnstr_count([j], True, 1, 1, wt)
    tests.append((setup, [False]))

    def setup(solver, wt, a, b):
        j = solver.make_conj([a, a, a, a, b], True)
        solver.cnstr_count([j], True, 1, 1, wt)
    tests.append((setup, [True, True]))

    def setup(solver, wt, a, b):
        solver.cnstr_implies_disj(a, True, [b, b, b, b], True, wt)
        solver.cnstr_count([a], True, 1, 1, wt)
    tests.append((setup, [True, True]))

    def setup(solver, wt, a, b):
        solver.cnstr_count([a, a, b, b, b], True, 1, 2, wt)
    tests.append((setup, [True, False]))

    def setup(solver, wt, a, b, c):
        solver.cnstr_count([a, a, b, b, b, b, c, c, c, c, c, c], True, 7, 9, wt)
    tests.append((setup, [True, False, True]))

    def setup(solver, wt, a, b, c):
        solver.cnstr_count([a, a, b, b, b, b, c, c, c, c, c, c], False, 7, 9, wt)
    tests.append((setup, [False, True, False]))

    def setup(solver, wt, a, b, c, d):
        solver.cnstr_count([a, b, c, d], True, 0, 2, wt)
        solver.cnstr_count([a, b], True, 2, 2, wt)
    tests.append((setup, [True, True, False, False]))

    def setup(solver, wt, a, b, c, d):
        solver.cnstr_count([a, b, c, d], False, 0, 2, wt)
        solver.cnstr_count([a, b], False, 2, 2, wt)
    tests.append((setup, [False, False, True, True]))

    def setup(solver, wt, a, b, c, d):
        solver.cnstr_count([a, b, c, d], True, 2, 4, wt)
        solver.cnstr_count([a, b], False, 2, 2, wt)
    tests.append((setup, [False, False, True, True]))

    def setup(solver, wt, a, b, c, d):
        solver.cnstr_count([a, b, c, d], False, 2, 4, wt)
        solver.cnstr_count([a, b], True, 2, 2, wt)
    tests.append((setup, [True, True, False, False]))

    for solver_id in solvers_to_test:
        for use_portfolio in [False, True]:
            for use_weight in [None, 1]:
                print(solver_id, 'portfolio:' + str(use_portfolio), 'weight:' + str(use_weight))

                solver = util_solvers.solver_id_to_solver(solver_id)
                if use_weight is not None and not solver.supports_weights():
                    print('skip')
                    continue

                for setup, expect in tests:
                    nvars = len(expect)
                    print('.', end='')
                    if use_portfolio:
                        solver = util_solvers.PortfolioSolver([solver_id], None)
                    else:
                        solver = util_solvers.solver_id_to_solver(solver_id)
                    vvs = [solver.make_var() for ii in range(nvars)]
                    setup(solver, use_weight, *vvs)
                    solved = solver.solve()
                    util_common.check(solved, 'solve')
                    res = [solver.get_var(vv) for vv in vvs]
                    util_common.check(res == expect, 'var')
                    obj = solver.get_objective()
                    util_common.check(obj == 0, 'objective')
                print()
