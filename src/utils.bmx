
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
		returns: The module's version (which may be "dev" if Subversion or git is found controlling the module's directory), or Null if the module was not found.
	End Rem
	Function GetInstalledVersionFromVerID:String(verid:String)
		verid = GetIDFromVerID(verid)
		'DebugLog("(mxModUtils.GetInstalledVersionFromVerID) modid: " + verid)
		Local ver:String
		Local path:String = mxModUtils.ModulePath(verid) + "/"
		If FileType(path) = FILETYPE_DIR
			If FileType(path + ".git") = FILETYPE_DIR Or FileType(path + ".svn") = FILETYPE_DIR
				ver = "dev"
			Else If FileType(path + GetNameFromID(verid) + ".bmx") = FILETYPE_FILE
				Local stream:TStream = ReadStream(path + GetNameFromID(verid) + ".bmx")
				If stream
					Local line:String
					While Not stream.Eof()
						line = stream.ReadLine().Trim().ToLower()
						If line.Contains("moduleinfo") And line.Contains("version")
							line = line.Replace(" ", "").Replace("~q", "")
							'Local vp:Int = line.Find("moduleinfoversion:")
							If line.StartsWith("moduleinfoversion:") ' vp > -1 And (vp + 18 <= line.Length)
								ver = line[18..]
								Exit
							End If
						End If
					End While
					stream.Close()
				End If
			End If
		End If
		Return ver
	End Function
	
	Rem
	Function GetInstalledVersionFromVerID:String(verid:String)
		verid = GetIDFromVerID(verid)
		Local ver:String
		Local path:String = mxModUtils.ModulePath(verid) + "/"
		If FileType(path) = FILETYPE_DIR
			If FileType(path + ".git") = FILETYPE_DIR Or FileType(path + ".svn") = FILETYPE_DIR
				ver = "dev"
			Else
				DebugLog("(mxModUtils.GetInstalledVersionFromVerID) modid: " + verid + "  path: " + path + GetNameFromID(verid) + ".bmx")
				Local text:String = LoadText(path + GetNameFromID(verid) + ".bmx")
				SaveText(text, AppDir + "/tmp.tmp")
				Local lexer:TLexer = New TLexer.InitWithSource(text)
				If lexer.Run()
					Local tokens:TToken[] = lexer.GetTokens()
					For Local i:Int = 0 Until tokens.Length
						Local token:TToken = tokens[i]
						If token.kind = TToken.TOK_MODULEINFO_KW
							If Not (i + 1 >= tokens.Length)
								token = tokens[i + 1]
								If token.kind = TToken.TOK_STRING_LIT
									Local str:String = token.ToString().Replace("~q", "").ToLower()
									If str.Contains("version:")
										Local colon:Int = str.Find(":")
										ver = str[(colon > -1 And colon + 1 Or 0)..].Trim()
										Exit
									End If
								End If
							End If
						End If
					Next
				Else
					DebugLog("(mxModule.GetInstalledVersion) lexer.Run() failed on ~q" + path + "~q : " + lexer.GetError())
				End If
			End If
		End If
		Return ver
	End Function
	End Rem
	
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
		If threaded Then opts:+ " -h"
		Return RunBMK("makemods" + opts + " " + args)
	End Function
	
End Type

Rem
	bbdoc: Maximus temporary progress storage for url fetching.
End Rem
Type _mxProgressStore
	
	Field m_progress:Int = 0
	
End Type

