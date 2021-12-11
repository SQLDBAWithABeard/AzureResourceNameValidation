````
# Success
$Body = @{
    name = "Azure"
    NameSpace= "Microsoft.AnalysisServices/servers"
}
$URL = "https://azurenamecheck.azurewebsites.net/api/AzureNameValidation"
Invoke-RestMethod $URL -Body ( $Body | ConvertTo-Json)
# Wrong NameSpace
$Body = @{
    name = "Azure"
    NameSpace= "Microsoft.AnalysisServices/server"
}
$URL = "https://azurenamecheck.azurewebsites.net/api/AzureNameValidation"
Invoke-RestMethod $URL -Body ( $Body | ConvertTo-Json)
# Too Short
$Body = @{
    name = "Az"
    NameSpace= "Microsoft.AnalysisServices/servers"
}
$URL = "https://azurenamecheck.azurewebsites.net/api/AzureNameValidation"
Invoke-RestMethod $URL -Body ( $Body | ConvertTo-Json)
# Too Long
$Body = @{
    name = "AzureAzureAzureAzureAzureAzureAzureAzureAzureAzureAzureAzureAzure"
    NameSpace= "Microsoft.AnalysisServices/servers"
}
$URL = "https://azurenamecheck.azurewebsites.net/api/AzureNameValidation"
Invoke-RestMethod $URL -Body ( $Body | ConvertTo-Json)

````