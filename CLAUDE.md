# Dungeon Descent

2D top-down real-time dungeon crawler RPG roguelike built in Godot 4.7 with GDScript.

## Tooling

Use PowerShell for any file inspection tasks (reading files, binary files, etc.). Never use Python.

**Never run git commands autonomously.** Do not stage, commit, push, or run any git operations without explicit user instruction for each command.

## Game Overview

Warrior/Knight descends through handcrafted dungeon floors with randomized enemy/loot placement. Clear-to-unlock combat rooms, shops, trap/puzzle rooms, floor boss. Hybrid melee+ranged combat, WASD+mouse aim. 45-60 min runs, full permadeath with meta-progression currency. 16-bit SNES pixel art (Claude-generated SVGs).

**MVP scope:** 1 class (Warrior), 1 floor (8-12 rooms + boss), 3-5 enemy types, fixed hand-designed items, 2-3 ability slots, shop, fog-of-war minimap.

## Directory Structure

```
res://
  scripts/autoload/       Autoloaded singletons (EventBus, GameManager, etc.)
  scripts/util/           Shared utilities (StateMachine, State, LootTable)
  scripts/player/         Player controller + player_states/ subfolder
  scripts/enemies/        Base enemy + enemy_ai/ subfolder
  scripts/rooms/          Room logic, door, spawn points
  scripts/items/          Item effect base, item pickup
  scripts/combat/         Hitbox, hurtbox, health component, knockback
  scripts/ui/             HUD, minimap, inventory, shop, ability bar, damage numbers
  scenes/main/            Main menu, game scene, game over
  scenes/player/          Player scene
  scenes/enemies/         Enemy scenes (base + specific types)
  scenes/rooms/           Room templates + combat_rooms/ subfolder
  scenes/pickups/         Item drops, gold, potions, chests
  scenes/interactables/   Doors, merchant NPCs
  scenes/attacks/         Sword swing, projectiles
  scenes/ui/              UI scenes (HUD, inventory, shop, minimap, etc.)
  resources/items/        Item .tres files (weapons/, armor/, rings/, accessories/, consumables/)
  resources/abilities/    Ability .tres files
  resources/enemy_data/   Enemy stat .tres files
  resources/loot_tables/  Loot table .tres files
  resources/player/       Player base stat .tres files
  assets/sprites/         Claude-generated pixel art SVGs (player/, enemies/, items/, effects/, ui/)
  assets/audio/           SFX and music (sfx/, music/)
  assets/fonts/           Pixel-art compatible fonts
  shaders/                Visual effect shaders (hit flash, outline)
```

## Architecture

Composition-based entities with reusable component nodes and a state machine pattern. Designed from scratch for this game — does NOT share patterns with PitchRun.

### Core Rules

1. **Every tunable value must be @export.** Speed, HP, damage, ranges, cooldowns — all @export.
2. **Entities are CharacterBody2D** with child component nodes (HealthComponent, HurtboxComponent, KnockbackComponent, StateMachine). No deep inheritance — composition via attached nodes.
3. **Entity scripts are thin.** Wire components in `_ready()`, defer state machine start. Movement, combat, and AI logic live in states and components.
4. **Static typing everywhere.** Every variable, parameter, and return type must have an explicit type annotation. Use `-> void` on all functions that return nothing.
5. **Signals for events, methods for commands.** Components emit signals when something happens. Other nodes call methods to make things happen.
6. **EventBus for cross-system events.** Decoupled communication between unrelated systems.

### State Machine Pattern

`StateMachine` (Node) manages `State` children. Each state extends `State` base class with `enter()`, `exit()`, `process_state()`, `physics_process_state()`, `handle_input()`. States emit `transition_requested(from, to)` to request transitions.

**Player states:** `IdleState`, `RunState`, `AttackState`, `AbilityState`, `HurtState`, `DeadState`
**Enemy states:** `IdleState`, `ChaseState`, `AttackState`, `HurtState`, `DeadState` (+ type-specific states)

State machine start is deferred via `call_deferred` in entity `_ready()`. Entity-specific base states (e.g., `PlayerState`) use `await owner.ready` to get references.

### Component Pattern

Components are plain Node scripts attached as children of entities:
- **HealthComponent** — HP tracking, i-frames, signals: `damaged`, `healed`, `died`, `health_changed`
- **KnockbackComponent** — Velocity impulse with friction decay, parent reads `knockback_velocity`
- **Hitbox** (Area2D) — Deals damage, carries damage/knockback data, activated during attack frames
- **Hurtbox** (Area2D) — Receives hits, delegates to HealthComponent

Components find their owner via `get_parent()`. Entity scripts wire references via `$NodeName` in `_ready()`.

## Autoloads

Registered in project.godot. Access globally by name. **Autoload scripts must NOT use `class_name`.**

- **EventBus** — Signal-only singleton. Signals: `enemy_killed`, `room_cleared`, `item_picked_up`, `player_damaged`, `player_died`, `door_transition_requested`, `floor_completed`, `boss_defeated`, `gold_changed`, `meta_currency_gained`, etc.
- **GameManager** — Game state (MAIN_MENU/PLAYING/PAUSED/GAME_OVER), run lifecycle, scene transitions, permadeath flow
- **DungeonManager** — Floor graph generation, room transitions (fade+swap), spawn population, room clear/visit tracking
- **CombatManager** — `calculate_damage()`, defense formula, hit feedback coordination (screen shake, hit pause)
- **ItemDatabase** — Scans `res://resources/items/`, provides `get_item(id)`, `get_random_item(loot_table)`
- **SaveManager** — Meta-progression persistence to `user://save_data.json`
- **AudioManager** — Pooled SFX playback, music crossfade

