# Dungeon Descent — TODO

## Current Focus: Polish & Systems Overhaul

Core game is feature-complete (2 classes, 5 enemies, boss, shop, minimap, 3 floors, meta-progression framework). Now improving game feel, depth, and progression.

---

## Phase 1: Combat Juice Overhaul

Make existing attacks feel impactful. Creates VFX infrastructure reused by later phases.

- [x] **Parameterize hit feedback** — Add `@export` shake/pause values to `hitbox.gd` so each attack tunes its own feedback (boss slam ≠ slime poke). Update `hurtbox.gd` to use hitbox values instead of hardcoded `0.06` / `2.0, 0.15`
- [x] **Wire hit flash shader** — `shaders/hit_flash.gdshader` exists but is never used. Create `scripts/combat/vfx_helper.gd` with `apply_hit_flash()` and `spawn_particles_at()` static methods. Call from `hurtbox.gd` on every hit
- [x] **Particle effects** — Create `scenes/effects/` GPUParticles2D scenes: `hit_sparks.tscn`, `death_poof.tscn`, `crit_flash.tscn`. Spawn via VFXHelper
- [x] **Enemy death effects** — All `*_dead_state.gd` currently just set alpha 0.5 and queue_free. Change to: hit flash → death particles → tween scale down + fade → queue_free. Boss: bigger particles + shake
- [x] **Enemy attack telegraphing** — Add `@export var windup_duration` to enemy attack states. During windup: flash sprite, show telegraph indicator. Create `scenes/effects/telegraph_indicator.tscn`
- [x] **SFX pitch variation** — Add `play_sfx_varied(sfx_name, pitch_min, pitch_max)` to `audio_manager.gd`. Use for combat SFX
- [x] **Melee swing trail** — Create `scenes/effects/melee_swing.tscn` (animated arc sprite). Spawn in `attack_state.gd`
- [x] **Projectile impact** — Spawn hit_sparks on arrow collision in `arrow.gd` and `player_arrow.gd`

## Melee Combat Depth

- [x] **Active frames system** — Replace the always-on hitbox with specific active frames during the swing animation. Add `active_frame_start` and `active_frame_end` config values so the hitbox only deals damage during the middle of the swing, making timing matter
- [x] **Charged heavy attack** — Hold the attack button to charge a heavy swing (0.6-0.8s wind-up) that deals 2x damage with increased knockback and a wider hitbox. Add a visual indicator (sprite glow or weapon shake) during charge-up
- [x] **Dodge-cancel out of attacks** — Add a dodge roll state that can interrupt the last 40% of attack animations, letting players commit to a swing but escape if they mistime it. Uses a short invincible dash in the movement direction

## Phase 2: Status Effects System

Only stun exists. Add burn, poison, freeze, slow.

- [x] **StatusEffectData resource** — Create `scripts/combat/status_effect_data.gd` with type enum, duration, tick_interval, damage_per_tick, speed_multiplier, tint_color, particle_scene
- [x] **StatusEffectComponent** — Create `scripts/combat/status_effect_component.gd` (Node, composition pattern) with apply/remove/tick logic, signals, tint/particle management
- [x] **Wire into combat** — Add `@export var applied_status_effect` to `hitbox.gd`. In `hurtbox.gd`, apply status on hit. Convert `burn_on_hit` in `item_effect_handler.gd` from instant damage to real BURN DoT
- [x] **Add to entities** — StatusEffectComponent as child node on all player and enemy scenes. Enemy states query `get_speed_multiplier()` for slow/freeze
- [x] **Status VFX** — Create looping particle scenes: burn, poison, freeze, slow particles
- [x] **Status UI** — EventBus signals for status changes. Small colored icons near health bar in HUD

## Phase 3: Branching Floor Layout

Currently `_build_floor_graph()` creates a strict N→S linear chain. Need proper dungeon map.

