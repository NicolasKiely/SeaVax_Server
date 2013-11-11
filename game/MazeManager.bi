#Include Once "../player/Account.bi"
#Include Once "../table/Table.bi"

#Define MAZE_STATS_FILE_NAME "mazes.txt"

/' Maps allowed per-package '/
#Define FREE_MAPS_ALLOWED    1
#Define ENTRY_MAPS_ALLOWED   3
#Define SILVER_MAPS_ALLOWED  5
#Define GOLD_MAPS_ALLOWED   50

/' Max allowed map sizes per package '/
#Define FREE_MAX_MAP_SIZE   10
#Define ENTRY_MAX_MAP_SIZE  20
#Define SILVER_MAX_MAP_SIZE 30
#Define GOLD_MAX_MAP_SIZE   50

/' File maze table headers '/
#Define MAZE_ID_HEADER    "ID"
#Define MAZE_NAME_HEADER  "Name"
#Define MAZE_SIZE_HEADER  "Size"
#Define MAZE_WINS_HEADER  "Wins"
#Define MAZE_PLAYS_HEADER "Plays"
#Define MAZE_STAGED_HEADER "Staged"


#Define MAZE_TILE_PASSABLE   "p"
#Define MAZE_TILE_IMPASSABLE "i"
#Define MAZE_TILE_START      "s"
#Define MAZE_TILE_FINISH     "f"
#Define MAZE_TILE_TRAP       "t"


Type MazeManager
	Dim As Integer foo
	
End Type


/' Gets an accounts maze stats from disk '/
Declare Function loadMazeStats(pAccount As Account Ptr) As Table Ptr


/' Returns 0 if invalid size, -1 if valid '/
Declare Function isValidMapSize(size As Integer) As Integer


/' Finds available index for a new table. -1 on failure '/
Declare Function getFreeMazeIndex(pMazeTab As Table Ptr) As Integer


/' Returns max map size for a give package '/
Declare Function getMaxMazeSize(package As String) As Integer


/' Returns -1 if allowed name, ascii value if not ( >-1 )'/
Declare Function isAllowedMazeName(mazeName As String) As Integer


/' Creates a new maze file '/
Declare Sub initializeMazeFile(pAcc As Account ptr, id As Integer, size As Integer)


/' Loads maze into table '/
Declare Sub loadMazeAsTable(fileName As String, pTable As Table Ptr)