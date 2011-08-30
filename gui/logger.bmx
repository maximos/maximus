Rem
	bbdoc: This observer for mxLogger will write received messages to a TGadget or use Notify
End Rem
Type mxLoggerObserverGUI

	Rem
		bbdoc: Object to write message to
	End Rem
	Field m_output:Object
	
	Rem
		bbdoc: Reset content of m_object
	End Rem
	Method Reset()
		If TGadget(m_output)
			SetGadgetText(TGadget(m_output), "")
		End If
	End Method

	Rem
		bbdoc: Handle messages
	End Rem
	Method SendMessage:Object(message:Object, context:Object)
		Local msg:String = String(message)
		If String(context) = mxLogger.c_error
			Notify(msg, True)
		Else If TGadget(m_output)
			Local gadget:TGadget = TGadget(m_output)
			SetGadgetText(gadget, GadgetText(gadget) + String(message))
			'Refresh GUI
			Driver.Poll
		Else If m_output = Null
			Notify(msg)
		End If
	End Method

End Type