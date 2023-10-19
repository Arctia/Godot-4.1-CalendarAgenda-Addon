@tool
class_name Calendar
extends VBoxContainer

# Emitting {"year": x:int, "month": y:int, "day": z:int} when a day is pressed
signal date_pressed(timedate:Dictionary)

@export var day_name : bool = true
@export var abbreviate_form : bool = true
@export var min_cell_width : int = 36
@export var min_cell_height : int = 36

var days_one_letter = ["M", "T", "W", "T", "F", "S", "S"]
var days_abbreviate = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

var date:Date
var day_tscn = preload("res://addons/calendar/day.tscn")
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
	if abbreviate_form: form = days_abbreviate
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


func day_signal_disconnect(day:Day) -> void:
	if day.day_pressed.is_connected(self.day_pressed):
		day.disconnect("day_pressed", self.day_pressed)


func day_signal_connect(day:Day, eom:bool, day_n:int) -> void:
	if not eom and day_n > 0:
		day.day_pressed.connect(self.day_pressed)


func day_should_be_invisible(full_last_week:bool, i:int) -> bool:
	if full_last_week and i > 35:
		return true
	return false


func _calc_days_number(temp_date:Dictionary = {}) -> void:
	if temp_date.is_empty(): temp_date = date.today
	var first_day = date.first_day_of_the_month(temp_date)
	var month_days = date.get_month_days(temp_date)
	var previous_month_days = get_previous_month_days(temp_date)
	
	var temp_date2 = temp_date.duplicate()
	var end_of_month:bool = false
	var end_before_last_week:bool = false
	var i:int = 0
	var out:int = 1
	
	for child in %DaysContainer.get_children():
		day_signal_disconnect(child)
		end_of_month = false
		i += 1
		var day_number = i - first_day
		
		if day_number > month_days:
			day_number = i - month_days - 6
			end_of_month = true
			if i < 37:
				end_before_last_week = true
		
		day_signal_connect(child, end_of_month, day_number)
		
		if not end_of_month:
			temp_date2.day = day_number
		
		if end_of_month:
			day_number = out
			out += 1
		
		if day_number < 1:
			day_number = previous_month_days + day_number
			end_of_month = true
		
		child._initialize(
			day_number, 
			date.is_today(temp_date2), 
			end_of_month, 
			day_should_be_invisible(end_before_last_week, i)
			)


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
