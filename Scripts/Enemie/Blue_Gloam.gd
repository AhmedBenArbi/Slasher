extends CharacterBody2D

@export var player : CharacterBody2D
@export var SPEED : int = 10
@export var CHACE_SPEED: int = 30
@export var ACCELERATION : int = 50
@onready var stop_hurt: Timer = $StopHurt
@onready var dead_timer: Timer = $Dead
@onready var attack_cd: Timer = $AttackCD



@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $AnimatedSprite2D/RayCast2D
@onready var timer = $Timer

var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : Vector2
var right_bounds : Vector2
var left_bounds : Vector2
var enemyhp = 300
var dead = false
var agro : bool = false

enum State {
	WANDER,
	CHASE,
	Dead,
	Hurt,
	Hit,
	Idle
}

var current_state = State.WANDER

func _ready():
	
	left_bounds = self.position + Vector2(-125, 0)
	right_bounds = self.position + Vector2(125, 0)

	direction = Vector2(1, 0)
	sprite.flip_h = false
	ray_cast.target_position = Vector2(125, 0)

func _physics_process(delta: float):
	animation()
	if current_state != State.Dead and dead != true:
		handle_garvity(delta)
		handle_movement(delta)
		change_direction(delta)
		look_for_player()
	move_and_slide()
	




func look_for_player():
	#print("look_for_player")
	if ray_cast.is_colliding() and current_state != State.Hit and !agro :
		var collider = ray_cast.get_collider()
		if collider == player:
			chase_player()
		elif current_state == State.CHASE:
			stop_chase()
	elif current_state == State.CHASE:
		stop_chase()

func chase_player() -> void:
	#print("chase_player")
	timer.stop()
	sprite.speed_scale = 1
	if current_state != State.Hurt and timer.is_stopped() and current_state != State.Hit and !agro:
		current_state = State.CHASE

func stop_chase() -> void:
	#print("stop_chase")
	if timer.time_left <= 0 and current_state != State.Hit:
		sprite.speed_scale = 1
		timer.start()

func handle_movement(delta : float) -> void:
	#print("handle_movement")
	if current_state == State.WANDER and current_state != State.Hit :
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(direction * CHACE_SPEED, ACCELERATION * delta)
	
	move_and_slide()

func change_direction(delta) -> void:
	#print("change_direction")
	if current_state == State.WANDER and current_state != State.Hurt and current_state != State.Hit and !agro :
		if not sprite.flip_h:
			# Moving right
			if self.position.x <= right_bounds.x:
				direction = Vector2(1, 0)
			else:
				# Turn and move left
				sprite.flip_h = true
				direction = Vector2(-1, 0)
				ray_cast.target_position = Vector2(-125, 0)

		else:
			# Moving left
			if self.position.x >= left_bounds.x:
				direction = Vector2(-1, 0)
			else:
				# Turn and move right
				sprite.flip_h = false
				direction = Vector2(1, 0)
				ray_cast.target_position = Vector2(125, 0)

	else:
		# Chase state - follow player
		direction = (player.position - self.position).normalized()

		if direction.x > 0:
			# Moving right
			sprite.flip_h = false
			ray_cast.target_position = Vector2(125, 0)
		else:
			# Moving left
			sprite.flip_h = true
			ray_cast.target_position = Vector2(-125, 0)
			
			
func handle_garvity(delta : float) -> void:
	#print("handle_gravity")
	if not is_on_floor():
		velocity.y += gravity * delta

func animation():
	#print("animation")
	if current_state == State.WANDER and current_state != State.Hit:
		sprite.play("Walk")
	elif current_state == State.Hurt and current_state != State.Hit:
		sprite.play("Hurt")
	elif current_state == State.CHASE and current_state != State.Hit:
		sprite.play("Run")
	elif current_state == State.Dead and current_state != State.Hit:
		sprite.play("Dead")
	elif current_state == State.Hit:
		velocity.x = 0
		sprite.play("Hit")
	elif current_state == State.Idle:
		sprite.play("Idle")

func _on_timer_timeout() -> void:
	#print("timer_timeout")
	if  current_state != State.Hit:
		current_state = State.WANDER


func _on_hurt_box_area_entered(area: Area2D) -> void:
	#print("hurt_box_aera")
	if enemyhp > 25 and dead == false:
		velocity.x = 0
		enemyhp -= Global.Player_Damge
		if current_state != State.WANDER or stop_hurt.is_stopped():
			current_state = State.Hurt
			stop_hurt.start()
	else: 
			dead_timer.start()
			velocity.x = 0
			current_state = State.Dead
			dead = true
			sprite.speed_scale = 1
			print("died")

func _on_stop_hurt_timeout() -> void:
	if dead != true:
		#print("stop_hurt")
		current_state = State.WANDER


func _on_dead_timeout() -> void:
	#print("dead_time_out")
	queue_free()


func _on_hit_box_area_entered(area: Area2D) -> void:
	velocity.x = 0
	agro = true 
	sprite.speed_scale = 1
	current_state = State.Hit
		





func _on_start_hit_timeout() -> void:
	pass # Replace with function body.


func _on_hit_box_area_exited(area: Area2D) -> void:
	agro = false
	current_state = State.WANDER
