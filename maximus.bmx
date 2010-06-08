
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

SuperStrict

Framework brl.blitz
Import brl.standardio
Import brl.maxutil
Import brl.ramstream

' We have to import this for BMax 1.39 on Linux because of a dependency issue in brl.system
' http://blitzbasic.com/Community/posts.php?topic=90547
?Linux
Import brl.glgraphics
?

Import gman.zipengine
Import htbaapub.rest

Import duct.variables
Import duct.objectmap
Import duct.json
Import duct.locale
Import duct.argparser

Incbin "locales/en.loc"

Include "src/logger.bmx"
Include "src/errors.bmx"
Include "src/config.bmx"
Include "src/dependencies.bmx"
Include "src/module.bmx"
Include "src/sources.bmx"
Include "src/utils.bmx"
Include "src/arghandler.bmx"
Include "src/impl/help.bmx"
Include "src/impl/version.bmx"
Include "src/impl/modpath.bmx"
Include "src/impl/install.bmx"
Include "src/impl/update.bmx"
Include "src/impl/list.bmx"

Global logger:mxLogger = New mxLogger
Global mainapp:mxApp
New mxApp.Create(AppArgs[1..]) ' Skip the first element because it is the program's location
mainapp.Run()

Rem
	bbdoc: Maximus app.
	about: This handles the basic flow of the program (initiation, parsing, command calling, exiting..)
End Rem
Type mxApp
	
	Const c_version:String = "0.01"
	Const c_configfile:String = "maximus.config"
	
	Field m_confighandler:mxConfigHandler
	Field m_defaultlocale:dLocale, m_locale:dLocale
	Field m_maxpath:String, m_modpath:String
	Field m_sourcesfile:String = "sources", m_sourcesurl:String = "http://maximus.htbaa.com/module/sources/json"
	Field m_useragent:String
	
	Field m_args:dIdentifier
	Field m_arghandler:mxArgumentHandler
	Field m_sourceshandler:mxSourcesHandler
	
	Rem
		bbdoc: Create a new mxApp.
		returns: Itself.
	End Rem
	Method Create:mxApp(args:String[])
		mainapp = Self
		SetArgs(args)
		OnInit()
		Return Self
	End Method
	
	Rem
		bbdoc: Called when the application is created.
		returns: Nothing.
	End Rem
	Method OnInit()
		Try
			m_maxpath = BlitzMaxPath()
		Catch e:Object
			ThrowError(_s("error.notfound.maxpath"))
		End Try
		SetModPath(m_maxpath + "/mod", False)
		m_confighandler = New mxConfigHandler.Create(c_configfile)
		m_confighandler.LoadDefaultLocale()
		m_confighandler.Load()
		m_arghandler = New mxArgumentHandler
		m_arghandler.AddArgImpl(New mxHelpImpl)
		m_arghandler.AddArgImpl(New mxVersionImpl)
		m_arghandler.AddArgImpl(New mxModPathImpl)
		m_arghandler.AddArgImpl(New mxInstallImpl)
		m_arghandler.AddArgImpl(New mxUpdateImpl)
		m_arghandler.AddArgImpl(New mxListImpl)
		m_sourceshandler = New mxSourcesHandler.FromFile(m_sourcesfile)
		If m_sourceshandler = Null
			' Don't throw an error here, the user may be updating the sources (an error will occur otherwise)
			logger.LogWarning(_s("error.load.sources.file", [m_sourcesfile]))
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
		Local argimpl:mxArgumentImplementation, isopt:Int
		For Local arg:dIdentifier = EachIn m_args.GetValues()
			argimpl = m_arghandler.GetArgImplFromAlias(arg.GetName())
			isopt = (arg.GetName()[0] = 45)
			If argimpl <> Null
				If isopt = True
					argimpl.SetCallConvention(mxCallConvention.OPTION)
					argimpl.SetArgs(arg)
					argimpl.CheckArgs()
					argimpl.Execute()
				Else
					argimpl.SetCallConvention(mxCallConvention.COMMAND)
					argimpl.SetArgs(arg)
					argimpl.CheckArgs()
					argimpl.Execute()
					Exit
				End If
			Else
				If isopt = True
					ThrowCommonError(mxOptErrors.UNKNOWN, arg.GetName())
				Else
					ThrowCommonError(mxCmdErrors.UNKNOWN, arg.GetName())
				End If
			End If
		Next
		OnExit()
	End Method
	
	Rem
		bbdoc: Set the application's arguments.
		returns: Nothing.
		about: NOTE: This will resolve to '--help' if the given args are Null.
	End Rem
	Method SetArgs(args:String[])
		If args = Null
			args = ["--help"]
		End If
		m_args = dArgParser.ParseArray(args, False, 1)
	End Method
	
	Rem
		bbdoc: Set the module path.
		returns: Nothing.
		about: This will throw an error if the module path could not be found.
	End Rem
	Method SetModPath(modpath:String, logchange:Int = True)
		m_modpath = FixPathEnding(modpath, True)
		If FileType(mainapp.m_modpath) = FILETYPE_DIR
			If logchange = True Then logger.LogMessage(_s("message.setmodpath", [mainapp.m_modpath]))
		Else
			ThrowError(_s("error.notfound.modpath", [mainapp.m_modpath]))
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
		bbdoc: Set the sources file.
		returns: Nothing.
		about: NOTE: This will throw an error if the path is Null (and, later, a warning will be logged if the path does not exist).
	End Rem
	Method SetSourcesFile(file:String)
		If file = Null
			ThrowError(_s("error.sources.setfile"))
		End If
		m_sourcesfile = file
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
	Global replacer:TTextReplacer = New TTextReplacer
	Local ltext:dLocalizedText
	If mainapp.m_locale <> Null Then ltext = mainapp.m_locale.TextFromStructureL(iden)
	If ltext = Null Then ltext = mainapp.m_defaultlocale.TextFromStructureL(iden)
	If ltext <> Null
		replacer.SetString(ltext.GetValue())
		replacer.AutoReplacements("{", "}")
		If extra <> Null
			Local i:Int
			For Local rep:TTextReplacement = EachIn replacer.GetList()
				If i > extra.Length Then Exit
				rep.SetReplacement(extra[i])
				i:+ 1
			Next
		End If
		Return replacer.DoReplacements()
	Else
		DebugLog("Failed to find localized text from structure: ~q" + iden + "~q")
	End If
End Function

