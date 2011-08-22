Type mxLoggerObserverGUI

	Field m_output:Object
	
	Method Reset()
		If TGadget(m_output)
			SetGadgetText(TGadget(m_output), "")
		End If
	End Method

	Method SendMessage:Object(message:Object, context:Object)
		Local msg:String = String(message)
		If String(context) = "error"
			Notify(msg, True)
		Else If TGadget(m_output)
			Local gadget:TGadget = TGadget(m_output)
			SetGadgetText(gadget, GadgetText(gadget) + "~n" + String(message))
			'Refresh GUI
			Driver.Poll
		Else If m_output = Null
			Notify(msg)
		End If
	End Method

End Type