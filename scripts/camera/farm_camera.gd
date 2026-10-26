extends Camera3D

## Three-quarter farm camera: pan, zoom, and orbit around a focus point.

const PAN_SPEED := 12.0
const ZOOM_MIN := 8.0
const ZOOM_MAX := 32.0
const PITCH_MIN := 0.35
const PITCH_MAX := 1.15
const KEY_ORBIT_SPEED := 0.9
const KEY_PITCH_SPEED := 0.45

var focus := Vector3(0.0, 1.2, 0.0)
var yaw := 0.9
var pitch := 0.58
var distance := 15.0

var _orbiting := false
var _panning := false


func _ready() -> void:
	current = true
	_apply()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.button_index == MOUSE_BUTTON_RIGHT:
			_orbiting = button.pressed
		elif button.button_index == MOUSE_BUTTON_MIDDLE:
			_panning = button.pressed
		elif button.pressed and button.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_by(-1.4)
		elif button.pressed and button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_by(1.4)
	elif event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if _orbiting:
			orbit(-motion.relative.x * 0.005, motion.relative.y * 0.005)
		elif _panning:
			pan_screen(motion.relative.x, motion.relative.y)
	elif event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_EQUAL or key.keycode == KEY_KP_ADD:
			zoom_by(-1.4)
		elif key.keycode == KEY_MINUS or key.keycode == KEY_KP_SUBTRACT:
			zoom_by(1.4)


func _process(delta: float) -> void:
	var dir := Vector3.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		dir.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		dir.z += 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		dir.z -= 1.0
	if dir != Vector3.ZERO:
		pan_keys(dir, delta)

	var yaw_delta := 0.0
	var pitch_delta := 0.0
	if Input.is_physical_key_pressed(KEY_Q):
		yaw_delta -= KEY_ORBIT_SPEED * delta
	if Input.is_physical_key_pressed(KEY_E):
		yaw_delta += KEY_ORBIT_SPEED * delta
	if Input.is_physical_key_pressed(KEY_R):
		pitch_delta -= KEY_PITCH_SPEED * delta
	if Input.is_physical_key_pressed(KEY_F):
		pitch_delta += KEY_PITCH_SPEED * delta
	if yaw_delta != 0.0 or pitch_delta != 0.0:
		orbit(yaw_delta, pitch_delta)


func orbit(yaw_delta: float, pitch_delta: float) -> void:
	yaw += yaw_delta
	pitch = clampf(pitch + pitch_delta, PITCH_MIN, PITCH_MAX)
	_apply()


func zoom_by(delta_distance: float) -> void:
	distance = clampf(distance + delta_distance, ZOOM_MIN, ZOOM_MAX)
	_apply()


func pan_screen(dx: float, dy: float) -> void:
	var scale := distance * 0.0018
	focus += (-_right() * dx + _forward() * dy) * scale
	focus.y = 1.2
	_apply()


func pan_keys(dir: Vector3, delta: float) -> void:
	var move: Vector3 = _right() * dir.x + _forward() * dir.z
	if move.length_squared() == 0.0:
		return
	focus += move.normalized() * PAN_SPEED * delta
	focus.y = 1.2
	_apply()


func _right() -> Vector3:
	return Vector3(cos(yaw), 0.0, -sin(yaw))


func _forward() -> Vector3:
	return Vector3(-sin(yaw), 0.0, -cos(yaw))


func _apply() -> void:
	var offset := Vector3(
		cos(pitch) * sin(yaw),
		sin(pitch),
		cos(pitch) * cos(yaw)
	) * distance
	global_position = focus + offset
	if not global_position.is_equal_approx(focus):
		look_at(focus, Vector3.UP)
