
Rem
	bbdoc: Maximus sources handler.
End Rem
Type mxSourcesHandler Extends dObjectMap
	
	Rem
		bbdoc: Add the given scope to the handler.
		returns: True if the scope was added, or False if it was not (scope is Null).
	End Rem
	Method AddScope:Int(modscope:mxModuleScope)
		If modscope <> Null
			_Insert(modscope.GetName(), modscope)
			Return True
		End If
		Return False
	End Method
	
	Rem
		bbdoc: Check if the handler has a scope with the given name.
		returns: True if a scope with the given name was found, or False if there is no scope with the given name.
	End Rem
	Method HasScope:Int(scopename:String)
		Return _Contains(scopename)
	End Method
	
	Rem
		bbdoc: Check if the given module is in the sources.
		returns: True if the sources contains the given module, or False if it does not.
	End Rem
	Method HasModule:Int(modid:String)
		Local scope:mxModuleScope = GetScopeWithName(mxModUtils.GetScopeFromID(modid))
		If scope <> Null
			Return scope.HasModule(mxModUtils.GetNameFromID(modid))
		End If
		Return False
	End Method
	
	Rem
		bbdoc: Get the scope with the given name.
		returns: The scope with the given name, or Null if there is no scope with the given name.
	End Rem
	Method GetScopeWithName:mxModuleScope(scopename:String)
		Return mxModuleScope(_ValueByKey(scopename))
	End Method
	
	Rem
		bbdoc: Get the module with the given id.
		returns: The module with the given id, or Null if there is no module with the given id.
	End Rem
	Method GetModuleWithID:mxModule(modid:String)
		Local scope:mxModuleScope = GetScopeWithName(mxModUtils.GetScopeFromID(modid))
		If scope <> Null
			Return scope.GetModuleWithName(mxModUtils.GetNameFromID(modid))
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Get the module version with the given versioned-id.
		returns: The module version with the given versioned-id, or Null if there is no module/version with the given versioned-id.
	End Rem
	Method GetVersionWithVerID:mxModuleVersion(verid:String)
		Local modul:mxModule = GetModuleWithID(verid)
		If modul <> Null
			Return modul.GetVersionWithName(mxModUtils.GetVersionFromVerID(verid))
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Load the given file into the handler.
		returns: Itself, or Null if the given file either could not be opened or does not exist.
	End Rem
	Method FromFile:mxSourcesHandler(file:String)
		Local jreader:dJReader, root:dJObject
		jreader = New dJReader.InitWithStream(file)
		If jreader <> Null
			Try
				root = jreader.Parse()
			Catch e:JException
				ThrowError(_s("errors.load.sources.parse", [e.ToString()]))
			End Try
			FromJSON(root)
			Return Self
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Load the given dJObject into the handler.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxSourcesHandler(root:dJObject)
		If root <> Null
			For Local obj:dJObject = EachIn root.GetValues()
				AddScope(New mxModuleScope.FromJSON(obj))
			Next
			Return Self
		End If
		Return Null
	End Method
	
End Type

