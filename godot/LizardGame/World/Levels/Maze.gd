extends Node2D

onready var _preview = preload("res://LizardGame/World/Levels/LevelsGridGeneration.tscn")

var size:= 4


#########
# READY #
#########
func _ready() -> void:
	generate_board()


#############
# TO DELETE #
#############
#func _input(event: InputEvent) -> void:
#	# warning-ignore:return_value_discarded
#	if event.is_action_pressed("ui_cancel"): 
#		CameraShake.SetCamera(null)
#		get_tree().reload_current_scene()


###################
# GENERATE A MAZE #
###################
func generate_board() -> void:
	randomize()
	
	var tm = _preview.instance()
	
	var l_generation_is_ok : bool = tm.generate(size,size)
	while l_generation_is_ok == false:
		l_generation_is_ok = tm.generate(size,size)
	
	for x in size+2:
		for y in size+2:
			var i = tm.get_cellv(Vector2(x, y))
			
			var scene
			var chunk : String = GetChunck(i)
			
			scene = load(chunk).instance()
			
			var pos = Vector2(960 * x, 544 * y)
			
			add_child(scene)
			scene.position = pos


#########################
# GET CHUNCK SCENE PATH #
#########################
func GetChunck(CellId : int) -> String:
	var l_cell_id = CellId
	var l_chunk_path : String = ""
	var l_chunk_id : int = 0
	randomize()
	
	match l_cell_id:
		0:#RIGHT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/R/R" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		1:#RIGHT AN LEFT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/RL/RL" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		2:#LEFT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/L/L" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		3:#RIGHT AND DOWN
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/RD/RD" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		4:#DOWN AND LEFT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/DL/DL" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		5:#RIGHT AND DOWN AND LEFT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/RDL/RDL" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		6:#RIGHT AND LEFT AND UP
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/RLU/RLU" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		7:#LEFT AND UP
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/LU/LU" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		8:#RIGHT AND UP
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/RU/RU" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		10:#WATER
			l_chunk_id = randi() %1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/WAT/WAT" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		11:#KEY RIGHT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/KR/KR" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		12:#KEY RIGHT AND LEFT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/KRL/KRL" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		13:#KEY LEFT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/KL/KL" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		14:#EXIT RIGHT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/ER/ER" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		15:#EXIT RIGHT AND LEFT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/ERL/ERL" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		16:#EXIT LEFT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/EL/EL" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		17:#START RIGHT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/SR/SR" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		18:#START RIGHT AND LEFT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/SRL/SRL" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		19:#START LEFT
			l_chunk_id = randi() %1+1 #number of chunk type available
			l_chunk_path = l_chunk_path + "res://LizardGame/World/Levels/SL/SL" + str(l_chunk_id) + ".tscn"
			return l_chunk_path
		_:#ELSE
			return "res://LizardGame/World/Levels/RefPuzzlePiece.tscn"
