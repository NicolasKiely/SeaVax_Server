/' Creates a raw world, saved in the file name.
 '  Returns empty string on success, error string on failure
 '/

#Include Once "EnvTiles.bi"
#Include Once "SaveRaw.bi"

/' Number of "peaks" to make in initial ground raising '/
#Define INIT_HEIGHT_SPOTS 30

/' Max size of a height spot '/
#Define INIT_MAX_HEIGHT_SPOT 50

/' Max width of a height spot '/
#Define INIT_MAX_WIDTH_SPOT 50

/' Maximum elevation to normalize with '/
#Define MAX_ELEVATION 100

/' Maximum precipitation '/
#Define MAX_PRECIP 100

/' Maximum temperature '/
#Define MAX_TEMP 100

/' Max current velocity '/
#Define MAX_VEL 100


/' Default number of rows and columns in world '/
#Define WORLD_ROWS 100
#Define WORLD_COLS 100

#Define COR_FORCE (MAX_VEL/10)


/' Attempts to generate and save a world. Returns empty string on success '/
Declare Function generateWorld(worldName As String) As String

/' Applies a random height function to the set '/
Declare sub applyHeightMap(pTileSet As EnvTileSet Ptr, heightSpots As Integer)

/' Function whos graph of returned y wrt x is hill shaped '/
Declare Function hillFunc(hillHeight As single, hillWidth As single, x As Single) As Single

/' Sets base temperature from latitude and elevation '/
Declare Sub applyLatElevTemp(pTileSet As EnvTileSet Ptr)

/' Initializes ocean currents '/
Declare sub initOceanCurrents(pTileSet As EnvTileSet ptr, maxCor As single)

/' Iterates forces on ocean currents '/
Declare Sub iterateOceanCurrents(pTileSet As EnvTileSet Ptr, maxCor As Single, maxIter As Integer)

/' Applies a precipitation map from the oceans '/
Declare Sub applyPrecipMap(pTileSet As EnvTileSet Ptr, maxPrecipLoad As Single)

/' Applies a ray of precipitation from a source across the map '/
Declare Sub applyPrecipRay(pTileSet As EnvTileSet Ptr, initLoad As Single, r As Integer, c As Integer, v As Current)