/'----------------------------------------------------------------------------
 ' Linked list of plugins
 ----------------------------------------------------------------------------'/
Type Plugin
	Dim As String plugName
	
	Dim As Plugin Ptr pNext
End Type


/'----------------------------------------------------------------------------
 ' Manages plugins for server
 ----------------------------------------------------------------------------'/
Type PluginManager
	/' Root node in plugin list '/
	Dim As Plugin Ptr pRoot
End Type
