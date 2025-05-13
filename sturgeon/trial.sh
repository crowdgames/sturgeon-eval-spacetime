# python lvl2game.py --infile ../setup/field/path_1_nw.lvl --outfile _field/field_1.game --gap 2
# python taggenerator.py --playthrough ../setup/field/path_1_nw.lvl --outfile _field/field_1.tag --gap 2
# python input2tile.py --outfile _field/field.tile --textfile ../setup/field/path_1_nw.lvl --gamefile ../setup/field/path_1_nw.game --text-key-only
# python tile2scheme.py --outfile _field/field-P.scheme --tilefile _field/field.tile --pattern 0=nbr-l 2=single X=single
# python tilediff2scheme.py --outfile _field/field-D.scheme --tilefile _field/field.tile --diff-offset-row 14 --game 1
# python scheme2merge.py --outfile _field/field-M.scheme --schemefile _field/field-P.scheme _field/field-D.scheme
# python scheme2output.py --outfile _field/out/field_1 --schemefile _field/field-M.scheme --solver pysat-gluecard41 --out-result-none --out-tlvl-none --pattern-hard --pattern-single --tagfile _field/field_1.tag --gamefile ../setup/field/path_1_nw.game --custom text-count 0 0 12 12 "P" 1 1 hard --custom text-count 0 0 12 12 "D" 1 1 hard




# python taggenerator.py --playthrough ../setup/field/path_1_nw.lvl --outfile _field/field_1.tag --gap 2
# python input2tile.py --outfile _field/field.tile --textfile ../setup/field/path_1_nw.lvl
# python tile2scheme.py --outfile _field/field_1.scheme --tilefile _field/field.tile --pattern block-rst-noout,2,3,3,14
# python scheme2output.py --outfile _field/out/field_1 --schemefile _field/field_1.scheme --solver pysat-gluecard41 --out-result-none --out-tlvl-none --pattern-hard --tagfile _field/field_1.tag --custom text-count 0 0 12 12 "P" 1 1 hard --custom text-count 0 0 12 12 "D" 1 1 hard