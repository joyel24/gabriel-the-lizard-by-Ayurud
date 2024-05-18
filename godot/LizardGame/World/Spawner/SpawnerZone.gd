extends ColorRect

#the spawner scene variable
export(PackedScene) var mSpawner

#area of the spawning zone
var mMyArea

#scene to add 
var mMazeScene

#variable to know if the spawning zone has release the spawners on area activation
var mActivated : bool = false


###########
## READY ##
###########
func _ready():
	#get the parent/parent scene
	mMyArea = get_parent().get_parent()
	mMazeScene = mMyArea.get_parent()
	
	#hide the rectangle
	self.hide()
	
	#connect to the global area activation signal
	# warning-ignore:return_value_discarded
	LzEngine.connect("gAreaActivated", self, "_On_Area_Activation")


###################
# AREA ACTIVATION #
###################
func _On_Area_Activation() -> void:
	if mMyArea == LzEngine.gActiveArea && mActivated == false :
		#check if the activated area is the spawningzone's area
		#if so, set activate and spawn the spawners
		mActivated = true
		
		var random = RandomNumberGenerator.new()
		random.randomize()
		randomize()
		
		var l_max_enemy_to_spawn : int
		#if LzEngine.gDifficulty <= 5:
		#	l_max_enemy_to_spawn = 1 + randi() %2
		#else:
		#	l_max_enemy_to_spawn = 2 + randi() %2
		match LzEngine.gDifficulty:
			1:
				l_max_enemy_to_spawn = 1 #2
			2:
				l_max_enemy_to_spawn = 1 #2
			3:
				l_max_enemy_to_spawn = 1 + randi() %2 #0-1 + 1 => 1-2 per spawner * 2 = 2 to 4
			4:
				l_max_enemy_to_spawn = 1 + randi() %2 #0-1 + 1 => 1-2 per spawner * 2 = 2 to 4
			5:
				l_max_enemy_to_spawn = 1 + randi() %3 #0-2 + 1 => 1-3 per spawner * 2 = 2 to 6
			6:
				l_max_enemy_to_spawn = 1 + randi() %3 #0-2 + 1 => 1-3 per spawner * 2 = 2 to 6
			7:
				l_max_enemy_to_spawn = 2 + randi() %2 #0-1 + 2 => 2-3 per spawner * 2 = 4 to 6
			8:
				l_max_enemy_to_spawn = 2 + randi() %2 #0-1 + 2 => 2-3 per spawner * 2 = 4 to 6
			9:
				l_max_enemy_to_spawn = 3 #6
			10:
				l_max_enemy_to_spawn = 3 #6
		
		
		
		
		var l_spawner : AnimatedSprite
		for i in l_max_enemy_to_spawn:
			l_spawner = mSpawner.instance()
			#random position within the spawning zone rectangle
			l_spawner.global_position = Vector2(rand_range(mMyArea.global_position.x+self.rect_position.x, mMyArea.global_position.x+self.rect_position.x+self.rect_size.x), rand_range(mMyArea.global_position.y+self.rect_position.y, mMyArea.global_position.y+self.rect_position.y+self.rect_size.y))
			#add the spawner as a child of the scene (parent)
			mMazeScene.call_deferred("add_child", l_spawner)


############################
## HANDLE GAMEPLAY INPUTS ##
############################
#func _unhandled_input(event : InputEvent) -> void:
#	#for now, the accept input initialize a spawn
#	if event.is_action_pressed("ui_accept"):
#		randomize()
#		var l_spawner : AnimatedSprite = mSpawner.instance()
#		#random position within the spawning zone rectangle
#		l_spawner.global_position = Vector2(rand_range(self.rect_position.x, self.rect_position.x+self.rect_size.x), rand_range(self.rect_position.y, self.rect_position.y+self.rect_size.y))
#		#add the spawner as a child of the scene (parent)
#		get_parent().call_deferred("add_child", l_spawner)
