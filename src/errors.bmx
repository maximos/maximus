
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
End Function

Function _HelpError(error:String)
	ThrowError("maximus: " + error + " " + _s("error.suggesthelp"))
End Function

