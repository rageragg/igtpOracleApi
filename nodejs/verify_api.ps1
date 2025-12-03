$baseUrl = "http://localhost:3000/api/countries"

Write-Host "1. GET All Countries"
try {
    $countries = Invoke-RestMethod -Method Get -Uri $baseUrl
    Write-Host "Success. Count: $($countries.Count)"
    $countries | ForEach-Object { Write-Host " - ID: $($_.ID), Code: $($_.COUNTRY_CO)" }
} catch {
    Write-Host "Failed: $_"
}

$rnd = Get-Random -Minimum 1000 -Maximum 9999
Write-Host "`n2. POST Create Country (Random: $rnd)"
$newCountry = @{
    country_co = "T$rnd"
    description = "Test Country $rnd"
    path_image = "/images/test_$rnd.png"
    telephone_co = "999"
    user_id = 1
    slug = "test-country-$rnd"
    uuid = "test-uuid-$rnd"
}
try {
    $created = Invoke-RestMethod -Method Post -Uri $baseUrl -Body ($newCountry | ConvertTo-Json) -ContentType "application/json"
    Write-Host "Success. Created ID: $($created.id)"
    $createdId = $created.id
} catch {
    Write-Host "Failed: $_"
    # Print error details if available
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader $_.Exception.Response.GetResponseStream()
        Write-Host "Error Body: $($reader.ReadToEnd())"
    }
    exit
}

if ($createdId) {
    Write-Host "`n3. GET Country By ID ($createdId)"
    try {
        $country = Invoke-RestMethod -Method Get -Uri "$baseUrl/$createdId"
        Write-Host "Success. Description: $($country.DESCRIPTION)"
    } catch {
        Write-Host "Failed: $_"
    }

    Write-Host "`n4. PUT Update Country ($createdId)"
    $updateData = @{
        country_co = "T$rnd"
        description = "Test Country Updated $rnd"
        path_image = "/images/test_updated_$rnd.png"
        telephone_co = "999"
        user_id = 1
        slug = "test-country-updated-$rnd"
        uuid = "test-uuid-$rnd"
    }
    try {
        $updated = Invoke-RestMethod -Method Put -Uri "$baseUrl/$createdId" -Body ($updateData | ConvertTo-Json) -ContentType "application/json"
        Write-Host "Success. New Description: $($updated.description)"
    } catch {
        Write-Host "Failed: $_"
    }

    Write-Host "`n5. DELETE Country ($createdId)"
    try {
        $deleted = Invoke-RestMethod -Method Delete -Uri "$baseUrl/$createdId"
        Write-Host "Success. Message: $($deleted.message)"
    } catch {
        Write-Host "Failed: $_"
    }
}
