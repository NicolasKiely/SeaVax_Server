#Include Once "EnvTiles.bi"

/' Displays different renderings of the environment tiles '/


/' Draws a coordinate block to an image '/
Declare Sub drawBlock(pImg As Integer Ptr, blockSize As Integer, c As Integer, r As Integer, blockC As UInteger)

/' Draw a current line to an image '/
Declare Sub drawCurrent(pImg As Integer Ptr, bs As Integer, bc As UInteger, c As Integer, r As Integer, cur As Current)

/' Creates a comprehensive render of an env tile set '/ 
Declare sub RenderCompEnv(pTiles As EnvTileSet Ptr, pixelSize As Integer, fileName As String)

/' Creates a render of the temperatures of a tile set '/
Declare Sub renderTempEnv(pTiles As EnvTileSet Ptr, pixelSize As Integer, fileName As String)

/' Creates a picture of the ocean currents. Perferably use non-even pixel size '/
Declare Sub renderOceanCurrent(pTiles As EnvTileSet Ptr, pixelSize As Integer, fileName As String)

/' Creates a picture of the precipitation amounts of a tile set '/
Declare Sub renderPrecipEnv(pTiles As EnvTileSet Ptr, pixelSize As Integer, fileName As String)