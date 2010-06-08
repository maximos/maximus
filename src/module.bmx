
Rem
	bbdoc: Maximus module base.
	about: An abstract type for the similarities between module scopes and modules.
End Rem
Type mxModuleBase Abstract
	
	Field m_name:String, m_description:String
	
'#region Field accessors
	
	Rem
		bbdoc: Set the base's name.
		returns: Nothing.
	End Rem
	Method SetName(name:String)
		Assert name, "(mxModuleBase.SetName) name cannot be Null!"
		m_name = name
	End Method
	
	Rem
		bbdoc: Get the base's name.
		returns: The base's name.
	End Rem
	Method GetName:String()
		Return m_name
	End Method
	
	Rem
		bbdoc: Set the base's description.
		returns: Nothing.
	End Rem
	Method SetDescription(description:String)
		Assert description, "(mxModuleBase.SetDescription) description cannot be Null!"
		m_description = description
	End Method
	
	Rem
		bbdoc: Get the base's description.
		returns: The base's description.
	End Rem
	Method GetDescription:String()
		Return m_description
	End Method
	
'#end region Field accessors
	
	Rem
		bbdoc: Set a common field from the given variable.
		returns: True if the given variable was handled, or False if it was not.
	End Rem
	Method SetCommonFromVariable:Int(variable:dVariable)
		Select variable.GetName().ToLower()
			Case "desc"
				SetDescription(variable.ValueAsString())
				Return True
		End Select
		Return False
	End Method
	
End Type

Rem
	bbdoc: Maximus module scope.
End Rem
Type mxModuleScope Extends mxModuleBase
	
	Field m_modules:dObjectMap
	
	Method New()
		m_modules = New dObjectMap
	End Method
	
	Rem
		bbdoc: Add the given module to the scope.
		returns: True if the module was added, or False if it was not (the module is Null).
	End Rem
	Method AddModule:Int(modul:mxModule)
		If modul <> Null
			m_modules._Insert(modul.GetName(), modul)
			modul.SetParent(Self)
			Return True
		End If
		Return False
	End Method
	
	Rem
		bbdoc: Check if the given module name is found in the scope.
		returns: True if the given module was found in the scope, or False if it was not.
	End Rem
	Method HasModule:Int(modname:String)
		Return m_modules._Contains(modname)
	End Method
	
	Rem
		bbdoc: Get a module with the given name.
		returns: The module with the given name, or Null if there is no module with the given name.
	End Rem
	Method GetModuleWithName:mxModule(modname:String)
		Return mxModule(m_modules._ValueByKey(modname))
	End Method
	
	Rem
		bbdoc: Load the given dJObject into the scope.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxModuleScope(root:dJObject)
		If root <> Null
			SetName(root.GetName())
			For Local variable:dVariable = EachIn root.GetValues()
				If dJObject(variable)
					AddModule(New mxModule.FromJSON(dJObject(variable)))
				Else
					SetCommonFromVariable(variable)
				End If
			Next
			Return Self
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Get the module enumerator for the scope.
		returns: The module enumerator for the scope.
	End Rem
	Method ModuleEnumerator:TMapEnumerator()
		Return m_modules.ValueEnumerator()
	End Method
	
End Type

Rem
	bbdoc: Maximus module.
End Rem
Type mxModule Extends mxModuleBase
	
	Field m_parent:mxModuleScope
	Field m_versions:dObjectMap
	
	Method New()
		m_versions = New dObjectMap
	End Method
	
'#region Field accessors
	
	Rem
		bbdoc: Set the module's parent.
		returns: Nothing.
	End Rem
	Method SetParent(parent:mxModuleScope)
		m_parent = parent
	End Method
	
	Rem
		bbdoc: Get the module's parent.
		returns: The module's parent.
	End Rem
	Method GetParent:mxModuleScope()
		Return m_parent
	End Method
	
	Rem
		bbdoc: Get the full name of the module (e.g. "modscope.module").
		returns: The full name of the module.
	End Rem
	Method GetFullName:String()
		Return m_parent.m_name + "." + m_name
	End Method
	
