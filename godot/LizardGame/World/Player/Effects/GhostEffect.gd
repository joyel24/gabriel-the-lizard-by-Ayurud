extends Sprite

onready var cTween := $Tween

###########
## READY ##
###########
func _ready() -> void:
	#init and start a tween on the alpha property of the sprite 1 -> 0 to make the ghost "disappear" in 0.5s
	cTween.interpolate_property(self, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_QUART, Tween.EASE_OUT)
	cTween.start()


#################
## TWEEN'S END ##
#################
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_Tween_tween_completed(object, key):
	#free the ghost effect instance from memory when tween is finished
	queue_free()
