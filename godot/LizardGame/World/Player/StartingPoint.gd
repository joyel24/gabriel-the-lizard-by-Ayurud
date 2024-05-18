extends Position2D

export(PackedScene) var mPlayerToAdd
onready var cWaitTimer := $WaitTimer


####################
# WAIT TIMER'S END #
####################
func _on_WaitTimer_timeout():
	#Stop the timer
	cWaitTimer.stop()
	
	#instance and add the player
	var l_player_to_add : KinematicBody2D = mPlayerToAdd.instance()
	l_player_to_add.global_position = self.global_position
	get_parent().get_parent().add_child(l_player_to_add)
	
	#spawnpoint queuefree
	queue_free()