'#end region Field accessors
	
	Rem
		bbdoc: Add the given version to the module.
		returns: True if the version was added, or False if it was not (the version is Null).
	End Rem
	Method AddVersion:Int(version:mxModuleVersion)
		If version <> Null
			m_versions._Insert(version.GetName(), version)
			version.SetParent(Self)
			Return True
		End If
		Return False
	End Method
	
	Rem
		bbdoc: Check if there is a version with the given name.
		returns: True if the version was found, or False if it was not.
	End Rem
	Method HasVersion:Int(name:String)
		Return m_versions._Contains(name)
	End Method
	
	Rem
		bbdoc: Get a version with the given name.
		returns: The version with the given name, or Null if there is no version with the given name.
	End Rem
	Method GetVersionWithName:mxModuleVersion(name:String)
		Return mxModuleVersion(m_versions._ValueByKey(name))
	End Method
	
	Rem
		bbdoc: Get the latest (non-dev) version for this module.
		returns: The latest version for this module.
	End Rem
	Method GetLatestVersion:mxModuleVersion()
		Local hver:mxModuleVersion
		For Local ver:mxModuleVersion = EachIn VersionEnumerator()
			If ver.GetName() <> "dev"
				If hver = Null Or hver.Compare(ver) = 1
					hver = ver
				End If
			End If
		Next
		Return hver
	End Method
	
	Rem
		bbdoc: Set a common field from the given variable.
		returns: True if the given variable was handled, or False if it was not.
	End Rem
	Method SetCommonFromVariable:Int(variable:dVariable)
		If Super.SetCommonFromVariable(variable) = True
			Return True
		Else
			Select variable.GetName().ToLower()
				Case "versions"
					For Local jobj:dJObject = EachIn dJObject(variable).GetValues()
						AddVersion(New mxModuleVersion.FromJSON(jobj))
					Next
			End Select
			Return False
		End If
	End Method
	
	Rem
		bbdoc: Load the given dJObject into the module.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxModule(root:dJObject)
		If root <> Null
			SetName(root.GetName())
			For Local variable:dVariable = EachIn root.GetValues()
				SetCommonFromVariable(variable)
			Next
			Return Self
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Get the version enumerator for the module.
		returns: The version enumerator for the module.
	End Rem
	Method VersionEnumerator:TMapEnumerator()
		Return m_versions.ValueEnumerator()
	End Method
	
End Type

Rem
	bbdoc: Maximus module version.
End Rem
Type mxModuleVersion
	
	Field m_parent:mxModule
	Field m_name:String, m_url:String
	Field m_dependencies:mxModuleDependencies
	
	Method New()
		m_dependencies = New mxModuleDependencies
	End Method
	
'#region Field accessors
	
	Rem
		bbdoc: Set the version's parent.
		returns: Nothing.
	End Rem
	Method SetParent(parent:mxModule)
		m_parent = parent
	End Method
	
	Rem
		bbdoc: Get the version's parent.
		returns: The version's parent.
	End Rem
	Method GetParent:mxModule()
		Return m_parent
	End Method
	
	Rem
		bbdoc: Set the version's name.
		returns: Nothing.
	End Rem
	Method SetName(name:String)
		Assert name, "(mxModuleVersion.SetName) name cannot be Null!"
		m_name = name
	End Method
	
	Rem
		bbdoc: Get the version's name.
		returns: The version's name.
	End Rem
	Method GetName:String()
		Return m_name
	End Method
	
	Rem
		bbdoc: Set the version's url.
		returns: Nothing.
	End Rem
	Method SetUrl(url:String)
		Assert url, "(mxModuleVersion.SetUrl) url cannot be Null!"
		m_url = url
	End Method
	
	Rem
		bbdoc: Get the version's url.
		returns: The version's url.
	End Rem
	Method GetUrl:String()
		Return m_url
	End Method
	
	Rem
		bbdoc: Get the temporary fetch path for the version's source archive.
		returns: The temporary file path for the version's source archive.
	End Rem
	Method GetTemporaryFilePath:String()
		Return "tmp/" + m_parent.GetFullName() + "-" + m_name + ".zip"
	End Method
	
	Rem
		bbdoc: Set the version's dependencies.
		returns: Nothing.
	End Rem
	Method SetDependencies(dependencies:mxModuleDependencies)
		m_dependencies = dependencies
	End Method
	
	Rem
		bbdoc: Get the version's dependencies.
		returns: The version's dependencies.
	End Rem
	Method GetDependencies:mxModuleDependencies()
		Return m_dependencies
	End Method
	
	Rem
		bbdoc: Get the version parts for the version.
		returns: True if the version is development, in which case the parameters are both 0; or False, in which case the parameters are set accordingly.
	End Rem
	Method GetVersionParts:Int(vmajor:String Var, vminor:String Var)
		If m_name <> "dev"
			Local i:Int = m_name.Find(".")
			If i > -1
				vmajor = m_name[..i]
				vminor = m_name[i + 1..]
			Else
				vmajor = m_name ' I'm not sure what other version formats would be used, so I'm just playing a random card here
			End If
			Return False
		End If
		Return True
	End Method
	
