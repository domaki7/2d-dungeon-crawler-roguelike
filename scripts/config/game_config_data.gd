class_name GameConfigData
extends Resource

## ============================================================================
## CENTRAL GAME CONFIGURATION
## All tunable gameplay values in one place. Edit the .tres to balance the game.
## Access at runtime via: GameConfig.config.<property_name>
## ============================================================================


# =============================================================================
# PLAYER - WARRIOR
# =============================================================================

@export_group("Player - Base Stats")

## Starting damage before equipment bonuses
@export var player_base_damage: int = 3
## Starting defense before equipment bonuses
@export var player_base_defense: int = 0
## Starting max HP before equipment bonuses
@export var player_base_max_hp: int = 10
## Base movement speed in pixels/sec
@export var player_base_speed: float = 120.0
## Base knockback force applied to enemies on hit
@export var player_base_knockback_force: float = 150.0
## Base critical hit chance (0.0 to 1.0)
@export var player_base_crit_chance: float = 0.0

@export_group("Player - Movement")

## How quickly the warrior reaches max speed (pixels/sec^2)
@export var player_acceleration: float = 800.0
## How quickly the warrior decelerates when not moving (pixels/sec^2)
@export var player_friction: float = 600.0

@export_group("Player - Melee Attack")

## Distance from player center to melee hitbox center (pixels)
@export var player_hitbox_offset: float = 18.0
## Width and height of the melee hitbox (pixels)
@export var player_hitbox_size: Vector2 = Vector2(18, 15)
## Animation frame index (0-based) when the hitbox becomes active
@export var player_attack_active_frame: int = 1
## Animation frame index (0-based) at which dodge-cancel becomes available
@export var player_attack_cancel_frame: int = 2

@export_group("Player - Heavy Attack")

## How long the player must hold attack to fully charge (seconds)
@export var player_heavy_charge_duration: float = 0.7
## Damage multiplier for fully charged heavy attack
@export var player_heavy_damage_multiplier: float = 2.0
## Knockback multiplier for fully charged heavy attack
@export var player_heavy_knockback_multiplier: float = 1.5
## Width and height of the heavy attack hitbox (pixels)
@export var player_heavy_hitbox_size: Vector2 = Vector2(24, 20)
## Sprite shake amplitude during charge-up (pixels)
@export var player_heavy_shake_intensity: float = 1.0

@export_group("Player - Shield Bash")

## Distance from player center to shield bash hitbox (pixels)
@export var player_shield_bash_hitbox_offset: float = 8.0

@export_group("Player - States")

## How long the player is stunned after taking a hit (seconds)
@export var player_hurt_stun_duration: float = 0.3
## Duration of the white flash on death (seconds)
@export var player_dead_flash_duration: float = 0.3
## Duration of the fade-out on death (seconds)
@export var player_dead_fade_duration: float = 0.6

@export_group("Player - Arrow")

## Player arrow travel speed (pixels/sec)
@export var player_arrow_speed: float = 160.0
## How long before the player arrow despawns (seconds)
@export var player_arrow_lifetime: float = 3.0


# =============================================================================
# PLAYER - RANGER
# =============================================================================

@export_group("Ranger - Movement")

## How quickly the ranger reaches max speed (pixels/sec^2)
@export var ranger_acceleration: float = 800.0
## How quickly the ranger decelerates when not moving (pixels/sec^2)
@export var ranger_friction: float = 600.0


# =============================================================================
# PLAYER - MAGE
# =============================================================================

@export_group("Mage - Base Stats")

## Starting damage before equipment bonuses
@export var mage_base_damage: int = 4
## Starting defense before equipment bonuses
@export var mage_base_defense: int = 0
## Starting max HP before equipment bonuses
@export var mage_base_max_hp: int = 7
## Base movement speed (pixels/sec)
@export var mage_base_speed: float = 110.0
## Base knockback force applied to enemies on hit
@export var mage_base_knockback_force: float = 80.0
## Base critical hit chance (0.0 to 1.0)
@export var mage_base_crit_chance: float = 0.0

@export_group("Mage - Movement")

## How quickly the mage reaches max speed (pixels/sec^2)
@export var mage_acceleration: float = 700.0
## How quickly the mage decelerates when not moving (pixels/sec^2)
@export var mage_friction: float = 550.0

@export_group("Mage - Mana")

## Maximum mana pool
@export var mage_max_mana: int = 50
## Mana regenerated per second
@export var mage_mana_regen_rate: float = 5.0

@export_group("Mage - Magic Bolt")

## Magic bolt travel speed (pixels/sec)
@export var mage_bolt_speed: float = 140.0
## How long before the magic bolt despawns (seconds)
@export var mage_bolt_lifetime: float = 2.5
## Knockback force applied by magic bolt
@export var mage_bolt_knockback: float = 60.0

@export_group("Mage - Ice Shard Projectile")

## Ice shard travel speed (pixels/sec)
@export var mage_ice_shard_speed: float = 120.0
## How long before the ice shard despawns (seconds)
@export var mage_ice_shard_lifetime: float = 2.5


# =============================================================================
# ENEMY - WANDER (shared idle patrol behavior)
# =============================================================================

@export_group("Enemy - Wander")

## Wander speed as a fraction of the enemy's chase speed (0.3 = 30%)
@export var enemy_wander_speed_multiplier: float = 0.3
## Max distance an enemy will wander from its spawn point (pixels)
@export var enemy_wander_radius: float = 48.0
## Minimum pause duration between wander moves (seconds)
@export var enemy_wander_pause_min: float = 1.0
## Maximum pause duration between wander moves (seconds)
@export var enemy_wander_pause_max: float = 3.0
## Boss wander speed as a fraction of chase speed (slightly slower than regular enemies)
@export var boss_wander_speed_multiplier: float = 0.25


# =============================================================================
# SKELETON
# =============================================================================

@export_group("Skeleton - Movement")

## Skeleton movement speed (pixels/sec)
@export var skeleton_speed: float = 60.0
## Skeleton acceleration (pixels/sec^2)
@export var skeleton_acceleration: float = 400.0
## Skeleton deceleration (pixels/sec^2)
@export var skeleton_friction: float = 500.0

@export_group("Skeleton - Health")

## Skeleton max hit points
@export var skeleton_max_hp: int = 5
## Skeleton invincibility frame duration after taking damage (seconds)
@export var skeleton_i_frame_duration: float = 0.2

