
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
Import cower.jonk
Import duct.objectmap

Include "src/logger.bmx"
Include "src/errors.bmx"
Include "src/arghandler.bmx"
Include "src/impl/help.bmx"
Include "src/impl/version.bmx"
Include "src/sources.bmx"

Global logger:mxLogger = New mxLogger
Global mainapp:mxApp = New mxApp.Create(AppArgs[1..]) ' Skip the first element because it is the program's location
mainapp.Run()

Rem
	bbdoc: Maximus app.
	about: This handles the basic flow of the program (initiation, parsing, command calling, exiting..)
End Rem
Type mxApp
	
	Const c_version:String = "0.01"
	
	Field m_args:String[]
	Field m_arghandler:mxArgumentHandler
	
	Rem
		bbdoc: Create a new mxApp.
		returns: The new mxApp.
	End Rem
	Method Create:mxApp(args:String[])
		m_args = args
		OnInit()
		Return Self
	End Method
	
	Rem
		bbdoc: Called when the application is created.
		returns: Nothing.
	End Rem
	Method OnInit()
		m_arghandler = New mxArgumentHandler
		m_arghandler.AddArgImpl(New mxHelpImpl)
		m_arghandler.AddArgImpl(New mxVersionImpl)
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
		Local argimpl:mxArgumentImplementation
		Local i:Int, arg:String, isopt:Int
		For i = 0 To m_args.Length - 1
			arg = m_args[i]
			argimpl = m_arghandler.GetArgImplFromAlias(arg)
			isopt = arg.StartsWith("-")
			If argimpl <> Null
				If isopt = True
					argimpl.SetArgs(Null)
					argimpl.SetCallConvention(mxCallConvention.OPTION)
					argimpl.Execute()
				Else ' Must be a command (leaving out parameters for options, as that would get really complicated)
					argimpl.SetCallConvention(mxCallConvention.COMMAND)
					ParseCommandArgs(argimpl, m_args[i + 1..])
					argimpl.Execute()
					Exit
				End If
			Else
				If isopt = True
					ThrowCommonError(mxOptErrors.UNKNOWN, arg)
				Else
					ThrowCommonError(mxCmdErrors.UNKNOWN, arg)
				End If
			End If
		Next
		OnExit()
	End Method
	
	Rem
		bbdoc: Parse command arguments.
		returns: Nothing.
	End Rem
	Method ParseCommandArgs(argimpl:mxArgumentImplementation, args:String[])
		' This will need to be parsed eventually, but for now..
		argimpl.SetArgs(args)
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

