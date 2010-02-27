
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
			Local dep:mxModuleDependency = New mxModuleDependency.Create(key, True)
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
		bbdoc: Add the dependencies from the given mxDependencies.
		returns: Nothing.
	End Rem
	Method MergeDependencies(dependencies:mxModuleDependencies)
		For Local dep:mxModuleDependency = EachIn dependencies.ValueEnumerator()
			AddDependency(dep) ' No need to check if they're already in here, they'll just be overwritten with the same thing
		Next
	End Method
	
	Rem
		bbdoc: Load the given dJObject into the scope.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxModuleDependencies(root:dJArray)
		If root <> Null
			For Local strvar:TStringVariable = EachIn root.GetValues()
				AddDependency(New mxModuleDependency.FromVariable(strvar, True))
			Next
			Return Self
		End If
		Return Null
	End Method
	
End Type

Rem
	bbdoc: Maximus module dependency.
End Rem
Type mxModuleDependency
	
	Field m_key:String
	Field m_isscope:Int
	
	Rem
		bbdoc: Create a new mxModuleDependency.
		returns: Itself.
		about: If @resolve is True, the dependency's type will be resolved.
	End Rem
	Method Create:mxModuleDependency(key:String, resolve:Int = True)
		Set(key, resolve)
		Return Self
	End Method
	
'#region Field accessors
	
	Rem
		bbdoc: Set the dependency.
		returns: True if the dependency is a scope, or False if it is a module.
		about: If @resolve is True, the dependency's type will be re-resolved.
	End Rem
	Method Set:Int(key:String, resolve:Int = True)
		Assert key, "(mxModuleDependency.Set) key cannot be Null"
		m_key = key
		If resolve = True Then ResolveType()
		Return m_isscope
	End Method
	
	Rem
		bbdoc: Get the dependency.
		returns: The dependency.
	End Rem
	Method Get:String()
		Return m_key
	End Method
	
	Rem
		bbdoc: Check if the dependency is a scope.
		returns: True if the dependency is a scope, or False if it is a module.
	End Rem
	Method IsScope:Int()
		Return m_isscope
	End Method
	
'#end region Field accessors
	
	Rem
		bbdoc: Resolve the dependency's type (scope or module).
		returns: True if the dependency is a scope or False if it is a module.
	End Rem
	Method ResolveType:Int()
		If m_key.Contains(".") = True
			m_isscope = False
		Else
			m_isscope = True
		End If
		Return m_isscope
	End Method
	
	Rem
		bbdoc: Set the dependency from the given variable.
		returns: Itself, or Null if the given variable is Null.
		about: If @resolve is True, the dependency's type will be (re-)resolved.
	End Rem
	Method FromVariable:mxModuleDependency(strvar:TStringVariable, resolve:Int = True)
		If strvar <> Null
			Set(strvar.Get(), resolve)
			Return Self
		End If
		Return Null
	End Method
	
End Type

