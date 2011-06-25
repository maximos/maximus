
Rem
	bbdoc: Maximus module base.
	about: An abstract type for the similarities between module scopes and modules.
End Rem
Type mxModuleBase Abstract
	
	Field m_name:String
	
'#region Field accessors
	
	Rem
		bbdoc: Set the base's name.
		returns: Nothing.
	End Rem
	Method SetName(name:String)
		Assert name, "(mxModuleBase.SetName) name cannot be Null"
		m_name = name
	End Method
	
	Rem
		bbdoc: Get the base's name.
		returns: The base's name.
	End Rem
	Method GetName:String()
		Return m_name
	End Method
	
'#end region Field accessors
	
	Rem
		bbdoc: Set a common field from the given variable.
		returns: True if the given variable was handled, or False if it was not.
	End Rem
	Method SetCommonFromVariable:Int(variable:dVariable)
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
		If modul
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
		Return mxModule(m_modules._ObjectWithKey(modname))
	End Method
	
	Rem
		bbdoc: Load the given dJObject into the scope.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxModuleScope(root:dJObject)
		If root
			SetName(root.GetName())
			For Local variable:dVariable = EachIn root
				If dJObject(variable)
					AddModule(New mxModule.FromJSON(dJObject(variable)))
				'Else
				'	SetCommonFromVariable(variable)
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
	Field m_description:String
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
	
	Rem
		bbdoc: Set the module's description.
		returns: Nothing.
	End Rem
	Method SetDescription(description:String)
		m_description = description
	End Method
	
	Rem
		bbdoc: Get the module's description.
		returns: The module's description.
	End Rem
	Method GetDescription:String()
		Return m_description
	End Method
	
'#end region Field accessors
	
	Rem
		bbdoc: Get the installed version of the module (if it is installed).
		returns: The version of the module that is installed, or Null if the module is not installed.
	End Rem
	Method GetInstalledVersion:mxModuleVersion()
		Local version:String = mxModUtils.GetInstalledVersionFromVerID(GetFullName())
		If version
			Return New mxModuleVersion.Create(Self, version, Null)
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Add the given version to the module.
		returns: True if the version was added, or False if it was not (the version is Null).
	End Rem
	Method AddVersion:Int(version:mxModuleVersion)
		If version
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
		Return mxModuleVersion(m_versions._ObjectWithKey(name))
	End Method
	
	Rem
		bbdoc: Get the latest (non-dev if available) version for this module.
		returns: The latest version for this module.
		about: The latest version will be returned, or the dev version if it is the only version.
	End Rem
	Method GetLatestVersion:mxModuleVersion()
		Local hver:mxModuleVersion
		For Local ver:mxModuleVersion = EachIn VersionEnumerator()
			If ver.GetName() <> "dev"
				If Not hver Or ver.Compare(hver) = 1
					hver = ver
				End If
			End If
		Next
		If Not hver
			hver = GetVersionWithName("dev")
		End If
		Return hver
	End Method
	
	Rem
		bbdoc: Set a common field from the given variable.
		returns: True if the given variable was handled, or False if it was not.
	End Rem
	Method SetCommonFromVariable:Int(variable:dVariable)
		If Super.SetCommonFromVariable(variable)
			Return True
		Else
			Select variable.GetName().ToLower()
				Case "desc"
					SetDescription(dValueVariable(variable).ValueAsString())
				Case "versions"
					For Local jobj:dJObject = EachIn dJObject(variable)
						AddVersion(New mxModuleVersion.FromJSON(jobj))
					Next
				Default
					Return False
			End Select
			Return True
		End If
	End Method
	
	Rem
		bbdoc: Load the given dJObject into the module.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxModule(root:dJObject)
		If root
			SetName(root.GetName())
			For Local variable:dVariable = EachIn root
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
	
	Rem
		bbdoc: Create a module version.
		returns: Itself.
	End Rem
	Method Create:mxModuleVersion(parent:mxModule, name:String, url:String)
		SetParent(parent)
		SetName(name)
		SetUrl(url)
		Return Self
	End Method
	
	Rem
		bbdoc: Clone the version.
		returns: A clone of the version.
		about: If @withdeps is True (default value), the dependencies will be added as well.
	End Rem
	Method Clone:mxModuleVersion(withdeps:Int = True)
		Local v:mxModuleVersion = New mxModuleVersion.Create(m_parent, m_name, m_url)
		For Local dep:mxModuleDependency = EachIn DependencyEnumerator()
			v.m_dependencies.AddDependency(dep)
		Next
		Return v
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
		'Assert url, "(mxModuleVersion.SetUrl) url cannot be Null!"
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
	
