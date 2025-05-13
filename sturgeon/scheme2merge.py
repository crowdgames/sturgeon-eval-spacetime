import argparse, os, pickle, pprint, sys
import util_common



def scheme2merge(scheme_infos, remap_rows):
    si = util_common.SchemeInfo()

    si.tileset = None

    si.game_to_tag_to_tiles = {}

    si.count_info = None

    si.pattern_info = util_common.SchemePatternInfo()

    si.pattern_info.game_to_patterns = {}

    si.pattern_info.stride_rows = None
    si.pattern_info.stride_cols = None
    si.pattern_info.dr_lo = 0
    si.pattern_info.dr_hi = 0
    si.pattern_info.dc_lo = 0
    si.pattern_info.dc_hi = 0

    for scheme_info in scheme_infos:
        if si.tileset is None:
            si.tileset = scheme_info.tileset
        else:
            util_common.check_tileset_match(si.tileset, scheme_info.tileset)



        if si.count_info is None:
            si.count_info = scheme_info.count_info
        else:
            util_common.check(scheme_info.count_info is None, 'merging count_info not supported.')



        for game in scheme_info.game_to_tag_to_tiles:
            for tag, tiles in scheme_info.game_to_tag_to_tiles[game].items():
                for tile in tiles:
                    if game not in si.game_to_tag_to_tiles:
                        si.game_to_tag_to_tiles[game] = {}
                    if tag not in si.game_to_tag_to_tiles[game]:
                        si.game_to_tag_to_tiles[game][tag] = {}
                    si.game_to_tag_to_tiles[game][tag][tile] = None


        if remap_rows is not None:
            util_common.check(scheme_info.pattern_info.stride_rows == 1 and scheme_info.pattern_info.stride_cols == 1, 'remap with stride not supported')

        if si.pattern_info.stride_rows is None:
            si.pattern_info.stride_rows = scheme_info.pattern_info.stride_rows
        else:
            util_common.check(si.pattern_info.stride_rows == scheme_info.pattern_info.stride_rows, 'cannot merge different strides')

        if si.pattern_info.stride_cols is None:
            si.pattern_info.stride_cols = scheme_info.pattern_info.stride_cols
        else:
            util_common.check(si.pattern_info.stride_cols == scheme_info.pattern_info.stride_cols, 'cannot merge different strides')

        si.pattern_info.dr_lo = min(si.pattern_info.dr_lo, scheme_info.pattern_info.dr_lo)
        si.pattern_info.dr_hi = max(si.pattern_info.dr_hi, scheme_info.pattern_info.dr_hi)
        si.pattern_info.dc_lo = min(si.pattern_info.dc_lo, scheme_info.pattern_info.dc_lo)
        si.pattern_info.dc_hi = max(si.pattern_info.dc_hi, scheme_info.pattern_info.dc_hi)



        remapped_rows = {}

        def _remap(_deltas):
            if remap_rows is None:
                return _deltas
            else:
                _deltas_new = ()
                for _rr, _cc in _deltas:
                    util_common.check(_rr in remap_rows, str(_rr) + ' not in remap_rows')
                    remapped_rows[_rr] = None
                    _rr = remap_rows[_rr]
                    _deltas_new += ((_rr, _cc),)
                return _deltas_new



        game_to_patterns = scheme_info.pattern_info.game_to_patterns
        game_to_patterns_new = si.pattern_info.game_to_patterns

        for game in game_to_patterns:
            if game not in game_to_patterns_new:
                game_to_patterns_new[game] = {}

            for pattern_template_in in game_to_patterns[game]:
                pattern_template_in_new = _remap(pattern_template_in)
                if pattern_template_in_new not in game_to_patterns_new[game]:
                    game_to_patterns_new[game][pattern_template_in_new] = {}

                for pattern_in in game_to_patterns[game][pattern_template_in]:
                    if pattern_in not in game_to_patterns_new[game][pattern_template_in_new]:
                        game_to_patterns_new[game][pattern_template_in_new][pattern_in] = {}

                    for pattern_group_template_out in game_to_patterns[game][pattern_template_in][pattern_in]:
                        if pattern_group_template_out is None:
                            game_to_patterns_new[game][pattern_template_in_new][pattern_in][None] = {None: None}

                        elif type(pattern_group_template_out) == tuple:
                            pattern_template_out = pattern_group_template_out
                            pattern_template_out_new = _remap(pattern_template_out)
                            if pattern_template_out_new not in game_to_patterns_new[game][pattern_template_in_new][pattern_in]:
                                game_to_patterns_new[game][pattern_template_in_new][pattern_in][pattern_template_out_new] = {}

                            for pattern_out in game_to_patterns[game][pattern_template_in][pattern_in][pattern_template_out]:
                                game_to_patterns_new[game][pattern_template_in_new][pattern_in][pattern_template_out_new][pattern_out] = None

                        else:
                            pattern_group_out = pattern_group_template_out
                            if pattern_group_out not in game_to_patterns_new[game][pattern_template_in_new][pattern_in]:
                                game_to_patterns_new[game][pattern_template_in_new][pattern_in][pattern_group_out] = {}

                            for pattern_template_out in game_to_patterns[game][pattern_template_in][pattern_in][pattern_group_out]:
                                pattern_template_out_new = _remap(pattern_template_out)
                                if pattern_template_out_new not in game_to_patterns_new[game][pattern_template_in_new][pattern_in][pattern_group_out]:
                                    game_to_patterns_new[game][pattern_template_in_new][pattern_in][pattern_group_out][pattern_template_out_new] = {}

                                for pattern_out in game_to_patterns[game][pattern_template_in][pattern_in][pattern_group_out][pattern_template_out]:
                                    game_to_patterns_new[game][pattern_template_in_new][pattern_in][pattern_group_out][pattern_template_out_new][pattern_out] = None

        if remap_rows is not None:
            for rr in remap_rows:
                util_common.check(rr in remapped_rows, str(rr) + ' not remapped')

    util_common.summarize_scheme_info(si, sys.stdout)

    return si



if __name__ == '__main__':
    util_common.timer_start()

    parser = argparse.ArgumentParser(description='Create scheme from tile info and (optionally) tag level.')
    parser.add_argument('--outfile', required=True, type=str, help='Output scheme file.')
    parser.add_argument('--schemefile', required=True, type=str, nargs='+', help='Scheme file(s) to remap.')
    parser.add_argument('--remap-row', type=str, nargs='+', help='Rows to remap.')
    parser.add_argument('--quiet', action='store_true', help='Reduce output.')
    args = parser.parse_args()

    if args.quiet:
        sys.stdout = open(os.devnull, 'w')

    scheme_info_in = []
    for schemefile in args.schemefile:
        with util_common.openz(schemefile, 'rb') as f:
            scheme_info_in.append(pickle.load(f))

    remap_row = None
    remap_row_str = util_common.arg_list_to_dict_str_int(parser, '--remap-row', args.remap_row)
    if remap_row_str is not None:
        remap_row = {}
        for rng_str, delta in remap_row_str.items():
            rng_lo, rng_hi = [int(ee) for ee in rng_str.split(',')]
            util_common.check(rng_lo <= rng_hi, 'remap')
            for ind in range(rng_lo, rng_hi + 1):
                util_common.check(ind not in remap_row, 'remap')
                remap_row[ind] = ind + delta

    scheme_info = scheme2merge(scheme_info_in, remap_row)
    with util_common.openz(args.outfile, 'wb') as f:
        pickle.dump(scheme_info, f)
