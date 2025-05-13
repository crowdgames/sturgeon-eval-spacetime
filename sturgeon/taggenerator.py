import argparse

def generate_tag_file_from_playthrough(play_file, keep_tiles, gap, output_file):
    with open(play_file, 'r') as infile:
        lines = [
            line.rstrip('\n')
            for line in infile
            if not line.lstrip().startswith("META")
        ]

    tag_blocks = []
    current_block = []

    for line in lines:
        if line.strip() == "":
            if current_block:
                tag_blocks.append(current_block)
                current_block = []
        else:
            current_block.append(line)
    if current_block:
        tag_blocks.append(current_block)

    tag_lines = []
    for i, block in enumerate(tag_blocks):
        for line in block:
            tag_line = ''.join([char if char in keep_tiles else ',' if char != ' ' else ' ' for char in line])
            tag_lines.append(tag_line)
        if i < len(tag_blocks) - 1 and gap > 0:
            width = max(len(line) for line in block)
            tag_lines.extend([" " * width for _ in range(gap)])

    with open(output_file, 'w') as outfile:
        outfile.write('\n'.join(tag_lines) + '\n')


def generate_tag_file(tag_rows, tag_cols, block_count, gap, output_file):
    block = "\n".join(["," * tag_cols for _ in range(tag_rows)])
    gap_block = "\n".join([" " * tag_cols for _ in range(gap)]) if gap > 0 else ""

    with open(output_file, "w") as f:
        for i in range(block_count):
            f.write(block)
            if i < block_count - 1 and gap > 0:
                f.write("\n" + gap_block + "\n")
            else:
                f.write("\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate a tag file from a playthrough or empty blocks.")
    
    parser.add_argument("--tagsize", nargs=2, type=int, default=[8, 10],
                        help="Rows and cols of each block (default: 8 10)")
    parser.add_argument("--blockcount", type=int, default=1,
                        help="Number of blocks to generate (default: 1)")
    parser.add_argument("--gap", type=int, default=1,
                        help="Gap between blocks (default: 1)")
    parser.add_argument("--outfile", type=str, default="levels/custom/tags.lvl",
                        help="Output file name")

    parser.add_argument("--playthrough", type=str, default=None,
                        help="Path to level playthrough file")
    parser.add_argument("--tiles", nargs='*', default=[],
                        help="Tiles to preserve in the tag file (e.g. X o #)")

    args = parser.parse_args()

    if args.playthrough:
        generate_tag_file_from_playthrough(args.playthrough, set(args.tiles), args.gap, args.outfile)
    else:
        generate_tag_file(args.tagsize[0], args.tagsize[1], args.blockcount, args.gap, args.outfile)
