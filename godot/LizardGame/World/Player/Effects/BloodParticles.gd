extends CPUParticles2D

#childs
onready var cTween := $Tween
onready var cDisapearTimer = $DisapearTimer

################################
## STOP PROCESSING TIMER ENDS ##
################################
func _on_StopProcessingTimer_timeout() -> void:
	#completely stops processing the particles when the timer is out
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	#start the disapear timer
	cDisapearTimer.start(20.0)


#################
## TWEEN'S END ##
#################
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_Tween_tween_completed(object, key):
	#free the blood effect instance from memory when tween is finished
	queue_free()


##########################
## DISAPEAR TIMER'S END ##
##########################
func _on_DisapearTimer_timeout():
	#init and start a tween on the alpha property of the particles 1 -> 0 to make it "disappear" in 0.5s
	cTween.interpolate_property(self, "modulate:a", 1.0, 0.0, 10.0, Tween.TRANS_SINE, Tween.EASE_IN)
	cTween.start()
