import argparse
import os

def read_text_file(filepath):
    with open(filepath, 'r') as file:
        return [line.strip() for line in file.readlines()]

def write_lvl_file(output_dir, outfiles, content, input_size, gap):
    lvl_filename = os.path.join(output_dir, f"{outfiles}_input.lvl")
    block = '\n'.join(content)
    # Create a gap block consisting of `gap` number of lines.
    gap_lines = '\n'.join([' ' * len(content[0]) for _ in range(gap)])
    lvl_content = ('\n'.join([block, gap_lines]) + '\n') * input_size
    
    with open(lvl_filename, 'w') as file:
        file.write(lvl_content.strip())
    print(f"Level file generated: {lvl_filename}")

def write_tag_file(output_dir, outfiles, tag_size, content_height, gap):
    tag_filename = os.path.join(output_dir, f"{outfiles}_tag.lvl")
    empty_line = "," * tag_size
    block = '\n'.join([empty_line] * content_height)
    # Create a gap block consisting of `gap` number of lines.
    gap_lines = '\n'.join([' ' * tag_size for _ in range(gap)])
    tag_content = ('\n'.join([block, gap_lines]) + '\n') * (tag_size + 1)
    
    with open(tag_filename, 'w') as file:
        file.write(tag_content.strip())
    print(f"Tag file generated: {tag_filename}")

def main():
    parser = argparse.ArgumentParser(description="Generate .lvl and _tag.lvl files from a text file.")
    parser.add_argument("--textfile", required=True, help="Path to the input text file")
    parser.add_argument("--outfiles", default="level", help="Level name prefix (default: level)")
    parser.add_argument("--tagsize", type=int, default=8, help="Size of the tag block (default: 8)")
    parser.add_argument("--inputsize", type=int, default=1, help="Number of times to repeat input pattern (default: 1)")
    parser.add_argument("--gap", type=int, default=1, help="Number of gap lines between blocks (default: 1)")
    
    args = parser.parse_args()
    
    if not os.path.exists(args.textfile):
        print("Error: The provided text file does not exist.")
        return
    
    output_dir = os.path.dirname(args.textfile)
    content = read_text_file(args.textfile)
    content_height = len(content)
    
    write_lvl_file(output_dir, args.outfiles, content, args.inputsize, args.gap)
    write_tag_file(output_dir, args.outfiles, args.tagsize, content_height, args.gap)
    
if __name__ == "__main__":
    main()