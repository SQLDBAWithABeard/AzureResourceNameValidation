using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $inputBlob, $TriggerMetadata)

# Write to the Azure Functions log stream.
$Message = "PowerShell HTTP trigger function processed a request. {0}" -f ($Request.body | Out-String)
Write-Host $Message

# Interact with query parameters or the body of the request.
$ApprovedParameters = 'Name', 'NameSpace'


# First check for invalid parameters.
if ($Request.Body.Keys | Where-Object { $ApprovedParameters -notcontains $_ }) {
    $HttpResult = [HttpStatusCode]::BadRequest
    $Body = "The Beard is sad, Invalid parameters have been used. Just {0} please" -f ($ApprovedParameters -join ',')
}
else {
    $Name = $Request.Body.Name 
    $NameSpace = $Request.Body.NameSpace 

    # Better check we have all the params we need
    if (-not $Name -or -not $NameSpace) {
        $HttpResult = [HttpStatusCode]::BadRequest
        $Body = "The Beard is sad, You missed a required Parameter. How am I supposed to work with that? You gave {0} but I need {1}" -f ($Request.Body.Keys | Out-String) , ($ApprovedParameters -join ',')
    }
    else {
        $NameSpaceRestrictions = $InputBlob | Where-Object { $_.NameSpace -eq $NameSpace }
        if (-not $NameSpaceRestrictions) {
            $HttpResult = [HttpStatusCode]::NotFound
            $Body = "The Beard is sad, I dont have a restriction for that Namespace. You gave {0} " -f $NameSpace
        }
        else {
            switch ($Name.Length) {
                {$_ -gt $NameSpaceRestrictions.MaxLength} { 
                $Result = "Failed"
                $Reason = "The Name length is longer than the Maximum Length"
                 }
                {$_ -lt $NameSpaceRestrictions.MinLength} { 
                $Result = "Failed"
                $Reason = "The Name length is less than the Minimum Length"
                 }
                Default {
                $Result = "Passed"
                $Reason = "The Beard is happy with the Name lengths"
                }
            }

            $body = @{
                Result = $Result
                Reason = $Reason
                Name = $Name
                NameSpace = $NameSpace
                MinLength = $NameSpaceRestrictions.MinLength
                MaxLength = $NameSpaceRestrictions.MaxLength
                Scope = $NameSpaceRestrictions.Scope
                ValidCharacters = $NameSpaceRestrictions.ValidCharacters
                MustContain = $NameSpaceRestrictions.MustContain
            }
            $HttpResult = [HttpStatusCode]::OK
        }
    }
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $HttpResult
        Body       = $body
    })
