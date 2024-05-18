extends CanvasLayer


onready var cChoice1 := $MenuContainer/MarginContainer/VBoxContainer/HBoxContainer/ChoiceList/Choice1
onready var cChoice2 := $MenuContainer/MarginContainer/VBoxContainer/HBoxContainer/ChoiceList/Choice2

#var mAppleIcon : Texture = load("res://LizardGame/Sprites/UI/AppleIcon.png")
var mAppleIcon : Texture = load("res://LizardGame/Sprites/UI/AppleIconX2.png")
var mDashIcon : Texture = load("res://LizardGame/Sprites/UI/DashIcon.png")
var mHeartIcon : Texture = load("res://LizardGame/Sprites/UI/HeartIcon.png")

var mButtonList = {1: "cChoice1", 2: "cChoice2"}

const LIFE : int = 1
const APPLE :int = 2
const DASH : int = 3

var mButton1 = {"Type": 0, "Amount": 0}
var mButton2 = {"Type": 0, "Amount": 0}

var mChoiceMade : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#Lzui.visible = true
	#Lzui.visible = false
	
	cChoice1.grab_focus()
	
	var random = RandomNumberGenerator.new()
	random.randomize()
	randomize()
	
	var l_random_type : int
	var l_ultra_chance : int
	var l_button : Button
	var l_mbutton_modifier
	
	for i in 2:
		l_random_type = 1 + randi() %3
		l_ultra_chance = 1 + randi() %100
		if l_ultra_chance <= 5:
			l_ultra_chance = 3
		else:
			if l_ultra_chance <= 25:
				l_ultra_chance = 2
			else:
				l_ultra_chance = 1
		
		match l_random_type:
			LIFE:
				l_button = get(mButtonList[i+1])
				l_button.text = "  Increase life (+" + str(l_ultra_chance) + ")"
				l_button.icon = mHeartIcon
				
				l_mbutton_modifier = get("mButton"+str(i+1))
				l_mbutton_modifier["Type"] = LIFE
				l_mbutton_modifier["Amount"] = l_ultra_chance
			APPLE:
				l_button = get(mButtonList[i+1])
				l_button.text = "  Increase apple max capacity (+" + str(l_ultra_chance) + ")"
				l_button.icon = mAppleIcon
				
				l_mbutton_modifier = get("mButton"+str(i+1))
				l_mbutton_modifier["Type"] = APPLE
				l_mbutton_modifier["Amount"] = l_ultra_chance
			DASH:
				l_button = get(mButtonList[i+1])
				l_button.text = "  Increase dash max capacity (+" + str(l_ultra_chance) + ")"
				l_button.icon = mDashIcon
				
				l_mbutton_modifier = get("mButton"+str(i+1))
				l_mbutton_modifier["Type"] = DASH
				l_mbutton_modifier["Amount"] = l_ultra_chance


#var l_max_enemy_to_spawn : int
#if LzEngine.gDifficulty <= 5:
#	l_max_enemy_to_spawn = 1 + randi() %2
	#else:
	#	l_max_enemy_to_spawn = 2 + randi() %2
	#match LzEngine.gDifficulty:
	#	1:
	#		l_max_enemy_to_spawn = 1
	#	2:
	#		l_max_enemy_to_spawn = 1 + randi() %2 
	
	#l_max_enemy_to_spawn = 1 + randi() %2 #0-1 + 1 => 1-2 per spawner * 2 = 2 to 4
	#var l_texture_name = load("res://assets/city/for objects/lights/" + m_texture_name + "_light.png")
	#$light_sign.set_texture(l_texture_name)
############################
## HANDLE GAMEPLAY INPUTS ##
############################
#func _unhandled_input(event : InputEvent) -> void:
#	if event.is_action_pressed("ui_accept"):
#		visible = false
#		Lzui.visible = true



func _on_Choice1_pressed():
	if mChoiceMade == false:
		mChoiceMade = true
		#mButton1
		
		LzEngine.gDifficulty = LzEngine.gDifficulty + 1
		
		match mButton1["Type"]:
			LIFE:
				LzEngine.gLife = LzEngine.gLife + mButton1["Amount"]
			APPLE:
				LzEngine.gMaxApple = LzEngine.gMaxApple + mButton1["Amount"]
				LzEngine.gAppleAmount = LzEngine.gAppleAmount
			DASH:
				LzEngine.gMaxDash = LzEngine.gMaxDash + mButton1["Amount"]
				LzEngine.gDashAmount = LzEngine.gMaxDash
		
		#visible = false
		Lzui.visible = true
		LzEngine.Startagame(self)
		
		Lzui.cLevelTime.text = str(0.0)
		Lzui.cLevelScore.text = str(0.0)
		LzEngine.gLeveltime = 0.0
		LzEngine.gLevelScore = 0
		LzEngine.gMultiplier = 100.0


func _on_Choice2_pressed():
	if mChoiceMade == false:
		mChoiceMade = true
		
		LzEngine.gDifficulty = LzEngine.gDifficulty +  1
		
		match mButton2["Type"]:
			LIFE:
				LzEngine.gLife = LzEngine.gLife + mButton2["Amount"]
			APPLE:
				LzEngine.gMaxApple = LzEngine.gMaxApple + mButton2["Amount"]
				LzEngine.gAppleAmount = LzEngine.gAppleAmount
			DASH:
				LzEngine.gMaxDash = LzEngine.gMaxDash + mButton2["Amount"]
				LzEngine.gDashAmount = LzEngine.gMaxDash
		
		#visible = false
		Lzui.visible = true
		LzEngine.Startagame(self)
		
		Lzui.cLevelTime.text = str(0.0)
		Lzui.cLevelScore.text = str(0.0)
		LzEngine.gLeveltime = 0.0
		LzEngine.gLevelScore = 0
		LzEngine.gMultiplier = 100.0
