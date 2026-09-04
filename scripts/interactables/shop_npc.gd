class_name ShopNPC
extends StaticBody2D

@export var shop_items: Array[ItemData] = []
@export var available_items: Array[ItemData] = []
@export var random_item_count: int = 3

var _player_nearby: bool = false
var _player_ref: CharacterBody2D = null

@onready var _interact_label: Label = $InteractLabel
@onready var _interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	_interact_label.visible = false
	_interaction_area.body_entered.connect(_on_body_entered)
	_interaction_area.body_exited.connect(_on_body_exited)
	if shop_items.is_empty() and not available_items.is_empty():
		_generate_random_shop()
	_filter_locked_items()
	_stock_consumables()

## Every shop carries potions on top of its rolled equipment. Healing is the
## one thing a run always needs, so it is never left to the random roll.
func _stock_consumables() -> void:
	var extra_count: int = GameConfig.config.shop_consumable_stock_count
	if extra_count <= 0:
		return
	# Exported arrays can carry over between instantiations; never double-stock.
	if ConsumablePool.HEALTH_POTION in shop_items:
		return
	shop_items.append(ConsumablePool.HEALTH_POTION)
	var others: Array[ItemData] = ConsumablePool.all()
	others.erase(ConsumablePool.HEALTH_POTION)
	others.shuffle()
	for i: int in range(mini(extra_count - 1, others.size())):
		shop_items.append(others[i])

func _generate_random_shop() -> void:
	var pool: Array[ItemData] = _filter_unlocked(available_items)
	pool.shuffle()
	for i: int in range(mini(random_item_count, pool.size())):
		shop_items.append(pool[i])

func _filter_locked_items() -> void:
	shop_items = _filter_unlocked(shop_items)

func _filter_unlocked(items: Array[ItemData]) -> Array[ItemData]:
	var result: Array[ItemData] = []
	for item: ItemData in items:
		if item.rarity == ItemData.Rarity.COMMON or SaveManager.is_unlocked(item.item_id):
			result.append(item)
	return result

func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby and event.is_action_pressed(&"interact"):
		EventBus.shop_opened.emit(shop_items)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_player_nearby = true
		_player_ref = body as CharacterBody2D
		_interact_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_player_nearby = false
		_player_ref = null
		_interact_label.visible = false
