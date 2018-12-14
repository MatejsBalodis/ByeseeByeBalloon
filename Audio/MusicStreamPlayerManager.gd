extends AudioStreamPlayer

export var make_quiet_on_ready = false # To fix the issue, when game starts and volume is being managed weirdly.

onready var original_volume_db = self.volume_db # To know, where to lerp the volume back.

const NON_AUDIBLE_VOLUME_DB = -80.0 # Consider this volume to be non audible.

func _ready():
	if make_quiet_on_ready:
		volume_db = NON_AUDIBLE_VOLUME_DB

func _process(delta):
	var level_transition = Global.level_transition # For speed and convenience.
	if level_transition != null && level_transition.current_transition_is_in_progress:
		volume_db = lerp(NON_AUDIBLE_VOLUME_DB, original_volume_db, level_transition.lerp_progress)
