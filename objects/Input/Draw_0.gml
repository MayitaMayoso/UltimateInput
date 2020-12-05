
SetConfiguration("Menu");
var instanceDir = ( CheckRepeated("Down") - CheckRepeated("Up") ) * abs( Check("Down") - Check("Up") );
var keysDir = ( CheckRepeated("Right") - CheckRepeated("Left") ) * abs( Check("Right") - Check("Left") );
var key = Draw("GamerMode", instanceDir, keysDir);
ChangeKey(key, CheckPressed("Accept"), CheckPressed("Cancel"));