@tool
class_name Date
extends Node

var month_days:Dictionary = {
	1: 31, 2:28, 3:31, 4:30,
	5: 31, 6:30, 7:31, 8:31,
	9: 30,10:31,11:30,12:31
}

var month_names:Array = ["", 
	"january", "february", "march", 
	"april", "may", "june", 
	"july", "august", "settember",
	"october", "november", "december"
	]

var today:Dictionary
var month:int = 0
var year:int = 0

func _ready() -> void:
	self._calc_today()

func _calc_today() -> void:
	today = Time.get_date_dict_from_system()
	self.month = today.month
	self.year = today.year

func first_day_of_the_month(date:Dictionary) -> int:
	var unix_time_day = Time.get_unix_time_from_datetime_dict(date)
	var first_day_unix_time = unix_time_day - date.day * 24 * 60 * 60
	var week_day = Time.get_datetime_dict_from_unix_time(first_day_unix_time)['weekday']
	return week_day

func get_month_days(date:Dictionary) -> int:
	if date.month == 2 and date.year % 4 == 0: return 29
	return month_days[date.month]

func is_the_same_day(dt1:Dictionary, dt2:Dictionary) -> bool:
	if dt1.year != dt2.year or dt1.month != dt2.month or dt1.day != dt2.day:
		return false
	return true

func is_today(date:Dictionary) -> bool:
	if self.is_the_same_day(today, date):
		return true
	return false
