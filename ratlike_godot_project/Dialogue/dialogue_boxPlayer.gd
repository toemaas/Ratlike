extends CanvasLayer


@export_file("*.json") var d_file

var dialogue = []
var current_dialogue_id = 0

func _ready():
	$NinePatchRect.visible = false
	#start()
	

func start():
	if GlobalVars.d_active:
		return
	GlobalVars.d_active = true
	$NinePatchRect.visible = true
	get_tree().paused = true
	
	dialogue = load_dialogue()
	current_dialogue_id = -1
	next_script()
	
func load_dialogue():
	var file = FileAccess.open(d_file, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content
	
func _input(event):
	if not GlobalVars.d_active:
		return
	if event.is_action_pressed("ui_accept"):
		
		next_script()

func next_script():
	current_dialogue_id += 1
	
	if current_dialogue_id >= len(dialogue):
		done_text()
		return
	
	$NinePatchRect/Name.text = dialogue[current_dialogue_id]["name"]
	$NinePatchRect/Chat.text = dialogue[current_dialogue_id]["text"]
	
func done_text():
	GlobalVars.d_active = false
	$NinePatchRect.visible = false
	get_tree().paused = false
