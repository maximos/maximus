
Rem
	bbdoc: Maximus 'list' argument implementation.
End Rem
Type mxListImpl Extends dArgumentImplementation
	
	Field m_queuemap:dObjectMap = New dObjectMap
	
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
		m_queuemap.Clear()
		Local nfounds:TListEx = New TListEx
		Local sources:mxSourcesHandler = mainapp.m_sourceshandler
		If sources
			If sources.Count() > 0
				If GetArgumentCount() > 0
					For Local variable:dStringVariable = EachIn m_args
						Local scope:mxModuleScope
						Local arg:String = variable.Get()
						If arg.Contains(".")
							scope = sources.GetScopeWithName(mxModUtils.GetScopeFromID(arg))
							If scope
								Local modul:mxModule = scope.GetModuleWithName(mxModUtils.GetNameFromID(arg))
								If modul
									QueueModule(modul)
								Else
									nfounds.AddLast(arg)
								End If
							Else
								nfounds.AddLast(arg)
							End If
						Else
							scope = sources.GetScopeWithName(arg)
							If scope
								QueueScope(scope)
							Else
								nfounds.AddLast(arg)
							End If
						End If
					Next
				Else
					For Local modscope:mxModuleScope = EachIn sources.ValueEnumerator()
						QueueScope(modscope)
					Next
				End If
				ReportQueue()
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
				logger.LogMessage(_s("arg.list.nosources"))
			End If
		Else
			ThrowError(_s("error.list.nosources"))
		End If
	End Method
	
	Rem
		bbdoc: Queue the given module scope's modules for printing.
		returns: Nothing.
	End Rem
	Method QueueScope(modscope:mxModuleScope)
		If modscope
			For Local modul:mxModule = EachIn modscope.ModuleEnumerator()
				QueueModule(modul)
			Next
		End If
	End Method
	
	Rem
		bbdoc: Queue the given module for printing.
		returns: Nothing.
	End Rem
	Method QueueModule(modul:mxModule)
		If modul
			m_queuemap._Insert(modul.GetName(), modul)
		End If
	End Method
	
	Rem
		bbdoc: Report the module queue.
		returns: Nothing.
	End Rem
	Method ReportQueue()
		Local namelen:Int, verlen:Int, modul:mxModule, latest_version:mxModuleVersion
		Local modules:TList = New TList
		Local str:String
		For modul = EachIn m_queuemap.ValueEnumerator()
			str = modul.GetParent().GetName() + "." + modul.GetName()
			If str.Length > namelen Then namelen = str.Length
			latest_version:mxModuleVersion = modul.GetLatestVersion()
			If latest_version Then str = latest_version.GetName()
			If str.Length > verlen Then verlen = str.Length
			modules.AddFirst(modul)
		Next
		
		modules.Sort()
		
		For modul = EachIn modules
			latest_version:mxModuleVersion = modul.GetLatestVersion()
			If latest_version Then str = latest_version.GetName()
			If str <> "dev" And modul.HasVersion("dev") Then str:+ " (has dev)"
			logger.LogMessage((modul.GetParent().GetName() + "." + modul.GetName())[..namelen] + " - " + str[..verlen] + " - " + modul.GetDescription())
		Next
	End Method
	
End Type

