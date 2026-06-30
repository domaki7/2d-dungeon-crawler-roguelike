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
- [ ] **Three-hit light combo string** — Extend `attack_state.gd` beyond the current light→heavy 2-step chain into a light1→light2→light3 string, each hit with slightly increased range/damage and a short input window to continue chaining (falls back to Idle if the player doesn't follow up in time)
- [ ] **Parry window on enemy telegraphs** — Add a block/parry input that, if pressed during the final frames of an enemy's telegraph windup (`skeleton_attack_state.gd`, `boss_melee_attack_state.gd`, `ogre_attack_state.gd`), stuns the enemy and opens a riposte window — turns the existing telegraph system into an interactive mechanic instead of just a dodge-or-eat-it tell
- [ ] **Backstab positional bonus** — In `hurtbox.gd`, compare the hitbox's attack direction against the target's facing direction; hits from behind grant bonus crit chance/damage. Lays groundwork for the planned Rogue class's "backstab crit bonus" (todo.md line 106)

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

- [x] **Rework floor graph generation** — Rewrite `dungeon_manager.gd` `_build_floor_graph()`: generate main N→S path, branch E/W randomly, 1-2 room deep side paths for treasure/shop. Store `grid_pos: Vector2i` per room
- [x] **Add FloorConfig params** — `branch_chance`, `max_branch_depth` exports in `floor_config.gd`
- [x] **Update minimap** — Replace `Vector2(0, room_id * room_spacing)` with `room.grid_pos * room_spacing` in `minimap.gd`
- [x] **Add E/W doors to rooms** — All room `.tscn` files need EAST and WEST door instances. `_configure_doors()` already locks unused ones
- [x] **Backtracking** — Already works (cleared rooms skip spawning). Just needs the graph rework

## Phase 4: Difficulty & Balance Pass

Runs too short/easy, difficulty doesn't ramp, items feel like stat-sticks.

- [x] **Expand FloorConfig** — Add `enemy_speed_multiplier`, `enemy_pool: Array[PackedScene]`, `elite_chance`, `gold_multiplier` to `floor_config.gd`
- [x] **Apply speed scaling** — `room_template.gd` `_populate_enemies()` currently only scales HP/damage. Add speed scaling
- [x] **Elite enemies** — Create `scripts/combat/elite_modifier.gd` (Node): 2x HP, 1.5x damage, 1.2x speed, status effect on hitbox, visual tint. Roll for elite chance per spawn in `room_template.gd`
- [x] **Floor-specific enemy pools** — Add `@export var use_floor_pool: bool` to `spawn_point.gd`. Floor 1: slime + skeleton. Floor 2: add bat + archer. Floor 3: all + elites
- [x] **Extend run length** — Add `floor_4.tres`, `floor_5.tres`. Change `max_floors` from 3 to 5 in `run_manager.gd`
- [x] **Item impact** — Widen stat gaps between COMMON/UNCOMMON/RARE tiers. Rare items should feel game-changing

## Phase 5: Meta-Progression Wiring

Framework exists but unlocks screen is a placeholder ("No unlocks available yet.").

- [x] **Create unlock resources** — `resources/unlocks/*.tres` for each unlockable (weapons, abilities, passive bonuses). Only starter items available without unlocks
- [x] **Rewrite unlocks screen** — Replace `unlocks_screen.gd` placeholder with functional UI: scrollable list, category tabs, currency display, purchase flow
- [x] **Gate content** — Filter loot tables by `SaveManager.unlocked_items`. Only offer unlocked abilities. Shop stocks unlocked items only

## Phase 6: UI Improvements

- [x] **Pause menu** — Add SFX/music volume sliders, fullscreen toggle, screen shake toggle, resume/restart/quit to `pause_menu.gd`
- [x] **Inventory stat comparison** — Show stat diff vs equipped item (green +, red -) in `inventory_ui.gd`
- [x] **Shop comparison** — Show equipped item comparison alongside shop item stats in `shop_ui.gd`
- [x] **Ability cooldown polish** — Radial cooldown overlay or countdown number in `ability_slot.gd`
- [x] **Title screen settings** — Add a "Settings" button to the title screen that opens volume/fullscreen/shake options, so players can configure before starting a run

## Enemy AI & Behavior

- [x] **Idle patrol wandering** — All enemies stand still in IdleState until aggroed. Add a WanderState where enemies slowly drift between random nearby points, making rooms feel alive before combat starts

## Items & Loot

- [x] **Set bonuses** — Add a `set_id` field to ItemData and a SetBonusData resource so equipping 2+ items from the same set grants bonus stats or a unique effect
- [x] **Floor-scaled loot tables** — Create per-floor loot table overrides so early floors only drop Common/Uncommon items and Rare+ items appear from floor 3 onward
- [x] **Legendary rarity tier** — Add a LEGENDARY tier with gold-colored names, unique pickup particles, a guaranteed special effect, and a 1-per-run drop limit
- [x] **Stackable item effects** — Allow items sharing the same effect_id to sum their values instead of last-equipped-wins, enabling build diversity
- [x] **More on-hit proc effects** — Add freeze_on_hit, poison_on_hit, and lifesteal_on_hit effects through the existing StatusEffectComponent, then create items that use them
- [x] **Chest variety** — Add locked chests (require keys from elites), mimic chests (enemy encounter on open), and gilded chests (guaranteed Rare+ drop with a guard wave)

---

## Bugs

- [ ] **Arrows pass through walls** — Projectiles (arrows) don't collide with wall tiles. Add wall collision detection to arrow scripts so they stop/despawn on wall contact
- [ ] **Death screen broken** — When the player dies, the restart button doesn't appear and enemies continue attacking the dead player. Need to show the restart UI and stop enemy AI on player death
- [ ] **Mage Fire Wall (R) useless** — The Fire Wall spell needs tuning/fixing to be more effective and worth the 25 mana cost

---

## Future Ideas (Not Planned Yet)

- [ ] Trap/puzzle rooms (spike traps, pressure plates, environmental hazards)
- [ ] Consumable items (health potions, buff potions, throwables)
- [x] More enemy types
- [ ] More music tracks
- [x] **Mage class** — Ranged magic user with spell-based attacks (fireball, lightning), mana resource, AoE abilities, glass cannon stats
- [ ] **Rogue class** — Fast melee with daggers, backstab crit bonus, dash ability, stealth mechanic, high speed / low HP
- [ ] **Cleric class** — Hybrid support/melee with mace, healing ability, holy damage vs undead, shield/buff spells, tanky stats
- [ ] Room environmental variety (water, lava, darkness)
- [ ] Achievement system
- [ ] Leaderboards / run history
