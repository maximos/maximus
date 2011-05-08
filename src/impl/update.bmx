
Rem
	bbdoc: Maximus 'update' argument implementation.
End Rem
Type mxUpdateImpl Extends dArgumentImplementation
	
	Field m_sourcesurl:String
	
	Method New()
		init(["update"])
	End Method
	
	Rem
		bbdoc: Check the current arguments for errors (according to the specific implementation).
		returns: Nothing.
		about: This method will throw an error if the arguments are invalid.
	End Rem
	Method CheckArgs()
		CheckOptions()
	End Method
	
	Rem
		bbdoc: Get a string describing the typical usage of the argument.
		returns: A string describing the typical usage of the argument.
	End Rem
	Method GetUsage:String()
		Return _s("arg.update.usage")
	End Method
	
	Rem
		bbdoc: Execute the implementation's operation.
		returns: Nothing.
	End Rem
	Method Execute()
		If mainapp.m_sourcesupdated Then Return
		If m_sourcesurl Then m_sourcesurl = mainapp.m_sourcesurl
		If m_sourcesurl
			ThrowError(_s("error.update.nourl"))
		End If
		mainapp.m_sourcesupdated = True
		Local file:String = mainapp.m_sourcesfile + ".tmp"
		logger.LogMessage("fetching: " + m_sourcesurl + " -> " + file + "~t", False)
		Local stream:TStream = WriteFileExplicitly(file)
		If stream
			Local request:TRESTRequest = New TRESTRequest, response:TRESTResponse
			request.SetProgressCallback(_ProgressCallback, New _mxProgressStore)
			request.SetStream(stream)
			Try
				response = request.Call(m_sourcesurl, ["User-Agent: " + mainapp.m_useragent], "GET")
			Catch e:Object
				stream.Close()
				DeleteFile(file)
				logger.LogMessage("")
				ThrowError(_s("error.fetch.sources", [e.ToString()]))
			End Try
			stream.Close()
			If response.IsSuccess()
				logger.LogMessage(_s("message.fetch.done", [String(response.responseCode)]))
				CopyFile(file, mainapp.m_sourcesfile)
				DeleteFile(file)
			Else
				DeleteFile(file)
				logger.LogMessage("")
				ThrowError(_s("error.fetch.sources", ["Bad response code: " + String(response.responseCode)]))
			End If
		Else
			ThrowError(_s("error.writeperms", [file]))
		End If
	End Method
	
	Rem
		bbdoc: Check the options given to the command.
		returns: Nothing.
	End Rem
	Method CheckOptions()
		m_sourcesurl = Null
		For Local opt:dIdentifier = EachIn m_args
			Select opt.GetName().ToLower()
				Case "--url"
					If opt.GetChildCount() = 1
						m_sourcesurl = dStringVariable(opt.GetValueAtIndex(0)).Get()
					Else
						ThrowCommonError(mxOptErrors.REQUIRESPARAMS, opt.GetName())
					End If
				Default ThrowCommonError(mxOptErrors.UNKNOWN, opt.GetName())
			End Select
		Next
	End Method
	
	Rem
		bbdoc: Progress callback for sources fetching.
		returns: Zero (no error).
	End Rem
	Function _ProgressCallback:Int(data:Object, dltotal:Double, dlnow:Double, ultotal:Double, ulnow:Double)
		Local store:_mxProgressStore = _mxProgressStore(data)
		Local prog:Int = (dlnow / dltotal) * 100
		If prog > store.m_progress + 5
			store.m_progress = prog
			WriteStdOut(".")
		End If
		Return 0
	End Function
	
End Type

