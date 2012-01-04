
Rem
	bbdoc: User Input interface
End Rem
Type mxUserInput

	Rem
		bbdoc:Command Line Interface
	End Rem
	Const c_cli:Byte = 0
	
	Rem
		bbdoc:Graphical User Interface
	End Rem
	Const c_gui:Byte = 1

	Field m_driver:mxUserInputDriver
	
	Rem
		bbdoc: Factory for initializing mxUserInput object
		about: interface can be either c_cli of c_gui
	End Rem
	Function factory:mxUserInput(interface:Byte)
		Local ui:mxUserInput = New mxUserInput
		Select interface
			Case c_cli
				ui.m_driver = New mxUserInputDriverCLI
			Case c_gui
				ui.m_driver = New mxUserInputDriverGUI
		End Select
		Return ui
	End Function
	
	Rem
		bbdoc: Ask user to confirm an action
		returns: True or False
	End Rem
	Method Confirm:Byte(question:String)
		Return Self.m_driver.Confirm(question)
	End Method

End Type

Rem
	bbdoc: User Input Driver interface
End Rem
Type mxUserInputDriver Abstract
	
	Rem
		bbdoc: Ask user to confirm an action
		returns: True or False
	End Rem
	Method Confirm:Byte(question:String) Abstract
	
End Type

	
Rem
	bbdoc: UserInpitDriver for Command Line Interface
End Rem
Type mxUserInputDriverCLI Extends mxUserInputDriver
	
	Rem
		bbdoc: Ask user to confirm an action
		returns: True or False
	End Rem
	Method Confirm:Byte(question:String)
		Local resp:String = Input(question + " " + _s("message.confirm")).ToLower()
		If resp = "y" Or resp = "yes"
			Return True
		Else
			Return False
		End If
	End Method

End Type

Rem
	bbdoc: UserInputDriver for Graphical User Interface
End Rem
Type mxUserInputDriverGUI Extends mxUserInputDriver

	Rem
		bbdoc:Ask user to confirm an action
	End Rem
	Method Confirm:Byte(question:String)
		Return brl.system.Confirm(question)
	End Method

End Type