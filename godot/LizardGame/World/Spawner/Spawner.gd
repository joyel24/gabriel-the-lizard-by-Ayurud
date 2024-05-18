extends AnimatedSprite

#the enemy to spawn variable
export(PackedScene) var mEnemy

#childs
onready var cIncomingSound := $Incoming


###########
## READY ##
###########
func _ready():
	#play the spawning sound and animation
	self.play("SPAWNING")
	cIncomingSound.play()


##############################
## SPAWNING ANIMATION'S END ##
##############################
func _on_Spawner_animation_finished():
	#when the animation is ending, add an enemy as a child of the scene (parent)
	var l_enemy : KinematicBody2D = mEnemy.instance()
	l_enemy.global_position = self.global_position
	get_parent().call_deferred("add_child", l_enemy)
	
	#queue free the spawner
	queue_free()
