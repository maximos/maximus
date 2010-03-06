
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
	bbdoc: Maximus sources handler.
End Rem
Type mxSourcesHandler Extends dObjectMap
	
	Rem
		bbdoc: Add the given scope to the handler.
		returns: True if the scope was added, or False if it was not (scope is Null).
	End Rem
	Method AddScope:Int(modscope:mxModuleScope)
		If modscope <> Null
			_Insert(modscope.GetName(), modscope)
			Return True
		End If
		Return False
	End Method
	
	Rem
		bbdoc: Check if the handler has a scope with the given name.
		returns: True if a scope with the given name was found, or False if there is no scope with the given name.
	End Rem
	Method HasScope:Int(scopename:String)
		Return _Contains(scopename)
	End Method
	
	Rem
		bbdoc: Get the scope with the given name.
		returns: The scope with the given name, or Null if there is no scope with the given name.
	End Rem
	Method GetScopeWithName:mxModuleScope(scopename:String)
		Return mxModuleScope(_ValueByKey(scopename))
	End Method
	
	Rem
		bbdoc: Load the given file into the handler.
		returns: Itself, or Null if the given file either could not be opened or does not exist.
	End Rem
	Method FromFile:mxSourcesHandler(file:String)
		Local jreader:dJReader, root:dJObject
		jreader = New dJReader.InitWithStream(file)
		If jreader <> Null
			Try
				root = jreader.Parse()
			Catch e:JException
				ThrowError(_s("errors.load.sources.parse", [e.ToString()]))
			End Try
			FromJSON(root)
			Return Self
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Load the given dJObject into the handler.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxSourcesHandler(root:dJObject)
		If root <> Null
			For Local obj:dJObject = EachIn root.GetValues()
				AddScope(New mxModuleScope.FromJSON(obj))
			Next
			Return Self
		End If
		Return Null
	End Method
	
End Type

