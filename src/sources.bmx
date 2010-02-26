
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
	bbdoc: Maximus event handler for JONK.
End Rem
Type mxJEventHandler Extends JEventHandler
	
	' Parser state
	Method BeginParsing()
	End Method
	
	Method EndParsing()
	End Method
	
	' Object handler
	Method ObjectBegin()
	End Method
	
	Method ObjectKey(name$)
	End Method
	
	Method ObjectEnd()
	End Method
	
	' Array handler
	Method ArrayBegin()
	End Method
	
	Method ArrayEnd()
	End Method
	
	' Values
	Method NumberValue(number$, isdecimal%)
	End Method
	
	Method StringValue(value$)
	End Method
	
	Method BooleanValue(value%)
	End Method
	
	Method NullValue()
	End Method
	
	' Errors
	Method Error%(err:JParserException)
		Return False
	End Method
	
End Type