@export_group("Skeleton - Combat")

## Skeleton melee damage per hit
@export var skeleton_damage: int = 2
## Skeleton knockback force applied on hit
@export var skeleton_knockback_force: float = 120.0
## How quickly the skeleton stops sliding after knockback (pixels/sec^2)
@export var skeleton_knockback_friction: float = 600.0
## Distance at which skeleton switches from chase to attack (pixels)
@export var skeleton_attack_range: float = 18.0
## Distance from skeleton center to hitbox center during attack (pixels)
@export var skeleton_hitbox_offset: float = 12.0
## Radius of the skeleton's player detection area (pixels)
@export var skeleton_detection_radius: float = 60.0

@export_group("Skeleton - States")

## How long the skeleton is stunned after taking a hit (seconds)
@export var skeleton_stun_duration: float = 0.25
## Delay before skeleton is removed after dying (seconds)
@export var skeleton_death_delay: float = 0.3


# =============================================================================
# SLIME
# =============================================================================

@export_group("Slime - Movement")

## Slime movement speed (pixels/sec)
@export var slime_speed: float = 40.0
## Slime acceleration (pixels/sec^2)
@export var slime_acceleration: float = 300.0
## Slime deceleration (pixels/sec^2)
@export var slime_friction: float = 500.0

@export_group("Slime - Health")

## Slime max hit points
@export var slime_max_hp: int = 8
## Slime invincibility frame duration after taking damage (seconds)
@export var slime_i_frame_duration: float = 0.2

@export_group("Slime - Combat")

## Slime melee damage per hit
@export var slime_damage: int = 1
## Slime knockback force applied on hit
@export var slime_knockback_force: float = 80.0
## How quickly the slime stops sliding after knockback (pixels/sec^2)
@export var slime_knockback_friction: float = 400.0
## Distance at which slime switches from chase to attack (pixels)
@export var slime_attack_range: float = 14.0
## Distance from slime center to hitbox center during attack (pixels)
@export var slime_hitbox_offset: float = 8.0
## Radius of the slime's player detection area (pixels)
@export var slime_detection_radius: float = 50.0

@export_group("Slime - States")

## How long the slime is stunned after taking a hit (seconds)
@export var slime_stun_duration: float = 0.3
## Delay before slime is removed after dying (seconds)
@export var slime_death_delay: float = 0.4


# =============================================================================
# BAT
# =============================================================================

@export_group("Bat - Movement")

## Bat movement speed (pixels/sec)
@export var bat_speed: float = 80.0
## Bat acceleration (pixels/sec^2)
@export var bat_acceleration: float = 500.0
## Bat deceleration (pixels/sec^2)
@export var bat_friction: float = 500.0

@export_group("Bat - Health")

## Bat max hit points
@export var bat_max_hp: int = 3
## Bat invincibility frame duration after taking damage (seconds)
@export var bat_i_frame_duration: float = 0.2

@export_group("Bat - Combat")

## Bat melee damage per hit
@export var bat_damage: int = 1
## Bat knockback force applied on hit
@export var bat_knockback_force: float = 80.0
## How quickly the bat stops sliding after knockback (pixels/sec^2)
@export var bat_knockback_friction: float = 700.0
## Distance at which bat switches from chase to attack (pixels)
@export var bat_attack_range: float = 16.0
## Distance from bat center to hitbox center during attack (pixels)
@export var bat_hitbox_offset: float = 10.0
## Radius of the bat's player detection area (pixels)
@export var bat_detection_radius: float = 70.0

@export_group("Bat - AI")

## How often the bat changes its jitter direction (seconds)
@export var bat_jitter_interval: float = 0.4
## Strength of the bat's random jitter movement (0.0 to 1.0)
@export var bat_jitter_strength: float = 0.5

@export_group("Bat - States")

## How long the bat is stunned after taking a hit (seconds)
@export var bat_stun_duration: float = 0.2
## Delay before bat is removed after dying (seconds)
@export var bat_death_delay: float = 0.3


# =============================================================================
# SKELETON ARCHER
# =============================================================================

@export_group("Archer - Movement")

## Archer movement speed (pixels/sec)
@export var archer_speed: float = 50.0
## Archer acceleration (pixels/sec^2)
@export var archer_acceleration: float = 350.0
## Archer deceleration (pixels/sec^2)
@export var archer_friction: float = 500.0

@export_group("Archer - Health")

## Archer max hit points
@export var archer_max_hp: int = 5
## Archer invincibility frame duration after taking damage (seconds)
@export var archer_i_frame_duration: float = 0.2

@export_group("Archer - Combat")

## Archer knockback friction after being hit (pixels/sec^2)
@export var archer_knockback_friction: float = 600.0
## Archer arrow damage per hit
@export var archer_arrow_damage: int = 2
## Delay before the archer fires after starting attack (seconds)
@export var archer_shoot_delay: float = 0.3
## Optimal distance the archer tries to maintain from the player (pixels)
@export var archer_preferred_range: float = 80.0
## Maximum distance at which the archer will fire (pixels)
@export var archer_attack_range: float = 90.0
## Distance at which the archer retreats away from the player (pixels)
@export var archer_too_close_range: float = 40.0
## Radius of the archer's player detection area (pixels)
@export var archer_detection_radius: float = 90.0

@export_group("Archer - States")

## How long the archer is stunned after taking a hit (seconds)
@export var archer_stun_duration: float = 0.25
## Delay before archer is removed after dying (seconds)
@export var archer_death_delay: float = 0.3

@export_group("Archer - Arrow Projectile")

## Enemy arrow travel speed (pixels/sec)
@export var enemy_arrow_speed: float = 120.0
## How long before the enemy arrow despawns (seconds)
@export var enemy_arrow_lifetime: float = 3.0


# =============================================================================
# SKELETON KNIGHT (BOSS)
# =============================================================================

@export_group("Boss - Movement")

## Boss movement speed (pixels/sec)
@export var boss_speed: float = 45.0
## Boss acceleration (pixels/sec^2)
@export var boss_acceleration: float = 350.0
## Boss deceleration (pixels/sec^2)
@export var boss_friction: float = 500.0

@export_group("Boss - Health")

## Boss max hit points
@export var boss_max_hp: int = 50
## Boss invincibility frame duration after taking damage (seconds)
@export var boss_i_frame_duration: float = 0.1

