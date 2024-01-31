
Input.SetConfiguration("Scene1");

if (Input.CheckPressed("TileDestroy")) {
	var tilesCount = instance_number(obj_tile);
	if (tilesCount) {
		repeat(min(30, tilesCount)) {
			var tile = instance_find(obj_tile, irandom(tilesCount-1));
			if (!tile.falling) {
				tile.Destroy();
				tilesCount--;
			}
		}
	}
}









