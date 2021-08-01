extends Node

const Colours : Dictionary = {
	20: Color(1.0,   0.683, 0.107),   # Birch
	4:  Color(0.02,  0.02,  0.02),    # Black
	23: Color(0.55,  0.52,  0.77),    # Blue01
	24: Color(0.029, 0.13,  0.199),   # Blue02
	25: Color(0.139, 0.33,  0.761),   # Blue03
	26: Color(0.202, 0.234, 0.296),   # Blue04
	27: Color(0.36,  0.433, 0.646),   # Blue05
	28: Color(0.406, 0.877, 1.0),     # Blue06
	29: Color(0.134, 0.071, 0.223),   # Blue07
	8:  Color(1.0,   0.0,   0.51),    # Bright_Purple
	11: Color(0.416, 0.098, 0.012),   # Brown
	9:  Color(0.068, 0.028, 0.834),   # Dark_Blue
	17: Color(0.528, 0.059, 0.038),   # Dark_Brown
	21: Color(0.0,   0.136, 0.044),   # Dark_Green
	22: Color(0.097, 0.108, 0.016),   # Dark_Olive
	7:  Color(0.46,  0.679, 0.033),   # Green
	1:  Color(0.288, 0.288, 0.288),   # Grey
	3:  Color(0.0,   0.748, 0.8),     # Light_Blue
	13: Color(0.086, 0.319, 0.074),   # Light_Green
	12: Color(0.603, 0.555, 0.047),   # Light_Olive
	30: Color(0.828, 0.077, 0.81),    # Light_Purple
	16: Color(0.883, 0.03,  0.002),   # Light_Red
	2:  Color(1.0,   0.282, 0.0),     # Orange
	15: Color(1.0,   0.412, 0.412),   # Pale_Pink
	31: Color(0.757, 0.518, 0.846),   # Pale_Purple
	14: Color(1.0,   0.804, 0.38),    # Pale_Yellow
	19: Color(0.321, 0.229, 0.229),   # Pink
	18: Color(0.367, 0.175, 0.211),   # Pinky_Brewster
	10: Color(0.376, 0.0,   0.336),   # Purple
	5:  Color(0.448, 0.008, 0.007),   # Red
	0:  Color(1.0,   1.0,   1.0),     # White
	6:  Color(0.992, 0.867, 0.098),   # Yellow
	34: Color(0,0,0), #idk
	32: Color(0,0,0)  #idk
}

func decode(file : String):
	var f : File = File.new()
	if f.open(file, File.READ) != OK:
		print("Decoder: Couldn't open file!")
		return
	var c : String = f.get_as_text()
	f.close()
	var js = JSON.parse(c)
	if js.error == OK:
		if js.result is Dictionary:
			return [Marshalls.base64_to_raw(js.result["cubeData"]), 
					Marshalls.base64_to_raw(js.result["colourData"])]
	print("Something went wrong!")


func parse(data : PoolByteArray, colour_data : PoolByteArray):
	var expected_count : int = data[0] + data[1]*256 + data[2]*65536 + data[3]*16777216 #The amount of cubes according to the data
	data = data.subarray(4, -1)
	colour_data = colour_data.subarray(4, -1)
	var bot : Array = []
# warning-ignore:integer_division
	if expected_count != len(data)/8:
		print("Parser: Invalid data header! File may be corrupted.")
	
	for i in range(0, len(data), 8):
# warning-ignore:integer_division
		var c : Color = Colours[colour_data[i/2]]
		var id : int = data[i] + data[i+1]*256 + data[i+2]*65536 + data[i+3]*16777216
		var loc : Vector3 = Vector3(data[i+4], data[i+5], data[i+6]) - Vector3(24,0,24)
		var o : int = data[i+7] #orientation
		bot.append([id, loc, o, c])
	return bot

func interpret(file : String):
	var data = decode(file)
	return parse(data[0], data[1])
