
Rem
	bbdoc: Maximus 'install' argument implementation.
End Rem
Type mxInstallImpl Extends dArgumentImplementation
	
	Field m_instmap:dObjectMap
	Field m_depcheckmap:dObjectMap
	Field m_unmanagedmap:dObjectMap
	Field m_nobuild:Int = False, m_nounpack:Int = False, m_keeptemp:Int = False
	Field m_nothreaded:Int = False, m_makedocs:Int = False, m_forceinstall:Int = False
	Field m_overwriteunmanaged:Int = False
	
	Method New()
		init(["install"])
		m_instmap = New dObjectMap
		m_depcheckmap = New dObjectMap
		m_unmanagedmap = New dObjectMap
	End Method
	
	Rem
		bbdoc: Check the current arguments for errors (according to the specific implementation).
		returns: Nothing.
		about: This method will throw an error if the arguments are invalid.
	End Rem
	Method CheckArgs()
		If GetArgumentCount() = 0
			ThrowCommonError(mxCmdErrors.REQUIRESPARAMS, m_args.GetName())
		End If
		CheckOptions()
	End Method
	
	Rem
		bbdoc: Get a string describing the typical usage of the argument.
		returns: A string describing the typical usage of the argument.
	End Rem
	Method GetUsage:String()
		Return _s("arg.install.usage")
	End Method
	
	Rem
		bbdoc: Execute the implementation's operation.
		returns: Nothing.
	End Rem
	Method Execute()
		m_instmap.Clear()
		m_depcheckmap.Clear()
		m_unmanagedmap.Clear()
		If mainapp.m_sourceshandler
			Local nfounds:dObjectMap = New dObjectMap
			For Local svar:dStringVariable = EachIn m_args
				Local verid:String = svar.Get(), modid:String = mxModUtils.GetIDFromVerID(verid)
				Local modul:mxModule = mainapp.m_sourceshandler.GetModuleWithID(modid)
				If modul
					Local instmod:mxInstModule = New mxInstModule.Create(verid, modul)
					If instmod.SetVersionFromVerID(verid)
						m_instmap._Insert(modid, instmod)
					Else
						ThrowError(_s("arg.install.notfound.version", [modid, mxModUtils.GetVersionFromVerID(verid)]))
					End If
				Else
					nfounds._Insert(modid, modid)
				End If
			Next
			If nfounds.Count() > 0
				logger.LogError(_s("arg.install.notfound.instmods"))
				Local a:String
				For Local b:String = EachIn nfounds.ValueEnumerator()
					a:+ b + " "
				Next
				a = a[..a.Length - 1]
				logger.LogMessage("~t" + a)
				Return
			End If
			If CheckDependencies()
				'Make sure we only install/update managed modules
				If CheckVersions()
					DoInstall()
				End If
			End If
		Else
			ThrowError(_s("error.install.nosources"))
		End If
	End Method
	
	Rem
		bbdoc: Check the options given to the command.
		returns: Nothing.
	End Rem
	Method CheckOptions()
		m_nobuild = False; m_nounpack = False; m_keeptemp = False
		m_nothreaded = False; m_makedocs = False
		For Local opt:dIdentifier = EachIn m_args
			Select opt.GetName().ToLower()
				Case "-nobuild" m_nobuild = True
				Case "-nounpack" m_nounpack = True
				Case "-keeptemp" m_keeptemp = True
				Case "-nothreaded" m_nothreaded = True
				Case "-makedocs" m_makedocs = True
				Case "-force" m_forceinstall = True
				Case "-ignoreunmanaged" m_overwriteunmanaged = True
				Default ThrowCommonError(mxOptErrors.UNKNOWN, opt.GetName())
			End Select
		Next
	End Method
	
	Rem
		bbdoc: Check for version conflictions and warn the user.
		returns: True if the installtion should continue, or False if the user halted the operation.
	End Rem
	Method CheckVersions:Int()
		For Local instmod:mxInstModule = EachIn m_instmap.ValueEnumerator()
			Local ver:String = mxModUtils.GetInstalledVersionFromVerID(instmod.GetVerID())
			'Make sure we skip unmanaged modules
			If ver = "unmanaged"
				If Not m_overwriteunmanaged Then m_instmap._Remove(instmod.GetID())
				m_unmanagedmap._Insert(instmod.GetID(), instmod)
			End If
		Next
		Return True
	End Method
	
	Rem
		bbdoc: Check the dependencies for the modules to be installed.
		returns: Nothing.
	End Rem
	Method CheckDependencies:Int()
		Local nfounds:dObjectMap = New dObjectMap
		For Local instmod:mxInstModule = EachIn m_instmap.ValueEnumerator()
			CheckModuleDependencies(instmod, nfounds)
		Next
		If nfounds.Count() > 0
			logger.LogError(_s("arg.install.notfound.instdeps"))
			Local a:String
			For Local b:String = EachIn nfounds.ValueEnumerator()
				a:+ b + " "
			Next
			a = a[..a.Length - 1]
			logger.LogMessage("~t" + a)
			If m_forceinstall
				m_nobuild = True
				If mainapp.m_userinput.Confirm(_s("arg.install.missingdeps"))
					Return True
				End If
			End If
			Return False
		End If
		Return True
	End Method
	
	Rem
		bbdoc: Check the dependencies for the given module and adapt the install list accordingly.
		returns: Nothing.
	End Rem
	Method CheckModuleDependencies(instmod:mxInstModule, nfounds:dObjectMap)
		Local addlist:TListEx = instmod.CheckCompliance()
		If addlist
			For Local modid:String = EachIn addlist
				If Not m_depcheckmap._Contains(modid)
					Local dmodul:mxModule = mainapp.m_sourceshandler.GetModuleWithID(modid)
					m_depcheckmap._Insert(modid, modid)
					If dmodul
						If Not m_instmap._Contains(modid)
							Local dinstmod:mxInstModule = New mxInstModule.Create(modid, dmodul)
							If instmod.GetVersionName().ToLower() = "dev"
								dinstmod.SetVersionFromName("dev")
							Else
								dinstmod.SetVersion(Null)
							End If
							m_instmap._Insert(modid, dinstmod)
							CheckModuleDependencies(dinstmod, nfounds)
						End If
					Else
						nfounds._Insert(modid, modid)
					End If
				End If
			Next
		End If
	End Method
	
	Rem
		bbdoc: Do the actual installing.
		returns: Nothing.
	End Rem
	Method DoInstall()
		If m_instmap.Count() > 0
			Local a:String, instmod:mxInstModule

			If m_unmanagedmap.Count()
				If m_overwriteunmanaged
					logger.LogMessage(_s("arg.install.modulestooverwrite"))
				Else
					logger.LogMessage(_s("arg.install.modulestoskip"))
				End If
				For instmod = EachIn m_unmanagedmap.ValueEnumerator()
					a:+instmod.GetVerID() + " "
				Next
				a = a[..a.Length - 1]
				logger.LogMessage("~t" + a)
				a = ""
			End If

			logger.LogMessage(_s("arg.install.modulestoinstall"))
			For instmod = EachIn m_instmap.ValueEnumerator()
				a:+ instmod.GetVerID() + " "
			Next
			a = a[..a.Length - 1]
			logger.LogMessage("~t" + a)
			If mainapp.m_userinput.Confirm(_s("arg.install.continuewithinstall"))
				For instmod = EachIn m_instmap.ValueEnumerator()
					instmod.FetchSourceArchive()
				Next
				If Not m_nounpack
					For instmod = EachIn m_instmap.ValueEnumerator()
						instmod.Unpack()
					Next
				Else
					logger.LogMessage(_s("message.skipping.unpack"))
				End If
				If Not m_keeptemp Then DeleteDir("tmp/", True)
				If Not m_nobuild
					Local scopes:dObjectMap = New dObjectMap
					For instmod = EachIn m_instmap.ValueEnumerator()
						scopes._Insert(instmod.GetModuleScope(), instmod.GetModuleScope())
					Next
					For Local scope:String = EachIn scopes.ValueEnumerator()
						If mxBMKUtils.MakeMods(scope, m_nothreaded ~ 1) <> 0
							ThrowError(_s("error.install.build", [scope]))
						End If
					Next
					If m_makedocs
						'For instmod = EachIn m_instmap.ValueEnumerator()
						'	mxModUtils.DocMods(instmod.GetID())
						'Next
						' Can't build docs for individual modules yet
						mxModUtils.DocMods()
					End If
				Else
					logger.LogMessage(_s("message.skipping.install"))
				End If
			End If
		Else
			logger.LogMessage(_s("arg.install.nomodulestoinstall"))
			If m_unmanagedmap.Count()
				logger.LogMessage(_s("arg.install.modulestoskip"))
				Local a:String
				For Local instmod:mxInstModule = EachIn m_unmanagedmap.ValueEnumerator()
					a:+instmod.GetVerID() + " "
				Next
				a = a[..a.Length - 1]
				logger.LogMessage("~t" + a)
			End If
		End If
	End Method
	
