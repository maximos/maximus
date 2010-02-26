
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
	bbdoc: Maximus 'help' argument implementation.
End Rem
Type mxHelpImpl Extends mxArgumentImplementation
	
	Method New()
		init(["help", "--help", "-h"])
	End Method
	
	Rem
		bbdoc: Check the current arguments for errors (according to the specific implementation).
		returns: Nothing.
		about: This method will throw an error if the given arguments are invalid.
	End Rem
	Method CheckArgs()
		Select GetCallConvention()
			Case mxCallConvention.COMMAND ' "help"
				If m_args = Null
					ThrowCommonError(mxCmdErrors.MISSINGPARAMS, "help")
				End If
			Case mxCallConvention.OPTION ' "--help" or "-h"
				If m_args <> Null
					ThrowCommonError(mxOptErrors.DOESNOTTAKEPARAMS, "-h|--help")
				End If
		End Select
	End Method
	
	Rem
		bbdoc: Get a string describing the typical usage of the argument.
		returns: A string describing the typical usage of the argument.
	End Rem
	Method GetUsage:String()
		Select GetCallConvention()
			Case mxCallConvention.COMMAND
				Return "usage: maximus help <command>~n" + ..
						"e.g. maximus help get"
			Case mxCallConvention.OPTION
				Return "maximus usage: maximus [-v|--version] [-h|--help] COMMAND [ARGS]~n" + ..
						"The most commonly used commands:~n" + ..
						"~tget~tGet the given set modules~n" + ..
						"~tremove~tRemove the given set of modules" + ..
						"~tupdate~tUpdate the current set of modules~n" + ..
						"~thelp~tGet help on a specific command~n" + ..
						"~n" + ..
						"Try 'maximus help <command>' for more information on a specific command."
		End Select
	End Method
	
	Rem
		bbdoc: Execute the implementation's operation.
		returns: Nothing.
	End Rem
	Method Execute()
		Select GetCallConvention()
			Case mxCallConvention.COMMAND
				For Local command:String = EachIn m_args
					If command.ToLower() = "help"
						logger.LogMessage(command + ":~t" + "HELP HELP I'M BEING REPRESSED!")
					Else
						Local argimpl:mxArgumentImplementation = mainapp.m_arghandler.GetArgImplFromAlias(command)
						If argimpl <> Null
							logger.LogMessage(command + ":~t" + argimpl.GetUsage().Replace("~n", "~n~t~t"))
						Else
							logger.LogMessage(command + ":~tCommand not found")
						End If
					End If
				Next
			Case mxCallConvention.OPTION
				logger.LogMessage(GetUsage())
		End Select
	End Method
	
End Type

