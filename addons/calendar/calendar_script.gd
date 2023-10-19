@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"Calendar",
		"VBoxContainer",
		preload("res://addons/calendar/src/calendar.gd"),
		preload("res://addons/calendar/icon.png")
		)

func _exit_tree():
	remove_custom_type("Calendar")
