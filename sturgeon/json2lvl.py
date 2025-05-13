import argparse
import json
import os

def read_json_file(filepath):
    with open(filepath, 'r') as file:
        return json.load(file)

def write_lvl_file(json_path, levels, gap):
    lvl_filename = json_path.replace(".json", ".lvl")
    
    with open(lvl_filename, 'w') as file:
        for i, level in enumerate(levels):
            block = '\n'.join(''.join(row) for row in level)
            file.write(block)
            
            # Add gap lines (each line is spaces equal to the width of the level) except for the last level
            if i < len(levels) - 1:
                gap_block = '\n'.join([' ' * len(level[0]) for _ in range(gap)])
                file.write('\n' + gap_block + '\n')
    
    print(f"Level file generated: {lvl_filename}")

def main():
    parser = argparse.ArgumentParser(
        description="Convert JSON level data to .lvl format."
    )
    parser.add_argument("--jsonfile", required=True, help="Path to the input JSON file")
    parser.add_argument("--gap", type=int, default=1, help="Number of gap lines between levels (default: 1)")
    
    args = parser.parse_args()
    
    if not os.path.exists(args.jsonfile):
        print("Error: The provided JSON file does not exist.")
        return
    
    levels = read_json_file(args.jsonfile)
    write_lvl_file(args.jsonfile, levels, args.gap)
    
if __name__ == "__main__":
    main()