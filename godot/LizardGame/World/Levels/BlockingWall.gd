extends StaticBody2D

#childs variables
onready var cAnimatedSprite := $AnimatedSprite
onready var cWallCollision := $WallCollision
onready var cActivationCollision := $Activation/ActivationCollision

#area of the wall
var mMyArea


#########
# READY #
#########
func _ready() -> void:
	#get the parent/parent scene
	mMyArea = get_parent().get_parent()
	
	#connect to the global area activation and freed signals
	# warning-ignore:return_value_discarded
	LzEngine.connect("gAreaActivated", self, "_On_Area_Activation")
	# warning-ignore:return_value_discarded
	LzEngine.connect("gAreaFreed", self, "_On_Area_Freed")


#########################################
# COLLISION WITH THE ACTIVATION AREA 2D #
#########################################
func _on_Activation_body_entered(body) -> void:
	if body.collision_layer == 2 && cActivationCollision.disabled==false:
		#the player activate the wall, set the wall's area on global
		LzEngine.gActiveArea = mMyArea
		
		#LzEngine.gEnemyCount = 5
		#print("5")
		
		#emit the global signal that will activate the area
		LzEngine.emit_signal("gAreaActivated")
		


###################
# AREA ACTIVATION #
###################
func _On_Area_Activation() ->void:
	if mMyArea == LzEngine.gActiveArea:
		#check if the activated area is the wall's area
		#if so, set the collision boxes and turn the wall visible on
		cWallCollision.set_deferred("disabled",  false)
		cActivationCollision.set_deferred("disabled",  true)
		cAnimatedSprite.visible = true


##############
# AREA FREED #
##############
func _On_Area_Freed() -> void:
	if mMyArea == LzEngine.gActiveArea:
		#check if the freed area is the wall's area
		#if so, set the collision boxe and turn the wall visible off
		cWallCollision.set_deferred("disabled",  true)
		cAnimatedSprite.visible = false
