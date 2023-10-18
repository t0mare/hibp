function Get-APIData {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$endpointURL,
        [Parameter()]
        [string]$apiKey
    )
    try {
        $headers = @{
            "hibp-api-key" = $apiKey
        }
        $response = Invoke-RestMethod -Uri $endpointURL -Headers $headers
        return $response
    }
    catch {
        Write-Error -Message $_.Exception.Message
    }
}

#Domain
$domain = Read-Host "Enter your domain"

# Set the API endpoint URL
$endpointUrl = "https://haveibeenpwned.com/api/v3"

# Set the API key
$apiKey = Read-Host "Enter your API key"

# Set the request headers
$headers = @{
    "hibp-api-key" = $apiKey
}

$response = Get-APIData -endpointURL ($endpointUrl + "/breacheddomain/" + $domain) -apiKey $apiKey

# Output the response
$response | ConvertTo-Json -Depth 100 | Out-File -FilePath "./pwned.json"

# I don't know how to treat json
$result = Get-Content -Raw -Path ./pwned.json | ConvertFrom-Json
$result = $result.psobject.properties | Select-Object Name, Value

# Get unique dump values
$breaches = @()
foreach ($item in $result) {
    $breaches += $item.Value
}
$uniqueBreaches = $breaches | Sort-Object -Unique

$breachDataList = @()
foreach ($breach in $uniqueBreaches) {
    $breachData = Get-APIData -endpointURL ($endpointUrl + "/breach/" + $breach) -apiKey $apiKey
    $breachDataList += $breachData
}