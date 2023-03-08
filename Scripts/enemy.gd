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
@export var chase_speed = 2
@export var patrol_speed = 2

var patrol_timer : Timer

var player_ears_far : bool
var player_ears_close : bool
var player_slight_close : bool

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	current_state = States.patrol
	waypoint_index = 0
	navigation_agent = $NavigationAgent3D
	patrol_timer = $PatrolTimer
	player = get_tree().get_nodes_in_group("Player")[0]

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
			MoveTowardsPoint(delta, patrol_speed)
			#print("patrol player")
		States.chasing:
			if navigation_agent.is_navigation_finished():
				patrol_timer.start()
				current_state = States.waiting
			navigation_agent.target_position = player.global_position
			MoveTowardsPoint(delta, chase_speed)
			print("chasing player")
			pass
		States.hunting:
			if navigation_agent.is_navigation_finished():
				patrol_timer.start()
				current_state = States.waiting
			MoveTowardsPoint(delta, chase_speed)
			print("hunting player")
			pass
		States.waiting:
			#print("wainting")
			CheckPlayer()
			

func MoveTowardsPoint(delta, speed):
	var target_pos = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(target_pos)
	FaceDirection(target_pos)
	velocity = direction * speed	
	move_and_slide()
	if player_ears_far:
		CheckPlayer()



func CheckPlayer():
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create($Head.global_position, player.get_node("camera").global_position, 1, [self.get_rid()])) 
	if result.size() > 0:
		if result["collider"].is_in_group("Player"):
			if player_ears_close:
				#if result["collider"].crouched == false:
				current_state = States.chasing
				print("Hear player close")

			if player_ears_far:
				#if result["collider"].crouched == false:
				current_state = States.hunting
				navigation_agent.target_position = player.global_position
				print("Hear player far")

			if player_slight_close:
				current_state = States.chasing
				navigation_agent.target_position = player.global_position
				print("Saw player")

			#if player_slight_far:
			#	if result["collider"].crouched = false:
			#		current_state = States.hunting

func FaceDirection(direction : Vector3):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func _on_patrol_timer_timeout():
	current_state = States.patrol
	waypoint_index += 1
	if waypoint_index > way_points.size() - 1:
		waypoint_index = 0
	navigation_agent.target_position = way_points[waypoint_index].global_position

func _on_hearing_far_body_entered(body):
	if body.is_in_group("Player"):
		print("hear far enter")
		player_ears_far = true

func _on_hearing_far_body_exited(body):
	if body.is_in_group("Player"):
		print("hear far exit")
		player_ears_far = false

func _on_hearing_close_body_entered(body):
	if body.is_in_group("Player"):
		print("hear close enter")
		player_ears_close = true

func _on_hearing_close_body_exited(body):
	if body.is_in_group("Player"):
		print("hear close exit")
		player_ears_close = false

func _on_slight_close_body_entered(body):
	if body.is_in_group("Player"):
		print("slight close enter")
		player_slight_close = true

func _on_slight_close_body_exited(body):
	if body.is_in_group("Player"):
		print("slight close exit")
		player_slight_close = false