End Type

Rem
	bbdoc: Maximus install info module.
	about: This type is used for temporary install information on modules.
End Rem
Type mxInstModule
	
	Field m_id:String
	Field m_version:mxModuleVersion
	Field m_module:mxModule
	
	Rem
		bbdoc: Create a new mxInstModule.
		returns: Itself.
	End Rem
	Method Create:mxInstModule(verid:String, modul:mxModule)
		SetID(mxModUtils.GetIDFromVerID(verid))
		SetModule(modul)
		Return Self
	End Method
	
'#region Field accessors
	
	Rem
		bbdoc: Set the modid to be installed.
		returns: Nothing.
	End Rem
	Method SetID(id:String)
		m_id = id
	End Method
	
	Rem
		bbdoc: Get the modid to be installed.
		returns: The modid to be installed.
	End Rem
	Method GetID:String()
		Return m_id
	End Method
	
	Rem
		bbdoc: Set the version from the given versioned-module name (e.g. "foo.bar/1.02").
		returns: True if the version was set, or False if the version could not be found (was not found).
		about: The latest version will be set if the given id is Null (or if it isn't versioned (e.g. "foo.bar", would result in the latest version being selected)).
	End Rem
	Method SetVersionFromVerID:Int(verid:String)
		Return SetVersionFromName(mxModUtils.GetVersionFromVerID(verid))
	End Method
	
	Rem
		bbdoc: Set the version to be installed from the given version name (e.g. "1.02").
		returns: True if the version was set, or False if the version could not be set (was not found).
		about: The latest version will be set if the given name is Null.
	End Rem
	Method SetVersionFromName:Int(name:String)
		If Not name
			SetVersion(Null) ' Set the latest version (the version wasn't forced)
			Return True
		Else
			Local ver:mxModuleVersion = m_module.GetVersionWithName(name)
			If ver
				SetVersion(ver)
				Return True
			End If
		End If
		Return False
	End Method
	
	Rem
		bbdoc: Set the install version.
		returns: Nothing.
		about: If the given value is Null, it will be automatically set to the latest (non-development) version.
	End Rem
	Method SetVersion(version:mxModuleVersion)
		m_version = version
		If Not m_version
			m_version = m_module.GetLatestVersion()
		End If
	End Method
	
	Rem
		bbdoc: Get the install version.
		returns: The version to be installed.
	End Rem
	Method GetVersion:mxModuleVersion()
		Return m_version
	End Method
	
	Rem
		bbdoc: Set the module to be installed.
		returns: Nothing.
	End Rem
	Method SetModule(modul:mxModule)
		m_module = modul
	End Method
	
	Rem
		bbdoc: Get the module to be installed.
		returns: The module to be installed.
	End Rem
	Method GetModule:mxModule()
		Return m_module
	End Method
	
	Rem
		bbdoc: Get the module's scope.
		returns: The module's scope.
	End Rem
	Method GetModuleScope:String()
		Return mxModUtils.GetScopeFromID(m_id)
	End Method
	
	Rem
		bbdoc: Get the module's name.
		returns: The module's name.
	End Rem
	Method GetModuleName:String()
		Return mxModUtils.GetNameFromID(m_id)
	End Method
	
	Rem
		bbdoc: Get the versioned-module id.
		returns: The exact module to be installed (e.g. "foo.bar/1.02").
	End Rem
	Method GetVerID:String()
		Return m_id + "/" + m_version.GetName()
	End Method
	
	Rem
		bbdoc: Get the name of the version to be installed.
		returns: The name of the version to be installed.
	End Rem
	Method GetVersionName:String()
		Return m_version.GetName()
	End Method
	
