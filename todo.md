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
- [x] **Three-hit light combo string** — Extend `attack_state.gd` beyond the current light→heavy 2-step chain into a light1→light2→light3 string, each hit with slightly increased range/damage and a short input window to continue chaining (falls back to Idle if the player doesn't follow up in time)
- [x] **Parry window on enemy telegraphs** — Add a block/parry input that, if pressed during the final frames of an enemy's telegraph windup (`skeleton_attack_state.gd`, `boss_melee_attack_state.gd`, `ogre_attack_state.gd`), stuns the enemy and opens a riposte window — turns the existing telegraph system into an interactive mechanic instead of just a dodge-or-eat-it tell
- [x] **Backstab positional bonus** — In `hurtbox.gd`, compare the hitbox's attack direction against the target's facing direction; hits from behind grant bonus crit chance/damage. Lays groundwork for the planned Rogue class's "backstab crit bonus" (todo.md line 106)
- [x] **Attack lunge step** — Forward impulse on the light attack's active frame, scaled up through the combo string. Routed through KnockbackComponent because `physics_process_state` drives velocity from it, so setting velocity directly would be overwritten the next frame
- [ ] **Heavy attack shockwave finisher** — A fully charged heavy attack releases a short-range shockwave ring (new effect scene + second Hitbox) beyond the blade arc, rewarding full charges with extra reach
- [ ] **Shatter frozen enemies** — Heavy/charged melee hits on a FROZEN target deal bonus damage and trigger a shatter VFX + SFX, wiring melee attack states into the existing StatusEffectComponent for a first real status synergy
- [x] **Melee kill dodge refund** — Covered by the kill-driven cooldown ticks below: the dodge occupies an ability cooldown slot, so every kill refunds part of it. Applies to all three classes rather than melee only

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
- [x] **Group surround positioning** — Chase states (`skeleton_chase_state.gd`, `ogre_chase_state.gd`, `bat_chase_state.gd`, etc.) path straight to the player's exact position, so multiple aggroed enemies stack into a single-file line instead of surrounding. Add a per-enemy angular offset (derived from instance ID among currently-aggroed enemies) so melee chasers spread around the player
- [x] **Alert telegraph on first detection** — Idle/Wander → Chase transition is silent; the player gets no feedback that an enemy just noticed them. Add a brief "spotted" indicator (icon + SFX) the moment `is_player_detected`/`is_aggroed` flips true, mirroring the existing attack-telegraph pattern but for awareness instead of attacks
- [x] **Last-known-position search before giving up** — Chase states drop straight to IdleState the instant the player breaks detection, with no memory. Add a SearchState: enemy moves to the last known player position and pauses/looks around before returning to Idle/Wander
- [x] **Patrol waypoints** — `wander_state.gd` only picks random points within a radius of spawn. Add an optional `patrol_points: Array[Marker2D]` so specific rooms can author deliberate patrol routes instead of every enemy wandering aimlessly
- [x] **Archer kiting retreat** — Archers now retreat whenever the player is inside `archer_preferred_range` (was only inside the much tighter `too_close_range`), back away at `archer_retreat_speed_multiplier` speed, and wait out `archer_attack_cooldown` between shots so they reposition instead of firing on loop
- [x] **Slime split on death** — Full-size slimes spawn `slime_split_count` mini-slimes on death (`is_mini` flag → reduced scale/HP, no loot drops, never split again). Minis register with the room via new `RoomTemplate.register_external_enemy()` so room-clear counting stays correct
- [x] **Ogre charge wall-stun** — The charge now watches `get_slide_collision()` for non-enemy contacts; hitting a wall without landing the hit applies a real STUN status for `ogre_wall_stun_duration` (screen shake + sparks + SFX) and drops the ogre into `StunnedState` for a punish window
- [x] **Low-HP flee behavior** — New shared `flee_state.gd`: slime and bat break off at `enemy_flee_hp_fraction` HP, sprint directly away at `enemy_flee_speed_multiplier` for `enemy_flee_duration`, then re-engage. One-shot per enemy via `has_flee_triggered` so they don't loop forever at low HP

## HUD & Health Bars

- [x] **Enemy health bars** — Float a small ProgressBar above each enemy that fills to current/max HP. Appears permanently on elites; fades out after 2s of no damage on normal enemies. Implemented as a `scripts/ui/enemy_health_bar.gd` node added as a child in each enemy scene.

- [x] **Status effect icons on enemies** — Show tiny colored squares (matching the player status display palette) directly above each enemy for every active status effect they carry. Reuses StatusEffectComponent signals. Implemented as a `scripts/ui/enemy_status_display.gd` node added as a child in each enemy scene.

- [x] **Low health warning** — When player HP drops to ≤ 25% of max, pulse the HUD health bar red and overlay a screen-edge vignette (ColorRect with gradient shader or radial alpha). Clears when HP rises above 25%. Driven by `health_changed` in `hud.gd`.

- [x] **Boss health bar** — Already live in `hud.gd` (`_on_boss_fight_started`): named red bar pinned top-centre, driven by the boss HealthComponent and torn down on `boss_defeated`

- [x] **Gold gain popup** — Floating "+N" beside the HUD counter on every `gold_changed` increase (spends produce no popup)

- [x] **Floor indicator on HUD** — Already live in `hud.gd` (`_create_floor_label` / `_on_floor_started`): top-centre "Floor N — Title" plus a fade-in banner on each descent

## Items & Loot

- [x] **Set bonuses** — Add a `set_id` field to ItemData and a SetBonusData resource so equipping 2+ items from the same set grants bonus stats or a unique effect
- [x] **Floor-scaled loot tables** — Create per-floor loot table overrides so early floors only drop Common/Uncommon items and Rare+ items appear from floor 3 onward
- [x] **Legendary rarity tier** — Add a LEGENDARY tier with gold-colored names, unique pickup particles, a guaranteed special effect, and a 1-per-run drop limit
- [x] **Stackable item effects** — Allow items sharing the same effect_id to sum their values instead of last-equipped-wins, enabling build diversity
- [x] **More on-hit proc effects** — Add freeze_on_hit, poison_on_hit, and lifesteal_on_hit effects through the existing StatusEffectComponent, then create items that use them
- [x] **Chest variety** — Add locked chests (require keys from elites), mimic chests (enemy encounter on open), and gilded chests (guaranteed Rare+ drop with a guard wave)
- [x] **Consumable items + belt slot** — `ItemData.SlotType.CONSUMABLE` + `ConsumableEffect` (heal / heal %, damage buff, speed buff, cleanse). New `ConsumableBelt` node on all three player scenes holds one stack, bound to `use_consumable` (**1** / **X**). Buffs run through new `PlayerStats.apply_temp_buff()` timed-stat pipeline and reuse the existing buff-duration HUD pill. `BeltSlot` widget bottom-left of the HUD. 5 potions in `resources/items/consumables/`, weighted via `ConsumablePool`; drop from breakables, auto-pick-up off the floor, stocked in every shop, and one Health Potion granted at run start
- [ ] **Cursed items** — Items with a strong stat bonus plus a real drawback (e.g. +10 damage / -15 max HP), purple-tinted names, and a warning line in the pickup/shop UI; adds risk-reward decisions to loot
- [x] **Treasure choice pedestals** — `treasure_room.gd` wires its two chests into one decision: a "Take one — the other is lost" hint, and opening either calls the new `Chest.seal()` on the rest (dim + shrink, no longer interactable)
- [x] **Gold magnet accessory** — `gold_pickup.gd` now drifts toward the player inside `economy_gold_magnet_base_radius`, accelerating as it closes. New Magnet Charm accessory (`gold_magnet` effect) adds +70px of pull

## Trap & Hazard Rooms

- [x] **Spike trap hazard** — Reusable hazard component (telegraph → arm → damage window → disarm loop) built on the existing Hitbox pattern (`scripts/combat/hitbox.gd`), placeable via a marker in any room scene
- [x] **Pressure-plate ambush trigger** — Stepping on a plate triggers a one-shot effect (dart volley / door lock + enemy ambush), reusing the spike-trap hazard as its payload
- [x] **Dedicated Trap Room floor-graph archetype** — New `"trap"` room type wired into `dungeon_manager.gd` `_build_floor_graph()` and `minimap.gd`, alongside shop/treasure — a hazard gauntlet room with a loot reward for clearing it

## Ranged Combat

- [x] **Charged power shot** — Hold the attack button to charge the bow (mirrors `heavy_attack_state.gd`'s CHARGING/SWINGING pattern); release for a heavy arrow that deals 2x damage and pierces through the first enemy hit, continuing on to a second target. Add a visual glow/charge indicator on the arrow during windup
- [x] **Quick-draw strafing** — `ranged_attack_state.gd` currently zeroes player velocity and fully roots them for the entire shot animation. Allow strafing at reduced speed during the shot so Ranger play doesn't feel like a melee lock
- [x] **Rapid chain shot** — Firing basic shots in quick succession within a short follow-up window increases fire rate slightly each step (shot1→shot2→shot3), resetting if the player stops shooting — gives the Ranger's basic attack its own light progression, mirroring the melee combo string already planned in `## Melee Combat Depth`
- [ ] **Sweet-spot range bonus** — Arrows deal bonus damage in an optimal distance band (tracked via travel distance in `player_arrow.gd`), with reduced damage point-blank — rewards positioning instead of face-tanking with a bow
- [ ] **Point-blank kick** — When an enemy is within melee range, the Ranger's attack becomes a fast knockback kick (no damage or minimal) that creates space, giving the class a native panic button
- [ ] **Charged shot trajectory preview** — While charging in `charged_shot_state.gd`, draw a dotted aim line toward the mouse so the pierce path is readable before release
- [ ] **Elemental arrow visuals from weapon procs** — When the equipped bow carries an on-hit status effect (frost/fire/poison), tint the arrow sprite and add a matching particle trail so procs are readable in flight

## Room & Level Design

- [x] **Breakable environment objects** — Barrels and crates as destructible obstacles in combat rooms, using the existing HealthComponent + Hitbox pattern. Hit them with any attack to break them; chance to drop gold or potions. Adds tactile liveliness to melee and decorates rooms with interactable scenery.

- [x] **Darkness room variant** — New `"dark"` room type in the floor graph: a black CanvasLayer overlay covers the screen with a circular cutout that follows the player, creating a limited-visibility combat challenge. Wired into DungeonManager, FloorConfig, and minimap (purple outline). All existing combat/enemy/door logic unchanged.

- [ ] **Secret rooms behind cracked walls** — A visually distinct cracked wall tile that breaks when hit (reusing the `breakable_object.gd` pattern), revealing a hidden treasure alcove; place 1 per floor at graph generation

- [ ] **Lava and water hazard tiles** — Environmental floor hazards: lava tiles deal BURN through the existing StatusEffectComponent on contact, shallow water applies SLOW — placed as TileMapLayer regions in select combat room variants

- [ ] **Lever puzzle room archetype** — New `"puzzle"` room type: hit floor levers/torches in the correct order (hinted by wall markings) to unlock a treasure chest; wrong order triggers a spike trap or ambush wave, reusing existing hazard components

- [ ] **Challenge shrine room** — Optional interactable shrine that locks the doors and spawns 2-3 escalating enemy waves; surviving grants a gilded-chest-tier reward. Reuses room clear flow plus wave spawning

- [ ] **More combat room layouts** — Only 6 combat rooms exist (`room_001`–`room_006`); add 4-6 more with distinct tactical identities: pillar mazes, a chokepoint bridge, an open arena, an L-shaped room with blind corners

---

## Bugs

- [x] **GameConfig tuning overlay was dead code** — `game_config.gd` loaded each item/ability `.tres`, mutated it, then dropped the reference. Nothing else held it, so Godot freed it immediately and every scene that loaded the same resource later got a fresh, **untuned** copy off disk. Every value in the `Items - *` and `Abilities - *` config blocks was silently discarded — verified live: the Mage's Fire Wall still read `damage=2 / mana=25` straight from the `.tres` while the config said otherwise. GameConfig now retains the resources it tunes in `_tuned_resources`, so the cache keeps them alive and the overlay actually reaches the game. A disk-vs-live diff of every item and ability confirmed Fire Wall was the only resource whose config and `.tres` disagreed, so nothing else shifted in balance. Guarded by a regression check in `tools/test_consumables.tscn`

- [x] **Arrows pass through walls** — Projectiles (arrows) don't collide with wall tiles. Fixed for all projectiles (enemy arrow, player arrow, piercing arrow, magic bolt, ice shard): walls added to collision masks + `body_entered` despawn with impact sparks
- [x] **Death screen broken** — Root cause: dead player's hurtbox stayed `monitorable`, so every enemy hit re-triggered HurtState and yanked the player out of DeadState, stalling the `player_died` → run summary flow. Fixed: HealthComponent ignores damage when dead, Hurtbox rejects hits on dead targets, StateMachine refuses transitions out of DeadState (also prevents dying enemies being "revived" by extra hits), player DeadState disables hurtbox shapes and emits `player_died` immediately, all enemies + boss disengage to IdleState on `player_died`, and the run summary screen now has Restart + Main Menu buttons
- [x] **Ogre sprites missing** — `ogre.tscn` referenced 27 nonexistent `ogre_*.svg` textures, so the scene failed to parse and the Ogre could never spawn. Created all 27 sprites (idle/walk/attack × down/up/side) in the standard 16x32 SVG style
- [x] **Mage Fire Wall (R) useless** — Was a tuning + readability problem, as originally suspected; there was no mechanical bug. It dealt 2 damage per 0.5s tick through a 48x12 sliver for 25 mana on a 10s cooldown, and the particles were hardcoded to that old size in the scene, so the flames did not even mark the strip that dealt damage. Retuned via GameConfig (which required the overlay fix under `## Bugs` to take effect at all): 2->4 damage, 0.5s->0.4s ticks, 48x12->72x20, 3s->5s, 25->18 mana, 10s->8s cooldown, +40 knockback. `fire_wall_zone.gd` now sizes its particles from the real wall dimensions via `_fit_particles_to()` and fades out instead of popping. The re-tick was also refactored from `deactivate()+activate()` to an explicit new `Hitbox.refresh_targets()` — a readability change, not a fix: both re-tick correctly (measured at 5 damage ticks either way; removing the re-tick entirely gives 1). Covered by a sensitive damage-tick test in `tools/test_consumables.tscn`

## Audio & Music

- [x] **Light attack SFX** — `attack_state.gd` makes no SFX call; the warrior's basic swing is silent. Add `AudioManager.play_sfx_varied(&"swing")` on state enter for the wind-up and `AudioManager.play_sfx_varied(&"hit")` on the active frame for the impact
- [x] **Dodge roll SFX** — `dodge_roll_state.gd` is silent; add `AudioManager.play_sfx_varied(&"dodge")` on `enter()` using `shield_bash.wav` as a fallback (remapped via the SFX fallback system below)
- [x] **SFX fallback system** — `_load_sfx()` in `audio_manager.gd` silently returns null for 6 missing SFX names (`attack`/`swing`/`dodge`/`magic_bolt`/`ice_shard`/`chain_lightning`/`fire_wall`/`ogre_charge`), silencing heavy attack, the entire Mage class, and the Ogre. Add a `_sfx_fallbacks: Dictionary` that maps each missing name to an existing file (e.g. `attack` → `hit`, `magic_bolt` → `arrow_fire`), checked in `_load_sfx()` before returning null
- [x] **MUSIC NEVER LOOPED (bug)** — `edit/loop_mode=0` on the WAV imports means "Detect From WAV", and `AudioStreamWAV.save_to_wav` writes no `smpl` chunk, so every track played once and left the rest of the run silent. All music `.import` files now set `edit/loop_mode=2` (Forward)
- [x] **Per-floor music variety** — `tools/generate_music.gd` synthesises six themes (`theme_halls` D minor march, `theme_depths` A minor halftime bells, `theme_caverns` E phrygian tribal, `theme_vault` C minor glassy, `theme_abyss` F# minor doom, `boss` D minor drive). Each floor `.tres` names its theme in `music_track`
- [x] **Combat music intensity layer** — Every theme is two stems of identical length/tempo (`<name>_base` + `<name>_layer`). AudioManager starts both players on the same frame and only crossfades the layer's volume, so the score reacts to combat without ever restarting or drifting out of sync. DungeonManager polls the `enemies` group for `is_aggroed` (polling, not the `enemy_aggroed` signal, which only fires on the transition) and holds the layer through `audio_combat_calm_delay` lulls. Boss rooms pin it on
- [x] **Ambient dungeon loop** — `ambience_bed.wav` (24s of rumble, air and water drips, every ingredient held at constant amplitude so the loop seam is silent) on its own player under the music, started with the floor
- [x] **Footstep SFX** — `step_footsteps()` on the shared `PlayerState` base, called from all three class run states; interval scales with actual speed so slows and haste change the cadence, with pitch spread and a big negative volume offset
- [x] **UI feedback sounds** — `UISounds.attach(self)` wires hover + click to every button under a screen in one call (8 screens). Shop purchase plays a cha-ching, can't-afford an error buzz, unlock purchases a chime, and the floor exit appearing plays the chime too
- [x] **Low-HP heartbeat** — Looping `heartbeat.wav` driven from the same `_check_low_health` transition as the vignette, so audio and visual warnings can't disagree
- [x] **Real SFX for the faked sounds** — `_SFX_FALLBACKS` was remapping swing, dodge and the entire Mage kit onto `hit.wav`/`arrow_fire.wav`, so a fireball sounded like an arrow. `tools/generate_sfx.gd` synthesises real `swing`, `dodge`, `footstep`, `heartbeat`, `magic_bolt`, `ice_shard`, `chain_lightning`, `fire_wall`, `ogre_charge`, `ui_hover`, `ui_purchase`, `ui_error` and `chime`

## Abilities & Cooldowns

- [x] **Active-buff HUD indicator** — War Cry (and any future buff abilities) grants a damage multiplier for up to 5s, but there is no HUD element showing the remaining buff duration. Add a small colored pill/bar that appears above the ability bar while a buff is active, shrinking as the timer counts down and disappearing when the buff expires. Driven by AbilityManager's `_buff_timer` and `_damage_multiplier` fields; connect via EventBus or a direct signal from AbilityManager.

- [x] **Cooldown reduction stat** — No item or ring currently reduces ability cooldowns. Add a `cooldown_reduction: float` field to the player's stat pipeline (read from equipped items in `item_effect_handler.gd`). Modify `ability_manager.start_cooldown(index)` to multiply the raw cooldown duration by `(1.0 - player.cooldown_reduction)` before storing it. Add at least one Ring item resource that grants 20% CDR, so the stat is exercised in a run.

- [x] **Ability interrupt on death** — All ability states (`shield_bash_state.gd`, `whirlwind_state.gd`, `war_cry_state.gd`, `ice_shard_state.gd`, `chain_lightning_state.gd`, `fire_wall_state.gd`, `blink_state.gd`, `multishot_state.gd`, `rain_of_arrows_state.gd`) run async tweens and timers; if the player dies mid-cast the state machine stops but in-flight effects (hitboxes, projectiles, tweens) may persist or keep the ability slot locked. In each ability state's `exit()`, cancel any running tween/timer and free any spawned scene if still alive. In the base `AbilityState.enter()`, subscribe to `player.health_component.died` and immediately force-transition to `DeadState` if it fires mid-cast.

- [ ] **Ability loadout selection** — Each class currently has a fixed 3-ability kit; add a loadout picker on the class select screen that lets the player slot any 3 unlocked abilities, making `unlocked_abilities` in SaveManager actually matter

- [x] **Kill-driven cooldown ticks** — `ability_kill_cooldown_reduction` seconds off every running cooldown per kill, hooked to `EventBus.enemy_killed` in `ability_manager.gd`. The HUD slots mirror their own timers, so a new `EventBus.ability_cooldown_reduced` keeps the radial overlays honest. This also covers the dodge slot, which is what the "melee kill dodge refund" idea below was after

- [ ] **Mid-run ability upgrades at shop** — The merchant offers one ability upgrade per shop visit (e.g. Whirlwind pulls enemies in, Fire Wall widens, Multishot +1 arrow), giving gold a build-shaping sink beyond items

- [ ] **Shield Bash wall-slam bonus** — Enemies knocked into a wall by Shield Bash take bonus damage and an extended stun, rewarding aim and positioning with the existing knockback + wall collision data

## Screen Effects

- [x] **Mouse-aim camera lookahead** — The camera is locked to the player; add a small camera script that offsets the camera a clamped fraction toward the mouse cursor (smoothed), so players can see farther in the direction they're aiming. Applies to all three class scenes' Camera2D.

- [x] **Boss death slow-motion** — On `EventBus.boss_defeated`, ramp `Engine.time_scale` down (~0.3) for a short beat and ease back to 1.0, paired with a subtle camera zoom-in on the boss, so the kill lands as a moment instead of an instant poof.

- [x] **Room-clear feedback pulse** — On `EventBus.room_cleared`, flash a quick white screen overlay and do a subtle camera zoom pulse so unlocking doors registers viscerally instead of only via the door SFX.

- [x] **Directional damage vignette** — New `shaders/directional_flash.gdshader` lights only the screen edge the hit came from. `Hurtbox` emits the new `EventBus.player_damaged_directional` carrying the incoming direction (the negated knockback push); the HUD tweens the shader's strength down from `ui_damage_flash_alpha`

- [ ] **Floor transition title card** — On floor advance, fade to black, show "Floor 2 — <flavor name>" text for a beat, then fade into the start room; currently floors swap with no ceremony

- [x] **Dark room light flicker** — `dark_room.gd` oscillates the visibility radius with two detuned sines so the wobble never settles into an obvious repeating pulse

## VFX & Particles

- [x] **Ambient room particles** — `scenes/effects/dust_motes.tscn` spawned per room by `RoomTemplate._ready` via `VFXHelper.spawn_room_motes`, with the emission box duplicated and resized to the room so one room's tuning can't leak into another's
- [x] **Persistent death decals** — `scripts/util/death_decal.gd` draws overlapping circles seeded from the death position (so every splatter differs) in a per-enemy colour: bone for skeletons/archers, goo for slimes, dark purple for bats, blood for ogres and the boss. Self-fading, and capped at `vfx_decal_max_count` with the oldest dismissed first
- [x] **Footstep dust puffs** — `scenes/effects/footstep_dust.tscn`, ticked on its own interval alongside the footstep sound in `PlayerState.step_footsteps`
- [x] **Elite aura particles** — `scripts/util/elite_aura.gd` draws a flattened orbiting ring whose motes brighten as they swing to the front; attached in `elite_modifier.gd`, because the tint alone was invisible against a dark floor
- [x] **Drop shadows under entities** — `scripts/util/drop_shadow.gd`, attached programmatically to all six enemies, the boss and all three player classes rather than authored into each scene, so one config change moves every shadow. The bat's is smaller and pinned lower to sell flight
- [ ] **Boss slam shockwave ring** — Expanding ring sprite + floor-crack particles under the boss slam attack, matching its damage radius so the AOE is readable

## Animation & Sprites

- [ ] **Sprite-based death animations** — Enemy deaths are a tween scale-down + fade; add 2-3 dedicated death frames per enemy (skeleton collapses to bone pile, slime deflates) for proper 16-bit deaths
- [ ] **Idle fidget animations** — After ~5s idle, play a one-shot fidget (warrior inspects sword, ranger spins an arrow, mage's orb sparks) before returning to the idle loop
- [ ] **Hurt sprites** — No hurt frames exist for any class; add a single recoil frame per direction shown during HurtState so getting hit reads in the sprite, not just the flash shader
- [ ] **Drop shadows under entities** — Small dark ellipse under every character sprite; give the bat a vertical hover bob against its fixed shadow to sell flight
- [ ] **Velocity-scaled walk animation** — Scale AnimatedSprite2D `speed_scale` with actual movement speed so slows, speed buffs, and elite speed multipliers visibly change the walk cycle

## Inventory & Equipment

- [ ] **Item effect tooltips** — Hovering an inventory or shop item shows a tooltip with its special effect text (procs, set membership, legendary effect), not just raw stats
- [ ] **Sort and filter controls** — Sort inventory by rarity/slot/newest buttons in `inventory_ui.gd`; matters now that runs span 5 floors of loot
- [ ] **Sell items at shop** — While the shop UI is open, allow selling inventory items for a fraction of their value, giving dead pickups a purpose and gold another source
- [ ] **Rarity-colored slot borders** — Tint inventory slot borders by item rarity (gray/green/blue/gold) with a subtle pulse on legendaries, so the good stuff pops without reading names

## Menus & Navigation

- [ ] **Class select preview panel** — Show each class's stats bar (HP/damage/speed), 3 ability icons with names, and a one-line playstyle blurb on the class select screen instead of a bare choice
- [ ] **Quit-run confirmation** — Quitting from the pause menu mid-run ends a permadeath run; add an "Abandon run? Progress will be lost" confirm dialog
- [ ] **Key rebinding menu** — Settings tab that lists input actions and lets players click-to-rebind, persisted via the existing SaveManager settings dictionary
- [ ] **Animated title screen** — Replace the static title with a slow parallax dungeon backdrop (flickering torches, drifting dust reusing the VFX scenes) so the first impression isn't a flat menu

## Minimap & Info

- [ ] **Room-type icons** — Replace the colored-outline coding in `minimap.gd` with tiny glyphs (skull=boss, $=shop, chest=treasure, !=trap, moon=dark) drawn over room squares — outlines are invisible at 6px
- [ ] **Unknown-room fog** — The minimap currently draws the entire floor graph from the start; show only visited rooms plus adjacent unvisited ones as "?" squares so exploration reveals the map
- [ ] **Hold-M map overlay** — Tapping M toggles the corner minimap; holding M opens an enlarged centered overlay with a legend and floor number, reusing the same draw code scaled up
- [ ] **Minimap floor label** — Draw "F2" in the minimap corner so depth is visible at a glance alongside the room layout

## Difficulty & Balance

- [ ] **Run modifier curses** — Optional toggles at run start (enemies +25% HP, no shops, elites everywhere) that each raise the meta-currency multiplier, giving veterans self-serve difficulty
- [ ] **Boss enrage phase** — Below 25% HP the boss gains attack speed, a red tint, and a new attack mix, so fights end on a spike instead of a fade-out
- [ ] **No-damage room bonus** — Clearing a combat room without taking damage drops bonus gold with a "Flawless!" popup, rewarding mastery room by room
- [ ] **Ascension levels** — After a victory, unlock stacking difficulty tiers (+enemy stats, -healing, faster telegraphs) with increased meta-currency rewards, giving the 5-floor loop long-term replayability

## Meta-Progression

- [ ] **Run history log** — Persist the last 20 runs (class, floors cleared, kills, time, victory) in `save_data.json` via SaveManager and show them in a table from the title screen; `run_stats` already collects everything needed
- [ ] **Achievements** — Achievement definitions as resources (first boss kill, flawless floor, legendary found, win as each class) with one-time meta-currency rewards and a toast popup on unlock
- [ ] **Class unlock gating** — Ranger and Mage start locked and are purchased with meta currency from the unlocks screen, giving the currency a marquee sink and runs a goal beyond passives
- [ ] **Lifetime stats screen** — SaveManager already tracks total runs, kills, gold, and best floor but nothing displays them; add a stats panel to the title/unlocks screen

---

## Future Ideas (Not Planned Yet)

- [x] More enemy types
- [x] **Mage class** — Ranged magic user with spell-based attacks (fireball, lightning), mana resource, AoE abilities, glass cannon stats
- [ ] **Rogue class** — Fast melee with daggers, backstab crit bonus, dash ability, stealth mechanic, high speed / low HP
- [ ] **Cleric class** — Hybrid support/melee with mace, healing ability, holy damage vs undead, shield/buff spells, tanky stats
