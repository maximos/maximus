
Rem
	bbdoc: Maximus app.
	about: This handles the basic flow of the program (initiation, parsing, command calling, exiting..)
End Rem
Type mxApp Extends dCLApp
	
	Const c_version:String = "1.1.2"
	Const c_configfile:String = "maximus.config"
	
	Field m_apppath:String
	Field m_maxpath:String, m_binpath:String, m_modpath:String
	
	Field m_confighandler:mxConfigHandler
	Field m_defaultlocale:dLocale, m_locale:dLocale
	Field m_sourcesfile:String = "sources", m_sourcesurl:String = "http://maximus.htbaa.com/module/sources/json"
	Field m_useragent:String
	Field m_autoupdatesources:Int = True
	Field m_proxyserver:String
	
	Field m_sourceshandler:mxSourcesHandler
	
	Field m_updateimpl:mxUpdateImpl
	Field m_sourcesupdated:Int
	
	Field m_userinput:mxUserInput
	
	Rem
		bbdoc: Create a new mxApp.
		returns: Itself.
	End Rem
	Method Create:mxApp()
		mainapp = Self
		Super.Create()
		Return Self
	End Method
	
	Rem
		bbdoc: Called when the application is created.
		returns: Nothing.
	End Rem
	Method OnInit()
		m_apppath = GetUserAppDir() + "/"
		?Linux
		m_apppath:+ ".maximus/"
		?Not Linux
		m_apppath:+ "maximus/"
		?
		If FileType(m_apppath) = FILETYPE_NONE
			If Not CreateDir(m_apppath, False)
				ThrowError(_s("error.createperms", [m_apppath]))
			End If
		End If
		ChangeDir(m_apppath)
		m_confighandler = New mxConfigHandler.Create(m_apppath + c_configfile)
		m_confighandler.LoadDefaultLocale()
		m_confighandler.Load()
		If Not m_maxpath
			Try
				SetMaxPath(BlitzMaxPath())
			Catch e:Object
				If m_userinput <> Null And mxUserInputDriverGUI(m_userinput.m_driver)
					Local path:String = RequestDir(_s("message.selectbmxpath"), CurrentDir())
					SetMaxPath(path)
				End If
			End Try
		End If
		If Not m_maxpath Then ThrowError(_s("error.notfound.maxenv"))
		If Not m_modpath Then SetModPath(m_maxpath + "/mod", False)
		m_arghandler = New dArgumentHandler.Create()
		m_arghandler.AddArgImpl(New mxHelpImpl)
		m_arghandler.AddArgImpl(New mxVersionImpl)
		m_arghandler.AddArgImpl(New mxModPathImpl)
		m_arghandler.AddArgImpl(New mxInstallImpl)
		m_updateimpl = New mxUpdateImpl
		m_arghandler.AddArgImpl(m_updateimpl)
		m_arghandler.AddArgImpl(New mxListImpl)
		UpdateSources()
		SetSourcesHandler()
		If Not m_sourceshandler
			' Don't throw an error here, the user may be updating the sources (an error will occur otherwise)
			logger.LogWarning(_s("error.load.sources.file", [m_apppath + m_sourcesfile]))
		End If
		Local os:String
		?Win32
			os = "Windows"
		?Linux
			os = "Linux"
		?MacOS
			os = "MacOS"
		?
		m_useragent = "Maximus/" + c_version + " (" + os + "; " + m_locale.GetName() + ")"
	End Method
	
	Rem
		bbdoc: Called when the application is ended (this includes #ThrowError calls).
		returns: Nothing.
	End Rem
	Method OnExit()
	End Method
	
	Rem
		bbdoc: Run the application.
		returns: Nothing.
	End Rem
	Method Run()
		Local argimpl:dArgumentImplementation, isopt:Int
		For Local arg:dIdentifier = EachIn m_arguments
			argimpl = m_arghandler.GetArgImplWithAlias(arg.GetName())
			isopt = (arg.GetName()[0] = 45)
			If argimpl
				If isopt
					argimpl.SetCallConvention(dCallConvention.OPTION)
					argimpl.SetArgs(arg)
					argimpl.CheckArgs()
					argimpl.Execute()
				Else
					argimpl.SetCallConvention(dCallConvention.COMMAND)
					argimpl.SetArgs(arg)
					argimpl.CheckArgs()
					argimpl.Execute()
					Exit
				End If
			Else
				If isopt
					ThrowCommonError(mxOptErrors.UNKNOWN, arg.GetName())
				Else
					ThrowCommonError(mxCmdErrors.UNKNOWN, arg.GetName())
				End If
			End If
		Next

		OnExit()
	End Method
	
	Rem
		bbdoc: Update the sources list.
		returns: Nothing.
		about: Updates when: the sources file is greater than 23 hours old; the sources file does not exist.
	End Rem
	Method UpdateSources()
		If m_autoupdatesources And Not m_sourcesupdated
			Local ctime:dTime, ftime:dTime
			ctime = New dTime.CreateFromCurrent()
			ftime = New dTime.CreateFromFile(m_apppath + m_sourcesfile)
			'DebugLog("Auto-update file time: c" + ctime.Get() + " | " + ftime.Get() + ", hours: " + (ctime.Get() - ftime.Get()) / 3600)
			If Not ftime Or (ctime.Get() - ftime.Get()) / 3600 > 23
				logger.LogMessage(_s("arg.update.autoupdate"))
				m_updateimpl.SetCallConvention(dCallConvention.COMMAND)
				m_updateimpl.SetArgs(New dIdentifier.Create())
				m_updateimpl.CheckArgs()
				m_updateimpl.Execute()
			End If
		End If
	End Method
	
	Rem
		bbdoc: Set the sourceshandler.
		returns: Nothing.
		about: Create a new mxSourcesHandler object to set a fresh module list
	End Rem
	Method SetSourcesHandler()
		m_sourceshandler = New mxSourcesHandler.FromFile(m_apppath + m_sourcesfile)
	End Method
	
	Rem
		bbdoc: Set the application's arguments.
		returns: Nothing.
		about: NOTE: This will resolve to '--help' if the given args are Null.
	End Rem
	Method SetArgs(args:String[])
		If Not args
			args = ["--help"]
		End If
		ParseArguments(args, False, 1)
	End Method
	
	Rem
		bbdoc: Set the module path.
		returns: Nothing.
		about: This will throw an error if the module path could not be found.
	End Rem
	Method SetModPath(modpath:String, logchange:Int = True)
		m_modpath = FixPathEnding(modpath, True)
		If FileType(m_modpath) = FILETYPE_DIR
			If logchange Then logger.LogMessage(_s("message.setmodpath", [m_modpath]))
		Else
			ThrowError(_s("error.notfound.modpath", [m_modpath]))
		End If
	End Method
	
	Rem
		bbdoc: Set the path to the BlitzMax installation.
		returns: Nothing.
		about: This will throw an error if the path could not be found.
	End Rem
	Method SetMaxPath(maxpath:String)
		m_maxpath = FixPathEnding(maxpath, True)
		m_binpath = m_maxpath + "/bin"
		Local bmk:String
		?Win32
			bmk = "/bmk.exe"
		?Not Win32
			bmk = "/bmk"
		?
		If FileType(m_maxpath) = FILETYPE_NONE
			ThrowError(_s("error.notfound.maxpath", [m_maxpath]))
		Else If FileType(m_binpath + bmk) = FILETYPE_NONE
			ThrowError(_s("error.notfound.bmk", [m_binpath + bmk]))
		End If
	End Method
	
	Rem
		bbdoc: Set the sources url.
		returns: Nothing.
	End Rem
	Method SetSourcesUrl(url:String)
		m_sourcesurl = url
	End Method
	
	Rem
		bbdoc: Set a proxy server.
		returns: Nothing.
	End Rem
	Method SetProxyServer(server:String)
		m_proxyserver = server
	End Method
	
	Rem
		bbdoc: Set the sources file.
		returns: Nothing.
		about: NOTE: This will throw an error if the path is Null (and, later, a warning will be logged if the path does not exist).
	End Rem
	Method SetSourcesFile(file:String)
		If Not file
			ThrowError(_s("error.sources.setfile"))
		End If
		m_sourcesfile = file
	End Method
	
	Rem
		bbdoc: Set the user input driver.
		returns: Nothing.
	End Rem
	Method SetUserInput(ui_driver:Byte)
		m_userinput = mxUserInput.factory(ui_driver)
	End Method
	
End Type

Rem
	bbdoc: Throw an error (terminating the application).
	returns: Nothing.
End Rem
Function ThrowError(error:String)
	logger.LogError(error)
	mainapp.OnExit()
	End
End Function

Rem
	bbdoc: Get the localized text for the given identifier.
	returns: The translated text.
End Rem
Function _s:String(iden:String, extra:String[] = Null)
	Global replacer:dTextReplacer = New dTextReplacer
	Local ltext:dLocalizedText
	If mainapp.m_locale Then ltext = mainapp.m_locale.TextFromStructureL(iden)
	If ltext Then ltext = mainapp.m_defaultlocale.TextFromStructureL(iden)
	If ltext
		replacer.SetString(ltext.GetValue())
		replacer.AutoReplacements("{", "}")
		If extra
			Local i:Int
			For Local rep:dTextReplacement = EachIn replacer.GetList()
				If i > extra.Length Then Exit
				rep.SetReplacement(extra[i])
				i:+ 1
			Next
		End If
		Return replacer.DoReplacements()
	Else
		DebugLog("Failed to find localized text from structure: ~q" + iden + "~q")
	End If
	Return Null
End Function
