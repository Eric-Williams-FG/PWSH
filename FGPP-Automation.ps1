function Add-FGPPIdentities {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$OUSearchPath,
        [Parameter(Mandatory = $true)]
        [String]$FGPPGroupName
    )
    
    try {
        ipmo activedirectory
    }
    catch {
        throw $global:Error[0].Exception.Message
    
    }

    [array]$FGPPGroupMembers = Get-ADGroupMember -Identity $FGPPGroupName | Select-Object -ExpandProperty SamAccountName
    $Results = [System.Collections.ArrayList]::new()

    [array]$SVCAccountOUUserObjs = Get-ADUser -SearchBase $OUSearchPath -Filter * | Select-Object -ExpandProperty SamAccountName

    foreach ($SVCAccountOUUser in $SVCAccountOUUserObjs) {
        if ($FGPPGroupMembers -notcontains $SVCAccountOUUser) {
            [void]$Results.Add($SVCAccountOUUser)
        }
    }

    foreach ($MissingSVCUser in $Results) {
        try {
            Add-ADGroupMember -Identity $FGPPGroupName -Members $MissingSVCUser -WhatIf
        }
        catch {
            throw $global:error[0].ExceptionMessage
        }
    }
}


