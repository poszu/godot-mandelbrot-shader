extends Node2D

onready var mandelbrot = $Sprite

export(Vector2) onready var upper_left = Vector2(-1.2, 0.35) setget set_upper_left
export(Vector2) onready var lower_right = Vector2(-1.0, 0.20) setget set_lower_down

export(float) var zoom_speed = 0.2

var mouse_pressed = false
var last_pos = Vector2.ZERO

func set_upper_left(value: Vector2) -> void:
	if mandelbrot != null:
		mandelbrot.material.set_shader_param("upper_left", value)
		upper_left = value

func set_lower_down(value: Vector2) -> void:
	if mandelbrot != null:
		mandelbrot.material.set_shader_param("lower_right", value)
		lower_right = value
	
func mandelbrot_size() -> Vector2:
	var ul = mandelbrot.material.get_shader_param("upper_left")
	var ld = mandelbrot.material.get_shader_param("lower_right")
	return Vector2(ld.x - ul.x, ul.y - ld.y)

func set_mandelbrot_bounds(upper_left: Vector2, lower_right: Vector2) -> void:
	self.upper_left = upper_left
	self.lower_right = lower_right

func pixel2point(pixel_coords: Vector2, upper_left: Vector2, size: Vector2) -> Vector2:
	return upper_left + size * pixel_coords * Vector2(1, -1)

func _input(event):
	if event.is_action_pressed("zoom_in"):
		var mandelbrot_size = mandelbrot_size()
		var mouse_uv = event.global_position / get_viewport().size
		var mouse_point = pixel2point(mouse_uv, self.upper_left, mandelbrot_size)
		mandelbrot_size *= (1.0 - zoom_speed)
		self.upper_left = mouse_point + mouse_uv * mandelbrot_size * Vector2(-1, 1)
		self.lower_right = mouse_point + (Vector2.ONE - mouse_uv) * mandelbrot_size * Vector2(1, -1)

	elif event.is_action_pressed("zoom_out"):
		var mandelbrot_size = mandelbrot_size()
		var mouse_uv = event.global_position / get_viewport().size
		var mouse_point = pixel2point(mouse_uv, self.upper_left, mandelbrot_size)
		mandelbrot_size /= (1.0 - zoom_speed)
		
		self.upper_left = mouse_point + mouse_uv * mandelbrot_size * Vector2(-1, 1)
		self.lower_right = mouse_point + (Vector2.ONE - mouse_uv) * mandelbrot_size * Vector2(1, -1)
	
	elif event is InputEventMouseButton:
		mouse_pressed = event.pressed
		last_pos = event.global_position

	elif event is InputEventMouseMotion and mouse_pressed:
		var pos_delta = event.global_position - last_pos
		last_pos = event.global_position
		# Move Mandelbrot
		var mandelbrot_size = mandelbrot_size()
		var movement = Vector2(
			-mandelbrot_size.x * (pos_delta.x / get_viewport().size.x),
			mandelbrot_size.y * (pos_delta.y / get_viewport().size.y)
		)
		self.upper_left += movement
		self.lower_right += movement

# Called when the node enters the scene tree for the first time.
func _ready():
	set_mandelbrot_bounds(self.upper_left, self.lower_right)
