tool
extends Resource

class_name Equipment

#export (Texture) var equipment_sprite
export (Texture) var equipment_sprite
var columns = 3
var rows = 6
var faces = []


# Create custom export logic
func _get_property_list():
	var properties = []

	properties.append({
		name = "columns",
		type = TYPE_INT
	})
	
	properties.append({
		name = "rows",
		type = TYPE_INT
	})
	
	if faces.size() == 0:
		faces = calculate_faces()
	
	properties.append({
		name = "faces",
		type = TYPE_ARRAY
	})
	return properties

func calculate_faces():
	faces = []
	
	for column in columns:
		var init_column = []
		
		for row in rows:
			init_column.append(load("res://resources/faces/miss_data.tres"))
		
		faces.append([])
		faces[column] = init_column
	
	return faces
