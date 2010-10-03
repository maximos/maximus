
Rem
	bbdoc: Maximus basic logger.
End Rem
Type mxLogger
	
	Rem
		bbdoc: Log a message.
		returns: Nothing.
		about: If @newline is True, a new line will be started, if it is False, a new line will not be started.
	End Rem
	Method LogMessage(message:String, newline:Int = True)
		If newline Then message:+ "~n"
		StandardIOStream.WriteString(message)
	End Method
	
	Rem
		bbdoc: Log a warning message.
		returns: Nothing.
		about: If @newline is True, a new line will be started, if it is False, a new line will not be started.
	End Rem
	Method LogWarning(warning:String, newline:Int = True)
		warning = _s("message.warning", [warning])
		If newline Then warning:+ "~n"
		StandardIOStream.WriteString(warning)
	End Method
	
	Rem
		bbdoc: Log an error message.
		returns: Nothing.
		about: If @newline is True, a new line will be started, if it is False, a new line will not be started.
	End Rem
	Method LogError(error:String, newline:Int = True)
		error = _s("message.error", [error])
		If newline Then error:+ "~n"
		StandardIOStream.WriteString(error)
	End Method
	
End Type