@export_group("Boss - Combat")

## Boss base melee damage per hit
@export var boss_damage: int = 3
## Boss knockback force applied on hit
@export var boss_knockback_force: float = 180.0
## How quickly the boss stops sliding after knockback (pixels/sec^2)
@export var boss_knockback_friction: float = 300.0
## Radius of the boss's player detection area (pixels)
@export var boss_detection_radius: float = 120.0

@export_group("Boss - Phases")

## HP ratio at which boss enters phase 2 (0.0 to 1.0)
@export var boss_phase_2_threshold: float = 0.6
## HP ratio at which boss enters phase 3 (0.0 to 1.0)
@export var boss_phase_3_threshold: float = 0.3

@export_group("Boss - States")

## Delay before boss engages after spawning (seconds)
@export var boss_engage_delay: float = 1.0
## Delay before boss is removed after dying (seconds)
@export var boss_death_delay: float = 1.0
## How long the boss is stunned after taking a hit (seconds)
@export var boss_stun_duration: float = 0.2
## Duration of boss stunned state from shield bash etc. (seconds)
@export var boss_stunned_duration: float = 0.8

@export_group("Boss - Melee Attack")

## Distance at which boss uses melee attack (pixels)
@export var boss_melee_range: float = 22.0
## Distance from boss center to melee hitbox center (pixels)
@export var boss_melee_hitbox_offset: float = 14.0

@export_group("Boss - Charge Attack")

## Cooldown between charge attacks (seconds)
@export var boss_charge_cooldown: float = 5.0
## Boss charge movement speed (pixels/sec)
@export var boss_charge_speed: float = 300.0
## Duration of the charge windup animation (seconds)
@export var boss_charge_windup: float = 0.5
## Duration of the active charge movement (seconds)
@export var boss_charge_duration: float = 0.4
## Distance from boss center to charge hitbox center (pixels)
@export var boss_charge_hitbox_offset: float = 16.0

@export_group("Boss - Slam Attack")

## Cooldown between slam attacks (seconds)
@export var boss_slam_cooldown: float = 7.0
## Damage dealt by the slam AOE
@export var boss_slam_damage: int = 4
## Radius of the slam damage area (pixels)
@export var boss_slam_radius: float = 40.0
## Duration of the slam windup / lift animation (seconds)
@export var boss_slam_windup: float = 0.5
## Duration of the slam descent / impact (seconds)
@export var boss_slam_duration: float = 0.3
## Screen shake intensity on slam impact
@export var boss_slam_shake_intensity: float = 4.0
## Screen shake duration on slam impact (seconds)
@export var boss_slam_shake_duration: float = 0.3

@export_group("Boss - Summon")

## Cooldown between summon phases (seconds)
@export var boss_summon_cooldown: float = 10.0
## Number of minions spawned per summon
@export var boss_summon_count: int = 2
## Delay before minions actually appear (seconds)
@export var boss_summon_delay: float = 0.8
## Distance from boss where minions spawn (pixels)
@export var boss_spawn_radius: float = 40.0


# =============================================================================
# COMBAT SYSTEM
# =============================================================================

@export_group("Combat - Knockback")

## Default knockback friction for all entities (pixels/sec^2)
@export var combat_default_knockback_friction: float = 800.0

@export_group("Combat - Hit Feedback")

## Duration of the hit pause / freeze frame effect (real seconds)
@export var combat_hit_pause_duration: float = 0.06
## Screen shake intensity on normal hits
@export var combat_screen_shake_intensity: float = 2.0
## Screen shake duration on normal hits (seconds)
@export var combat_screen_shake_duration: float = 0.15

@export_group("Combat - Critical Hits")

## Damage multiplier for critical hits
@export var combat_crit_multiplier: int = 2

@export_group("Combat - I-Frames")

## Default invincibility frame duration (seconds)
@export var combat_default_i_frame_duration: float = 0.5

@export_group("Combat - Stun")

## Default stun duration for generic stunned state (seconds)
@export var combat_default_stun_duration: float = 1.0
## Tint color applied to stunned enemies
@export var combat_stunned_color: Color = Color(1.0, 1.0, 0.5, 1.0)

@export_group("Status Effects - Stun")

## Tint color applied to stunned entities
@export var status_stun_tint_color: Color = Color(1.0, 1.0, 0.5, 1.0)

@export_group("Status Effects - Burn")

## Burn effect duration (seconds)
@export var status_burn_duration: float = 3.0
## Time between burn damage ticks (seconds)
@export var status_burn_tick_interval: float = 0.5
## Damage dealt per burn tick
@export var status_burn_damage_per_tick: int = 3
## Tint color applied to burning entities
@export var status_burn_tint_color: Color = Color(1.0, 0.6, 0.3, 1.0)

@export_group("Status Effects - Poison")

## Poison effect duration (seconds)
@export var status_poison_duration: float = 5.0
## Time between poison damage ticks (seconds)
@export var status_poison_tick_interval: float = 1.0
## Damage dealt per poison tick
@export var status_poison_damage_per_tick: int = 2
## Tint color applied to poisoned entities
@export var status_poison_tint_color: Color = Color(0.5, 0.9, 0.3, 1.0)

@export_group("Status Effects - Freeze")

## Freeze effect duration (seconds)
@export var status_freeze_duration: float = 2.5
## Speed multiplier while frozen (0.1 = 90% slow)
@export var status_freeze_speed_multiplier: float = 0.1
## Tint color applied to frozen entities
@export var status_freeze_tint_color: Color = Color(0.5, 0.8, 1.0, 1.0)

@export_group("Status Effects - Slow")

## Slow effect duration (seconds)
@export var status_slow_duration: float = 4.0
## Speed multiplier while slowed (0.5 = 50% slow)
@export var status_slow_speed_multiplier: float = 0.5
## Tint color applied to slowed entities
@export var status_slow_tint_color: Color = Color(0.7, 0.5, 0.9, 1.0)


@export_group("Combat - Attack Telegraph")

## Skeleton attack windup duration before the swing (seconds)
@export var skeleton_telegraph_duration: float = 0.3
## Slime attack windup duration (seconds)
@export var slime_telegraph_duration: float = 0.25
## Bat attack windup duration (seconds)
@export var bat_telegraph_duration: float = 0.2
## Boss melee attack windup duration (seconds)
@export var boss_melee_telegraph_duration: float = 0.35
## Fastest flash interval at end of windup (seconds)
@export var telegraph_min_flash_interval: float = 0.06
## Slowest flash interval at start of windup (seconds)
@export var telegraph_max_flash_interval: float = 0.2
## Duration of each telegraph flash pulse (seconds)
@export var telegraph_flash_duration: float = 0.05


