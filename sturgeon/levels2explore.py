import argparse, glob, gzip, math, os, pickle, random, sys, threading, time
import util_common, util_explore
import numpy as np
import PIL.Image, PIL.ImageDraw, PIL.ImageTk
import tkinter, tkinter.messagebox



def one_hot(rows, cols, ntind, neind, npind, levels, einds, pinds):
    a = np.zeros((len(levels), rows, cols, ntind), dtype=np.uint8)
    for ll, level in enumerate(levels):
        for rr in range(rows):
            for cc in range(cols):
                for tind in level[rr][cc]:
                    a[ll][rr][cc][tind] = 1
    a = a.reshape((len(levels), rows * cols * ntind))

    b = np.zeros((len(levels), neind), dtype=np.uint8)
    for ll, ll_einds in enumerate(einds):
        for eind in ll_einds:
            b[ll][eind] = 1

    c = np.zeros((len(levels), npind), dtype=np.uint8)
    for ll, ll_pinds in enumerate(pinds):
        for pind in ll_pinds:
            c[ll][pind] = 1

    return np.concatenate((a, b, c), axis=1)



def levels2explore(tilefiles, resultfiles, pad_top, text_only, image_only):
    print('loading...')

    rows, cols = None, None
    tileset = None
    use_text = None
    use_image = None

    all_levels = []

    tind_to_text = {}
    text_to_tind = {}
    tind_to_image = {}
    image_to_tind = {}
    tinds_to_tiles = {}
    tile_to_tinds = {}

    ntind = 0
    ntind_both = 0
    ntind_text = 0
    ntind_image = 0

    eind_to_edge = {}
    edge_to_eind = {}
    all_edges = []
    all_einds = []

    pind_to_prop = {}
    prop_to_pind = {}
    all_pinds = []

    def set_tileset(_tileset):
        nonlocal tileset, use_text, use_image
        nonlocal tind_to_text, text_to_tind, tind_to_image, image_to_tind, tinds_to_tiles, tile_to_tinds
        nonlocal ntind, ntind_both, ntind_text, ntind_image

        if tileset == None:
            tileset = _tileset
            use_text = (tileset.tile_to_text is not None) and (not image_only)
            use_image = (tileset.tile_to_image is not None) and (not text_only)

            tile_to_tinds = {}
            for _tile in tileset.tile_ids:
                tile_to_tinds[_tile] = []

            _tile_to_image_key = {}
            if use_image:
                for _tile in tileset.tile_ids:
                    _tile_to_image_key[_tile] = tuple(tileset.tile_to_image[_tile].getdata())

            _text_uniq = {}
            _image_key_uniq = {}

            for _tile in tileset.tile_ids:
                if use_text:
                    _text = tileset.tile_to_text[_tile]
                    if _text in _text_uniq:
                        _text_uniq[_text] = False
                    else:
                        _text_uniq[_text] = True
                if use_image:
                    _image_key = _tile_to_image_key[_tile]
                    if _image_key in _image_key_uniq:
                        _image_key_uniq[_image_key] = False
                    else:
                        _image_key_uniq[_image_key] = True

            for _tile in tileset.tile_ids:
                if use_text and use_image:
                    _text = tileset.tile_to_text[_tile]
                    _image_key = _tile_to_image_key[_tile]

                    if _text_uniq[_text] and _image_key_uniq[_image_key]:
                        text_to_tind[_text] = ntind
                        tind_to_text[ntind] = _text
                        image_to_tind[_image_key] = ntind
                        tind_to_image[ntind] = tileset.tile_to_image[_tile]
                        tile_to_tinds[_tile].append(ntind)
                        ntind += 1
                        ntind_both += 1
                        continue

                if use_text:
                    _text = tileset.tile_to_text[_tile]
                    if _text not in text_to_tind:
                        text_to_tind[_text] = ntind
                        tind_to_text[ntind] = _text
                        ntind += 1
                        ntind_text += 1
                    tile_to_tinds[_tile].append(text_to_tind[_text])

                if use_image:
                    _image_key = _tile_to_image_key[_tile]
                    if _image_key not in image_to_tind:
                        image_to_tind[_image_key] = ntind
                        tind_to_image[ntind] = tileset.tile_to_image[_tile]
                        ntind += 1
                        ntind_image += 1
                    tile_to_tinds[_tile].append(image_to_tind[_image_key])

            for _tile, _tinds in tile_to_tinds.items():
                _key = tuple(sorted(_tinds))
                if _key not in tinds_to_tiles:
                    tinds_to_tiles[_key] = ()
                tinds_to_tiles[_key] = tuple(sorted(tinds_to_tiles[_key] + (_tile,)))

        else:
            util_common.check_tileset_match(tileset, _tileset)

    def add_level(_tile_level, _edges, _props):
        nonlocal rows, cols

        _lrows = len(_tile_level)
        _lcols = len(_tile_level[0])
        if rows is None:
            rows, cols = _lrows, _lcols
        else:
            rows = max(rows, _lrows)
            cols = max(cols, _lcols)

        _level = []
        for _rr in range(_lrows):
            _row = []
            for _cc in range(_lcols):
                _row.append(tile_to_tinds[_tile_level[_rr][_cc]])
            _level.append(_row)

        _pinds = []
        if _props is not None:
            for _prop in _props:
                if _prop not in prop_to_pind:
                    _pind = len(prop_to_pind)
                    prop_to_pind[_prop] = _pind
                    pind_to_prop[_pind] = _prop
                _pinds.append(prop_to_pind[_prop])

        all_levels.append(_level)
        all_edges.append([tuple(_edge) for _edge in _edges] if _edges is not None else [])
        all_pinds.append(_pinds)

    def add_einds(_edges):
        _einds = []
        for _edge in _edges:
            if _edge not in edge_to_eind:
                _eind = len(edge_to_eind)
                edge_to_eind[_edge] = _eind
                eind_to_edge[_eind] = _edge
            _einds.append(edge_to_eind[_edge])
        all_einds.append(_einds)

    def pad_level(_level, _path, _rows, _cols, _void_tind):
        if len(_level) == _rows and len(_level[0]) == _cols:
            return False

        for _rr in range(len(_level)):
            while len(_level[_rr]) != _cols:
                _level[_rr].append(_void_tind)
        while len(_level) != _rows:
            if pad_top:
                _level.insert(0, [_void_tind] * _cols)
                for ii in range(len(_path)):
                    _path[ii] = (_path[ii][0] + 1, _path[ii][1], _path[ii][2] + 1, _path[ii][3])
            else:
                _level.append([_void_tind] * _cols)
        return True

    if tilefiles is not None:
        for tilefile_glob in tilefiles:
            for tilefile in glob.iglob(tilefile_glob):
                with util_common.openz(tilefile, 'rb') as f:
                    tile_info = pickle.load(f)

                    set_tileset(tile_info.tileset)

                    if tile_info.levels is not None:
                        for tli in tile_info.levels:
                            path = util_common.get_meta_path(tli.meta)
                            properties = util_common.get_meta_properties(tli.meta)
                            add_level(tli.tiles, path, properties)

    if resultfiles is not None:
        for resultfile_glob in resultfiles:
            for resultfile in glob.iglob(resultfile_glob):
                with util_common.openz(resultfile, 'rb') as f:
                    result_info = pickle.load(f)

                    set_tileset(result_info.tileset)

                    edges = None
                    if result_info.reach_info is not None:
                        util_common.check(len(result_info.reach_info) == 1, 'only support for one path')
                        edges = result_info.reach_info[0].path_edges
                    add_level(result_info.tile_level, edges, None)

    print('loaded', len(all_levels), 'levels')

    print('encoding...')

    void_tind = None
    any_padded = False
    for level, edges in zip(all_levels, all_edges):
        this_padded = pad_level(level, edges, rows, cols, [ntind])
        any_padded = any_padded or this_padded

    if any_padded:
        print('padded!')
        void_tind = ntind
        ntind += 1

    for edges in all_edges:
        add_einds(edges)

    ex = util_explore.ExploreInfo()
    ex.rows = rows
    ex.cols = cols

    ex.tileset = tileset

    ex.ntind = ntind
    ex.neind = max(list(eind_to_edge.keys()) + [-1]) + 1
    ex.npind = max(list(pind_to_prop.keys()) + [-1]) + 1

    ex.void_tind = void_tind

    ex.tind_to_text = tind_to_text
    ex.tind_to_image = tind_to_image
    ex.tinds_to_tiles = tinds_to_tiles
    ex.eind_to_edge = eind_to_edge
    ex.pind_to_prop = pind_to_prop

    ex.level_data = np.packbits(one_hot(ex.rows, ex.cols, ex.ntind, ex.neind, ex.npind, all_levels, all_einds, all_pinds), axis=1)

    print('encoded', len(ex.level_data), 'levels')
    print('encoded', len(ex.tileset.tile_ids), 'tiles into', str(ex.ntind) + ';', ntind_text, 'text', ntind_image, 'image', ntind_both, 'both', 1 if ex.void_tind is not None else 0, 'void')
    print('encoded', len(ex.eind_to_edge), 'edges into', ex.neind)
    print('encoded', len(ex.pind_to_prop), 'props into', ex.npind)
    print('encoded data', ex.level_data.shape)

    return ex



if __name__ == '__main__':
    util_common.timer_start()

    parser = argparse.ArgumentParser(description='Convert levels to explore file.')
    parser.add_argument('--outfile', required=True, type=str, help='Explore file to write to.')
    parser.add_argument('--tilefile', type=str, nargs='+', help='Input tile file(s).')
    parser.add_argument('--resultfile', type=str, nargs='+', help='Input result file(s).')
    parser.add_argument('--text-only', action='store_true', help='Only use tile edges.')
    parser.add_argument('--image-only', action='store_true', help='Only use image edges.')
    parser.add_argument('--pad-top', action='store_true', help='Pad top of level when needed.')

    args = parser.parse_args()

    explore_info = levels2explore(args.tilefile, args.resultfile, args.pad_top, args.text_only, args.image_only)
    with util_common.openz(args.outfile, 'wb') as f:
        pickle.dump(explore_info, f)
