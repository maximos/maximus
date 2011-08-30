
Rem
	bbdoc: Maximus basic logger.
End Rem
Type mxLogger
	
	Field m_observers:TList = New TList
	
	Const c_message:String = "message"
	Const c_warning:String = "warning"
	Const c_error:String = "error"

	Rem
		bbdoc: Log a message.
		returns: Nothing.
		about: If @newline is True, a new line will be started, if it is False, a new line will not be started.
	End Rem
	Method LogMessage(message:String, newline:Int = True)
		If newline Then message:+ "~n"
		MessageObservers(message, c_message)
	End Method
	
	Rem
		bbdoc: Log a warning message.
		returns: Nothing.
		about: If @newline is True, a new line will be started, if it is False, a new line will not be started.
	End Rem
	Method LogWarning(warning:String, newline:Int = True)
		warning = _s("message.warning", [warning])
		If newline Then warning:+ "~n"
		MessageObservers(warning, c_warning)
	End Method
	
	Rem
		bbdoc: Log an error message.
		returns: Nothing.
		about: If @newline is True, a new line will be started, if it is False, a new line will not be started.
	End Rem
	Method LogError(error:String, newline:Int = True)
		error = _s("message.error", [error])
		If newline Then error:+ "~n"
		MessageObservers(error, c_error)
	End Method
	
	Rem
		bbdoc: Add an observer
		Returns: Nothing.
	End Rem
	Method AddObserver(observer:Object)
		m_observers.AddLast(observer)
	End Method
	
	Rem
		bbdoc: Send messages to observers
		returns: Nothing.
		about: This helper method messages all registered observers with the SendMessage method
	End Rem
	Method MessageObservers(message:String, context:String)
		For Local observer:Object = EachIn m_observers
			observer.SendMessage(message, context)
		Next
	End Method
End Type

Rem
	bbdoc: This observer for mxLogger will write received messages to StandardIOStream
End Rem
Type mxLoggerObserverIOStream
	Method SendMessage:Object(message:Object, context:Object)
		StandardIOStream.WriteString(String(message))
	End Method
End Type

Rem
	bbdoc: This observer for mxLogger will print received messages with DebugLog
End Rem
Type mxLoggerObserverDebuglog
	Method SendMessage:Object(message:Object, context:Object)
		DebugLog "[" + String(context) + "] " + String(message)
	End Method
End Type