## Physics Collision Layers

| Layer | Name | Purpose |
|-------|------|---------|
| 1 | Walls | StaticBody2D environment |
| 2 | Player | Player CharacterBody2D |
| 3 | Enemies | Enemy CharacterBody2D |
| 4 | PlayerHurtbox | Player's hurtbox Area2D |
| 5 | EnemyHurtbox | Enemy hurtbox Area2D |
| 6 | PlayerAttack | Player hitbox/attacks |
| 7 | EnemyAttack | Enemy hitbox/attacks |
| 8 | Pickups | Item drops, gold, potions |
| 9 | Interaction | Doors, NPCs, chests |
| 10 | Detection | Enemy aggro areas |

## Display Settings

```
Viewport: 480x270 (16:9, pixel-perfect at 4x)
Window: 1920x1080
Stretch mode: viewport
Stretch aspect: keep
Texture filter: Nearest (pixel art)
Tile size: 16x16
Standard room: ~24x16 tiles
Boss room: ~32x24 tiles
```

## Combat System

**Hitbox/Hurtbox pattern:** Hitbox (Area2D, layer 6 or 7) overlaps Hurtbox (Area2D, layer 5 or 4). Hitbox carries damage data. Hurtbox delegates to HealthComponent. Player attacks (layer 6) mask enemy hurtbox (layer 5). Enemy attacks (layer 7) mask player hurtbox (layer 4). No friendly fire.

**Hit juice:** Hit pause (2-3 frame freeze) → white flash shader → screen shake → knockback → floating damage number → SFX.

**I-frames:** 0.5s invincibility after taking damage.

## Room System

Each room is a `.tscn` with TileMapLayer (walls/floor), Door nodes (N/S/E/W), SpawnPoint markers (Marker2D with type + spawn chance). Only one room active at a time. DungeonManager swaps rooms with fade transition.

**Room clear flow:** Enter room → doors lock → kill all enemies → doors unlock → proceed.

**Floor structure:** Start → Combat rooms → Shop → More combat → Boss. 1-2 branch rooms (treasure). Rooms are handcrafted scenes with randomized enemy/loot via spawn points.

## Item System

Items are custom `ItemData` Resources (`.tres` files) with unique effects via `ItemEffect` sub-resources. Equipment slots: weapon, armor, ring, accessory. `LootTable` resources for weighted random drops.

**Economy:** Gold (shops), gems/souls (special upgrades), keys (locked areas).

## Abilities

`AbilityData` resources with cooldown, damage multiplier, effect scene. PlayerCombat manages 3 ability slots. Warrior: Shield Bash (stun dash), Whirlwind (360 AOE), War Cry (damage buff).

## Input Actions

| Action | Key | Purpose |
|--------|-----|---------|
| `move_up` | W / Up | Movement |
| `move_down` | S / Down | Movement |
| `move_left` | A / Left | Movement |
| `move_right` | D / Right | Movement |
| `attack` | LMB | Sword swing toward mouse |
| `ability_1` | Q | Ability slot 1 |
| `ability_2` | E | Ability slot 2 |
| `ability_3` | R | Ability slot 3 |
| `interact` | F | Chests, NPCs, portals |
| `open_inventory` | I / Tab | Toggle inventory |
| `pause` | Escape | Pause menu |
| `minimap_toggle` | M | Toggle minimap |

## Art / Visuals

16-bit SNES style pixel art using Claude-generated SVGs with `viewBox="0 0 16 32"` and `shape-rendering="crispEdges"`. Godot's nearest-neighbor texture filter renders them as crisp pixel art.

**Sprite specs:** 16x32 pixels per frame, 4 directional facing (down, up, side), side sprites mirrored via `flip_h` for left/right.

**Location:** `assets/sprites/` organized by entity type:
```
assets/sprites/
  player/               warrior_<anim>_<dir>_<frame>.svg
  enemies/              (future) enemy variant SVGs
  items/                (future) item/pickup SVGs
  effects/              (future) VFX SVGs
  ui/                   (future) UI element SVGs
```

**SVG rules:**
- Use `viewBox="0 0 16 32"` for character sprites (1 tile wide, 2 tiles tall)
- `shape-rendering="crispEdges"` on root `<svg>` element
- Flat fills only — no gradients, no filters
- Align all shapes to integer coordinates for clean pixel boundaries
- Distinct color palettes per entity type for readability

## GDScript Style

Same conventions as standard GDScript:
- **Files/directories:** `snake_case`
- **Node names:** `PascalCase` in scene tree
- **class_name:** `PascalCase`
- **Signals:** `snake_case`, past tense for events
- **Variables/functions:** `snake_case`, private with `_` prefix, booleans `is_`/`has_`/`can_`
- **Constants:** `SCREAMING_SNAKE_CASE`
- **Enums:** `PascalCase` name, `SCREAMING_SNAKE_CASE` values

### Script Section Order

1. class_name and extends
2. Signals
3. Enums
4. Constants
5. @export vars (grouped with @export_group)
6. @onready vars
7. Regular vars (public then private)
8. _ready, _process, _physics_process, _input/_unhandled_input
9. Public methods
10. Private methods
11. Signal handlers
