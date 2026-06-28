extends Node

## Centralized game configuration singleton.
## Access via: GameConfig.config.<property_name>
## Example: GameConfig.config.player_base_damage

var config: GameConfigData = preload("res://resources/config/game_config.tres")

func _ready() -> void:
	_apply_item_tuning()
	_apply_ability_tuning()

func _apply_item_tuning() -> void:
	var dirs: Array[String] = ["weapons", "armor", "rings", "accessories", "consumables"]
	for dir: String in dirs:
		var base_path: String = "res://resources/items/%s/" % dir
		var da: DirAccess = DirAccess.open(base_path)
		if da == null:
			continue
		da.list_dir_begin()
		var file_name: String = da.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var item: ItemData = load(base_path + file_name) as ItemData
				if item:
					_apply_single_item_tuning(item)
			file_name = da.get_next()

func _apply_single_item_tuning(item: ItemData) -> void:
	var tuning: Dictionary = config.get_item_tuning(item.item_id)
	if tuning.is_empty():
		return
	if tuning.has("bonus_damage"):
		item.bonus_damage = tuning["bonus_damage"]
	if tuning.has("bonus_defense"):
		item.bonus_defense = tuning["bonus_defense"]
	if tuning.has("bonus_max_hp"):
		item.bonus_max_hp = tuning["bonus_max_hp"]
	if tuning.has("bonus_speed"):
		item.bonus_speed = tuning["bonus_speed"]
	if tuning.has("bonus_knockback_force"):
		item.bonus_knockback_force = tuning["bonus_knockback_force"]
	if tuning.has("bonus_crit_chance"):
		item.bonus_crit_chance = tuning["bonus_crit_chance"]
	if tuning.has("effect_value"):
		item.effect_value = tuning["effect_value"]
	if tuning.has("buy_price"):
		item.buy_price = tuning["buy_price"]
	if tuning.has("sell_price"):
		item.sell_price = tuning["sell_price"]

func _apply_ability_tuning() -> void:
	var base_path: String = "res://resources/abilities/"
	var da: DirAccess = DirAccess.open(base_path)
	if da == null:
		return
	da.list_dir_begin()
	var file_name: String = da.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var ability: AbilityData = load(base_path + file_name) as AbilityData
			if ability:
				_apply_single_ability_tuning(ability)
		file_name = da.get_next()

func _apply_single_ability_tuning(ability: AbilityData) -> void:
	var tuning: Dictionary = config.get_ability_tuning(ability.ability_id)
	if tuning.is_empty():
		return
	if tuning.has("cooldown"):
		ability.cooldown = tuning["cooldown"]
	if tuning.has("damage"):
		ability.damage = tuning["damage"]
	if tuning.has("knockback_force"):
		ability.knockback_force = tuning["knockback_force"]
	if tuning.has("dash_speed"):
		ability.dash_speed = tuning["dash_speed"]
	if tuning.has("dash_duration"):
		ability.dash_duration = tuning["dash_duration"]
	if tuning.has("stun_duration"):
		ability.stun_duration = tuning["stun_duration"]
	if tuning.has("aoe_radius"):
		ability.aoe_radius = tuning["aoe_radius"]
	if tuning.has("buff_duration"):
		ability.buff_duration = tuning["buff_duration"]
	if tuning.has("damage_multiplier"):
		ability.damage_multiplier = tuning["damage_multiplier"]
	if tuning.has("arrow_count"):
		ability.arrow_count = tuning["arrow_count"]
	if tuning.has("spread_angle"):
		ability.spread_angle_degrees = tuning["spread_angle"]
	if tuning.has("rain_delay"):
		ability.rain_delay = tuning["rain_delay"]
	if tuning.has("rain_duration"):
		ability.rain_duration = tuning["rain_duration"]
