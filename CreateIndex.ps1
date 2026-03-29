$docsPath = ".\docs"
$outputFile = Join-Path $docsPath "index.html"

# Get all HTML files except index.html
$files = Get-ChildItem -Path $docsPath -Filter *.html |
    Where-Object { $_.Name -ne "index.html" }

$items = @()

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    # Extract <title>...</title>
    if ($content -match '(?is)<title>(.*?)</title>') {
        $title = $matches[1].Trim()
    } else {
        # fallback to filename if no title found
        $title = $file.BaseName
    }

    $items += [PSCustomObject]@{
        FileName = $file.Name
        Title    = $title
    }
}

# Sort by title
$items = $items | Sort-Object Title

# Build HTML list
$listItems = $items | ForEach-Object {
    "<li><a href=""$($_.FileName)"">$($_.Title)</a></li>"
}

# Generate final HTML
$html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>CodeProject.com Articles</title>
</head>
<body>
    <h1>CodeProject.com Articles</h1>
    <ol>
        $(($listItems -join "`n        "))
    </ol>
</body>
</html>
"@

# Write to index.html
$html | Set-Content -Path $outputFile -Encoding UTF8

Write-Host "index.html generated at $outputFile"
