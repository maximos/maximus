
SuperStrict

Framework brl.blitz
Import brl.standardio
Import brl.maxutil
Import brl.ramstream

Import bah.volumes
Import gman.zipengine
Import htbaapub.rest

Import duct.variables
Import duct.objectmap
Import duct.json
Import duct.locale
Import duct.clapp
Import duct.time

Incbin "locales/en.loc"

Include "src/main.bmx"
Include "src/logger.bmx"
Include "src/errors.bmx"
Include "src/config.bmx"
Include "src/dependencies.bmx"
Include "src/module.bmx"
Include "src/sources.bmx"
Include "src/userinput.bmx"
Include "src/utils.bmx"
Include "src/impl/help.bmx"
Include "src/impl/version.bmx"
Include "src/impl/modpath.bmx"
Include "src/impl/install.bmx"
Include "src/impl/update.bmx"
Include "src/impl/list.bmx"

Global logger:mxLogger = New mxLogger
logger.AddObserver(New mxLoggerObserverIOStream)

Global mainapp:mxApp
New mxApp.Create()
mainapp.SetUserInput(mxUserInput.c_cli)
'Skip the first element because it is the program's location
mainapp.SetArgs(AppArgs[1..])
mainapp.Run()
