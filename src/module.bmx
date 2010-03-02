
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
	bbdoc: Maximus module base.
	about: An abstract type for the similarities between module scopes and modules.
End Rem
Type mxModuleBase Abstract
	
	Field m_name:String, m_description:String
	
'#region Field accessors
	
	Rem
		bbdoc: Set the base's name.
		returns: Nothing.
	End Rem
	Method SetName(name:String)
		Assert name, "(mxModuleBase.SetName) name cannot be Null!"
		m_name = name
	End Method
	
	Rem
		bbdoc: Get the base's name.
		returns: The base's name.
	End Rem
	Method GetName:String()
		Return m_name
	End Method
	
	Rem
		bbdoc: Set the base's description.
		returns: Nothing.
	End Rem
	Method SetDescription(description:String)
		Assert description, "(mxModuleBase.SetDescription) formalname cannot be Null!"
		m_description = description
	End Method
	
	Rem
		bbdoc: Get the base's description.
		returns: The base's description.
	End Rem
	Method GetDescription:String()
		Return m_description
	End Method
	
'#end region Field accessors
	
	Rem
		bbdoc: Set a common field from the given variable.
		returns: True if the given variable was handled, or False if it was not.
	End Rem
	Method SetCommonFromVariable:Int(variable:TVariable)
		Select variable.GetName().ToLower()
			Case "desc"
				SetDescription(variable.ValueAsString())
				Return True
		End Select
		Return False
	End Method
	
End Type

Rem
	bbdoc: Maximus module scope.
End Rem
Type mxModuleScope Extends mxModuleBase
	
	Field m_modules:TObjectMap
	
	Method New()
		m_modules = New TObjectMap
	End Method
	
	Rem
		bbdoc: Add the given module to the scope.
		returns: True if the module was added, or False if it was not (the module is Null).
	End Rem
	Method AddModule:Int(modul:mxModule)
		If modul <> Null
			m_modules._Insert(modul.GetName(), modul)
			modul.SetParent(Self)
			Return True
		End If
		Return False
	End Method
	
	Rem
		bbdoc: Check if the given module name is found in the scope.
		returns: True if the given module was found in the scope, or False if it was not.
	End Rem
	Method HasModule:Int(modname:String)
		Return m_modules._Contains(modname)
	End Method
	
	Rem
		bbdoc: Get a module with the given name.
		returns: The module with the given name, or Null if there is no module with the given name.
	End Rem
	Method GetModuleWithName:mxModule(modname:String)
		Return mxModule(m_modules._ValueByKey(modname))
	End Method
	
	Rem
		bbdoc: Load the given dJObject into the scope.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxModuleScope(root:dJObject)
		If root <> Null
			SetName(root.GetName())
			For Local variable:TVariable = EachIn root.GetValues()
				If dJObject(variable)
					AddModule(New mxModule.FromJSON(dJObject(variable)))
				Else
					SetCommonFromVariable(variable)
				End If
			Next
			Return Self
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Get the module enumerator for the scope.
		returns: The module enumerator for the scope.
	End Rem
	Method ModuleEnumerator:TMapEnumerator()
		Return m_modules.ValueEnumerator()
	End Method
	
End Type

Rem
	bbdoc: Maximus module.
End Rem
Type mxModule Extends mxModuleBase
	
	Field m_parent:mxModuleScope
	Field m_versions:TObjectMap
	
	Method New()
		m_versions = New TObjectMap
	End Method
	
'#region Field accessors
	
	Rem
		bbdoc: Set the module's parent.
		returns: Nothing.
	End Rem
	Method SetParent(parent:mxModuleScope)
		m_parent = parent
	End Method
	
	Rem
		bbdoc: Get the module's parent.
		returns: The module's parent.
	End Rem
	Method GetParent:mxModuleScope()
		Return m_parent
	End Method
	
