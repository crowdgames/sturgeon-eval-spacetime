import argparse
import util_common, util_path, util_reach



def level2concat(text_levels, term_inst, padding, game_init, game_intr, game_fini, game_pdng):
    concat_text = None
    concat_game = None
    rows, cols = None, None

    for ii in range(term_inst - 1):
        text_levels.append(text_levels[-1])

    use_games = False
    if (game_init is not None) or (game_intr is not None) or (game_fini is not None) or (game_pdng is not None):
        util_common.check(game_init is not None, 'game')
        util_common.check(game_intr is not None, 'game')
        util_common.check(game_fini is not None, 'game')
        util_common.check(game_pdng is not None, 'game')
        use_games = True

    for ii, text_level in enumerate(text_levels):
        curr_rows = len(text_level)
        curr_cols = len(text_level[0])
        if ii == 0:
            rows, cols = curr_rows, curr_cols
            concat_text = list(text_level)
            if use_games:
                concat_game = util_common.make_grid(rows, cols, game_init)
        else:
            util_common.check((rows, cols) == (curr_rows, curr_cols), 'level sizes do not match')
            concat_text += util_common.make_grid(padding, cols, util_common.VOID_TEXT)
            concat_text += text_level
            if use_games:
                concat_game += util_common.make_grid(padding, cols, game_pdng)
                if ii + 1 < len(text_levels):
                    concat_game += util_common.make_grid(rows, cols, game_intr)
                else:
                    concat_game += util_common.make_grid(rows, cols, game_fini)

    return concat_text, concat_game



if __name__ == '__main__':
    util_common.timer_start()

    parser = argparse.ArgumentParser(description='Concatenate multiple levels into a single level.')
    parser.add_argument('--outfile', required=True, type=str, help='File to write to.')
    parser.add_argument('--term-inst', type=int, help='Number of instances of last level to include.')
    parser.add_argument('--padding', required=True, type=int, help='Padding between individual levels.')
    parser.add_argument('--game', type=str, nargs=4, help='Game to use for initial, interior, final levels, and padding.')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--size', type=int, nargs=2, help='Level size (if no tag or game file provided.')
    group.add_argument('--textfile', type=str, nargs='+', help='Input text file.')
    args = parser.parse_args()

    if args.size is not None:
        rows, cols = args.size
        text_levels = [util_common.make_grid(rows, cols, util_common.DEFAULT_TEXT)]
        suff = '.tag'
    elif args.textfile is not None:
        text_levels = [util_common.read_text_level(textfile, False) for textfile in args.textfile]
        suff = '.lvl'

    if args.game is not None:
        game_init, game_intr, game_fini, game_pdng = args.game
    else:
        game_init, game_intr, game_fini, game_pdng = [None] * 4

    concat_text, concat_game = level2concat(text_levels, args.term_inst, args.padding, game_init, game_intr, game_fini, game_pdng)

    with util_common.openz(args.outfile + suff, 'wt') as f:
        util_common.print_text_level(concat_text, outstream=f)

    if concat_game is not None:
        with util_common.openz(args.outfile + '.game', 'wt') as f:
            util_common.print_text_level(concat_game, outstream=f)

    util_common.exit_solution_found()
