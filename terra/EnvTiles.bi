#Include Once "Current.bi"

/' Environmental properties of a tile
 ' Represents average annual climate
 '/
Type EnvTile
	/' Precipitation/humidity '/
	precip As Single
	
	/' Average temperature '/
	temp As Single
	
	/' Average elevation '/
	elev As Single
	
	/' Ocean current '/
	ocean As Current
	
	/' Calculates and retrieves representative color '/
	Declare Function getColor(maxPrecip As Single, maxTemp As Single, maxElev As single) As UInteger
End Type


/' Set of environmental tiles
 ' Coordinate system: r goes from North to South, c from West to East
 '/
Type EnvTileSet
	/' Number of rows of tiles across the set '/
	rows As Integer
	
	/' Number of columns of tiles across the set '/
	cols As Integer
	
	/' Max height of tiles '/
	maxHeight As Single
	
	/' Max precip on tiles '/
	maxPrecip As Single
	
	/' Max temperature of tiles '/
	maxTemp As Single
	
	/' Max current magnitude '/
	maxVel As Single
	
	/' Array of tiles '/
	pTiles As EnvTile Ptr
	
	/' Initializes set '/
	Declare Constructor(newRows As Integer, newCols As Integer, newMaxHeight As Integer, _
								newMaxPrecip As Integer, newMaxTemp As Integer, newMaxVel As Single)
	
	/' Frees allocated memory '/
	Declare Destructor()
	
	/' Grabs a tile at position (row, column). (0, 0) offset '/
	Declare Function getTile(r As Integer, c As Integer) As EnvTile Ptr
	
	/' Sets average elevation to zero (sea level) '/
	Declare sub normalize()
	
	/' Adjusts so currents max out properly '/
	Declare Sub normalizeCurrents()
	
	/' Adjusts so precip maxes out properly '/
	Declare Sub normalizePrecip()
	
	/' Displays stats '/
	Declare Sub printStats()
	
	/' Get the effects of surrounding currents on a given tile '/
	Declare Function calcOceanDiff(r As Integer, c As Integer) As Current
	
	/' Converts a tiles row position to a latitude. Latitude numbers are in [0, 1] range '/
	Declare Function getLat(r As Integer) As Single
End Type