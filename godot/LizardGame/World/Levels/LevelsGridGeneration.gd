extends TileMap

#############################
# LUNCH THE MAZE GENERATION #
#############################
#func _input(event: InputEvent) -> void:
#	if event.is_action_pressed("ui_page_down"):
#		Lzui.hide()
#		var l_generation_is_ok : bool = generate(4,4)
#		while l_generation_is_ok == false:
#			l_generation_is_ok = generate(4,4)


####################
#  MAZE GENERATION #
####################
func generate(col, row) -> bool:
	#initialize the randomness
	randomize()
	
	#bool to return if the generation worked or not
	var l_did_it_workded : bool = true
	
	#clear the grid
	clear()
	
	#fill the grid with all water tiles with an outline of 1
	for xpos in col+2:
		for ypos in row+2:
			if xpos == 0 or xpos == col+1 or ypos == 0 or ypos == row+1:
				set_cell(xpos, ypos, 10)
			else:
				set_cell(xpos, ypos, 9)
	
	#start random at the top row
	var l_starting_col = randi() %col + 1
	
	#with the outline the first row is always water, start at the second row from 0
	var l_processing_row : int = 1
	
	var l_actual_cell := Vector2(l_starting_col, l_processing_row)
	
	#set the first cell
	SetCell(l_actual_cell, col, "LINE")
	
	#while not at the bottom
	while l_processing_row < (row) :
		#random between 1 to 5,  1&2 => RIGHT, 3&4 => LEFT, 5=>DOWN
		var l_rng = randi() %5 +1
		
		if l_rng in [1, 2]:
			#if not at the last col, we can move right
			if l_actual_cell.x != col:
				l_actual_cell.x +=1
				#if this cell is a black one, set it
				if get_cellv(l_actual_cell) == 9: 
					SetCell(l_actual_cell, col, "LINE")
			
		elif l_rng in [3, 4]: 
			#if not at the first col, we can move left
			if l_actual_cell.x != 1:
				l_actual_cell.x -=1
				#if this cell is a black one, set it
				if get_cellv(l_actual_cell) == 9: 
					SetCell(l_actual_cell, col, "LINE")
			
		else:
			#if the upper cell is not already a down, set the down, move down and set the up + update the processing row
			# warning-ignore:narrowing_conversion
			# warning-ignore:narrowing_conversion
			# warning-ignore:narrowing_conversion
			# warning-ignore:narrowing_conversion
			# warning-ignore:narrowing_conversion
			# warning-ignore:narrowing_conversion
			if get_cell(l_actual_cell.x, l_actual_cell.y -1) != 3 && get_cell(l_actual_cell.x, l_actual_cell.y -1) != 4 && get_cell(l_actual_cell.x, l_actual_cell.y -1) != 5:
				
				SetCell(l_actual_cell, col, "DOWN")
				l_actual_cell.y += 1  
				
				SetCell(l_actual_cell, col, "UP")
				l_processing_row += 1
	
	#array of the unaffected black tiles, shuffle it
	var l_array_tiles_left = get_used_cells_by_id(9)
	l_array_tiles_left.shuffle()
	
	#is there at least 3 tile for exit, start and key, else generation of the maze failed
	if l_array_tiles_left.size() < 3:
		l_did_it_workded = false
		return l_did_it_workded
	
	#affect a start
	SetCell(l_array_tiles_left[0], col, "START")
	
	#array of the unaffected black tiles, shuffle it
	l_array_tiles_left = get_used_cells_by_id(9)
	l_array_tiles_left.shuffle()
	
	#affect a key
	SetCell(l_array_tiles_left[0], col, "KEY")
	
	#array of the unaffected black tiles, shuffle it
	l_array_tiles_left = get_used_cells_by_id(9)
	l_array_tiles_left.shuffle()
	
	var l_exit_found : bool = false
	var l_valid_cell : bool = false
	var l_left_cell : Vector2 = Vector2.ZERO
	var l_right_cell : Vector2 = Vector2.ZERO
	
	#affect an exit
	for i in range(l_array_tiles_left.size()):
		l_left_cell = l_array_tiles_left[i]
		l_left_cell.x -= 1
		
		l_right_cell = l_array_tiles_left[i]
		l_right_cell.x += 1
		
		#if the cell to right or to the left is the start, the cell is not valid to set the exit
		l_valid_cell = true
		if get_cellv(l_left_cell) in [17, 18, 19]:
			l_valid_cell = false
		if get_cellv(l_right_cell) in [17, 18, 19]:
			l_valid_cell = false
		
		#if still no exit and the cell is valid, set it
		if l_exit_found == false && l_valid_cell == true:
			SetCell(l_array_tiles_left[i], col, "EXIT")
			l_exit_found = true
	
	#if no exit could be set, the generation of the maze failed
	if l_exit_found == false:
		l_did_it_workded = false
		return l_did_it_workded
	
	#array of the unaffected black tiles
	l_array_tiles_left = get_used_cells_by_id(9)
	
	#fill all the remaining black cells
	for i in range(l_array_tiles_left.size()):
		SetCell(l_array_tiles_left[i], col, "LINE")
	
	#the generation of the maze worked
	return l_did_it_workded


###############
#  SET A CELL #
###############
func SetCell(actualcell : Vector2, col : int, type : String) -> void:
	var l_actual_cell = actualcell
	var l_col = col
	var l_type = type
	
	#manate the cell to set in terms of type and if we are on the border of the maze (1 or col)
	match l_type:
		"LINE":
			if l_actual_cell.x == 1:
				set_cell(l_actual_cell.x, l_actual_cell.y, 0) 
			else:
				if l_actual_cell.x == l_col:
					set_cell(l_actual_cell.x, l_actual_cell.y, 2) 
				else:
					set_cell(l_actual_cell.x, l_actual_cell.y, 1) 
			
		"DOWN":
			if l_actual_cell.x == 1:
				set_cell(l_actual_cell.x, l_actual_cell.y, 3) 
			else:
				if l_actual_cell.x == l_col:
					set_cell(l_actual_cell.x, l_actual_cell.y, 4) 
				else:
					set_cell(l_actual_cell.x, l_actual_cell.y, 5) 
			
		"UP":
			if l_actual_cell.x == 1:
				set_cell(l_actual_cell.x, l_actual_cell.y, 8) 
			else:
				if l_actual_cell.x == l_col:
					set_cell(l_actual_cell.x, l_actual_cell.y, 7) 
				else:
					set_cell(l_actual_cell.x, l_actual_cell.y, 6) 
			
		"START":
			if l_actual_cell.x == 1:
				set_cell(l_actual_cell.x, l_actual_cell.y, 17) 
			else:
				if l_actual_cell.x == l_col:
					set_cell(l_actual_cell.x, l_actual_cell.y, 19) 
				else:
					set_cell(l_actual_cell.x, l_actual_cell.y, 18) 
			
		"EXIT":
			if l_actual_cell.x == 1:
				set_cell(l_actual_cell.x, l_actual_cell.y, 14) 
			else:
				if l_actual_cell.x == l_col:
					set_cell(l_actual_cell.x, l_actual_cell.y, 16) 
				else:
					set_cell(l_actual_cell.x, l_actual_cell.y, 15) 
			
		"KEY":
			if l_actual_cell.x == 1:
				set_cell(l_actual_cell.x, l_actual_cell.y, 11) 
			else:
				if l_actual_cell.x == l_col:
					set_cell(l_actual_cell.x, l_actual_cell.y, 13) 
				else:
					set_cell(l_actual_cell.x, l_actual_cell.y, 12) 
