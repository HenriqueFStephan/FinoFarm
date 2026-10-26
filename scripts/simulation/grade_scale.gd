class_name GradeScale
extends RefCounted

## Abstract quality grades for fictional goods. 1 common, 2 fine, 3 select.

const COMMON := 1
const FINE := 2
const SELECT := 3

static func is_valid(grade: int) -> bool:
	return grade >= COMMON and grade <= SELECT


static func minimum(grades: Array) -> int:
	var best := SELECT
	for value in grades:
		best = mini(best, int(value))
	return best


static func label(grade: int) -> String:
	match grade:
		COMMON:
			return "common"
		FINE:
			return "fine"
		SELECT:
			return "select"
		_:
			return "invalid"
