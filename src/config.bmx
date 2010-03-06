
Rem
Copyright (c) 2010 Tim Howard

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
End Rem

Rem
	bbdoc: Maximus configuration handler.
End Rem
Type mxConfigHandler
	
	Field tpl_language:dTemplate = New dTemplate.Create(["language"], [[TV_STRING]])
	Field m_configfile:String
	
	Rem
		bbdoc: Create a new handler.
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
				Local root:dSNode = dSNode.LoadScriptFromObject(GetConfigFile())
				If root <> Null
					For Local iden:dIdentifier = EachIn root.GetChildren()
						If tpl_language.ValidateIdentifier(iden)
							Local lang:String = dStringVariable(iden.GetValueAtIndex(0)).Get()
							If lang <> "en"
								mainapp.m_locale = LoadLocale(lang, False, True)
							End If
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
		If locale = Null
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
		If stream <> Null
			Local locale:dLocale
			Try
				Local node:dSNode = dSNode.LoadScriptFromObject(stream)
				locale = New dLocale.FromNode(node)
				dLocaleManager.AddLocale(locale)
			Catch e:Object
				If err = True
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
			If err = True
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
	Return text
End Function

