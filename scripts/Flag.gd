extends Area

func _ready():
	pass


func _on_Flag_body_entered(body):
	get_parent().won()