# =============================================================================
# ELITE ENEMIES
# =============================================================================

@export_group("Elite Enemies - Stat Scaling")

## HP multiplier for elite enemies (2.0 = double HP)
@export var elite_hp_multiplier: float = 2.0
## Damage multiplier for elite enemies (1.5 = 50% more damage)
@export var elite_damage_multiplier: float = 1.5
## Speed multiplier for elite enemies (1.2 = 20% faster)
@export var elite_speed_multiplier: float = 1.2

@export_group("Elite Enemies - Visuals")

## Scale multiplier for elite enemy sprites
@export var elite_scale: float = 1.3
## Tint color applied to elite enemy sprites
@export var elite_tint_color: Color = Color(1.0, 0.3, 0.3, 1.0)

@export_group("Elite Enemies - Loot")

## Drop chance for elite enemy item drops (1.0 = guaranteed)
@export var elite_guaranteed_drop_chance: float = 1.0
## Number of extra gold pickups dropped by elite enemies
@export var elite_bonus_gold_drops: int = 2

@export_group("Elite Enemies - Status Effects")

## Duration of SLOW applied by elite skeletons (seconds)
@export var elite_skeleton_status_duration: float = 2.0
## Duration of POISON applied by elite slimes (seconds)
@export var elite_slime_status_duration: float = 3.0
## Duration of BURN applied by elite bats (seconds)
@export var elite_bat_status_duration: float = 2.0
## Duration of FREEZE applied by elite archers (seconds)
@export var elite_archer_status_duration: float = 2.5


# =============================================================================
# DUNGEON
# =============================================================================

@export_group("Dungeon - Transitions")

## Duration of the room transition fade effect (seconds)
@export var dungeon_fade_duration: float = 0.3

@export_group("Dungeon - Floors")

## Total number of floors in a run
@export var dungeon_max_floors: int = 5

@export_group("Dungeon - Branching")

## Probability that each main-path room spawns a side branch (0.0 to 1.0)
@export var dungeon_branch_chance: float = 0.4
## Maximum number of rooms deep a branch can extend
@export var dungeon_max_branch_depth: int = 2

@export_group("Dungeon - Room Defaults")

## Default room width in pixels
@export var dungeon_room_pixel_width: int = 384
## Default room height in pixels
@export var dungeon_room_pixel_height: int = 256


# =============================================================================
# UI / VISUAL EFFECTS
# =============================================================================

@export_group("VFX")

## Duration of the white hit flash on damaged entities (seconds)
@export var vfx_hit_flash_duration: float = 0.15

@export_group("VFX - Death")

## Duration of the scale-down + fade-out tween on enemy death (seconds)
@export var vfx_death_tween_duration: float = 0.3
## Final scale at end of death tween (multiplier)
@export var vfx_death_tween_end_scale: float = 0.5
## Boss death tween duration (seconds)
@export var vfx_boss_death_tween_duration: float = 0.6
## Screen shake intensity on boss death
@export var vfx_boss_death_shake_intensity: float = 5.0
## Screen shake duration on boss death (seconds)
@export var vfx_boss_death_shake_duration: float = 0.4


@export_group("UI - Damage Numbers")

## How fast damage numbers float upward (pixels/sec)
@export var ui_damage_float_speed: float = 30.0
## How long damage numbers are visible (seconds)
@export var ui_damage_duration: float = 0.6
## Random horizontal spread of damage numbers (pixels)
@export var ui_damage_spread: float = 8.0

@export_group("UI - Minimap")

## Size of each room icon on the minimap (pixels)
@export var ui_minimap_room_size: Vector2 = Vector2(8, 8)
## Spacing between room icons on the minimap (pixels)
@export var ui_minimap_room_spacing: float = 12.0

@export_group("UI - Death Screen")

## Duration of the death screen fade-in (seconds)
@export var ui_death_fade_in_duration: float = 0.4

@export_group("UI - Door Colors")

## Color of locked doors
@export var ui_door_locked_color: Color = Color(0.6, 0.2, 0.2, 1.0)
## Color of unlocked doors
@export var ui_door_unlocked_color: Color = Color(0.2, 0.5, 0.3, 1.0)

@export_group("UI - Buffs")

## Tint color applied to the player during War Cry buff
@export var ui_war_cry_buff_color: Color = Color(1.2, 1.1, 0.8, 1.0)

@export_group("UI - Settings")

## Minimum volume for settings sliders (decibels)
@export var ui_settings_volume_min_db: float = -20.0
## Maximum volume for settings sliders (decibels)
@export var ui_settings_volume_max_db: float = 0.0

@export_group("UI - Stat Comparison")

## Color for positive stat differences (green)
@export var ui_stat_positive_color: Color = Color(0.3, 0.9, 0.3)
## Color for negative stat differences (red)
@export var ui_stat_negative_color: Color = Color(0.9, 0.3, 0.3)

@export_group("UI - Ability Cooldown")

## Overlay color for radial cooldown sweep
@export var ui_cooldown_overlay_color: Color = Color(0.0, 0.0, 0.0, 0.6)
## Font size for cooldown countdown text (pixels)
@export var ui_cooldown_text_size: int = 7


# =============================================================================
# AUDIO
# =============================================================================

@export_group("Audio")

## Sound effects volume in decibels
@export var audio_sfx_volume_db: float = -5.0
## Music volume in decibels
@export var audio_music_volume_db: float = -10.0

@export_group("Audio - Pitch Variation")

## Minimum pitch scale for varied SFX (1.0 = normal)
@export var audio_sfx_pitch_min: float = 0.9
## Maximum pitch scale for varied SFX (1.0 = normal)
@export var audio_sfx_pitch_max: float = 1.1


# =============================================================================
# ECONOMY
# =============================================================================

@export_group("Economy - Gold")

## Gold value per gold pickup
@export var economy_gold_pickup_value: int = 1

@export_group("Economy - Meta Currency")

## Meta currency earned per floor cleared
@export var economy_floor_multiplier: int = 10
## Meta currency earned per enemy kill
@export var economy_kill_multiplier: int = 1
## Bonus meta currency for winning the run
@export var economy_victory_bonus: int = 50

