extends KinematicBody2D

export var limit_left=0
export var limit_right = 100000
export var limit_up = -100000
export var limit_down = 100000

const WALK_SPEED = 350
const GRAVITY = 2500;
const JUMP_FORCE = 950;
const TERMINAL_VELOCITY = 20
const MAX_JUMPS = 1

enum State{IDLE, WALKING, DYING}

onready var sprite = get_node("sprite")
onready var sfx = get_node("sfx")

var current_state
var previous_state
var next_state

var velocity = Vector2()
var jump_count=0
var airborn_time=0
var is_dead = false
var is_moving_left
var is_moving_right

var health = 3 setget set_health,get_health

var current_anim
var next_anim


func get_health():
	return health

func set_health(value):
	health=value


func _ready():
	set_process(true)
	set_process_input(true)
	set_fixed_process(true)
	current_state = State.IDLE
	
func do_idle_state(delta):
	velocity.x=0
	next_anim="idle"
	
	
func do_walking_state(delta):
	if !is_dead:
		next_anim="running"
		
		if is_moving_left:
			velocity.x = -WALK_SPEED
			sprite.set_flip_h(true)
		elif is_moving_right:
			velocity.x = WALK_SPEED
			sprite.set_flip_h(false)

func do_dying_state(delta):
#	if is_dead:
#		return
#	is_dead = true
#	anim.stop_all()
#	anim.play("death")
#	sfx.play("player_death")	
#	next_anim="dying"
	pass

func _input(event):
	if is_dead:
		return
	if Input.is_action_pressed("ui_left"):
		is_moving_left = true
		is_moving_right = false
		next_state = State.WALKING
	elif Input.is_action_pressed("ui_right"):
		is_moving_left = false
		is_moving_right = true
		next_state = State.WALKING
	else:
		is_moving_left = false
		is_moving_right = false
		next_state = State.IDLE

	if event.is_action_pressed("ui_up") and jump_count < MAX_JUMPS:
		jump()

	
		
func jump():
	velocity.y=-JUMP_FORCE
	jump_count += 1
	sfx.play("jump")
	
func shoot():
	next_anim = next_anim+"_firing"
	if !sfx.is_active():
		sfx.play("shoot")
	
func _fixed_process(delta):
		
	previous_state = current_state
	current_state = next_state	
	
	if current_state == State.WALKING:
		do_walking_state(delta)
	elif current_state == State.DYING:
		do_dying_state(delta)
	else:
		do_idle_state(delta)
		
	if health <= 0:
		next_state = State.DYING
		
	velocity.y += delta * GRAVITY
	
	var motion = velocity * delta
	if motion.y>TERMINAL_VELOCITY:
		motion.y=TERMINAL_VELOCITY
	
	motion = move(motion)
	
	var found_floor=false
	if is_colliding():
		var floor_velocity = Vector2()
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		
		if n == Vector2(0,-1):
			found_floor = true
			floor_velocity = get_collider_velocity()
			jump_count = 0
			
		if floor_velocity != Vector2():
			motion += floor_velocity * delta

		move(motion)
	
	if found_floor:
		airborn_time = 0
	else:
		airborn_time += delta;
		
	if airborn_time > .1: 
		next_anim = "air"
		
	#shoot() is here so we can limit it to a fixed interval
	if Input.is_action_pressed("ui_accept"):
		shoot()
		
	if current_anim != next_anim:
		current_anim = next_anim
		sprite.play(current_anim)
		
	constrain_pos()
		
func constrain_pos():
	var pos = get_pos()
	if pos.x < limit_left:
		pos.x = limit_left
		set_pos(pos)
	if pos.x > limit_right:
		pos.x = limit_right
		set_pos(pos)
	if pos.y < limit_up:
		pos.y = limit_up
		set_pos(pos)
	if pos.y > limit_down:
		pos.y = limit_down
		set_pos(pos)