'#end region Field accessors
	
	Rem
		bbdoc: Set a common field from the given variable.
		returns: True if the given variable was handled, or False if it was not.
	End Rem
	Method SetCommonFromVariable:Int(variable:dVariable)
		Select variable.GetName().ToLower()
			Case "url"
				SetUrl(dValueVariable(variable).ValueAsString())
			Case "deps"
				m_dependencies.FromJSON(dJArray(variable))
			Default
				Return False
		End Select
		Return True
	End Method
	
	Rem
		bbdoc: Load the given dJObject into the version.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxModuleVersion(root:dJObject)
		If root
			SetName(root.GetName())
			For Local variable:dVariable = EachIn root
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
		If ver
			Local version1:mxVersionObject = New mxVersionObject.Parse(m_name)
			Local version2:mxVersionObject = New mxVersionObject.Parse(ver.m_name)
			Return version1.Compare(version2)
		End If
		Return Super.Compare(with)
	End Method
	
	Rem
		bbdoc: Fetch the version's source archive.
		returns: Nothing.
	End Rem
	Method FetchSourceArchive()
		Local file:String = GetTemporaryFilePath()
		logger.LogMessage("fetching: " + GetUrl() + " -> " + file + "    ", False)
		If FileType(file) = FILETYPE_NONE
			Local stream:TStream = WriteFileExplicitly(file)
			If stream
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

Rem
	bbdoc: A object representing a version, not to be confused with mxModuleVersion
	about: Supported formats are 1, 1.1 and 1.1.1.
	Do note that because the version is represented as a Double there's a change
	the precision of the final number is off.
	
	1.1.2 Would be converted to 1.001002 but when converted to a Double it results
	in 1.0010019999999999.
	
	1.1.12 However would be converted to 1.001012 and when converted to a Double it
	results in 1.0010120000000000.
	
	A version string of 'dev' will be represented as 99999
End Rem
Type mxVersionObject

	Field m_version:Double

	Rem
		bbdoc: Parse a version string
		returns: Itself.
	End Rem
	Method Parse:mxVersionObject(version:String)
		If version = "dev"
			m_version = 99999
			Return Self
		End If

		Local parts:String[] = version.Split(".")
		Local converted:String = parts[0]
		If parts.Length > 1
			converted:+"."
			For Local part:String = EachIn parts[1..]
				While part.Length <> 3
					part = "0" + part
				WEnd
				converted:+part
			Next

			'Make sure we format to x.x.x
			If parts.Length = 2
				converted:+"000"
			End If
		End If

		m_version = converted.ToDouble()
		Return Self
	End Method

	Rem
		bbdoc: Compare version numbers
	End Rem
	Method Compare:Int(withObject:Object)
		Local version:mxVersionObject = mxVersionObject(withObject)
		If version
			If m_version = version.m_version
				Return 0
			Else If m_version > version.m_version
				Return 1
			Else If m_version < version.m_version
				Return - 1
			End If
		End If
		Return Super.Compare(withObject)
	End Method
End Type

Rem
	bbdoc: Maximus metafile handler
End Rem
Type mxMetaFile

	Field m_metafile:String
	Field m_scope:String
	Field m_name:String
	Field m_version:String
	
	Rem
		bbdoc: Create a metafile handler.
		returns: Itself.
	End Rem
	Method Create:mxMetaFile(metafile:String)
		SetMetaFile(metafile)
		Return Self
	End Method
	
'#region Field accessors
	
	Rem
		bbdoc: Set the metafile file path.
		returns: Nothing.
	End Rem
	Method SetMetaFile(metafile:String)
		m_metafile = metafile
	End Method
	
	Rem
		bbdoc: Get the metafile path.
		returns: The metafile path.
	End Rem
	Method GetMetaFile:String()
		Return m_metafile
	End Method
	
	Rem
		bbdoc: Set metadata
		returns: Nothing.
	End Rem
	Method SetMetaData(scope:String, name:String, version:String)
		Self.m_scope = scope
		Self.m_name = name
		Self.m_version = version
	End Method
	
'#end region Field accessors
	
	Rem
		bbdoc: Load the configuration.
		returns: Nothing.
	End Rem
	Method Load()
		If FileType(GetMetaFile()) = FILETYPE_FILE
			Try
				Local contents:String = LoadText(GetMetaFile()).Trim()
				Local parts:String[] = contents.Split("/")
				
				If parts.Length <> 2
					Throw _s("error.load.meta.invalid_format") ;
				End If
				
				Local modinfo:String[] = parts[0].Split(".")
				m_scope = modinfo[0]
				m_name = modinfo[1]
				m_version = parts[1]
			Catch e:Object
				logger.LogError(_s("error.load.metafile.parse", [GetMetaFile()]))
				logger.LogError(e.ToString())
			End Try
		Else
			logger.LogWarning(_s("error.load.metafile.notfound", [GetMetaFile()]))
		End If
	End Method
	
	Rem
		bbdoc: Save the configuration
		returns: Nothing.
	End Rem
	Method Save()
		If m_scope.Length = 0 Or m_name.Length = 0 Or m_version.Length = 0
			ThrowError(_s("error.save.metafile.incomplete", [m_scope, m_name, m_version]))
		End If
		
		Local file:String = GetMetaFile()
		Local stream:TStream = WriteFileExplicitly(file)
		If stream
			stream.WriteString(m_scope + "." + m_name + "/" + m_version)
			stream.Close
		Else
			ThrowError(_s("error.writeperms", [file]))
		End If
	End Method
End Type