'#end region Field accessors
	
	Rem
		bbdoc: Set a common field from the given variable.
		returns: True if the given variable was handled, or False if it was not.
	End Rem
	Method SetCommonFromVariable:Int(variable:dVariable)
		Select variable.GetName().ToLower()
			Case "url"
				SetUrl(variable.ValueAsString())
			Case "deps"
				m_dependencies.FromJSON(dJArray(variable))
				Return True
		End Select
		Return False
	End Method
	
	Rem
		bbdoc: Load the given dJObject into the version.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxModuleVersion(root:dJObject)
		If root <> Null
			SetName(root.GetName())
			For Local variable:dVariable = EachIn root.GetValues()
				SetCommonFromVariable(variable)
			Next
			Return Self
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Get the dependency enumerator for the version.
		returns: The dependency enumerator for the version.
	End Rem
	Method DependencyEnumerator:TMapEnumerator()
		Return m_dependencies.DependencyEnumerator()
	End Method
	
	Rem
		bbdoc: Compare the version with the given version.
		returns: 0 if the two versions are the same (same in version number alone), 1 if this version is greater than the given, or -1 if the given version is greater than this version.
	End Rem
	Method Compare:Int(with:Object)
		Local ver:mxModuleVersion = mxModuleVersion(with)
		If ver <> Null
			If m_name = ver.m_name
				Return 0
			Else
				Local smajor:String, sminor:String, wmajor:String, wminor:String
				Local sdev:Int = GetVersionParts(smajor, sminor), wdev:Int = ver.GetVersionParts(wmajor, wminor)
				If (sdev = True And wdev = True) Or (smajor = wmajor And sminor = wminor)
					Return 0
				Else If smajor > wmajor
					Return 1
				Else If smajor = wmajor
					If sminor > wminor
						Return 1
					Else
						Return -1
					End If
				Else
					Return -1
				End If
			End If
		End If
		Return 0
	End Method
	
	Rem
		bbdoc: Fetch the version's source archive.
		returns: Nothing.
	End Rem
	Method FetchSourceArchive()
		Local file:String = GetTemporaryFilePath()
		logger.LogMessage("fetching: " + GetUrl() + " -> " + file + "~t", False)
		If FileType(file) = FILETYPE_NONE
			Local stream:TStream = WriteFileExplicitly(file)
			If stream <> Null
				Local request:TRESTRequest = New TRESTRequest, response:TRESTResponse
				request.SetProgressCallback(_ProgressCallback, New _mxProgressStore)
				request.SetStream(stream)
				Try
					response = request.Call(GetUrl(), ["User-Agent: " + mainapp.m_useragent], "GET")
				Catch e:Object
					stream.Close()
					DeleteFile(file)
					logger.LogMessage("")
					ThrowError(_s("error.fetch.archive", [e.ToString()]))
				End Try
				stream.Close()
				If response.responseCode = 200
					logger.LogMessage(_s("message.fetch.done", [String(response.responseCode)]))
				Else
					DeleteFile(file)
					logger.LogMessage("")
					ThrowError(_s("error.fetch.archive", ["Bad response code: " + String(response.responseCode)]))
				End If
			Else
				ThrowError(_s("error.writeperms", [file]))
			End If
		Else
			logger.LogMessage(_s("message.fetch.alreadyfetched"))
		End If
	End Method
	
	Rem
		bbdoc: Progress callback for source archive fetching.
		returns: Zero (no error).
	End Rem
	Function _ProgressCallback:Int(data:Object, dltotal:Double, dlnow:Double, ultotal:Double, ulnow:Double)
		Local store:_mxProgressStore = _mxProgressStore(data)
		Local prog:Int = (dlnow / dltotal) * 100
		If prog > store.m_progress + 5
			store.m_progress = prog
			WriteStdOut(".")
		End If
		Return 0
	End Function
	
End Type

