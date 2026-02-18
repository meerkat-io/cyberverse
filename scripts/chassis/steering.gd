class_name SteeringSmartCar
extends Node2D

signal level_passed

@export var wheels_animation: Array[AnimatedSprite2D] = []

@export var slots: Array[Slot] = []

@export var pre_populate_components: Array[String] = []

var _power := 0.8
var _steering_angle := 0.0
var _current_speed := 0.0

const MAX_SPEED := 500.0
const ACCELERATION := 300.0
const FRICTION := 100.0

func _ready() -> void:
	# For testing, we can pre-populate some components in the chassis.
	# In a real game, you might load this from a save file or start empty.
	for i in range(min(pre_populate_components.size(), slots.size())):
		var component_scene := load(pre_populate_components[i]) as PackedScene
		if component_scene:
			var component_instance := component_scene.instantiate() as Component
			if component_instance:
				_equip_component_to_slot(component_instance, slots[i])
			if component_instance.component_type == Component.ComponentType.BATTERY:
				component_instance.get_node("Animation").play("start")
			if component_instance.component_type == Component.ComponentType.ENGINE:
				component_instance.get_node("Animation").play("forward_run")

func _physics_process(delta: float) -> void:
	_simulate_movement(delta)
	_check_collision()

func set_engine_power(power_ratio: float) -> void:
	_power = clamp(power_ratio, 0.0, 1.0)

func set_steering(angle_rad: float) -> void:
	_steering_angle = angle_rad

func _simulate_movement(delta: float) -> void:
	var target_speed := _power * MAX_SPEED
	
	# Accelerate
	if _current_speed < target_speed:
		_current_speed = min(_current_speed + ACCELERATION * delta, target_speed)
	elif _current_speed > target_speed:
		_current_speed = max(_current_speed - FRICTION * delta, target_speed)
	
	# Apply rotation based on steering and speed
	if not is_zero_approx(_current_speed):
		rotation += _steering_angle * delta
	
	# Move
	var direction := Vector2.UP.rotated(rotation)
	global_position += direction * _current_speed * delta
	
	# Update animations
	for anim in wheels_animation:
		if _current_speed > 10.0:
			# If the speed is high, play the "run" animation.
			# This check ensures we play "run" even if another animation was active.
			if anim.animation != "run" or not anim.is_playing():
				anim.play("run")
		else:
			# If the speed is low, stop the animation.
			if anim.is_playing():
				anim.stop()

func _check_collision() -> void:
	# Simple distance check for trophies since we are Node2D
	var trophies := get_tree().get_nodes_in_group("trophy")
	for trophy in trophies:
		if trophy is Node2D:
			if global_position.distance_to(trophy.global_position) < 64.0:
				level_passed.emit()
				set_engine_power(0.0)
				_current_speed = 0.0
				print("Level Passed!")

func _equip_component_to_slot(component: Component, slot: Slot) -> void:
	# Move component to chassis
	if component.get_parent():
		component.get_parent().remove_child(component)
	
	add_child(component)
	component.global_position = slot.global_position
	
	# Hide the slot to indicate it's filled
	slot.visible = false
