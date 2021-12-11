<#
.SYNOPSIS
    Collects naming restrictions from the Microsoft Docs and stores them in a storage account.
.DESCRIPTION
    This function will collect all the naming restrictionss from the Microsoft Docs (and some others).
    They are stored as a json file in a storage account.
.INPUTS
    Timer trigger, reccomended to run once a day
.OUTPUTS
    A JSON file that is written to a storage account

#>
param($Timer)

# Write to the Azure Functions log stream.
$Message = "PowerShell HTTP trigger function processed a request. {0}" -f ($Request.body | Out-String)
Write-Host $Message
function Get-AzNamingRestrictions {
    [cmdletbinding()]
    Param ()
    # This will get the naming restrictions from the Microsoft Docs page and output s

    # requires PowerHTML module 
    # The URL is where the resource rules
    # All props to Barbara Forbes https://github.com/Ba4bes/ResourceAbbreviations
    # @ba4bes
    # 4bes.nl

    Write-Output "Calling the URL and converting"
    $URL = 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules'
    try {
        $SourceContent = ConvertFrom-Html -URI $URL -ErrorAction Stop
    }
    catch {
        Write-Output "Something went wrong"
        $HttpResult = [HttpStatusCode]::BadRequest
        $Body = "The Beard is sad, Something went wrong - {0}" -f $_ 

        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
                StatusCode = $HttpResult
                Body       = $body
            })
        break    
    }
    

    Write-Debug "Got the details from the URL"
    # we need to find the tables with the info
    $TablesInSource = $SourceContent.SelectNodes('//table')
    # we also need to find the headers to identify the info - rubbish isnt it?
    $HeadersInSource = $SourceContent.SelectNodes('//h2')  

    foreach ($Table in $TablesInSource) {
        # because the header is always (we hope - nothing can go wrong here) 2 lines above the table in the source
        $header = ($HeadersInSource | Where-Object { $_.Line -eq ($Table.Line - 2) }).InnerText
        $childNotes = $Table.Element('tbody').ChildNodes | Where-Object { $_.NodeType -eq 'Element' -and $_.Name -eq 'tr' }
        foreach ($childNote in $childNotes) {
            $ChildNoteArray = ($childNote.InnerText -split '\r?\n') | Where-Object { $_ -ne '' }
            if ($ChildNoteArray[2]) {
                # switching to add in some of the specific values because consistency is hard
                switch ($ChildNoteArray[2]) {
                    { $_ -match 'Must be default' } { 
                        [PSCustomObject]@{
                            Header          = $header
                            Entity          = $ChildNoteArray[0] 
                            NameSpace       = "{0}/{1}" -f $header, $ChildNoteArray[0] -replace ' / ' , '/'
                            Scope           = $ChildNoteArray[1]
                            MinLength       = 7
                            MaxLength       = 7
                            ValidCharacters = 'Must be default.'
                            MustContain     = 'default'
                        }
                    }
                    { $_ -match 'Should always be \$default' } { 
                        [PSCustomObject]@{
                            Header          = $header
                            Entity          = $ChildNoteArray[0]
                            NameSpace       = "{0}/{1}" -f $header, $ChildNoteArray[0] -replace ' / ' , '/'
                            Scope           = $ChildNoteArray[1]
                            MinLength       = 8
                            MaxLength       = 8
                            ValidCharacters = 'Should always be $default'
                            MustContain     = '$default'
                        }
                    }
                    { $_ -match 'Must Be ActiveDirectory' } { 
                        [PSCustomObject]@{
                            Header          = $header
                            Entity          = $ChildNoteArray[0]
                            NameSpace       = "{0}/{1}" -f $header, $ChildNoteArray[0] -replace ' / ' , '/'
                            Scope           = $ChildNoteArray[1]
                            MinLength       = 15
                            MaxLength       = 15
                            ValidCharacters = 'Should always be $default'
                            MustContain     = 'ActiveDirectory'
                        }
                    }
                    { $_ -match 'value' } { 
                        # of course they use different things so sometimes we also need to do some of this rubbish
                        switch ($ChildNoteArray[0] ) {
                            'serverVulnerabilityAssessments' { 
                                [PSCustomObject]@{
                                    Header          = $header
                                    Entity          = $ChildNoteArray[0]
                                    NameSpace       = "{0}/{1}" -f $header, $ChildNoteArray[0] -replace ' / ' , '/'
                                    Scope           = $ChildNoteArray[1]
                                    MinLength       = 7
                                    MaxLength       = 7
                                    ValidCharacters = 'Must be Default'
                                    MustContain     = 'Default'
                                }
                            }
                            'settings' {
                                [PSCustomObject]@{
                                    Header          = $header
                                    Entity          = $ChildNoteArray[0]
                                    NameSpace       = "{0}/{1}" -f $header, $ChildNoteArray[0] -replace ' / ' , '/'
                                    Scope           = $ChildNoteArray[1]
                                    MinLength       = 4
                                    MaxLength       = 34
                                    ValidCharacters = 'Use one of:MCAS,Sentinel,WDATP,WDATP_EXCLUDE_LINUX_PUBLIC_PREVIEW'
                                    MustContain     = 'MCAS', 'Sentinel', 'WDATP', 'WDATP_EXCLUDE_LINUX_PUBLIC_PREVIEW'
                                }
                            }
                            'informationProtectionPolicies' {
                                [PSCustomObject]@{
                                    Header          = $header
                                    Entity          = $ChildNoteArray[0]
                                    NameSpace       = "{0}/{1}" -f $header, $ChildNoteArray[0] -replace ' / ' , '/'
                                    Scope           = $ChildNoteArray[1]
                                    MinLength       = 5
                                    MaxLength       = 9
                                    ValidCharacters = 'Use one of: custom effective'
                                    MustContain     = 'custom', 'effective'
                                }
                            }
                            'advancedThreatProtectionSettings' {
                                [PSCustomObject]@{
                                    Header          = $header
                                    Entity          = $ChildNoteArray[0]
                                    NameSpace       = "{0}/{1}" -f $header, $ChildNoteArray[0] -replace ' / ' , '/'
                                    Scope           = $ChildNoteArray[1]
                                    MinLength       = 7
                                    MaxLength       = 7
                                    ValidCharacters = 'must be current'
                                    MustContain     = 'current'
                                }
                            }
                            Default {
                                [PSCustomObject]@{
                                    Header          = $header
                                    Entity          = $ChildNoteArray[0]
                                    NameSpace       = "{0}/{1}" -f $header, $ChildNoteArray[0] -replace ' / ' , '/'
                                    Scope           = $ChildNoteArray[1]
                                    MinLength       = 0
                                    MaxLength       = 150
                                    ValidCharacters = 'See the values'
                                    MustContain     = $ChildNoteArray[3]
                                }
                            }
                        }

                    }
                    # most things will be here though
                    { $_ -match '-' } {
                        [PSCustomObject]@{
                            Header          = $header
                            Entity          = $ChildNoteArray[0]
                            Scope           = $ChildNoteArray[1]
                            NameSpace       = "{0}/{1}" -f $header, $ChildNoteArray[0] -replace ' / ' , '/'
                            MinLength       = $ChildNoteArray[2].Split('-')[0]
                            MaxLength       = $ChildNoteArray[2].Split('-')[1]
                            ValidCharacters = $ChildNoteArray[3]
                            MustContain     = ''
                        }
                    }
                    # but we better catch everything just in case
                    Default {
                        [PSCustomObject]@{
                            Header          = $header
                            Entity          = $ChildNoteArray[0]
                            NameSpace       = "{0}/{1}" -f $header, $ChildNoteArray[0] -replace ' / ' , '/'
                            Scope           = $ChildNoteArray[1]
                            MinLength       = $ChildNoteArray[2].Split('-')[0]
                            MaxLength       = $ChildNoteArray[2].Split('-')[1]
                            ValidCharacters = $ChildNoteArray[3]
                            MustContain     = 'Unknown' # so we know it hit this one because it ought not to
                        }
                    }
                }
            }
        }
    }

    # Add in some extras that are not on the naming restrictions page because it is rubbish - This isnt built with duct tape and sticky plaster!

    [PSCustomObject]@{
        Header          = 'Microsoft.Search'
        Entity          = 'searchServices'
        NameSpace       = 'Microsoft.Search/searchServices'
        Scope           = 'subscription'
        MinLength       = 2
        MaxLength       = 60
        ValidCharacters = 'Service name must only contain lowercase letters, digits or dashes, cannot use dash as the first two or last one characters, cannot contain consecutive dashes, and is limited between 2 and 60 characters in length.'
        MustContain     = $null
    }
    [PSCustomObject]@{
        Header          = 'Microsoft.Purview'
        Entity          = 'accounts'
        NameSpace       = 'Microsoft.Purview/accounts'
        Scope           = 'subscription'
        MinLength       = 3
        MaxLength       = 63
        ValidCharacters = ' must only contain lowercase letters, digits or dashes'
        MustContain     = $null
    }
    [PSCustomObject]@{
        Header          = 'Microsoft.StreamAnalytics'
        Entity          = 'cluster'
        NameSpace       = 'Microsoft.StreamAnalytics/cluster'
        Scope           = 'subscription'
        MinLength       = 3
        MaxLength       = 63
        ValidCharacters = 'Stream Analytics cluster name can contain alphanumeric characters, hyphens, and underscores only and must be 3-63 characters long'
        MustContain     = $null
    }
    [PSCustomObject]@{
        Header          = 'Microsoft.Synapse/workspaces'
        Entity          = 'workspaces'
        NameSpace       = 'Microsoft.Synapse/workspaces'
        Scope           = 'subscription'
        MinLength       = 1
        MaxLength       = 50
        ValidCharacters = 'Workspace name must be between 1 and 50 characters long.
        Workspace name must contain only lowercase letters or numbers or hyphens.
        Workspace name must start with a letter or a number.
        Workspace name must end with a letter or a number.
        Workspace name must not contain -ondemand word.'
        MustContain     = $null
    }
}

$Restrictions = Get-AzNamingRestrictions
# Write to the Azure Functions log stream.
$Message = "Run the function" 
Write-Host $Message
Write-Output $Restrictions
Push-OutputBinding -Name outputBlob -Value $Restrictions 