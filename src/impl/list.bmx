
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
	bbdoc: Maximus 'list' argument implementation.
End Rem
Type mxListImpl Extends mxArgumentImplementation
	
	Method New()
		init(["list"])
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
		Return _s("arg.list.usage")
	End Method
	
	Rem
		bbdoc: Execute the implementation's operation.
		returns: Nothing.
	End Rem
	Method Execute()
		Local sources:mxSourcesHandler = mainapp.m_sourceshandler
		If sources.Count() > 0
			If GetArgumentCount() > 0
				Local nfounds:TListEx = New TListEx, scope:mxModuleScope
				For Local variable:dStringVariable = EachIn m_args.GetValues()
					Local arg:String = variable.Get()
					If arg.Contains(".") = True
						scope = sources.GetScopeWithName(arg[..arg.Find(".")])
						If scope <> Null
							Local modul:mxModule = scope.GetModuleWithName(arg[arg.Find(".") + 1..])
							If modul <> Null
								ReportModule(modul, "", scope.GetName())
							Else
								nfounds.AddLast(arg)
							End If
						Else
							nfounds.AddLast(arg)
						End If
					Else
						scope = sources.GetScopeWithName(arg)
						If scope <> Null
							ReportModuleScope(scope)
						Else
							nfounds.AddLast(arg)
						End If
					End If
				Next
				If nfounds.Count() > 0
					Local a:String
					logger.LogWarning(_s("arg.list.unfound"))
					For Local b:String = EachIn nfounds
						a:+ b + " "
					Next
					a = a[..a.Length - 1]
					logger.LogMessage("~t" + a)
				End If
			Else
				For Local modscope:mxModuleScope = EachIn sources.ValueEnumerator()
					ReportModuleScope(modscope)
				Next
			End If
		Else
			logger.LogMessage(_s("arg.list.nosources"))
		End If
	End Method
	
	Rem
		bbdoc: Report the given module scope's information.
		returns: Nothing.
	End Rem
	Method ReportModuleScope(modscope:mxModuleScope)
		If modscope <> Null
			logger.LogMessage(modscope.GetName() + " - " + modscope.GetDescription())
			For Local modul:mxModule = EachIn modscope.ModuleEnumerator()
				ReportModule(modul, "~t", Null)
			Next
		End If
	End Method
	
	Rem
		bbdoc: Report the given module's information.
		returns: Nothing.
	End Rem
	Method ReportModule(modul:mxModule, tab:String = "", dn:String = "")
		If modul <> Null
			logger.LogMessage(tab + dn + "." + modul.GetName() + " - " + modul.GetDescription())
			For Local version:mxModuleVersion = EachIn modul.VersionEnumerator()
				logger.LogMessage(tab + "~t/" + version.GetName() + " - " + version.GetUrl())
				logger.LogMessage(tab + "~t~tdeps:[" + version.GetDependencies().DependencyList() + "]")
			Next
		End If
	End Method
	
End Type

