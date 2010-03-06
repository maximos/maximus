
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
	bbdoc: Maximus option errors.
End Rem
Type mxOptErrors
	Rem
		bbdoc: Unknown option.
	End Rem
	Const UNKNOWN:Int = 100
	Rem
		bbdoc: Option does not take parameters.
	End Rem
	Const DOESNOTTAKEPARAMS:Int = 101
	Rem
		bbdoc: Option is missing parameters.
	End Rem
	Const REQUIRESPARAMS:Int = 102
End Type

Rem
	bbdoc: Maximus command errors.
End Rem
Type mxCmdErrors
	Rem
		bbdoc: Unknown command.
	End Rem
	Const UNKNOWN:Int = 200
	Rem
		bbdoc: Command does not take parameters.
	End Rem
	Const DOESNOTTAKEPARAMS:Int = 201
	Rem
		bbdoc: Command is missing parameters.
	End Rem
	Const REQUIRESPARAMS:Int = 202
End Type

Rem
	bbdoc: Throw a common error (see #mxOptErrors and #mxCmdErrors).
	returns: Nothing.
End Rem
Function ThrowCommonError(errortype:Int, value:String = Null)
	Select errortype
		Case mxOptErrors.UNKNOWN
			_HelpError(_s("error.option.unknown", [value]))
		Case mxCmdErrors.UNKNOWN
			_HelpError(_s("error.command.unknown", [value]))
		Case mxOptErrors.DOESNOTTAKEPARAMS
			_HelpError(_s("error.option.doesnottakeparams", [value]))
		Case mxCmdErrors.DOESNOTTAKEPARAMS
			_HelpError(_s("error.command.doesnottakeparams", [value]))
		Case mxOptErrors.REQUIRESPARAMS
			_HelpError(_s("error.option.requiresparams", [value]))
		Case mxCmdErrors.REQUIRESPARAMS
			_HelpError(_s("error.command.requiresparams", [value]))
	End Select
	
	Function _HelpError(error:String)
		ThrowError("maximus: " + error + " " + _s("error.suggesthelp"))
	End Function
End Function

