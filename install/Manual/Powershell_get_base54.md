$uuid = Read-Host "请输入 UUID"
$base64_uuid = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($uuid)) -replace '[/+]'
$base64_uuid = $base64_uuid.Substring(0, 22)
while ($base64_uuid.Length % 4 -ne 0) {
    $base64_uuid += '='
}
Write-Host "UUID: $uuid"
Write-Host "BASE64: $base64_uuid"