@export_group("Economy - Item Pickup Animation")

## Vertical bob amplitude for item pickups (pixels)
@export var economy_bob_amplitude: float = 2.0
## Vertical bob speed for item pickups
@export var economy_bob_speed: float = 3.0


# =============================================================================
# ITEMS
# Each item's tunable stats. Values here override the item .tres files at load.
# =============================================================================

@export_group("Items - Weapons")

@export_subgroup("Iron Sword")
@export var iron_sword_bonus_damage: int = 2
@export var iron_sword_bonus_defense: int = 0
@export var iron_sword_bonus_max_hp: int = 0
@export var iron_sword_bonus_speed: float = 0.0
@export var iron_sword_bonus_knockback_force: float = 0.0
@export var iron_sword_bonus_crit_chance: float = 0.0
@export var iron_sword_effect_value: float = 0.0
@export var iron_sword_buy_price: int = 15
@export var iron_sword_sell_price: int = 5

@export_subgroup("Steel Greatsword")
@export var steel_greatsword_bonus_damage: int = 5
@export var steel_greatsword_bonus_defense: int = 0
@export var steel_greatsword_bonus_max_hp: int = 0
## Negative value = slower movement
@export var steel_greatsword_bonus_speed: float = -10.0
@export var steel_greatsword_bonus_knockback_force: float = 80.0
@export var steel_greatsword_bonus_crit_chance: float = 0.0
@export var steel_greatsword_effect_value: float = 0.0
@export var steel_greatsword_buy_price: int = 35
@export var steel_greatsword_sell_price: int = 12

@export_subgroup("Ember Blade")
@export var ember_blade_bonus_damage: int = 6
@export var ember_blade_bonus_defense: int = 0
@export var ember_blade_bonus_max_hp: int = 0
@export var ember_blade_bonus_speed: float = 0.0
@export var ember_blade_bonus_knockback_force: float = 0.0
@export var ember_blade_bonus_crit_chance: float = 0.1
## Burn damage per tick
@export var ember_blade_effect_value: float = 3.0
@export var ember_blade_buy_price: int = 60
@export var ember_blade_sell_price: int = 22

@export_subgroup("Short Bow")
@export var short_bow_bonus_damage: int = 1
@export var short_bow_bonus_defense: int = 0
@export var short_bow_bonus_max_hp: int = 0
@export var short_bow_bonus_speed: float = 10.0
@export var short_bow_bonus_knockback_force: float = 0.0
@export var short_bow_bonus_crit_chance: float = 0.0
@export var short_bow_effect_value: float = 0.0
@export var short_bow_buy_price: int = 12
@export var short_bow_sell_price: int = 4

@export_subgroup("Longbow")
@export var longbow_bonus_damage: int = 4
@export var longbow_bonus_defense: int = 0
@export var longbow_bonus_max_hp: int = 0
@export var longbow_bonus_speed: float = 0.0
@export var longbow_bonus_knockback_force: float = 50.0
@export var longbow_bonus_crit_chance: float = 0.0
@export var longbow_effect_value: float = 0.0
@export var longbow_buy_price: int = 35
@export var longbow_sell_price: int = 12

@export_subgroup("Shadow Bow")
@export var shadow_bow_bonus_damage: int = 5
@export var shadow_bow_bonus_defense: int = 0
@export var shadow_bow_bonus_max_hp: int = 0
@export var shadow_bow_bonus_speed: float = 0.0
@export var shadow_bow_bonus_knockback_force: float = 0.0
@export var shadow_bow_bonus_crit_chance: float = 0.25
@export var shadow_bow_effect_value: float = 0.0
@export var shadow_bow_buy_price: int = 65
@export var shadow_bow_sell_price: int = 25

@export_group("Items - Armor")

@export_subgroup("Leather Armor")
@export var leather_armor_bonus_damage: int = 0
@export var leather_armor_bonus_defense: int = 2
@export var leather_armor_bonus_max_hp: int = 0
@export var leather_armor_bonus_speed: float = 0.0
@export var leather_armor_bonus_knockback_force: float = 0.0
@export var leather_armor_bonus_crit_chance: float = 0.0
@export var leather_armor_effect_value: float = 0.0
@export var leather_armor_buy_price: int = 20
@export var leather_armor_sell_price: int = 7

@export_subgroup("Chainmail")
@export var chainmail_bonus_damage: int = 0
@export var chainmail_bonus_defense: int = 4
@export var chainmail_bonus_max_hp: int = 5
## Negative value = slower movement
@export var chainmail_bonus_speed: float = -15.0
@export var chainmail_bonus_knockback_force: float = 0.0
@export var chainmail_bonus_crit_chance: float = 0.0
@export var chainmail_effect_value: float = 0.0
@export var chainmail_buy_price: int = 35
@export var chainmail_sell_price: int = 12

@export_subgroup("Thorn Vest")
@export var thorn_vest_bonus_damage: int = 0
@export var thorn_vest_bonus_defense: int = 3
@export var thorn_vest_bonus_max_hp: int = 5
@export var thorn_vest_bonus_speed: float = 0.0
@export var thorn_vest_bonus_knockback_force: float = 0.0
@export var thorn_vest_bonus_crit_chance: float = 0.0
## Thorn reflect damage
@export var thorn_vest_effect_value: float = 2.0
@export var thorn_vest_buy_price: int = 60
@export var thorn_vest_sell_price: int = 22

@export_group("Items - Rings")

@export_subgroup("Ring of Vitality")
@export var ring_of_vitality_bonus_damage: int = 0
@export var ring_of_vitality_bonus_defense: int = 1
@export var ring_of_vitality_bonus_max_hp: int = 5
@export var ring_of_vitality_bonus_speed: float = 0.0
@export var ring_of_vitality_bonus_knockback_force: float = 0.0
@export var ring_of_vitality_bonus_crit_chance: float = 0.0
@export var ring_of_vitality_effect_value: float = 0.0
@export var ring_of_vitality_buy_price: int = 30
@export var ring_of_vitality_sell_price: int = 10

