
Rem
	bbdoc: Maximus 'modpath' option implementation.
End Rem
Type mxModPathImpl Extends mxArgumentImplementation
	
	Method New()
		init(["--modpath"])
	End Method
	
	Rem
		bbdoc: Check the current arguments for errors (according to the specific implementation).
		returns: Nothing.
		about: This method will throw an error if the arguments are invalid.
	End Rem
	Method CheckArgs()
		If GetArgumentCount() = 0
			ThrowCommonError(mxOptErrors.REQUIRESPARAMS, m_args.GetName())
		End If
	End Method
	
	Rem
		bbdoc: Get a string describing the typical usage of the argument.
		returns: A string describing the typical usage of the argument.
	End Rem
	Method GetUsage:String()
		Return _s("arg.modpath.usage")
	End Method
	
	Rem
		bbdoc: Execute the implementation's operation.
		returns: Nothing.
	End Rem
	Method Execute()
		If GetArgumentCount() > 0
			mainapp.SetModPath(m_args.GetValueAtIndex(0).ValueAsString(), True)
		End If
	End Method
	
End Type

