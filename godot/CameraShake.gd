extends Node

#variables
var gCameraShakeIntensity : int = 0
var gCameraShakeDuration : float = 0.0
var gCurrentCamera : Camera2D


##########################
# SET THE CURRENT CAMERA #
##########################
func SetCamera(camera : Camera2D):
	gCurrentCamera = camera


##########################
# SET THE CAMERA TO NULL #
##########################
func SetNull():
	gCurrentCamera = null
	gCameraShakeIntensity = 0
	gCameraShakeDuration = 0.0
	

#########
# SHAKE #
#########
func Shake(intensity, duration):#, type = gShakeType.Random):
	if intensity > gCameraShakeIntensity and duration > gCameraShakeDuration:
		gCameraShakeIntensity = intensity
		gCameraShakeDuration = duration
		#gCameraShakeType = type


###########
# PROCESS #
###########
func _process(delta):
	if gCurrentCamera != null:
		#stop shaking if the duration is equal or below 0
		if gCameraShakeDuration <= 0:
			#reset the current camera and the variables
			gCurrentCamera.offset = Vector2.ZERO
			gCameraShakeIntensity = 0
			gCameraShakeDuration = 0.0
			return
		
		#the duration become shorter
		gCameraShakeDuration = gCameraShakeDuration - delta
		#apply the random offset and the intensity to the current camera
		gCurrentCamera.offset = Vector2(randf(), randf()) * gCameraShakeIntensity