@export_subgroup("Ring of Haste")
@export var ring_of_haste_bonus_damage: int = 0
@export var ring_of_haste_bonus_defense: int = 0
@export var ring_of_haste_bonus_max_hp: int = 0
@export var ring_of_haste_bonus_speed: float = 20.0
@export var ring_of_haste_bonus_knockback_force: float = 0.0
@export var ring_of_haste_bonus_crit_chance: float = 0.0
@export var ring_of_haste_effect_value: float = 0.0
@export var ring_of_haste_buy_price: int = 15
@export var ring_of_haste_sell_price: int = 5

@export_subgroup("Berserker Band")
@export var berserker_band_bonus_damage: int = 3
@export var berserker_band_bonus_defense: int = 0
@export var berserker_band_bonus_max_hp: int = 0
@export var berserker_band_bonus_speed: float = 0.0
@export var berserker_band_bonus_knockback_force: float = 0.0
@export var berserker_band_bonus_crit_chance: float = 0.25
## Bonus damage when below half HP
@export var berserker_band_effect_value: float = 5.0
@export var berserker_band_buy_price: int = 65
@export var berserker_band_sell_price: int = 25

@export_group("Items - Accessories")

@export_subgroup("Vampire Pendant")
@export var vampire_pendant_bonus_damage: int = 0
@export var vampire_pendant_bonus_defense: int = 1
@export var vampire_pendant_bonus_max_hp: int = 0
@export var vampire_pendant_bonus_speed: float = 0.0
@export var vampire_pendant_bonus_knockback_force: float = 0.0
@export var vampire_pendant_bonus_crit_chance: float = 0.0
## HP healed per kill
@export var vampire_pendant_effect_value: float = 2.0
@export var vampire_pendant_buy_price: int = 35
@export var vampire_pendant_sell_price: int = 12

@export_subgroup("Lucky Coin")
@export var lucky_coin_bonus_damage: int = 1
@export var lucky_coin_bonus_defense: int = 0
@export var lucky_coin_bonus_max_hp: int = 0
@export var lucky_coin_bonus_speed: float = 0.0
@export var lucky_coin_bonus_knockback_force: float = 0.0
@export var lucky_coin_bonus_crit_chance: float = 0.0
## Extra gold dropped per kill
@export var lucky_coin_effect_value: float = 3.0
@export var lucky_coin_buy_price: int = 30
@export var lucky_coin_sell_price: int = 10

@export_subgroup("Guardian Idol")
@export var guardian_idol_bonus_damage: int = 0
@export var guardian_idol_bonus_defense: int = 2
@export var guardian_idol_bonus_max_hp: int = 5
@export var guardian_idol_bonus_speed: float = 0.0
@export var guardian_idol_bonus_knockback_force: float = 0.0
@export var guardian_idol_bonus_crit_chance: float = 0.0
## HP restored on revive
@export var guardian_idol_effect_value: float = 8.0
@export var guardian_idol_buy_price: int = 75
@export var guardian_idol_sell_price: int = 28

@export_subgroup("Quiver of Speed")
@export var quiver_of_speed_bonus_damage: int = 2
@export var quiver_of_speed_bonus_defense: int = 0
@export var quiver_of_speed_bonus_max_hp: int = 0
@export var quiver_of_speed_bonus_speed: float = 25.0
@export var quiver_of_speed_bonus_knockback_force: float = 0.0
@export var quiver_of_speed_bonus_crit_chance: float = 0.0
@export var quiver_of_speed_effect_value: float = 0.0
@export var quiver_of_speed_buy_price: int = 30
@export var quiver_of_speed_sell_price: int = 10


# =============================================================================
# ABILITIES
# Each ability's tunable stats. Values here override the ability .tres at load.
# =============================================================================

@export_group("Abilities - Shield Bash")

## Cooldown between uses (seconds)
@export var ability_shield_bash_cooldown: float = 4.0
## Damage dealt on hit
@export var ability_shield_bash_damage: int = 2
## Knockback force applied to enemies
@export var ability_shield_bash_knockback_force: float = 100.0
## Dash movement speed (pixels/sec)
@export var ability_shield_bash_dash_speed: float = 200.0
## Duration of the dash (seconds)
@export var ability_shield_bash_dash_duration: float = 0.15
## How long enemies are stunned by the bash (seconds)
@export var ability_shield_bash_stun_duration: float = 1.0

@export_group("Abilities - Whirlwind")

## Cooldown between uses (seconds)
@export var ability_whirlwind_cooldown: float = 6.0
## Damage dealt per hit
@export var ability_whirlwind_damage: int = 4
## Knockback force applied to enemies
@export var ability_whirlwind_knockback_force: float = 80.0
## Radius of the whirlwind AOE (pixels)
@export var ability_whirlwind_aoe_radius: float = 24.0

@export_group("Abilities - War Cry")

## Cooldown between uses (seconds)
@export var ability_war_cry_cooldown: float = 10.0
## Duration of the damage buff (seconds)
@export var ability_war_cry_buff_duration: float = 5.0
## Damage multiplier during buff
@export var ability_war_cry_damage_multiplier: float = 1.5

@export_group("Abilities - Multishot")

## Cooldown between uses (seconds)
@export var ability_multishot_cooldown: float = 5.0
## Damage per arrow
@export var ability_multishot_damage: int = 2
## Knockback force per arrow
@export var ability_multishot_knockback_force: float = 60.0
## Number of arrows fired
@export var ability_multishot_arrow_count: int = 5
## Total spread angle of the fan (degrees)
@export var ability_multishot_spread_angle: float = 30.0

@export_group("Abilities - Dodge Roll")

## Cooldown between uses (seconds)
@export var ability_dodge_roll_cooldown: float = 3.0
## Roll movement speed (pixels/sec)
@export var ability_dodge_roll_dash_speed: float = 250.0
## Duration of the roll (seconds)
@export var ability_dodge_roll_dash_duration: float = 0.3

@export_group("Abilities - Rain of Arrows")

## Cooldown between uses (seconds)
@export var ability_rain_of_arrows_cooldown: float = 10.0
## Damage per arrow
@export var ability_rain_of_arrows_damage: int = 3
## Knockback force per arrow
@export var ability_rain_of_arrows_knockback_force: float = 40.0
## Radius of the rain area (pixels)
@export var ability_rain_of_arrows_aoe_radius: float = 24.0
## Delay before arrows start falling (seconds)
@export var ability_rain_of_arrows_rain_delay: float = 0.4
## Duration of the arrow rain (seconds)
@export var ability_rain_of_arrows_rain_duration: float = 0.6

