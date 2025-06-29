class_name Player
extends CharacterBody2D
@onready var hp_label: Label = %HP
@onready var sprite: Sprite2D = $Sprite2D

@export var acceleration := 4.5
@export var top_speed := 74.0
@export var air_speed_scale := 0.8
@export var min_jump_force := 100.0
@export var max_jump_frames := 6
@export var jump_force_increment := 12.0
@export var brake_scale := 10.0
@export var gravity := 200.0
@export var just_stop_zone := 50

@export var normal_color : Color
@export var hurt_color : Color
@export var hop_color : Color
@export var slam_color : Color

var current_iframe_color : Color

var lr_input := 0
var jump_input := 0
var jumping_frames := 0
var iframe := 0.0

var current_hp := 3

const kill_plane := 500

var starting_position: Vector2

func _ready():
    starting_position = position
    current_iframe_color = hurt_color


func _physics_process(delta):
    hp_label.text = "HP: %s" %current_hp
    iframe -= delta
    check_kill_plane()
    handle_hit_display()
    var grounded := is_on_floor()
    _handle_inputs(grounded)
    
    if lr_input == -1:
        sprite.scale = Vector2(-1, 1)
    if lr_input == 1:
        sprite.scale = Vector2(1, 1)
    
    _handle_jumping(grounded)
    _handle_movement(grounded)
    _apply_gravity(grounded, delta)
    move_and_slide()
    

func _apply_gravity(grounded, delta):
    if grounded: return
    velocity.y += gravity * delta

func _handle_movement(grounded):
    var temp_top_speed = top_speed if iframe <= 0 else 999999
    var speed_scale := 1.0 if grounded else air_speed_scale
    
    if lr_input == 0 || lr_input != signf(velocity.x):
        # reduce velocity
        if absf(velocity.x) < just_stop_zone:
            velocity.x = 0
        else:
            velocity.x = clampf(velocity.x + brake_scale * acceleration * -signf(velocity.x) * speed_scale, -temp_top_speed, temp_top_speed)
    
    if lr_input != 0:
        velocity.x = clampf(velocity.x + acceleration * lr_input * speed_scale, -temp_top_speed, temp_top_speed)
    
func _handle_jumping(grounded):
    if grounded:
        if jump_input > 0:
            _start_jump()

    else:
        if _is_jumping():
            if jump_input > 0:
                _continue_jump()
            else:
                _end_jump()

func _is_jumping():
    return jumping_frames > 0

func _start_jump():
    SFX.play_sfx(SFX.JUMP)
    jumping_frames = 1
    velocity.y = -min_jump_force

func _continue_jump():
    jumping_frames += 1
    velocity.y = velocity.y - jump_force_increment
    if jumping_frames >= max_jump_frames:
        _end_jump()

func _end_jump():
    jumping_frames = 0

func _handle_inputs(grounded: bool):
    lr_input = 0
    jump_input = 0
    if Input.is_action_just_pressed("jump"):
        jump_input = 1
    
    if Input.is_action_pressed("left"):
        lr_input = lr_input - 1
    
    if Input.is_action_pressed("right"):
        lr_input = lr_input + 1
    if Input.is_action_just_pressed("action") && !grounded:
        SFX.play_sfx(SFX.SLAM)
        velocity = Vector2(0,120)
        current_iframe_color = slam_color
        iframe = 0.25
        current_hp -= 1
        if current_hp <= 0:
            kill()
    if Input.is_action_just_pressed("reset"):
        kill()
        
        
func kill():
    Enemy.enemy_count = 0
    Enemy.enemy_killed = 0
    call_deferred("reset")

func reset():
    get_tree().change_scene_to_file("res://world.tscn")
    
func lose_health(pos):
    if iframe > 0: return
    SFX.play_sfx(SFX.HURT)
    current_iframe_color = hurt_color
    current_hp -= 1
    if current_hp <= 0:
        kill()
    else:
        bump(pos,40)

func bump(source, power):
    iframe = 0.5
    var diff = source - position
    velocity = -diff * power
    
func check_kill_plane():
    if position.y > kill_plane:
        kill()

func handle_hit_display():
    if iframe >= 0:
        sprite.modulate = current_iframe_color
    else:
        sprite.modulate = normal_color
        
