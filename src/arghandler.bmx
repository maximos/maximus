
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
	bbdoc: Maximus argument handler.
	about: This ties in all of the types for each specific argument (e.g. 'get', 'help', 'version', etc.)
End Rem
Type mxArgumentHandler Extends dObjectMap
	
	Rem
		bbdoc: Add an alias for the given argument implementation.
		returns: Nothing.
	End Rem
	Method AddArgImplAlias(als:String, argimpl:mxArgumentImplementation)
		Assert als, "(mxArgumentHandler.AddArgImplAlias) als = Null"
		_Insert(als, argimpl)
	End Method
	
	Rem
		bbdoc: Add all of the aliases from the given argument implementation.
		returns: Nothing.
	End Rem
	Method AddArgImpl(argimpl:mxArgumentImplementation)
		If argimpl.GetAliases() <> Null
			For Local als:String = Eachin argimpl.GetAliases()
				AddArgImplAlias(als, argimpl)
			Next
		End If
	End Method
	
	Rem
		bbdoc: Get an argument implementation from the given alias.
		returns: The argument implementation with the given alias, or Null (not found).
	End Rem
	Method GetArgImplFromAlias:mxArgumentImplementation(als:String)
		Assert als, "(mxArgumentHandler.GetArgImplFromAlias) als = Null"
		Return mxArgumentImplementation(_ValueByKey(als))
	End Method
	
End Type

Rem
	bbdoc: Maximus argument call conventions.
End Rem
Type mxCallConvention
	Rem
		bbdoc: For arguments as options (e.g. '--help', '--version').
	End Rem
	Const OPTION:Int = 1
	Rem
		bbdoc: For arguments as commands (e.g. 'help', 'get').
	End Rem
	Const COMMAND:Int = 2
End Type

Rem
	bbdoc: Maximus arugment implementation.
	about: This type is extended to provide implementations for specific arguments (e.g. 'get', 'help', 'version', etc.)
End Rem
Type mxArgumentImplementation Abstract
	
	Field m_callconv:Int
	Field m_args:dIdentifier, m_argcount:Int
	Field m_aliases:String[]
	
	Rem
		bbdoc: Initiation method for extending types.
		returns: Nothing.
	End Rem
	Method init(aliases:String[])
		m_aliases = aliases
	End Method
	
	Rem
		bbdoc: Get the aliases for this implementation.
		returns: The argument implementation's aliases.
	End Rem
	Method GetAliases:String[]()
		Return m_aliases
	End Method
	
	Rem
		bbdoc: Set the implementation's arguments.
		returns: Nothing.
	End Rem
	Method SetArgs(args:dIdentifier)
		m_args = args
		m_argcount = m_args.GetValueCount()
	End Method
	
	Rem
		bbdoc: Get the argument's argument count (number of arguments passed to the command/option).
		returns: The argument count.
	End Rem
	Method GetArgumentCount:Int()
		Return m_argcount
	End Method
	
	Rem
		bbdoc: Set the call convention.
		returns: Nothing.
		about: Options (e.g. '--version') should be mxCallConvention.OPTION, and commands (e.g. 'help') should be mxCallConvention.COMMAND.
	End Rem
	Method SetCallConvention(callconv:Int)
		m_callconv = callconv
	End Method
	
	Rem
		bbdoc: Get the current call convention.
		returns: The call convention (mxCallConvention.OPTION for options, and mxCallConvention.COMMAND for commands).
	End Rem
	Method GetCallConvention:Int()
		Return m_callconv
	End Method
	
	Rem
		bbdoc: Check if the argument implementation has the given alias.
		returns: True if the given alias was found, or False if it was not.
	End Rem
	Method HasAlias:Int(als:String)
		For Local al:String = EachIn m_aliases
			If als = al
				Return True
			End If
		Next
		Return False
	End Method
	
	Rem
		bbdoc: Check the current arguments for errors (according to the specific implementation).
		returns: Nothing.
		about: This method will throw an error if the arguments are invalid.<br>
		This method is abstract.
	End Rem
	Method CheckArgs() Abstract
	
	Rem
		bbdoc: Get a string describing the typical usage of the argument.
		returns: A string describing the typical usage of the argument.
		about: This method is abstract.
	End Rem
	Method GetUsage:String() Abstract
	
	Rem
		bbdoc: Execute the implementation's operation.
		returns: Nothing.
		about: This method is abstract.
	End Rem
	Method Execute() Abstract
	
End Type

