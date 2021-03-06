
Rem
	bbdoc: Maximus configuration handler.
End Rem
Type mxConfigHandler
	
	Field tpl_language:dTemplate = New dTemplate.Create(["language"], [[TV_STRING]])
	Field tpl_maxpath:dTemplate = New dTemplate.Create(["maxpath"], [[TV_STRING]])
	Field tpl_modpath:dTemplate = New dTemplate.Create(["modpath"], [[TV_STRING]])
	Field tpl_sourcesurl:dTemplate = New dTemplate.Create(["sourcesurl"], [[TV_STRING]])
	Field tpl_sourcesfile:dTemplate = New dTemplate.Create(["sourcesfile"], [[TV_STRING]])
	Field tpl_proxyserver:dTemplate = New dTemplate.Create(["proxyserver"], [[TV_STRING]])
	Field tpl_autoupdate:dTemplate = New dTemplate.Create(["autoupdate"], [[TV_BOOL]])
	Field m_configfile:String
	
	Rem
		bbdoc: Create a config handler.
		returns: Itself.
	End Rem
	Method Create:mxConfigHandler(configfile:String)
		SetConfigFile(configfile)
		dLocaleManager.SetPostProcessFunc(PostProcessLocaleText)
		Return Self
	End Method
	
'#region Field accessors
	
	Rem
		bbdoc: Set the configuration file path.
		returns: Nothing.
	End Rem
	Method SetConfigFile(configfile:String)
		m_configfile = configfile
	End Method
	
	Rem
		bbdoc: Get the configuration file path.
		returns: The configuration file path.
	End Rem
	Method GetConfigFile:String()
		Return m_configfile
	End Method
	
'#end region Field accessors
	
	Rem
		bbdoc: Load the configuration.
		returns: Nothing.
	End Rem
	Method Load()
		If FileType(GetConfigFile()) = FILETYPE_FILE
			Try
				Local root:dNode = dScriptFormatter.LoadFromFile(GetConfigFile())
				If root
					For Local iden:dIdentifier = EachIn root
						If tpl_language.ValidateIdentifier(iden)
							Local lang:String = dStringVariable(iden.GetValueAtIndex(0)).Get()
							If lang <> "en"
								mainapp.m_locale = LoadLocale(lang, False, True)
							End If
						Else If tpl_maxpath.ValidateIdentifier(iden) 
							mainapp.SetMaxPath(dStringVariable(iden.GetValueAtIndex(0)).Get())
						Else If tpl_modpath.ValidateIdentifier(iden)
							mainapp.SetModPath(dStringVariable(iden.GetValueAtIndex(0)).Get(), False)
						Else If tpl_sourcesurl.ValidateIdentifier(iden)
							mainapp.SetSourcesUrl(dStringVariable(iden.GetValueAtIndex(0)).Get())
						Else If tpl_sourcesfile.ValidateIdentifier(iden)
							mainapp.SetSourcesFile(dStringVariable(iden.GetValueAtIndex(0)).Get())
						Else If tpl_proxyserver.ValidateIdentifier(iden)
							mainapp.SetProxyServer(dStringVariable(iden.GetValueAtIndex(0)).Get())
						Else If tpl_autoupdate.ValidateIdentifier(iden)
							mainapp.m_autoupdatesources = dBoolVariable(iden.GetValueAtIndex(0)).Get()
						Else
							logger.LogWarning(_s("error.load.config.unkiden", [iden.GetName()]))
						End If
					Next
				End If
			Catch e:Object
				logger.LogError(_s("error.load.config.parse", [e.ToString()]))
			End Try
		'Else
		'	logger.LogWarning("Configuration file not found: " + GetConfigFile())
		End If
	End Method
	
	Rem
		bbdoc: Load the default locale.
		returns: Nothing.
	End Rem
	Method LoadDefaultLocale()
		Local locale:dLocale = LoadLocale("en", False, False)
		If Not locale
			locale = LoadLocale("en", True, False)
		End If
		mainapp.m_defaultlocale = locale
		mainapp.m_locale = locale
	End Method
	
	Rem
		bbdoc: Load the given locale.
		returns: The loaded locale, or Null if the given file could not be read/parsed.
	End Rem
	Method LoadLocale:dLocale(locale:String, bin:Int = False, err:Int = True)
		Local file:String = "locales/" + locale + ".loc"
		If bin = True Then file = "incbin::" + file
		Local stream:TStream = ReadStream(file)
		If stream
			Local locale:dLocale
			Try
				Local node:dNode = dScriptFormatter.LoadFromStream(stream)
				locale = New dLocale.FromNode(node)
				dLocaleManager.AddLocale(locale)
			Catch e:Object
				If err
					logger.LogWarning(_s("error.load.locale.parse", [file, e.ToString()]))
				?Debug
				Else
					DebugLog("Failed to parse locale file: " + file + "~n~tReason: " + e.ToString())
				?
				End If
			End Try
			stream.Close()
			Return locale
		Else
			If err
				logger.LogWarning(_s("error.load.locale.file", [file]))
			End If
		End If
		Return Null
	End Method
	
End Type

Rem
	bbdoc: Do post-processing on the given locale text (used when loading a locale).
	returns: The processed test.
End Rem
Function PostProcessLocaleText:String(text:String)
	text = text.Replace("~~t", "~t")
	text = text.Replace("~~n", "~n")
	text = text.Replace("~~q", "~q")
	text = text.Replace("~~t", "~t")
	text = text.Replace("~~~~", "~~")
	Return text
End Function