- [ ] **Rework floor graph generation** — Rewrite `dungeon_manager.gd` `_build_floor_graph()`: generate main N→S path, branch E/W randomly, 1-2 room deep side paths for treasure/shop. Store `grid_pos: Vector2i` per room
- [ ] **Add FloorConfig params** — `branch_chance`, `max_branch_depth` exports in `floor_config.gd`
- [ ] **Update minimap** — Replace `Vector2(0, room_id * room_spacing)` with `room.grid_pos * room_spacing` in `minimap.gd`
- [ ] **Add E/W doors to rooms** — All room `.tscn` files need EAST and WEST door instances. `_configure_doors()` already locks unused ones
- [ ] **Backtracking** — Already works (cleared rooms skip spawning). Just needs the graph rework

## Phase 4: Difficulty & Balance Pass

Runs too short/easy, difficulty doesn't ramp, items feel like stat-sticks.

- [ ] **Expand FloorConfig** — Add `enemy_speed_multiplier`, `enemy_pool: Array[PackedScene]`, `elite_chance`, `gold_multiplier` to `floor_config.gd`
- [ ] **Apply speed scaling** — `room_template.gd` `_populate_enemies()` currently only scales HP/damage. Add speed scaling
- [ ] **Elite enemies** — Create `scripts/combat/elite_modifier.gd` (Node): 2x HP, 1.5x damage, 1.2x speed, status effect on hitbox, visual tint. Roll for elite chance per spawn in `room_template.gd`
- [ ] **Floor-specific enemy pools** — Add `@export var use_floor_pool: bool` to `spawn_point.gd`. Floor 1: slime + skeleton. Floor 2: add bat + archer. Floor 3: all + elites
- [ ] **Extend run length** — Add `floor_4.tres`, `floor_5.tres`. Change `max_floors` from 3 to 5 in `run_manager.gd`
- [ ] **Item impact** — Widen stat gaps between COMMON/UNCOMMON/RARE tiers. Rare items should feel game-changing

## Phase 5: Meta-Progression Wiring

Framework exists but unlocks screen is a placeholder ("No unlocks available yet.").

- [ ] **Create unlock resources** — `resources/unlocks/*.tres` for each unlockable (weapons, abilities, passive bonuses). Only starter items available without unlocks
- [ ] **Rewrite unlocks screen** — Replace `unlocks_screen.gd` placeholder with functional UI: scrollable list, category tabs, currency display, purchase flow
- [ ] **Gate content** — Filter loot tables by `SaveManager.unlocked_items`. Only offer unlocked abilities. Shop stocks unlocked items only

## Phase 6: UI Improvements

- [ ] **Pause menu** — Add SFX/music volume sliders, fullscreen toggle, screen shake toggle, resume/restart/quit to `pause_menu.gd`
- [ ] **Inventory stat comparison** — Show stat diff vs equipped item (green +, red -) in `inventory_ui.gd`
- [ ] **Shop comparison** — Show equipped item comparison alongside shop item stats in `shop_ui.gd`
- [ ] **Ability cooldown polish** — Radial cooldown overlay or countdown number in `ability_slot.gd`

---

## Bugs

- [ ] **Arrows pass through walls** — Projectiles (arrows) don't collide with wall tiles. Add wall collision detection to arrow scripts so they stop/despawn on wall contact

---

## Future Ideas (Not Planned Yet)

- [ ] Trap/puzzle rooms (spike traps, pressure plates, environmental hazards)
- [ ] Consumable items (health potions, buff potions, throwables)
- [ ] More enemy types
- [ ] More music tracks
- [ ] **Mage class** — Ranged magic user with spell-based attacks (fireball, lightning), mana resource, AoE abilities, glass cannon stats
- [ ] **Rogue class** — Fast melee with daggers, backstab crit bonus, dash ability, stealth mechanic, high speed / low HP
- [ ] **Cleric class** — Hybrid support/melee with mace, healing ability, holy damage vs undead, shield/buff spells, tanky stats
- [ ] Room environmental variety (water, lava, darkness)
- [ ] Achievement system
- [ ] Leaderboards / run history
