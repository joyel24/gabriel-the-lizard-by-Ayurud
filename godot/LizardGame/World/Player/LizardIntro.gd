extends KinematicBody2D

#camera
onready var cCamera2D := $Camera2D
onready var cAnimationplayer := $AnimationPlayer

#########
# READY #
#########
func _ready() -> void:
	#mask the ui
	Lzui.visible = false
	
	#set the camera for shaking global script
	CameraShake.SetCamera(cCamera2D)
	
	#start the background animation traveling
	cAnimationplayer.play("ANIM1")

func _on_AnimationPlayer_animation_finished(anim_name):
	#move the screen in the background level
	match anim_name:
		"ANIM1":
			cAnimationplayer.play("ANIM2")
		"ANIM2":
			cAnimationplayer.play("ANIM3")
		"ANIM3":
			cAnimationplayer.play("ANIM1")
	
