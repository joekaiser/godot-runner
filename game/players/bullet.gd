extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	connect("body_enter",self,"do_collision");
	
func do_collision(body):
	Logger.warn("bullet collision not implemented")
	queue_free()
