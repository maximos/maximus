
Rem
	bbdoc: Maximus 'version' argument implementation.
End Rem
Type mxVersionImpl Extends dArgumentImplementation
	
	Method New()
		init(["version", "-version", "-v"])
	End Method
	
	Rem
		bbdoc: Check the current arguments for errors (according to the specific implementation).
		returns: Nothing.
		about: This method will throw an error if the arguments are invalid.
	End Rem
	Method CheckArgs()
		Select GetCallConvention()
			Case dCallConvention.COMMAND ' "version"
				If GetArgumentCount() > 0
					ThrowCommonError(mxCmdErrors.DOESNOTTAKEPARAMS, "version")
				End If
			Case dCallConvention.OPTION ' "-version" or "-v"
				If GetArgumentCount() > 0
					ThrowCommonError(mxOptErrors.DOESNOTTAKEPARAMS, "-v|-version")
				End If
		End Select
	End Method
	
	Rem
		bbdoc: Get a string describing the typical usage of the argument.
		returns: A string describing the typical usage of the argument.
	End Rem
	Method GetUsage:String()
		Return _s("arg.version.usage")
	End Method
	
	Rem
		bbdoc: Execute the implementation's operation.
		returns: Nothing.
	End Rem
	Method Execute()
		logger.LogMessage(_s("arg.version.report", [mainapp.c_version]))
	End Method
	
End Type

