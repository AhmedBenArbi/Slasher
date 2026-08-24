extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var vfx_animated_sprite: AnimatedSprite2D = $VFX_Animated_Sprite
@onready var hit_box_collision_shape_right: CollisionShape2D = $HitBox/Hit_Box_CollisionShape_Right
@onready var hitbox: Node2D = $Hitbox
@onready var hit_box_collision_shape_left: CollisionShape2D = $HitBox/Hit_Box_CollisionShape_Left
@onready var timer: Timer = $Timer
@onready var damage_cd: Timer = $DamageCD


const  GRAVITY = 1000
var can_flip  = true
var speed = 200
var jump = 150
enum State {Idle,Walk,Hit,Jump}
var current_state : State
var Player_Hp = 200
var taking_damage = false
func _ready() -> void:
	hit_box_collision_shape_right.disabled = true
	hit_box_collision_shape_left.disabled = true
	current_state = State.Idle


func _physics_process(delta: float) -> void:
	print(Player_Hp)
	#print(current_state)
	Hit(delta)
	idle(delta)
	Walk(delta)
	Jump(delta)
	falling(delta)
	move_and_slide()
	animation()
	hande_damage()


func idle(delta):
	if is_on_floor() and current_state != State.Hit:
		current_state = State.Idle
		


func falling(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta


func Walk(delta):
	var direction = Input.get_axis("move_left","move_right")
	if direction and is_on_floor() and current_state != State.Hit:
		current_state = State.Walk
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	if direction < 0 and current_state != State.Hit:
		animated_sprite_2d.flip_h = true
	elif direction > 0 and current_state != State.Hit:
		animated_sprite_2d.flip_h = false


func Jump(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += -300
		current_state = State.Jump
	
	if !is_on_floor() and current_state == State.Jump:
		var direction = Input.get_axis("move_left","move_right")
		velocity.x += direction * jump 


func animation():
	if current_state == State.Idle:
		animated_sprite_2d.play("Idle")
	elif current_state == State.Walk:
		animated_sprite_2d.play("Walk")
	elif  current_state == State.Jump:
		animated_sprite_2d.play("Jump")
	elif current_state == State.Hit:
		animated_sprite_2d.play("Hit")
	else:
		animated_sprite_2d.play("Idle")
		current_state = State.Idle


func Hit(delta):
	var direction = Input.get_axis("move_left","move_right")
	if Input.is_action_just_pressed("hit") and timer.is_stopped():
		if direction < 0 :
			hit_box_collision_shape_left.disabled = false
		elif direction > 0:
			hit_box_collision_shape_right.disabled = false
		else:
			if animated_sprite_2d.flip_h == true : 
				hit_box_collision_shape_left.disabled = false
			else: 
				hit_box_collision_shape_right.disabled = false
		current_state = State.Hit
		print(current_state)
		timer.start()


func _on_timer_timeout() -> void:
	current_state = State.Idle
	hit_box_collision_shape_right.disabled = true
	hit_box_collision_shape_left.disabled = true


func _on_hurt_box_area_entered(area: Area2D) -> void:
	taking_damage = true
		
func _on_hurt_box_area_exited(area: Area2D) -> void:
	taking_damage = false

func hande_damage():
	if taking_damage and damage_cd.is_stopped():
		if Player_Hp > 0:
			Player_Hp -= Global.melee_enemie_skelaton_damge
			damage_cd.start()
