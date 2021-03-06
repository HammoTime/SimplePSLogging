#
# Module manifest for module 'SimplePSLogging'
#

@{

# Version number of this module.
ModuleVersion = '1.1.0.0'

# ID used to uniquely identify this module
GUID = '34a074ea-124e-4a96-86ca-168a6d1610fa'

# Author of this module
Author = 'Adam Hammond'

# Company or vendor of this module
CompanyName = 'None'

# Copyright statement for this module
Copyright = '(c) Adam Hammond. All rights reserved.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# List of all modules packaged with this module
ModuleList = @('SimplePSLogging')

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('.\SimplePSLogging.psm1', '.\LoggingModules\SimplePSFileLogging.psm1', '.\LoggingModules\SimplePSSqlLogging.psm1', '.\SimplePSLoggingUtilities.psm1')

# Functions to export from this module
FunctionsToExport = @('Write-Message', 'Write-ScriptHeader', 'Enable-LogWriting', 'Disable-LogWriting', 'Write-BlankLine', 'Update-SimplePSLogging', 'Enable-FileLogWriting', 'Disable-FileLogWriting', 'Write-FileLog')

# HelpInfo URI of this module
HelpInfoURI = 'https://github.com/HammoTime/SimplePSLogging'

}
