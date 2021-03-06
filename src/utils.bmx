
Rem
	bbdoc: Maximus module utilities.
End Rem
Type mxModUtils
	
	Global g_modules:dObjectMap
	
	Rem
		bbdoc: Get an object map of the current modules.
		returns: An object map containing the current modules.
		about: @force can be used to force re-enumeration of the modules.
	End Rem
	Function GetModules:dObjectMap(force:Int = False)
		If Not g_modules Or force
			g_modules = EnumModules(Null, Null)
		End If
		Return g_modules
	End Function
	
	Rem
		bbdoc: Check if the user currently has the given module.
		returns: True if the given module was found.
	End Rem
	Function HasModule:Int(modul:String)
		Return GetModules()._Contains(modul)
	End Function
	
	Rem
		bbdoc: Get the path to the given module or modscope.
		returns: The path to the given module or modscope, or the modules path if the given modid is Null.
	End Rem
	Function ModulePath:String(modid:String)
		Local p:String = mainapp.m_modpath
		If modid Then p:+ "/" + modid.Replace(".", ".mod/") + ".mod"
		Return p
	End Function
	
	Rem
		bbdoc: Get the path to the main source file for the given module id .
		returns: The path to the given module's main source file, or Null if the given module id is Null.
	End Rem
	Function SourceFilePath:String(modid:String)
		If modid
			Return ModulePath(modid) + "/" + GetNameFromID(modid) + ".bmx"
		End If
		Return Null
	End Function
	
	Rem
		bbdoc: Get the module scope from the given versioned-module id (for modules with forced versions (or normal ids), e.g. mxModUtils.GetScopeFromID("foo.bar/dev")  would return "foo").
		returns: The scope of the given versioned-module id, or Null if the given versioned-module id was incorrect.
	End Rem
	Function GetScopeFromID:String(verid:String)
		verid = GetIDFromVerID(verid)
		Local i:Int = verid.Find(".")
		If i > -1 Then Return verid[..i]
		Return Null
	End Function
	
	Rem
		bbdoc: Get the module name from the given versioned-module id (for modules with forced versions (or normal ids), e.g. mxModUtils.GetNameFromID("foo.bar/dev")  would return "bar").
		returns: The name of the given versioned-module id, or Null if the given versioned-module is was incorrect.
	End Rem
	Function GetNameFromID:String(verid:String)
		verid = GetIDFromVerID(verid)
		Local i:Int = verid.Find(".")
		If i > -1 Then Return verid[i + 1..]
		Return Null
	End Function
	
	Rem
		bbdoc: Get the actual module id from the given versioned-module id (for modules with forced versions (or normal ids), e.g. mxModUtils.GetIDFromVerID("foo.bar/dev")  would return "foo.bar").
		returns: The id of the given versioned-module id.
	End Rem
	Function GetIDFromVerID:String(verid:String)
		Local i:Int = verid.Find("/")
		If i > -1 Then verid = verid[..i]
		Return verid
	End Function
	
	Rem
		bbdoc: Get the version from the given versioned-module id (for modules with forced versions, e.g. mxModUtils.GetVersionFromVerID("foo.bar/dev) would return "dev").
		returns: The version of the given versioned-module id (which will be Null if the given value is not versioned).
	End Rem
	Function GetVersionFromVerID:String(verid:String)
		Local i:Int = verid.Find("/")
		If i > -1 Then Return verid[i + 1..]
		Return Null
	End Function
	
	Rem
		bbdoc: Get the version of the module from the given versioned-module id, if it is installed.
		returns: The module's version if it's being managed by Maximus, Null if the module was not found or "unmanaged" if not being managed by Maximus
	End Rem
	Function GetInstalledVersionFromVerID:String(verid:String)
		verid = GetIDFromVerID(verid)
		'DebugLog("(mxModUtils.GetInstalledVersionFromVerID) modid: " + verid)
		Local ver:String
		Local path:String = mxModUtils.ModulePath(verid)
		Local metafile_path:String = path + "/meta.maximus"
		If FileType(metafile_path) = FILETYPE_FILE
			Local metafile:mxMetaFile = New mxMetaFile.Create(metafile_path)
			metafile.Load()
			ver = metafile.m_version
		Else If FileType(path) = FILETYPE_DIR
			ver = "unmanaged"
		End If
		Return ver
	End Function
	
	Rem
		bbdoc: Enumerate all of the current modules.
		returns: An object map containing the current modules.
	End Rem
	Function EnumModules:dObjectMap(modid:String = Null, mods:dObjectMap = Null)
		If Not mods Then mods = New dObjectMap
		Local dir:String = ModulePath(modid)
		Local files:String[] = LoadDir(dir)
		For Local file:String = EachIn files
			Local path:String = dir + "/" + file
			If file[file.length - 4..] <> ".mod" Or FileType(path) <> FILETYPE_DIR Then Continue
			Local t:String = file[..file.length - 4]
			If modid Then t = modid + "." + t
			Local i:Int = t.Find(".")
			If i > -1 And t.Find(".", i + 1) = -1 Then mods._Insert(t, path)
			EnumModules(t, mods)
		Next
		Return mods
	End Function
	
	Rem
		bbdoc: Document all modules, or the modules given (doesn't work yet - all documentation will be built).
		returns: The exit code from makedocs.
	End Rem
	Function DocMods:Int(args:String = Null)
		args = "docmods " + args.Trim()
		logger.LogMessage("run: " + args)
		Return system_(mainapp.m_binpath + "/" + args)
	End Function
	
End Type

Rem
	bbdoc: Maximus BMK utilities.
End Rem
Type mxBMKUtils
	
	Rem
		bbdoc: Run BMK with the given arguments.
		returns: The exit code from bmk (non-zero when an error occured).
	End Rem
	Function RunBMK:Int(args:String)
		args = "bmk " + args.Trim()
		logger.LogMessage("run: " + args)
		Return system_(mainapp.m_binpath + "/" + args)
	End Function
	
	Rem
		bbdoc: Make modules with the given arguments.
		returns: The exit code from bmk (non-zero when an error occured).
	End Rem
	Function MakeMods:Int(args:String, threaded:Int)
		Local opts:String
		Local return_code:Int = RunBMK("makemods" + opts + " " + args)
		If return_code = 0 And threaded
			opts:+" -h"
			return_code = RunBMK("makemods" + opts + " " + args)
		End If
		Return return_code
	End Function
	
End Type

Rem
	bbdoc: Create a preconfigured HTTP request
	returns: TRESTRequest object.
End Rem
Function mxHTTPRequest:TRESTRequest(stream:TStream = Null, progressFunction:Int(data:Object, dltotal:Double, dlnow:Double, ultotal:Double, ulnow:Double) = Null)
	Local request:TRESTRequest = New TRESTRequest
	request.SetStream(stream)
	request.SetProgressCallback(progressFunction, New _mxProgressStore)
	request.SetProxyServer(mainapp.m_proxyserver)
	request.AddHeader("User-Agent", mainapp.m_useragent)
	Return request
End Function

Rem
	bbdoc: Maximus temporary progress storage for url fetching.
End Rem
Type _mxProgressStore
	
	Field m_progress:Int = 0
	
End Type

