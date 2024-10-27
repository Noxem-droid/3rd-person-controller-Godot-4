extends CharacterBody3D

@onready var head = $head

@onready var world = load("res://Scènes/world.tscn")

@onready var UI = $"/root/Menu/UI"
@onready var FOV = $head/Camera
extends CharacterBody3D

@onready var head = $head

@onready var world = load("res://Scènes/world.tscn")

@onready var UI = $"/root/Menu/UI"
@onready var FOV = $head/Camera
@onready var raycast = $head/RayCast3D
@onready var Ssound = $Shoot
@onready var label = $CanvasLayer/Ammo
@onready var RewindLabel = $CanvasLayer/Rewind
@onready var crosshair = $CanvasLayer/Crosshair
@onready var canvas = $CanvasLayer
@onready var animation = $AnimationPlayer
@onready var animation2d = $CanvasLayer/AnimatedSprite2D

var play = true


@export var SPEED = 5.0


@export var DIRECTION = 5.0
@export var walk = 6.0
@export var sprinting = 8.0
@export var crouching = 3.0
@export var S_ONAIR = 7.3

@export var JUMP_VELOCITY = 3.5

@export var sensitivity = 0.1
@export var acceleration = 1.07

@export var ammo = 3
@export var MaxAmmo = 6
@export var gravity = 13.5

var canShoot = true
var canreload = true



func _ready(): 
	
	FOV.current = true
	UI.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation2d.animation_finished.connect(shoot_anim_done)
	

func _input(event):
	
	if play:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * sensitivity))
			$head.rotate_x(deg_to_rad((-event.relative.y * sensitivity) * acceleration))
			$head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
	 

	
	
	
func _process(_delta):
	
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit() 
	if play:
		if Input.is_action_pressed("shoot"):
			shoot()
		label.text = str (ammo)
		if Input.is_action_just_pressed("reload"):
			reload()
		if Input.is_action_just_pressed("restart"):
			restart()			
		if rewinding : return		
		if position.y < -4:
			restart()
   func _physics_process(delta):
	if play:
		
		animation.play("idle")
		
		gravity = 13.5
		if raycast.is_colliding() and raycast.get_collider().has_method("kill"):
			crosshair.set_color("red")
		if raycast.is_colliding() and !raycast.get_collider().has_method("kill"):
			crosshair.set_color("ffffff97")
		if !raycast.is_colliding():
			crosshair.set_color("ffffff97")
				
		if Input.is_action_pressed("Sprinting"):
			SPEED = sprinting
	

		
		else:
			SPEED = walk
		
		if is_on_floor():
			gravity = 13.5
		
	
	# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta
			gravity = 13.5
			SPEED = S_ONAIR
		
			 
		
			

	# Handle jump.
		while Input.is_action_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY	
			break

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
		var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction :
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()func restart():

	get_tree().change_scene_to_file("res://Scènes/menu.tscn")
		

func shoot():
	
	if ammo <= 0:
		return
	if !play:
		return
	if !canShoot:
		return
	canShoot = false
	canreload = false
	animation2d.play("shoot")
	Ssound.play()
	if raycast.is_colliding() and raycast.get_collider().has_method("kill"):
		raycast.get_collider().kill()
	ammo = ammo - 1	
		
func shoot_anim_done():
	
	canShoot = true
	canreload = true
	
func reload():
	
	if !canreload: return
	if ammo < MaxAmmo:
		ammo = ammo + 1
		canShoot = false
		animation2d.play("reload")
	
