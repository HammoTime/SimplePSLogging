<#
    Version:        1.1.0.0
    Author:         Adam Hammond
    Creation Date:  02/05/2016
    Last Change:    Created file.
    Description:    Contains functions used to manage log writing to a Sql Db.
                    
    Link:           https://github.com/HammoTime/SimplePSLogging
    License:        The MIT License (MIT)
#>

Function Enable-SqlLogWriting
{
    param
    (
        [Parameter(Mandatory=$True)]
        [String]
        $ConnectionString
    )
    
    # Remember DB must be included in ConnectionString, gotta validate that.
}

Function Disable-SqlLogWriting
{
    
}

Export-ModuleMember -Function Enable-SqlLogWriting
Export-ModuleMember -Function Disable-SqlLogWriting