'#end region Field accessors
	
	Rem
		bbdoc: Check the dependency compliance of the current module set.
		returns: Null if all dependencies are matched by existing modules, or a list of module ids that are not yet installed.
	End Rem
	Method CheckCompliance:TListEx()
		Return m_version.GetDependencies().CheckCompliance()
	End Method
	
	Rem
		bbdoc: Fetch the source archive for the version to be installed.
		returns: Nothing.
	End Rem
	Method FetchSourceArchive()
		m_version.FetchSourceArchive()
	End Method
	
	Rem
		bbdoc: Unpack the version's archive.
		returns: Nothing.
	End Rem
	Method Unpack()
		Local archivepath:String = m_version.GetTemporaryFilePath()
		Local zreader:ZipReader = New ZipReader
		logger.LogMessage(_s("message.unpacking", [archivepath]))
		If zreader.OpenZip(archivepath)
			Local filename:String, outputpath:String
			Local basepath:String = mainapp.m_modpath + "/" + mxModUtils.GetScopeFromID(m_id) + ".mod/"
			DeleteDir(mxModUtils.ModulePath(m_id), True)
			For Local fileinfo:SZipFileEntry = EachIn zreader.m_zipFileList.FileList
				filename = fileinfo.zipFileName
				outputpath = basepath + filename
				'DebugLog("Zip outputpath: ~q" + outputpath + "~q")
				If filename[filename.Length - 1] = 47 ' "/"
					CreateDir(outputpath, True)
				Else
					If CreateFileExplicitly(outputpath)
						zreader.ExtractFileToDisk(filename, outputpath, False)
					Else
						zreader.CloseZip()
						ThrowError(_s("error.writeperms", [outputpath]))
					End If
				End If
			Next
			zreader.CloseZip()

			Local metafile:mxMetaFile = New mxMetaFile.Create(basepath + GetModuleName() + ".mod/meta.maximus")
			metafile.SetMetaData(GetModuleScope(), GetModuleName(), GetVersionName())
			metafile.Save()
		Else
			ThrowError(_s("error.install.openarchive", [archivepath]))
		End If
	End Method
	
End Type

