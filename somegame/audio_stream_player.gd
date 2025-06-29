extends AudioStreamPlayer
class_name MusicLoop

static var I : MusicLoop

func _ready() -> void:
    if I:
        queue_free()
        return
    I = self
    call_deferred("delayed_play")

func delayed_play():
    reparent(get_tree().root)
    play()
