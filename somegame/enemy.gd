extends CharacterBody2D
class_name Enemy


@onready var player: Player = %Player

@export var target: Node2D
@export var acceleration := 4.5
@export var top_speed := 74.0
@export var air_speed_scale := 0.8
@export var min_jump_force := 100.0
@export var max_jump_frames := 6
@export var jump_force_increment := 12.0
@export var brake_scale := 10.0
@export var gravity := 200.0
@export var just_stop_zone := 50

static var enemy_count := 0
static var enemy_killed := 0

var lr_input := 0
var jump_input := 0
var jumping_frames := 0

var current_hp := 2

var starting_position: Vector2

var moving_to_target = true

func _ready():
    starting_position = position
    enemy_count += 1

func _physics_process(delta):

    _handle_inputs()
    var grounded := is_on_floor()
    
    _handle_movement(grounded)
    _apply_gravity(grounded, delta)
    move_and_slide()
    

func _apply_gravity(grounded, delta):
    if grounded: return
    velocity.y += gravity * delta

func _handle_movement(grounded):
    var speed_scale := 1.0 if grounded else air_speed_scale
    
    if lr_input == 0 || lr_input != signf(velocity.x):
        # reduce velocity
        if absf(velocity.x) < just_stop_zone:
            velocity.x = 0
        else:
            velocity.x = clampf(velocity.x + brake_scale * acceleration * -signf(velocity.x) * speed_scale, -top_speed, top_speed)
    
    if lr_input != 0:
        velocity.x = clampf(velocity.x + acceleration * lr_input * speed_scale, -top_speed, top_speed)
    
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
    jumping_frames = 1
    velocity.y = -min_jump_force

func _continue_jump():
    jumping_frames += 1
    velocity.y = velocity.y - jump_force_increment
    if jumping_frames >= max_jump_frames:
        _end_jump()

func _end_jump():
    jumping_frames = 0

func _handle_inputs():
    lr_input = 0
    jump_input = 0
    if not target: return
    
    if moving_to_target:
        if abs(position.x - target.position.x) < 0.5:
            moving_to_target = false
        lr_input = sign(target.position.x - position.x)
    else:
        if abs(position.x - starting_position.x) < 0.5:
            moving_to_target = true
        lr_input = sign(starting_position.x - position.x)
        
        
    
func kill():
    position = starting_position
    velocity = Vector2.ZERO


func _on_area_2d_body_entered(body: Node2D) -> void:
    if body is Player:
        if player.iframe < 0:
            SFX.play_sfx(SFX.BOUNCE)
            player.bump(position, 10)
        else:
            SFX.play_sfx(SFX.SUPER_BOUNCE)
            current_hp -= 1
            player.bump(position, 20)
        player.current_iframe_color = player.hop_color
        current_hp -= 1
        if current_hp <= 0:
            enemy_killed += 1
            queue_free()
    
func _on_hit_box_entered(body: Node2D) -> void:
    if body is Player:
        player.lose_health(position)
