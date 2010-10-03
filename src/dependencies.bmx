
Rem
	bbdoc: Maximus module dependencies.
End Rem
Type mxModuleDependencies Extends dObjectMap
	
	Rem
		bbdoc: Add a new dependency with the given key.
		returns: True if the dependency was added, or False if it was not (given string is Null).
	End Rem
	Method AddNewDependency:Int(key:String)
		If key
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
		If dep
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
		For Local dep:mxModuleDependency = EachIn dependencies.DependencyEnumerator()
			AddDependency(dep) ' No need to check if they're already in here, they'll just be overwritten with the same thing
		Next
	End Method
	
	Rem
		bbdoc: Check the dependency compliance of the current module set.
		returns: Null if all dependencies are matched by existing modules, or a list of module ids that are not yet installed.
	End Rem
	Method CheckCompliance:TListEx()
		Local nocomp:TListEx = New TListEx
		For Local dep:mxModuleDependency = EachIn DependencyEnumerator()
			If mxModUtils.HasModule(dep.Get()) = False
				nocomp.AddLast(dep.Get())
			End If
		Next
		If nocomp.Count() > 0 Then Return nocomp
		Return Null
	End Method
	
	Rem
		bbdoc: Load the dependencies from the given dJArray.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxModuleDependencies(root:dJArray)
		If root
			For Local strvar:dStringVariable = EachIn root
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
		For dep = EachIn DependencyEnumerator()
			a:+ dep.Get() + separator
		Next
		If a.Length > 0 Then a = a[..a.Length - separator.Length]
		Return a
	End Method
	
	Rem
		bbdoc: Get the dependency enumerator.
		returns: The dependency enumerator.
	End Rem
	Method DependencyEnumerator:TMapEnumerator()
		Return ValueEnumerator()
	End Method
	
End Type

Rem
	bbdoc: Maximus module dependency.
End Rem
Type mxModuleDependency
	
	Field m_key:String
	
	Rem
		bbdoc: Create a module dependency.
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
	Method FromVariable:mxModuleDependency(strvar:dStringVariable)
		If strvar
			Set(strvar.Get())
			Return Self
		End If
		Return Null
	End Method
	
End Type

