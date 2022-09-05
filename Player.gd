extends KinematicBody2D


export(int) var JUMP_VELOCITY = 120
export(int) var JUMP_RELEASE_VELOCITY = 60
export(int) var ACCELERATION = 150
export(float) var ACCELERATION_DAMPING = 0.15
export(int) var GRAVITY = 400
export(int) var EXTRA_GRAVITY = 150

var velocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	if input.x != 0:
		velocity.x += ACCELERATION * delta * input.x
		velocity.x *= pow(1-ACCELERATION_DAMPING, delta*10)
		
	if input.x == 0:
		velocity.x = 0
		
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = -JUMP_VELOCITY
		
	if not is_on_floor():
		if Input.is_action_just_released("ui_up") and velocity.y < -JUMP_RELEASE_VELOCITY:
			velocity.y = -JUMP_RELEASE_VELOCITY
		velocity.y += GRAVITY * delta
		if velocity.y > 0:
			velocity.y += EXTRA_GRAVITY * delta
	
	if is_on_floor():
		velocity.y == 0
		
	velocity = move_and_slide(velocity, Vector2.UP)
		
