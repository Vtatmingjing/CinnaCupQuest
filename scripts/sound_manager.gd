extends Node
class_name CinnaSoundManager

const MIX_RATE := 22050

const SFX := {
    "menu": {"freq": 420.0, "duration": 0.07, "shape": "square", "volume": 0.10},
    "start": {"freq": 560.0, "duration": 0.16, "shape": "sine", "volume": 0.14},
    "attack": {"freq": 760.0, "duration": 0.055, "shape": "square", "volume": 0.12},
    "dash": {"freq": 280.0, "duration": 0.11, "shape": "noise", "volume": 0.09},
    "skill": {"freq": 900.0, "duration": 0.18, "shape": "sparkle", "volume": 0.16},
    "pickup": {"freq": 660.0, "duration": 0.11, "shape": "sine", "volume": 0.12},
    "rare": {"freq": 880.0, "duration": 0.22, "shape": "sparkle", "volume": 0.15},
    "recipe": {"freq": 520.0, "duration": 0.30, "shape": "arpeggio", "volume": 0.14},
    "enemy_down": {"freq": 190.0, "duration": 0.12, "shape": "noise", "volume": 0.11},
    "hurt": {"freq": 120.0, "duration": 0.14, "shape": "square", "volume": 0.14},
    "route": {"freq": 480.0, "duration": 0.09, "shape": "sine", "volume": 0.10},
    "victory": {"freq": 640.0, "duration": 0.45, "shape": "arpeggio", "volume": 0.16},
    "defeat": {"freq": 140.0, "duration": 0.38, "shape": "fall", "volume": 0.15}
}

func play_sfx(key: String) -> void:
    if not SFX.has(key):
        return
    var data: Dictionary = SFX[key]
    _play_tone(float(data.get("freq", 440.0)), float(data.get("duration", 0.1)), str(data.get("shape", "sine")), float(data.get("volume", 0.1)))

func _play_tone(freq: float, duration: float, shape: String, volume: float) -> void:
    var stream := AudioStreamGenerator.new()
    stream.mix_rate = MIX_RATE
    stream.buffer_length = maxf(0.05, duration + 0.08)
    var player := AudioStreamPlayer.new()
    player.stream = stream
    player.volume_db = -8.0
    add_child(player)
    player.play()
    var playback := player.get_stream_playback()
    if playback == null:
        player.queue_free()
        return
    var frames := int(MIX_RATE * duration)
    var phase := 0.0
    for i in range(frames):
        var t := float(i) / float(maxi(frames, 1))
        var amp := volume * (1.0 - t)
        var local_freq := freq
        if shape == "fall":
            local_freq = lerpf(freq, freq * 0.45, t)
        elif shape == "arpeggio":
            var step := int(t * 4.0) % 4
            local_freq = freq * [1.0, 1.25, 1.5, 2.0][step]
        elif shape == "sparkle":
            var step2 := int(t * 8.0) % 4
            local_freq = freq * [1.0, 1.33, 1.66, 2.0][step2]
        phase += TAU * local_freq / float(MIX_RATE)
        var sample := 0.0
        match shape:
            "square":
                sample = (1.0 if sin(phase) >= 0.0 else -1.0) * amp
            "noise":
                sample = randf_range(-1.0, 1.0) * amp
            _:
                sample = sin(phase) * amp
        playback.push_frame(Vector2(sample, sample))
    await get_tree().create_timer(duration + 0.12).timeout
    if is_instance_valid(player):
        player.queue_free()
