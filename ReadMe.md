# Validate Azure Name is correct

Thanks to Barbara Forbes https://4bes.nl/  @Ba4bes for the inspiration https://4bes.nl/2021/10/24/api-to-collect-azure-resource-abbreviations/

The Collect-NamingRestrictions Function will gather the information every day from the https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules web-page, parse it and store it in a storage account ready to be used by  

The AzureNameValidation function which takes a `Name` and a `NameSpace` parameter and validates against Max and Min length of the restrictions (at present) and provides a pass or fail response  

````
Result          : Passed
Reason          : The Beard is happy with the Name lengths
MinLength       : 3
Scope           : resource group
NameSpace       : Microsoft.AnalysisServices/servers
MaxLength       : 63
ValidCharacters : Lowercase letters and numbers.Start with lowercase letter.
MustContain     : 
Name            : Azure
````  
or  

````
Result          : Failed
Reason          : The Name length is longer than the Maximum Length
MinLength       : 3
Scope           : resource group
NameSpace       : Microsoft.AnalysisServices/servers
MaxLength       : 63
ValidCharacters : Lowercase letters and numbers.Start with lowercase letter.
MustContain     : 
Name            : AzureAzureAzureAzureAzureAzureAzureAzureAzureAzureAzureAzureAzure
````

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

# wrong params
$Body = @{
     name = "AzureAzureAzureAzureAzureAzureAzureAzureAzureAzureAzureAzureAzure"
     NotNameSpace= "Microsoft.AnalysisServices/servers"
 }
 $URL = "https://azurenamecheck.azurewebsites.net/api/AzureNameValidation"
 Invoke-RestMethod $URL -Body ( $Body | ConvertTo-Json)

# Not correct params

$Body = @{
     name = "AzureAzureAzureAzureAzureAzureAzureAzureAzureAzureAzureAzureAzure"
 }                                                     
 $URL = "https://azurenamecheck.azurewebsites.net/api/AzureNameValidation"
 Invoke-RestMethod $URL -Body ( $Body | ConvertTo-Json)

````

![image](https://user-images.githubusercontent.com/6729780/145676335-dcf2edde-7afe-4cb7-95b0-445b30905034.png)
