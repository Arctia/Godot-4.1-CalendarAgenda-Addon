@tool
class_name Calendar
extends VBoxContainer

# Emitting {"year": x:int, "month": y:int, "day": z:int} when a day is pressed
signal date_pressed(timedate:Dictionary)

@export var day_name : bool = true
@export var abbreviate : bool = true
@export var min_cell_width : int = 36
@export var min_cell_height : int = 36

var days_one_letter = ["M", "T", "W", "T", "F", "S", "S"]
var days_abbreviate = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

var date:Date

var day_tscn = load("res://src/entities/day.tscn")

var date_selected:Dictionary

func _ready() -> void:
	self.date = Date.new()
	self.date._ready()
	self.date_selected = date.today.duplicate()
	self._set_labels()
	self._put_days()
	self._set_cell_size()
	self._calc_days_number()

func _set_cell_size() -> void:
	for child in %DayNameContainer.get_children():
		child.custom_minimum_size.x = min_cell_width
		child.custom_minimum_size.y = min_cell_height
	for child in %DaysContainer.get_children():
		child.custom_minimum_size.x = min_cell_width
		child.custom_minimum_size.y = min_cell_height

func _set_labels() -> void:
	_set_day_labels()
	_set_month_year_labels()

func _set_month_year_labels() -> void:
	%lbl_month.text = date.month_names[date_selected.month].capitalize()
	%lbl_year.text = str(date_selected.year)

func _set_day_labels() -> void:
	var i:int = 0
	var form:Array = days_one_letter
	if abbreviate: form = days_abbreviate
	for lbl in %DayNameContainer.get_children():
		lbl.visible = true
		if not day_name: 
			lbl.visible = false
			continue
		lbl.text = form[i]
		i += 1

func _put_days() -> void:
	for i in range(7*6):
		var day:Day = day_tscn.instantiate()
		day.text = str(i)
		day.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		day.size_flags_vertical = Control.SIZE_EXPAND_FILL
		%DaysContainer.add_child(day)

func get_previous_month_days(datetime:Dictionary) -> int:
	var datet:Dictionary = datetime.duplicate()
	datet.month -= 1
	if datet.month == 0: datet.month = 12
	return date.get_month_days(datet)

func _calc_days_number(temp_date:Dictionary = {}) -> void:
	if temp_date.is_empty(): temp_date = date.today
	var first_day = date.first_day_of_the_month(temp_date)
	var month_days = date.get_month_days(temp_date)
	var previous_month_days = get_previous_month_days(temp_date)
	
	var temp_date2 = temp_date.duplicate()
	var month_end:bool = false
	var end_before_last_week:bool = false
	var invisible:bool = false
	var i:int = 1
	var out:int = 1
	for child in %DaysContainer.get_children():
		# connect press to signal
		month_end = false
		if child.day_pressed.is_connected(self.day_pressed):
			child.disconnect("day_pressed", self.day_pressed)
		var day_n = i - first_day
		if day_n > month_days:
			day_n = i - month_days - 6
			month_end = true
			if i < 37: end_before_last_week = true
		if month_end == false and 0 < day_n:
			child.day_pressed.connect(self.day_pressed)
		if not month_end:
			temp_date2.day = day_n
		if month_end:
			day_n = out
			out += 1
		if end_before_last_week and i > 35: invisible = true
		if day_n < 1:
			day_n = previous_month_days + day_n
			month_end = true
		child._initialize(day_n, date.is_today(temp_date2), month_end, invisible)
		i += 1

func day_pressed(day:int) -> void:
	var datetime = date_selected.duplicate()
	datetime.day = day
	datetime.erase("weekday")
	date_pressed.emit(datetime)
#	print(datetime)

# ---------------------------------------------------------------------------- #
# --- Changing month by buttons

func change_month(amount:int) -> void:
	date_selected.month += amount
	self._fix_date(date_selected)
	self._calc_days_number(date_selected)
	self._set_month_year_labels()

func _fix_date(datetime:Dictionary) -> void:
	if datetime.month < 1:
		datetime.month = 12
		datetime.year -= 1
	if datetime.month > 12:
		datetime.month = 1
		datetime.year += 1
