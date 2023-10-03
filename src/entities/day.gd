class_name Day
extends Button

signal day_pressed(day:int)

@export var today_color:Color = Color("#bb4444ff")

var day:int = 0

func _ready():
	pass

func _initialize(day_n:int, today:bool, month_end:bool, invisible:bool=false) -> void:
	self.day = day_n
	self.text = str(day_n)
	self.set_color(today)
	if day_n < 1: month_end = true
	self.disable_button(month_end)
	self.set_invisible(invisible)

func set_color(today:bool=false) -> void:
	self.self_modulate = Color(1,1,1,1)
	if today: self.self_modulate = today_color

func disable_button(status:bool=false) -> void:
	self.disabled = status

func set_invisible(invisible:bool=false) -> void:
	self.modulate.a = 1
	if invisible: self.modulate.a = 0

func _on_pressed():
	day_pressed.emit(self.day)
