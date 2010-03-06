
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
	bbdoc: Maximus 'modpath' option implementation.
End Rem
Type mxModPathImpl Extends mxArgumentImplementation
	
	Method New()
		init(["-mp", "--modpath"])
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