@export_group("Abilities - Ice Shard")

## Cooldown between uses (seconds)
@export var ability_ice_shard_cooldown: float = 4.0
## Damage dealt on hit
@export var ability_ice_shard_damage: int = 3
## Knockback force applied to enemies
@export var ability_ice_shard_knockback_force: float = 40.0
## Duration of SLOW applied on hit (seconds)
@export var ability_ice_shard_slow_duration: float = 3.0
## Mana cost to cast
@export var ability_ice_shard_mana_cost: int = 15

@export_group("Abilities - Chain Lightning")

## Cooldown between uses (seconds)
@export var ability_chain_lightning_cooldown: float = 6.0
## Damage dealt per bounce
@export var ability_chain_lightning_damage: int = 5
## Knockback force applied to enemies
@export var ability_chain_lightning_knockback_force: float = 30.0
## Number of times lightning bounces to additional enemies
@export var ability_chain_lightning_bounce_count: int = 3
## Maximum range to find the next bounce target (pixels)
@export var ability_chain_lightning_bounce_range: float = 60.0
## Maximum range to find initial target (pixels)
@export var ability_chain_lightning_cast_range: float = 80.0
## Mana cost to cast
@export var ability_chain_lightning_mana_cost: int = 20

@export_group("Abilities - Fire Wall")

## Cooldown between uses (seconds)
@export var ability_fire_wall_cooldown: float = 10.0
## Damage dealt per tick to enemies in the wall
@export var ability_fire_wall_damage: int = 2
## Knockback force applied per tick
@export var ability_fire_wall_knockback_force: float = 0.0
## Length of the fire wall (pixels)
@export var ability_fire_wall_length: float = 48.0
## Width of the fire wall (pixels)
@export var ability_fire_wall_width: float = 12.0
## How long the fire wall persists (seconds)
@export var ability_fire_wall_duration: float = 3.0
## Time between damage ticks (seconds)
@export var ability_fire_wall_tick_interval: float = 0.5
## Duration of BURN applied to enemies (seconds)
@export var ability_fire_wall_burn_duration: float = 2.0
## Mana cost to cast
@export var ability_fire_wall_mana_cost: int = 25

@export_group("Abilities - Blink")

## Cooldown between uses (seconds)
@export var ability_blink_cooldown: float = 3.0
## Teleport distance (pixels)
@export var ability_blink_distance: float = 60.0
## Mana cost to cast
@export var ability_blink_mana_cost: int = 10


# =============================================================================
# LEGENDARY ITEMS
# =============================================================================

@export_group("Legendary Items")

## Maximum legendary item drops per run (0 = unlimited)
@export var legendary_max_per_run: int = 1
## Tint color for legendary item pickups
@export var legendary_pickup_tint: Color = Color(1.0, 0.84, 0.0)
## AOE radius for explosion_on_kill effect (pixels)
@export var legendary_explosion_radius: float = 40.0
## Damage dealt by explosion_on_kill AOE
@export var legendary_explosion_damage: int = 5
## Number of chain lightning bounces on crit
@export var legendary_chain_lightning_bounces: int = 2
## Chain lightning bounce range (pixels)
@export var legendary_chain_lightning_range: float = 50.0
## Chain lightning damage per bounce
@export var legendary_chain_lightning_damage: int = 3
## Lifesteal percentage for lifesteal_percent effect (0.0 to 1.0)
@export var legendary_lifesteal_percent: float = 0.2
## Crit chance gained per 10 speed bonus from speed_to_crit (0.0 to 1.0)
@export var legendary_speed_to_crit_ratio: float = 0.01


# =============================================================================
# ON-HIT PROC EFFECTS
# =============================================================================

@export_group("Status Effects - On-Hit Procs")

## Duration of freeze applied by freeze_on_hit items (seconds)
@export var proc_freeze_duration: float = 1.5
## Duration of poison applied by poison_on_hit items (seconds)
@export var proc_poison_duration: float = 4.0
## Tick interval for poison_on_hit (seconds)
@export var proc_poison_tick_interval: float = 1.0


# =============================================================================
# CHESTS
# =============================================================================

@export_group("Chests")

## Gold cost to open a locked chest on floor 1
@export var chest_locked_base_cost: int = 50
## Gold cost increase per floor for locked chests
@export var chest_locked_cost_per_floor: int = 25
## Number of enemies spawned by mimic chests
@export var chest_mimic_enemy_count: int = 3
## Number of enemies spawned by gilded chest guard wave
@export var chest_gilded_guard_count: int = 4


# =============================================================================
# SET BONUSES
# =============================================================================

@export_group("Set Bonuses - Infernal")

## Bonus damage granted by Infernal 2-piece set
@export var set_infernal_bonus_damage: int = 2
## Bonus burn damage per tick granted by Infernal 2-piece set
@export var set_infernal_bonus_burn_damage: int = 3

@export_group("Set Bonuses - Shadow")

## Bonus crit chance granted by Shadow 2-piece set (0.0 to 1.0)
@export var set_shadow_bonus_crit_chance: float = 0.15
## Bonus heal on kill granted by Shadow 2-piece set
@export var set_shadow_bonus_heal_on_kill: int = 2

@export_group("Set Bonuses - Guardian")

## Bonus defense granted by Guardian 3-piece set
@export var set_guardian_bonus_defense: int = 5
## Bonus max HP granted by Guardian 3-piece set
@export var set_guardian_bonus_max_hp: int = 10
## Thorns damage granted by Guardian 3-piece set
@export var set_guardian_bonus_thorns: float = 1.0


# =============================================================================
# ITEMS - LEGENDARY
# =============================================================================

@export_group("Items - Legendary Weapons")

@export_subgroup("Hellfire Greatsword")
@export var hellfire_greatsword_bonus_damage: int = 8
@export var hellfire_greatsword_bonus_defense: int = 0
@export var hellfire_greatsword_bonus_max_hp: int = 0
@export var hellfire_greatsword_bonus_speed: float = -10.0
@export var hellfire_greatsword_bonus_knockback_force: float = 100.0
@export var hellfire_greatsword_bonus_crit_chance: float = 0.15
@export var hellfire_greatsword_effect_value: float = 5.0
@export var hellfire_greatsword_buy_price: int = 120
@export var hellfire_greatsword_sell_price: int = 45

