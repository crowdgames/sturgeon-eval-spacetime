import json
import os
import msvcrt

# Initial level (your 7x6 example; swap with 10x20 if desired)
level = [
"WWWWWWWWWWWWWWWWWWWWWWWW",
"W___________O__________W",
"W_WW_WW__B_____WW_WW___W",
"W______W__B__O____W____W",
"W_WW_W___W_WW_WW___WW__W",
"W____P______O____B___O_W",
"W_WW_WW__WW_____B______W",
"W___B____W_WW_W________W",
"W_______O____B_____WW__W",
"W__WW______WW__________W",
"WW_________O__________WW",
"WWWWWWWWWWWWWWWWWWWWWWWW",
]

# Convert to 2D list for manipulation
grid = [list(row) for row in level]
states = []
move_count = 0

# Track targets separately to preserve them
targets = [(x, y) for y in range(len(grid)) for x in range(len(grid[0])) if grid[y][x] == "O"]

# Find initial player position
player_x, player_y = None, None
for y, row in enumerate(grid):
    for x, cell in enumerate(row):
        if cell == "P":
            player_x, player_y = x, y
            break
    if player_x is not None:
        break

# Save the current state as a 2D grid
def save_state():
    global move_count
    # Copy grid as a 2D list of characters
    state = [row[:] for row in grid]
    states.append(state)
    move_count += 1

# Move the player and handle box pushing
def move(dx, dy):
    global player_x, player_y
    new_x, new_y = player_x + dx, player_y + dy

    # Check boundaries
    if not (0 <= new_x < len(grid[0]) and 0 <= new_y < len(grid)):
        return False

    next_cell = grid[new_y][new_x]
    if next_cell == "W":  # Wall
        return False

    # Handle box pushing
    if next_cell == "B" or next_cell == "G":
        box_new_x, box_new_y = new_x + dx, new_y + dy
        if not (0 <= box_new_x < len(grid[0]) and 0 <= box_new_y < len(grid)):
            return False
        if grid[box_new_y][box_new_x] in ["W", "B", "G"]:
            return False
        # Move box to new position
        grid[box_new_y][box_new_x] = "G" if (box_new_x, box_new_y) in targets else "B"
        # Move player to box's old position
        grid[new_y][new_x] = "P"
        # Clear or restore target at player's old position
        grid[player_y][player_x] = "O" if (player_x, player_y) in targets else "_"
    else:
        # Move player without pushing a box
        grid[player_y][player_x] = "O" if (player_x, player_y) in targets else "_"
        grid[new_y][new_x] = "P"

    player_x, player_y = new_x, new_y
    save_state()
    return True

# Check if all boxes are on targets
def is_solved():
    return all(
        grid[y][x] == "G"
        for y, row in enumerate(grid)
        for x, cell in enumerate(row)
        if cell == "B" or cell == "G"
    )

# Initial state
save_state()

# Game loop
print("Use WASD to move (q to quit):")
while True:
    os.system("cls")  # Clear console (Windows)
    for row in grid:
        print("".join(row))
    print(f"Step: {move_count}")

    # Get keypress (Windows-specific)
    key = msvcrt.getch().decode("utf-8").lower()

    # Handle movement
    if key == "q":
        break
    elif key == "w":  # Up
        move(0, -1)
    elif key == "s":  # Down
        move(0, 1)
    elif key == "a":  # Left
        move(-1, 0)
    elif key == "d":  # Right
        move(1, 0)

    # Check win condition
    if is_solved():
        os.system("cls")
        for row in grid:
            print("".join(row))
        print("Solved!")
        break

# Save states to JSON
with open("sokoban_states.json", "w") as f:
    json.dump([list("".join(row) for row in state) for state in states], f, indent=2)

print("Game ended. States saved to sokoban_states.json")
