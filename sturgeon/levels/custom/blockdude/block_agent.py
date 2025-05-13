import json
import os
import msvcrt

# Initial level
level = [
"W__________________W",
"W__________________W",
"W__________________W",
"W___W_______W______W",
"WO__W___W_B_W_B_P__W",
"WWWWWWWWWWWWWWWWWWWW",
]

# Convert to 2D list
grid = [list(row) for row in level]
states = []
carrying = False
move_count = 0

# Find initial player position
player_x, player_y = None, None
for y, row in enumerate(grid):
    for x, cell in enumerate(row):
        if cell == "P":
            player_x, player_y = x, y
            break
    if player_x is not None:
        break

# Find target position
target_x, target_y = None, None
for y, row in enumerate(grid):
    for x, cell in enumerate(row):
        if cell == "O":
            target_x, target_y = x, y
            break
    if target_x is not None:
        break

def is_right():
    return target_x > player_x

# Save state
def save_state():
    state = [row[:] for row in grid]
    states.append(state)

# Apply gravity
def apply_gravity():
    global player_y, move_count
    while True:
        below_y = player_y + 1
        if below_y >= len(grid):
            break
        if grid[below_y][player_x] == "_":
            grid[player_y][player_x] = "_"
            if carrying:
                grid[player_y - 1][player_x] = "_"
            player_y += 1
            grid[player_y][player_x] = "P"
            if carrying and player_y - 1 >= 0:
                grid[player_y - 1][player_x] = "B"
            if (player_x, player_y) == (target_x, target_y):
                grid[player_y][player_x] = "G"
            save_state()
            move_count += 1
        else:
            break

# Move horizontally
def move_horizontal(dx):
    global player_x, player_y, move_count

    new_x = player_x + dx
    if not (0 <= new_x < len(grid[0])):
        return

    front_y = player_y

    if grid[front_y][new_x] in ["B", "W"]:
        above_y = player_y - 1
        if above_y >= 0 and grid[above_y][new_x] == "_":
            grid[player_y][player_x] = "_"
            if carrying:
                grid[player_y - 1][player_x] = "_"
            player_x = new_x
            player_y = above_y
            grid[player_y][player_x] = "P"
            if carrying and player_y - 1 >= 0:
                grid[player_y - 1][player_x] = "B"
            if (player_x, player_y) == (target_x, target_y):
                grid[player_y][player_x] = "G"
            save_state()
            move_count += 1
            apply_gravity()
    elif grid[front_y][new_x] in ["_", "D", "O"]:
        grid[player_y][player_x] = "_"
        if carrying:
            grid[player_y - 1][player_x] = "_"
        player_x = new_x
        player_y = front_y
        grid[player_y][player_x] = "P"
        if carrying and player_y - 1 >= 0:
            grid[player_y - 1][player_x] = "B"
        if (player_x, player_y) == (target_x, target_y):
            grid[player_y][player_x] = "G"
        save_state()
        move_count += 1
        apply_gravity()

# Pickup block
def pickup():
    global carrying, move_count
    above_y = player_y - 1
    if carrying or above_y < 0:
        return
    
    fwd_block = player_x + 1 if is_right() else player_x - 1

    if grid[player_y][fwd_block] == "B":
        grid[player_y][fwd_block] = "_"
        if player_y - 1 >= 0:
            grid[player_y - 1][player_x] = "B"
        carrying = True
        save_state()
        move_count += 1

# Drop block
def drop():
    global carrying, move_count
    above_y = player_y - 1
    if not carrying or above_y < 0:
        return
    
    fwd_block = player_x + 1 if is_right() else player_x - 1

    if grid[above_y][player_x] == "B":
        grid[above_y][player_x] = "_"
        grid[player_y][fwd_block] = "B"
        carrying = False
        save_state()
        move_count += 1
        apply_gravity()

# Check win condition
def is_solved():
    return grid[target_y][target_x] == "G"

# Initial state
save_state()
apply_gravity()

# Game loop
print("Use A/D to move, W to pickup, S to drop, Q to quit.")
while True:
    os.system("cls")
    for row in grid:
        print("".join(row))
    print(f"Carrying: {carrying}")
    print(f"Moves: {move_count}")

    if is_solved():
        print("🎉 You reached the goal!")
        break

    key = msvcrt.getch().decode("utf-8").lower()

    if key == "q":
        break
    elif key == "a":
        move_horizontal(-1)
    elif key == "d":
        move_horizontal(1)
    elif key == "w":
        pickup()
    elif key == "s":
        drop()

# Save to JSON
with open("block_dude_states.json", "w") as f:
    json.dump([["".join(row) for row in state] for state in states], f, indent=2)

print(f"Game ended in {move_count} moves. States saved to block_dude_states.json")