@export_subgroup("Frostbrand")
@export var frostbrand_bonus_damage: int = 4
@export var frostbrand_bonus_defense: int = 0
@export var frostbrand_bonus_max_hp: int = 0
@export var frostbrand_bonus_speed: float = 0.0
@export var frostbrand_bonus_knockback_force: float = 0.0
@export var frostbrand_bonus_crit_chance: float = 0.05
@export var frostbrand_effect_value: float = 1.5
@export var frostbrand_buy_price: int = 55
@export var frostbrand_sell_price: int = 20

@export_group("Items - Legendary Armor")

@export_subgroup("Aegis of the Undying")
@export var aegis_of_the_undying_bonus_damage: int = 0
@export var aegis_of_the_undying_bonus_defense: int = 6
@export var aegis_of_the_undying_bonus_max_hp: int = 10
@export var aegis_of_the_undying_bonus_speed: float = 0.0
@export var aegis_of_the_undying_bonus_knockback_force: float = 0.0
@export var aegis_of_the_undying_bonus_crit_chance: float = 0.0
@export var aegis_of_the_undying_effect_value: float = 1.0
@export var aegis_of_the_undying_buy_price: int = 130
@export var aegis_of_the_undying_sell_price: int = 50

@export_group("Items - Legendary Rings")

@export_subgroup("Ring of Storms")
@export var ring_of_storms_bonus_damage: int = 5
@export var ring_of_storms_bonus_defense: int = 0
@export var ring_of_storms_bonus_max_hp: int = 0
@export var ring_of_storms_bonus_speed: float = 0.0
@export var ring_of_storms_bonus_knockback_force: float = 0.0
@export var ring_of_storms_bonus_crit_chance: float = 0.3
@export var ring_of_storms_effect_value: float = 3.0
@export var ring_of_storms_buy_price: int = 110
@export var ring_of_storms_sell_price: int = 42

@export_subgroup("Venom Ring")
@export var venom_ring_bonus_damage: int = 0
@export var venom_ring_bonus_defense: int = 1
@export var venom_ring_bonus_max_hp: int = 0
@export var venom_ring_bonus_speed: float = 0.0
@export var venom_ring_bonus_knockback_force: float = 0.0
@export var venom_ring_bonus_crit_chance: float = 0.0
@export var venom_ring_effect_value: float = 2.0
@export var venom_ring_buy_price: int = 30
@export var venom_ring_sell_price: int = 10

@export_group("Items - Legendary Accessories")

@export_subgroup("Bloodthirst Amulet")
@export var bloodthirst_amulet_bonus_damage: int = 4
@export var bloodthirst_amulet_bonus_defense: int = 0
@export var bloodthirst_amulet_bonus_max_hp: int = 0
@export var bloodthirst_amulet_bonus_speed: float = 0.0
@export var bloodthirst_amulet_bonus_knockback_force: float = 0.0
@export var bloodthirst_amulet_bonus_crit_chance: float = 0.0
@export var bloodthirst_amulet_effect_value: float = 0.2
@export var bloodthirst_amulet_buy_price: int = 100
@export var bloodthirst_amulet_sell_price: int = 38

@export_subgroup("Boots of the Wind")
@export var boots_of_the_wind_bonus_damage: int = 0
@export var boots_of_the_wind_bonus_defense: int = 0
@export var boots_of_the_wind_bonus_max_hp: int = 0
@export var boots_of_the_wind_bonus_speed: float = 40.0
@export var boots_of_the_wind_bonus_knockback_force: float = 0.0
@export var boots_of_the_wind_bonus_crit_chance: float = 0.0
@export var boots_of_the_wind_effect_value: float = 0.01
@export var boots_of_the_wind_buy_price: int = 90
@export var boots_of_the_wind_sell_price: int = 35

@export_subgroup("Leech Pendant")
@export var leech_pendant_bonus_damage: int = 2
@export var leech_pendant_bonus_defense: int = 0
@export var leech_pendant_bonus_max_hp: int = 0
@export var leech_pendant_bonus_speed: float = 0.0
@export var leech_pendant_bonus_knockback_force: float = 0.0
@export var leech_pendant_bonus_crit_chance: float = 0.0
@export var leech_pendant_effect_value: float = 2.0
@export var leech_pendant_buy_price: int = 55
@export var leech_pendant_sell_price: int = 20


# =============================================================================
# META-PROGRESSION
# =============================================================================

@export_group("Meta-Progression")

@export_subgroup("Unlock Costs")
## Soul Gem cost to unlock an Uncommon rarity item
@export var unlock_cost_uncommon: int = 50
## Soul Gem cost to unlock a Rare rarity item
@export var unlock_cost_rare: int = 100
## Soul Gem cost to unlock a Legendary rarity item
@export var unlock_cost_legendary: int = 300


# =============================================================================
# HELPER METHODS
# =============================================================================

## Returns the Soul Gem cost to unlock an item of the given ItemData.Rarity.
## COMMON items are always free (cost 0) since they're available without unlocking.
func get_unlock_cost_for_rarity(rarity: int) -> int:
	match rarity:
		1: return unlock_cost_uncommon
		2: return unlock_cost_rare
		3: return unlock_cost_legendary
	return 0

## Returns the item tuning values for a given item_id as a Dictionary.
## Keys: bonus_damage, bonus_defense, bonus_max_hp, bonus_speed,
##       bonus_knockback_force, bonus_crit_chance, effect_value,
##       buy_price, sell_price
func get_item_tuning(item_id: StringName) -> Dictionary:
	var prefix: String = str(item_id).replace("-", "_") + "_"
	var result: Dictionary = {}
	var props: Array[String] = [
		"bonus_damage", "bonus_defense", "bonus_max_hp", "bonus_speed",
		"bonus_knockback_force", "bonus_crit_chance", "effect_value",
		"buy_price", "sell_price",
	]
	for prop: String in props:
		var full_name: String = prefix + prop
		if full_name in self:
			result[prop] = get(full_name)
	return result

## Returns the ability tuning values for a given ability_id as a Dictionary.
func get_ability_tuning(ability_id: StringName) -> Dictionary:
	var prefix: String = "ability_" + str(ability_id).replace("-", "_") + "_"
	var result: Dictionary = {}
	for p: Dictionary in get_property_list():
		var pname: String = p.name as String
		if pname.begins_with(prefix):
			var key: String = pname.substr(prefix.length())
			result[key] = get(pname)
	return result
