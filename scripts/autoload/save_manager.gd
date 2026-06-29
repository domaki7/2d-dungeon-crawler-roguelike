extends Node

const SAVE_PATH: String = "user://save_data.json"
const SAVE_VERSION: int = 1

var meta_currency: int = 0
var unlocked_items: Array[StringName] = []
var unlocked_abilities: Array[StringName] = []
var lifetime_stats: Dictionary = {
	"total_runs": 0,
	"best_floor": 0,
	"total_kills": 0,
	"total_gold_earned": 0,
}
var settings: Dictionary = {
	"sfx_volume_db": -5.0,
	"music_volume_db": -10.0,
	"fullscreen": false,
	"screen_shake_enabled": true,
}

func _ready() -> void:
	load_data()
	_apply_settings()

func save() -> void:
	var data: Dictionary = {
		"version": SAVE_VERSION,
		"meta_currency": meta_currency,
		"unlocked_items": _string_name_array_to_strings(unlocked_items),
		"unlocked_abilities": _string_name_array_to_strings(unlocked_abilities),
		"lifetime_stats": lifetime_stats,
		"settings": settings,
	}
	var json_string: String = JSON.stringify(data, "\t")
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var json_string: String = file.get_as_text()
	file.close()
	var data: Variant = JSON.parse_string(json_string)
	if data is Dictionary:
		_apply_save_data(data as Dictionary)

func add_meta_currency(amount: int) -> void:
	meta_currency += amount
	EventBus.meta_currency_gained.emit(amount)

func get_meta_currency() -> int:
	return meta_currency

func spend_meta_currency(amount: int) -> bool:
	if meta_currency < amount:
		return false
	meta_currency -= amount
	return true

func is_unlocked(unlock_id: StringName) -> bool:
	return unlock_id in unlocked_items or unlock_id in unlocked_abilities

func unlock_item(unlock_id: StringName) -> void:
	if unlock_id not in unlocked_items:
		unlocked_items.append(unlock_id)

func unlock_ability(unlock_id: StringName) -> void:
	if unlock_id not in unlocked_abilities:
		unlocked_abilities.append(unlock_id)

func update_lifetime_stats(run_stats: Dictionary) -> void:
	lifetime_stats.total_runs = lifetime_stats.get("total_runs", 0) + 1
	lifetime_stats.total_kills = lifetime_stats.get("total_kills", 0) + run_stats.get("kills", 0)
	lifetime_stats.total_gold_earned = lifetime_stats.get("total_gold_earned", 0) + run_stats.get("gold_earned", 0)
	var floors_cleared: int = run_stats.get("floors_cleared", 0)
	if floors_cleared > lifetime_stats.get("best_floor", 0):
		lifetime_stats.best_floor = floors_cleared

func get_setting(key: String, default_value: Variant = null) -> Variant:
	return settings.get(key, default_value)

func set_setting(key: String, value: Variant) -> void:
	settings[key] = value
	save()

func _apply_settings() -> void:
	var sfx_db: float = settings.get("sfx_volume_db", -5.0) as float
	var music_db: float = settings.get("music_volume_db", -10.0) as float
	GameConfig.config.audio_sfx_volume_db = sfx_db
	GameConfig.config.audio_music_volume_db = music_db
	var fullscreen: bool = settings.get("fullscreen", false) as bool
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _apply_save_data(data: Dictionary) -> void:
	meta_currency = data.get("meta_currency", 0) as int
	var items_raw: Array = data.get("unlocked_items", []) as Array
	unlocked_items.clear()
	for item_id: Variant in items_raw:
		unlocked_items.append(StringName(str(item_id)))
	var abilities_raw: Array = data.get("unlocked_abilities", []) as Array
	unlocked_abilities.clear()
	for ability_id: Variant in abilities_raw:
		unlocked_abilities.append(StringName(str(ability_id)))
	var stats_raw: Variant = data.get("lifetime_stats", {})
	if stats_raw is Dictionary:
		lifetime_stats = stats_raw as Dictionary
	var settings_raw: Variant = data.get("settings", {})
	if settings_raw is Dictionary:
		for key: String in (settings_raw as Dictionary).keys():
			settings[key] = (settings_raw as Dictionary)[key]

func _string_name_array_to_strings(arr: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for sn: StringName in arr:
		result.append(String(sn))
	return result
