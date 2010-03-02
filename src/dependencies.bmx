
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
	bbdoc: Maximus module dependencies.
End Rem
Type mxModuleDependencies Extends TObjectMap
	
	Rem
		bbdoc: Add a new dependency with the given key.
		returns: True if the dependency was added, or False if it was not (given string is Null).
	End Rem
	Method AddNewDependency:Int(key:String)
		If key <> Null
			Local dep:mxModuleDependency = New mxModuleDependency.Create(key)
			_Insert(key, dep)
			Return True
		End If
		Return False
	End Method
	
	Rem
		bbdoc: Add the given dependency.
		returns: True if the dependency was added, or False if it was not (given string is Null).
	End Rem
	Method AddDependency:Int(dep:mxModuleDependency)
		If dep <> Null
			_Insert(dep.Get(), dep)
			Return True
		End If
		Return False
	End Method
	
	Rem
		bbdoc: Check if the given dependency exists.
		returns: True if the given dependency was found, or False if it was not.
	End Rem
	Method HasDependency:Int(key:String)
		Return _Contains(key)
	End Method
	
	Rem
		bbdoc: Add the dependencies from the given mxModuleDependencies.
		returns: Nothing.
	End Rem
	Method MergeDependencies(dependencies:mxModuleDependencies)
		For Local dep:mxModuleDependency = EachIn dependencies.ValueEnumerator()
			AddDependency(dep) ' No need to check if they're already in here, they'll just be overwritten with the same thing
		Next
	End Method
	
	Rem
		bbdoc: Load the dependencies from the given dJArray.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxModuleDependencies(root:dJArray)
		If root <> Null
			For Local strvar:TStringVariable = EachIn root.GetValues()
				AddDependency(New mxModuleDependency.FromVariable(strvar))
			Next
			Return Self
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Get a string containing the list of dependencies, separated by @separator.
		returns: A string containing the list of dependencies.
	End Rem
	Method DependencyList:String(separator:String = ", ")
		Local a:String, dep:mxModuleDependency
		For dep = EachIn ValueEnumerator()
			a:+ dep.Get() + separator
		Next
		If a.Length > 0 Then a = a[..a.Length - separator.Length]
		Return a
	End Method
	
End Type

Rem
	bbdoc: Maximus module dependency.
End Rem
Type mxModuleDependency
	
	Field m_key:String
	
	Rem
		bbdoc: Create a new mxModuleDependency.
		returns: Itself.
	End Rem
	Method Create:mxModuleDependency(key:String)
		Set(key)
		Return Self
	End Method
	
'#region Field accessors
	
	Rem
		bbdoc: Set the dependency.
		returns: Nothing.
	End Rem
	Method Set(key:String)
		Assert key, "(mxModuleDependency.Set) key cannot be Null"
		m_key = key
	End Method
	
	Rem
		bbdoc: Get the dependency.
		returns: The dependency.
	End Rem
	Method Get:String()
		Return m_key
	End Method
	
'#end region Field accessors
	
	Rem
		bbdoc: Set the dependency from the given variable.
		returns: Itself, or Null if the given variable is Null.
	End Rem
	Method FromVariable:mxModuleDependency(strvar:TStringVariable)
		If strvar <> Null
			Set(strvar.Get())
			Return Self
		End If
		Return Null
	End Method
	
End Type

