/// @function  Print(message [, message]);
/// @description Prints on the console every parameter given to the function.
/// @parameter [ Message ]
function Print(messsage) {
	if ( argument_count == 1 ) show_debug_message(messsage);
	else {
		var totalMessage = "";
		for ( var i=0; i < argument_count - 1 ; i++ ) totalMessage += string(argument[i]) + " ";
		totalMessage += string(argument[argument_count - 1]);
			
		show_debug_message(totalMessage);
	}
};

/// @function DefaultValue(variable, defaultValue)
/// @description Sets the given variable to the default value if it is undefined.
/// @parameter variable
/// @parameter defaultValue
function DefaultValue(variable, defaultValue) {
	return ( variable == undefined ) ? defaultValue : variable;
};

/// @function IsIn(value, list)
/// @description Checks if the given list contains the value.
/// @parameter value
/// @parameter {Array} list
function IsIn(value, list) {	
	for( var i=0 ; i<array_length(list) ; i++ ) {
		if ( list[i] == value ) return true;
	}
	
	return false;
};

/// @function Within(value, minimum, maximum)
/// @description Checks if the given value is between the min and the max.
/// @parameter {Real} value
/// @parameter {Real} minimum
/// @parameter {Real} maximum
function Within(value, minimum, maximum) {	
	return value >= minimum && value <= maximum;
};

/// @function approach(from, to, amount)
/// @description Approach by a constant the given amount in the direction of the target value.
/// @parameter {Real} from
/// @parameter {Real} to
/// @parameter {Real} amount
function Approach(from, to, amount) {
	if(from < to){
		return min(from + amount, to); 
	}else{
		return max(from - amount, to);
	}
};

/// @function DoLater(frames, func)
/// @description Executes the given function in the specified frames
/// @parameter {Real} frames
/// @parameter {Function} func
function DoLater(frames, func) {
	var inst = instance_create_depth(0, 0, 0, DoLaterInstance);
	inst.invoker = id;
	inst.FunctionToExecute = method(inst, func);
	inst.alarm[0] = frames;
};

/// @function Wave(from, to, period, offset)
/// @description Gives an oscilated value between two numbers in the given amount of milisecons.
/// @parameter {Real} from
/// @parameter {Real} to
/// @parameter {Real} period
/// @parameter [ {Real} offset ]
function Wave(from, to, period, offset) {
	offset = DefaultValue(offset, 0);
	var amplitude = ( to - from ) / 2;
	return from + amplitude + amplitude * sin( 2 * pi * current_time / period + offset * period );
};

/// @function Wrap(value, minimum, maximum)
/// @description If the given value surpases one of the boundaries it appears by the other side.
/// @parameter {Real} value
/// @parameter {Real} minimum
/// @parameter {Real} maximum
function Wrap(value, minimum, maximum) {
	var range = maximum - minimum;
	while(value >= maximum) value -= range;
	while(value < minimum) value += range;
	return value;
};

/// @function Split(str, separator)
/// @description Returns an array split by the separator
/// @param {real} str
/// @param {real} separator
function Split(str, separator) {
	var splitStr = [str];
	var l = 0;
	var sepL = string_length(separator);
	while(string_pos(separator, splitStr[l])) {
		var pos = string_pos(separator, splitStr[l]);
		var aux = splitStr[l];
		splitStr[l] = string_copy(aux, 0, pos-1);
		splitStr[l+1] = string_copy(aux, pos+sepL, string_length(aux) - pos - sepL + 1);
		l++;
	};
	
	var blank = 0;
	var l = array_length(splitStr);
	for(var i=0; i<l-blank ; i++) {
		if (splitStr[i]==EMPTY_STRING) {
			var aux = splitStr[l-1-blank];
			splitStr[l-1-blank] = splitStr[i];
			splitStr[i] = aux;
			blank++;
		}
	}
	array_resize(splitStr, l-blank);
	
	return splitStr;
};

function Modulo(n, m) {
	return n - floor( n / m ) * m;
};



