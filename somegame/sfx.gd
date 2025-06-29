class_name SFX
extends AudioStreamPlayer

static var I : SFX

const BOUNCE : AudioStream = preload("res://sfx/Bounce.wav")
const HEALTH : AudioStream = preload("res://sfx/Health.wav")
const HURT : AudioStream = preload("res://sfx/Hurt.wav")
const JUMP : AudioStream = preload("res://sfx/Jump.wav")
const SLAM : AudioStream = preload("res://sfx/Slam.wav")
const SUPER_BOUNCE : AudioStream = preload("res://sfx/SuperBounce.wav")

func _ready() -> void:
    if I:
        queue_free()
        return
    I = self

static func play_sfx(sfx: AudioStream) -> void:
    I.stop()
    I.stream = sfx
    I.play()
