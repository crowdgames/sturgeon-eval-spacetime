import argparse

def parse_blocks(lines, gap_size):
    blocks = []
    current_block = []
    space_line = lambda l: set(l.strip()) == set()

    i = 0
    while i < len(lines):
        if all(space_line(lines[j]) for j in range(i, min(i + gap_size, len(lines)))):
            if current_block:
                blocks.append(current_block)
                current_block = []
            i += gap_size
        else:
            current_block.append(lines[i])
            i += 1

    if current_block:
        blocks.append(current_block)

    return blocks

def convert_blocks(input_text: str, gap_size: int) -> str:
    lines = input_text.strip('\n').splitlines()
    blocks = parse_blocks(lines, gap_size)

    if not blocks:
        return ""

    line_length = len(blocks[0][0])
    gap_block = ['X' * line_length] * gap_size

    result = []

    for i, block in enumerate(blocks):
        if i == 0:
            fill_char = '0'
        elif i == len(blocks) - 1:
            fill_char = '2'
        else:
            fill_char = '1'
        filled_block = [fill_char * line_length for _ in block]
        result.extend(filled_block)
        if i < len(blocks) - 1:
            result.extend(gap_block)

    return '\n'.join(result) + '\n'

def main():
    parser = argparse.ArgumentParser(description="Convert game map blocks, inserting 'X' line gaps.")
    parser.add_argument('--infile', '-i', required=True, help='Path to the input text file')
    parser.add_argument('--outfile', '-o', required=True, help='Path to save the output text file')
    parser.add_argument('--gap', '-g', type=int, default=1, help='Number of consecutive space lines that define block separation')
    args = parser.parse_args()

    with open(args.infile, 'r') as infile:
        input_data = infile.read()

    output_data = convert_blocks(input_data, args.gap)

    with open(args.outfile, 'w') as outfile:
        outfile.write(output_data)

    print(f"Conversion complete. Output written to {args.outfile}")

if __name__ == "__main__":
    main()