'#end region Field accessors
	
	Rem
		bbdoc: Add the given version to the module.
		returns: True if the version was added, or False if it was not (the version is Null).
	End Rem
	Method AddVersion:Int(version:mxModuleVersion)
		If version <> Null
			m_versions._Insert(version.GetName(), version)
			version.SetParent(Self)
			Return True
		End If
		Return False
	End Method
	
	Rem
		bbdoc: Check if there is a version with the given name.
		returns: True if the version was found, or False if it was not.
	End Rem
	Method HasVersion:Int(name:String)
		Return m_versions._Contains(name)
	End Method
	
	Rem
		bbdoc: Get a version with the given name.
		returns: The version with the given name, or Null if there is no version with the given name.
	End Rem
	Method GetVersionWithName:mxModuleVersion(name:String)
		Return mxModuleVersion(m_versions._ValueByKey(name))
	End Method
	
	Rem
		bbdoc: Set a common field from the given variable.
		returns: True if the given variable was handled, or False if it was not.
	End Rem
	Method SetCommonFromVariable:Int(variable:TVariable)
		If Super.SetCommonFromVariable(variable) = True
			Return True
		Else
			Select variable.GetName().ToLower()
				Case "versions"
					For Local jobj:dJObject = EachIn dJObject(variable).GetValues()
						AddVersion(New mxModuleVersion.FromJSON(jobj))
					Next
			End Select
			Return False
		End If
	End Method
	
	Rem
		bbdoc: Load the given dJObject into the module.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxModule(root:dJObject)
		If root <> Null
			SetName(root.GetName())
			For Local variable:TVariable = EachIn root.GetValues()
				SetCommonFromVariable(variable)
			Next
			Return Self
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Get the version enumerator for the module.
		returns: The version enumerator for the module.
	End Rem
	Method VersionEnumerator:TMapEnumerator()
		Return m_versions.ValueEnumerator()
	End Method
	
End Type

Rem
	bbdoc: Maximus module version.
End Rem
Type mxModuleVersion
	
	Field m_parent:mxModule
	Field m_name:String, m_url:String
	Field m_dependencies:mxModuleDependencies
	
	Method New()
		m_dependencies = New mxModuleDependencies
	End Method
	
'#region Field accessors
	
	Rem
		bbdoc: Set the version's parent.
		returns: Nothing.
	End Rem
	Method SetParent(parent:mxModule)
		m_parent = parent
	End Method
	
	Rem
		bbdoc: Get the version's parent.
		returns: The version's parent.
	End Rem
	Method GetParent:mxModule()
		Return m_parent
	End Method
	
	Rem
		bbdoc: Set the version's name.
		returns: Nothing.
	End Rem
	Method SetName(name:String)
		Assert name, "(mxModuleVersion.SetName) name cannot be Null!"
		m_name = name
	End Method
	
	Rem
		bbdoc: Get the version's name.
		returns: The version's name.
	End Rem
	Method GetName:String()
		Return m_name
	End Method
	
	Rem
		bbdoc: Set the version's url.
		returns: Nothing.
	End Rem
	Method SetUrl(url:String)
		Assert url, "(mxModuleVersion.SetUrl) url cannot be Null!"
		m_url = url
	End Method
	
	Rem
		bbdoc: Get the version's url.
		returns: The version's url.
	End Rem
	Method GetUrl:String()
		Return m_url
	End Method
	
	Rem
		bbdoc: Set the version's dependencies.
		returns: Nothing.
	End Rem
	Method SetDependencies(dependencies:mxModuleDependencies)
		m_dependencies = dependencies
	End Method
	
	Rem
		bbdoc: Get the version's dependencies.
		returns: The version's dependencies.
	End Rem
	Method GetDependencies:mxModuleDependencies()
		Return m_dependencies
	End Method
	
'#end region Field accessors
	
	Rem
		bbdoc: Set a common field from the given variable.
		returns: True if the given variable was handled, or False if it was not.
	End Rem
	Method SetCommonFromVariable:Int(variable:TVariable)
		Select variable.GetName().ToLower()
			Case "url"
				SetUrl(variable.ValueAsString())
			Case "deps"
				m_dependencies.FromJSON(dJArray(variable))
				Return True
		End Select
		Return False
	End Method
	
	Rem
		bbdoc: Load the given dJObject into the version.
		returns: Itself, or Null if @root is Null.
	End Rem
	Method FromJSON:mxModuleVersion(root:dJObject)
		If root <> Null
			SetName(root.GetName())
			For Local variable:TVariable = EachIn root.GetValues()
				SetCommonFromVariable(variable)
			Next
			Return Self
		End If
		Return Null
	End Method
	
End Type

