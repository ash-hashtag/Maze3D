extends Spatial

var map_seed = 3161026589

const cell_walls = {Vector2(0, -1): 1, Vector2(1, 0): 2, 
				  Vector2(0, 1): 4, Vector2(-1, 0): 8}

var k = 0
var temp = 0

var cells = {}
var tm = Transform(Basis(Vector3(1, 0, 0), Vector3(0,1,0), Vector3(0,0,1)), Vector3(0,100,0))
var placed_blocks = []

var f = Vector2(101,205)

onready var wall = preload("res://scenes/wall.tscn")
onready var player = get_node("Player")
onready var line = $CanvasLayer/Control/LineEdit
onready var m_sensi = $CanvasLayer/Control/HSlider

var width = 4  # width of map (in tiles)
var height = 4 # height of map (in tiles)

var gmovr = false
# get a reference to the map for convenience

func _ready():
	m_sensi.value = player.MouseSensitivity * 300
	$CanvasLayer/Control/LineEdit.show()
	$CanvasLayer/Control/generate.show()
	$CanvasLayer/Control/replay.hide()
	$CanvasLayer/Control/Label.hide()
	m_sensi.hide()
	

func _physics_process(delta):
	if k < cells.size() && mazedone: blocktype()
	if k == cells.size() && mazedone:
		var fl = load("res://scenes/Flag.tscn").instance()
		fl.transform = Transform(r0, Vector3(f.x, 0, f.y)*10)
		add_child(fl)
		k += 1
	if isesc:
		player.MouseSensitivity = m_sensi.value / 300


# returns an array of cell's unvisited neighbors
func check_neighbors(cell, unvisited):
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list
	

var mazedone = false

#makes maze assuming unit cells
func make_maze():
	var unvisited = []  # array of unvisited tiles
	var stack = []
	# fill the map with solid tiles
	for x in range(width):
		for y in range(height):
			unvisited.append(Vector2(x, y))
			cells[Vector2(x, y)] = 15
	var current = Vector2(0, 0)
	unvisited.erase(current)
	# execute recursive backtracker algorithm
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			# remove walls from *both* cells
			var dir = next - current
			var current_walls = cells[current] - cell_walls[dir]
			var next_walls = cells[next] - cell_walls[-dir]
			cells[current] = current_walls
			cells[next] = next_walls
			current = next
			unvisited.erase(current)
		elif stack:
			if f == Vector2(101, 205):
				f = current
			current = stack.pop_back()
	if f == Vector2(101, 205):
		make_maze()
	else:
		mazedone = true
#		yield(get_tree(), 'idle_frame')

const r0 = Basis(Vector3(1, 0, 0), Vector3(0,1,0), Vector3(0,0,1))
const r90 = Basis(Vector3(-0,0,-1), Vector3(0,1,0), Vector3(1,0,0))


#Determines the walls shape and generates required transform
func blocktype():
	var m = 5
	var cs = 10
	var i  = cells.keys()[k]
	var t = []
	var cp = Vector3(i.x, 0, i.y) * cs
	var type = cells[i]
	if type == 0:
		pass
	elif type == 1:
		t.append(Transform(r0, (cp + Vector3.FORWARD*m)))
	elif type == 2:
		t.append(Transform(r90, (cp + Vector3.RIGHT*m)))
	elif type == 3:
		t.append(Transform(r90, (cp + Vector3.RIGHT*m)))
		t.append(Transform(r0, (cp + Vector3.FORWARD*m)))
	elif type == 4:
		t.append(Transform(r0, (cp + Vector3.BACK*m)))
	elif type == 5:
		t.append(Transform(r0, (cp + Vector3.FORWARD*m)))
		t.append(Transform(r0, (cp + Vector3.BACK*m)))
	elif type == 6:
		t.append(Transform(r90, (cp + Vector3.RIGHT*m)))
		t.append(Transform(r0, (cp + Vector3.BACK*m)))
	elif type == 7:
		t.append(Transform(r90, (cp + Vector3.RIGHT*m)))
		t.append(Transform(r0, (cp + Vector3.FORWARD*m)))
		t.append(Transform(r0, (cp + Vector3.BACK*m)))
	elif type == 8:
		t.append(Transform(r90, (cp + Vector3.LEFT*m)))
	elif type == 9:
		t.append(Transform(r0, (cp + Vector3.FORWARD*m)))
		t.append(Transform(r90, (cp + Vector3.LEFT*m)))
	elif type == 10:
		t.append(Transform(r90, (cp + Vector3.RIGHT*m)))
		t.append(Transform(r90, (cp + Vector3.LEFT*m)))
	elif type == 11:
		t.append(Transform(r0, (cp + Vector3.FORWARD*m)))
		t.append(Transform(r90, (cp + Vector3.RIGHT*m)))
		t.append(Transform(r90, (cp + Vector3.LEFT*m)))
	elif type == 12:
		t.append(Transform(r0, (cp + Vector3.BACK*m)))
		t.append(Transform(r90, (cp + Vector3.LEFT*m)))
	elif type == 13:
		t.append(Transform(r90, (cp + Vector3.LEFT*m)))
		t.append(Transform(r0, (cp + Vector3.FORWARD*m)))
		t.append(Transform(r0, (cp + Vector3.BACK*m)))
	elif type == 14:
		t.append(Transform(r0, (cp + Vector3.BACK*m)))
		t.append(Transform(r90, (cp + Vector3.RIGHT*m)))
		t.append(Transform(r90, (cp + Vector3.LEFT*m)))
	elif type == 15:
		pass
	place_block(t)
	k += 1


#places the walls with transfrom t
func place_block(t):
	var g = true
	var p
	for i in t:
		g = true
		for j in placed_blocks:
			if i == j:
				g = false
				break
		if g:
			var w = wall.instance()
			w.transform = i
			var s = rand_range(0.99, 1.01)
			while (p == s):
				s = rand_range(0.99, 1.01)
			p = s
			w.scale = Vector3(s, s, s)
			call_deferred("add_child", w)
			placed_blocks.append(i)


#checks if there is already a wall
func check():
	for i in placed_blocks:
		for j in placed_blocks:
			if i == j:
				pass
			elif abs(i - j) < 1:
				print(i, j)


func won():
	$CanvasLayer/Control/replay.show()


var isesc = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if !isesc:
			$CanvasLayer/Control/replay.show()
			$CanvasLayer/Control/Label.show()
			m_sensi.show()
			isesc = true
		else:
			m_sensi.hide()
			$CanvasLayer/Control/replay.hide()
			$CanvasLayer/Control/Label.hide()
			isesc = false


func _on_replay_button_down():
	get_tree().reload_current_scene()

#generates the maze
func _on_generate_button_down():
	if int(line.text) > 0:
		width = int(line.text)
		height = int(line.text)
	else:
		width = 10
		height = 10
	randomize()
	map_seed = randi()
	seed(map_seed)
	print(map_seed)
	#calls make maze function
	make_maze()
	$CanvasLayer/Control/LineEdit.hide()
	$CanvasLayer/Control/generate.hide()
	var t = []
	t.append(Transform(r0, (Vector3.FORWARD*5.5)))
	t.append(Transform(r90, (Vector3.LEFT*5.5)))
	place_block(t)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
