extends Node

var music_volume: float = 0.8  
var sfx_volume: float = 0.8    

const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

const CONFIG_PATH = "user://settings.cfg"

func _ready():
	load_settings()
	apply_audio_settings()

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	apply_audio_settings()
	save_settings()

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	apply_audio_settings()
	save_settings()

func apply_audio_settings():
	var music_db = linear_to_db(music_volume) if music_volume > 0.0 else -80.0
	var sfx_db = linear_to_db(sfx_volume) if sfx_volume > 0.0 else -80.0
	
	var music_bus_idx = AudioServer.get_bus_index(MUSIC_BUS)
	if music_bus_idx == -1:
		AudioServer.add_bus()
		music_bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(music_bus_idx, MUSIC_BUS)
	
	var sfx_bus_idx = AudioServer.get_bus_index(SFX_BUS)
	if sfx_bus_idx == -1:
		AudioServer.add_bus()
		sfx_bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(sfx_bus_idx, SFX_BUS)
	
	AudioServer.set_bus_volume_db(music_bus_idx, music_db)
	AudioServer.set_bus_volume_db(sfx_bus_idx, sfx_db)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	
	var error = config.save(CONFIG_PATH)
	if error != OK:
		push_error("Failed to save settings: " + str(error))

func load_settings():
	var config = ConfigFile.new()
	var error = config.load(CONFIG_PATH)
	
	if error != OK:
		return
	
	music_volume = config.get_value("audio", "music_volume", 0.8)
	sfx_volume = config.get_value("audio", "sfx_volume", 0.8)

func linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)
