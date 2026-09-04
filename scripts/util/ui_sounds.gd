class_name UISounds
extends RefCounted
## Blanket hover/click feedback for menu screens.
##
## Wiring every button by hand across the title screen, shop, inventory, pause
## menu and unlocks screen would mean touching each one on every UI change, so
## screens instead call `attach(self)` once at the end of `_ready` and every
## BaseButton in the subtree gets connected.

## Hover blips sit well under the click so a mouse sweep across a menu is not
## a machine gun.
const HOVER_VOLUME_OFFSET_DB: float = -8.0

## Connects hover and press sounds to every button under `root`, including
## `root` itself. Safe to call more than once — already-wired buttons are
## skipped, so screens that rebuild part of their tree can just call it again.
static func attach(root: Node) -> void:
	if root == null:
		return
	var button: BaseButton = root as BaseButton
	if button:
		attach_button(button)
	for child: Node in root.get_children():
		attach(child)

static func attach_button(button: BaseButton) -> void:
	if button.has_meta(&"ui_sounds_attached"):
		return
	button.set_meta(&"ui_sounds_attached", true)
	button.mouse_entered.connect(play_hover)
	button.pressed.connect(play_click)

static func play_hover() -> void:
	AudioManager.play_sfx_varied(&"ui_hover", 0.97, 1.04, HOVER_VOLUME_OFFSET_DB)

static func play_click() -> void:
	AudioManager.play_sfx(&"ui_click")

## Confirmation cha-ching for shop purchases and other successful spends.
static func play_purchase() -> void:
	AudioManager.play_sfx_varied(&"ui_purchase", 0.98, 1.03)

## Low buzz for a rejected action — can't afford it, nothing selected, etc.
static func play_error() -> void:
	AudioManager.play_sfx(&"ui_error")

## Bright arpeggio for unlocks, floor exits opening, and other rewards.
static func play_chime() -> void:
	AudioManager.play_sfx(&"chime")
