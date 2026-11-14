extends Node3D

const LANE_X := [-3.0, 0.0, 3.0]
const RUN_SPEED := 10.0
const MAX_ARMY := 45

var lane_index := 1
var distance := 0.0
var army_count := 3
var run_finished := false
var touch_start := Vector2.ZERO

var runner: Node3D
var army_root: Node3D
var hud: CanvasLayer
var army_label: Label
var distance_label: Label
var message_label: Label
var gates: Array[Area3D] = []

func _ready() -> void:
	_build_world()
	_build_player()
	_build_gates()
	_build_hud()
	_update_army()

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#91b8c7")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#d8e3e5")
	env.ambient_light_energy = 0.8
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_energy = 1.25
	add_child(sun)

	var ground := _box(Vector3(10, 0.4, 100), Color("#c5ad83"))
	ground.position = Vector3(0, -0.25, -38)
	add_child(ground)

	for i in range(4):
		var stripe := _box(Vector3(0.08, 0.02, 100), Color("#e6d4b2"))
		stripe.position = Vector3(-4.5 + i * 3.0, -0.035, -38)
		add_child(stripe)

	for side in [-1.0, 1.0]:
		var wall := _box(Vector3(0.6, 2.2, 100), Color("#8c765e"))
		wall.position = Vector3(side * 5.4, 0.9, -38)
		add_child(wall)

	var camera := Camera3D.new()
	camera.position = Vector3(0, 11, 15)
	camera.rotation_degrees = Vector3(-28, 0, 0)
	camera.current = true
	camera.fov = 55
	add_child(camera)

	# Distant castle silhouette
	for i in range(5):
		var tower := _box(Vector3(2.0, 5.0 + (i % 2) * 1.5, 2.0), Color("#8d7967"))
		tower.position = Vector3(-8 + i * 4, 2.5, -75)
		add_child(tower)

func _build_player() -> void:
	runner = Node3D.new()
	runner.position = Vector3(0, 0, 7)
	add_child(runner)
	army_root = Node3D.new()
	runner.add_child(army_root)

func _build_gates() -> void:
	_create_gate(Vector3(-3, 0, -18), "+5 SOLDIERS", 5, Color("#328cbd"))
	_create_gate(Vector3(3, 0, -18), "x2 ARMY", 2, Color("#d49b37"))
	_create_gate(Vector3(0, 0, -42), "+10 SOLDIERS", 10, Color("#328cbd"))
	_create_gate(Vector3(3, 0, -42), "x3 ARMY", 3, Color("#d49b37"))

func _create_gate(pos: Vector3, caption: String, value: int, tint: Color) -> void:
	var gate := Area3D.new()
	gate.position = pos
	gate.set_meta("value", value)
	gate.set_meta("is_multiplier", caption.begins_with("x"))
	var body := _box(Vector3(2.5, 3.0, 0.35), tint)
	body.position.y = 1.5
	gate.add_child(body)
	var label := Label3D.new()
	label.text = caption
	label.font_size = 48
	label.position = Vector3(0, 1.6, -0.25)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	gate.add_child(label)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.5, 3.0, 1.0)
	collision.shape = shape
	gate.add_child(collision)
	# Gate activation is checked manually against the runner position.
	# This avoids relying on a physics body that the greybox runner does not have yet.
	add_child(gate)
	gates.append(gate)

func _check_gates() -> void:
	for gate in gates:
		if not is_instance_valid(gate) or gate.get_meta("used", false):
			continue
		var z_distance := absf(runner.global_position.z - gate.global_position.z)
		var x_distance := absf(runner.global_position.x - gate.global_position.x)
		if z_distance <= 0.8 and x_distance <= 1.65:
			_apply_gate(gate)

func _apply_gate(gate: Area3D) -> void:
	if run_finished or gate.get_meta("used", false):
		return
	gate.set_meta("used", true)
	var gate_body := gate.get_child(0) as MeshInstance3D
	if gate_body:
		var faded := StandardMaterial3D.new()
		faded.albedo_color = Color("#777777")
		faded.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		faded.albedo_color.a = 0.35
		gate_body.material_override = faded
	var value: int = int(gate.get_meta("value"))
	if gate.get_meta("is_multiplier"):
		army_count = mini(army_count * value, MAX_ARMY)
	else:
		army_count = mini(army_count + value, MAX_ARMY)
	_update_army()

func _build_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var panel := PanelContainer.new()
	panel.position = Vector2(18, 18)
	panel.custom_minimum_size = Vector2(280, 100)
	hud.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	army_label = Label.new()
	army_label.add_theme_font_size_override("font_size", 26)
	column.add_child(army_label)
	distance_label = Label.new()
	distance_label.add_theme_font_size_override("font_size", 20)
	column.add_child(distance_label)
	message_label = Label.new()
	message_label.text = "SWIPE LEFT / RIGHT TO CHANGE LANES"
	message_label.position = Vector2(18, 1120)
	message_label.add_theme_font_size_override("font_size", 20)
	hud.add_child(message_label)

func _process(delta: float) -> void:
	if run_finished:
		return
	distance += RUN_SPEED * delta
	runner.position.z -= RUN_SPEED * delta
	_check_gates()
	distance_label.text = "DISTANCE: %d m" % int(distance)
	if distance >= 75.0:
		run_finished = true
		message_label.text = "RUN COMPLETE!  TAP TO RESTART"

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
		elif run_finished:
			get_tree().reload_current_scene()
		else:
			var dx := event.position.x - touch_start.x
			if absf(dx) > 35.0:
				_change_lane(1 if dx > 0 else -1)
	elif event is InputEventMouseButton and event.pressed:
		if run_finished:
			get_tree().reload_current_scene()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_LEFT or event.keycode == KEY_A:
			_change_lane(-1)
		elif event.keycode == KEY_RIGHT or event.keycode == KEY_D:
			_change_lane(1)

func _change_lane(direction: int) -> void:
	lane_index = clampi(lane_index + direction, 0, 2)
	runner.position.x = LANE_X[lane_index]

func _update_army() -> void:
	for child in army_root.get_children():
		child.queue_free()
	for i in range(army_count):
		var soldier := _box(Vector3(0.65, 1.25, 0.55), Color("#315f9b"))
		var row := i / 3
		var col := i % 3
		soldier.position = Vector3((col - 1) * 0.85, 0.65, 1.8 + row * 0.8)
		army_root.add_child(soldier)
	army_label.text = "⚔ ARMY: %d" % army_count

func _box(size: Vector3, tint: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.82
	mesh_instance.material_override = material
	return mesh_instance
