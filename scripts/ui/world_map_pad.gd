extends Control

## Stylized world map behind the region markers. Positions match the menu buttons.


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.42, 0.66, 0.82))
	draw_rect(Rect2(Vector2(18, 28), Vector2(size.x - 36, size.y - 56)), Color(0.55, 0.74, 0.58))
	var previous := Vector2.ZERO
	var index := 0
	for region in RegionCatalog.all():
		var center := Vector2(
			float(region["map_x"]) * 250.0 + 95.0,
			float(region["map_y"]) * 250.0 + 24.0
		)
		draw_circle(center, 46.0, Color(0.36, 0.55, 0.28))
		draw_circle(center, 10.0, Color(0.95, 0.72, 0.28))
		if index > 0:
			draw_line(previous, center, Color(0.86, 0.75, 0.48), 3.0)
		previous = center
		index += 1
