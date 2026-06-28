class_name KnockbackComponent
extends Node

var friction: float = 800.0

var knockback_velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, friction * delta)

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction.normalized() * force
