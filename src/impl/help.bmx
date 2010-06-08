
Rem
	bbdoc: Maximus 'help' argument implementation.
End Rem
Type mxHelpImpl Extends mxArgumentImplementation
	
	Method New()
		init(["help", "--help"])
	End Method
	
	Rem
		bbdoc: Check the current arguments for errors (according to the specific implementation).
		returns: Nothing.
		about: This method will throw an error if the arguments are invalid.
	End Rem
	Method CheckArgs()
	End Method
	
	Rem
		bbdoc: Get a string describing the typical usage of the argument.
		returns: A string describing the typical usage of the argument.
	End Rem
	Method GetUsage:String()
		Return _s("arg.help.usage")
	End Method
	
	Rem
		bbdoc: Execute the implementation's operation.
		returns: Nothing.
	End Rem
	Method Execute()
		If GetArgumentCount() > 0
			For Local variable:dVariable = EachIn m_args.GetValues()
				Local command:String = variable.ValueAsString()
				If command.ToLower() = "help"
					logger.LogMessage(command + ":~t" + "HELP HELP I'M BEING REPRESSED!")
				Else
					Local argimpl:mxArgumentImplementation = mainapp.m_arghandler.GetArgImplFromAlias(command)
					If argimpl <> Null
						logger.LogMessage(command + ":~n~t" + argimpl.GetUsage().Replace("~n", "~n~t"))
					Else
						logger.LogMessage(command + ":~t" + _s("arg.help.cmdnotfound"))
					End If
				End If
			Next
		Else
			logger.LogMessage(_s("arg.help.fullusage"))
		End If
	End Method
	
End Type

