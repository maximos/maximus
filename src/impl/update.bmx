
Rem
Copyright (c) 2010 Christiaan Kras

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
	bbdoc: Maximus 'update' argument implementation.
End Rem
Type mxUpdateImpl Extends mxArgumentImplementation
	
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
		If m_sourcesurl = Null Then m_sourcesurl = mainapp.m_sourcesurl
		If m_sourcesurl = Null
			ThrowError(_s("error.update.nourl"))
		End If
		Local file:String = mainapp.m_sourcesfile
		logger.LogMessage("fetching: " + m_sourcesurl + " -> " + file + "~t", False)
		Local stream:TStream = WriteFileExplicitly(file)
		If stream <> Null
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
			If response.responseCode = 200
				logger.LogMessage(_s("message.fetch.done", [String(response.responseCode)]))
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
		For Local opt:dIdentifier = EachIn m_args.GetValues()
			Select opt.GetName().ToLower()
				Case "--url"
					If opt.GetValueCount() = 1
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

