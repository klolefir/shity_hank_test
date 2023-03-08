extends CharacterBody3D

enum States {
	patrol,
	chasing,
	hunting,
	waiting
}

var current_state : States
var navigation_agent : NavigationAgent3D
@export var way_points : Array
var waypoint_index : int
@export var speed = 2

var patrol_timer : Timer

var player_ears_far : bool
var player_ears_close : bool
var player_slight_close : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	current_state = States.patrol
	waypoint_index = 0
	navigation_agent = $NavigationAgent3D
	patrol_timer = $PatrolTimer

	way_points = get_tree().get_nodes_in_group("EnemyWaypoint")
	navigation_agent.target_position = way_points[0].global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match current_state:
		States.patrol:
			if(navigation_agent.is_navigation_finished()):
				current_state = States.waiting
				patrol_timer.start()
				return
			var target_pos = navigation_agent.get_next_path_position()
			var direction = global_position.direction_to(target_pos)
			FaceDirection(target_pos)
			velocity = direction * speed	
			move_and_slide()
			if player_ears_far:
				CheckPlayer()

		States.chasing:
			pass
		States.hunting:
			pass
		States.waiting: pass

func CheckPlayer():
	pass 

func FaceDirection(direction : Vector3):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func _on_patrol_timer_timeout():
	current_state = States.patrol
	waypoint_index += 1
	if waypoint_index > way_points.size() - 1:
		waypoint_index = 0
	navigation_agent.target_position = way_points[waypoint_index].global_position
	pass # Replace with function body.

func _on_hearing_far_body_entered(body):
	if body.is_in_group("Player"):
		player_ears_far = true
		pass

func _on_hearing_far_body_exited(body):
	if body.is_in_group("Player"):
		player_ears_far = false
		pass

func _on_hearing_close_body_entered(body):
	if body.is_in_group("Player"):
		player_ears_close = true
		print("test")
	pass

func _on_hearing_close_body_exited(body):
	if body.is_in_group("Player"):
		player_ears_close = false
		pass

func _on_slight_close_body_entered(body):
	if body.is_in_group("Player"):
		player_slight_close = false
		pass

func _on_slight_close_body_exited(body):
	if body.is_in_group("Player"):
		player_slight_close = false
