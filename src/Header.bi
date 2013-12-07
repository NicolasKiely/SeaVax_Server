/'----------------------------------------------------------------------------
 ' Common defines 'n stuff
 ' Maybe some of this stuff should be changed to config-set variables
 ---------------------------------------------------------------------------'/
 
 
/' Number of times the servers Main() runs '/
#Define LOOP_SLICE (1/20)

/' Number of slices between flushing chat '/
#Define CHAT_SLICE (4)

/' Immediate sock read buffer '/
#Define SMALL_NET_BUFFER 250

/' Per client extra buffer '/
#Define LARGE_NET_BUFFER 1016