
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
		If newline = True
			Print(message)
		Else
			WriteStdOut(message)
		End If
	End Method
	
	Rem
		bbdoc: Log a warning message.
		returns: Nothing.
		about: If @newline is True, a new line will be started, if it is False, a new line will not be started.
	End Rem
	Method LogWarning(warning:String, newline:Int = True)
		If newline = True
			Print(_s("message.warning", [warning]))
		Else
			WriteStdOut(_s("message.warning", [warning]))
		End If
	End Method
	
	Rem
		bbdoc: Log an error message.
		returns: Nothing.
		about: If @newline is True, a new line will be started, if it is False, a new line will not be started.
	End Rem
	Method LogError(error:String, newline:Int = True)
		If newline = True
			Print(_s("message.error", [error]))
		Else
			WriteStdOut(_s("message.error", [error]))
		End If
	End Method
	
End Type

