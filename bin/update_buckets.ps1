# https://qiita.com/rkbk60/items/c55223c26a42776f7101
# globalのuser.nameとBucket所有者名が一致するものを自動更新
# * リモート名は"origin"のみ対応
# * 自動でcommitおよびpushをするので注意

$my_name = git config --global user.name
$my_buckets = @()
$prompt_current_dir = Get-Location

$scoop_root = "$HOME\scoop"
Get-ChildItem $scoop_root\buckets\* | ForEach-Object {
    Set-Location $_
    $url = git remote get-url --push "origin"
    if ($url -clike "https://github.com/$my_name/*") {
        $my_buckets += $_
    }
}

foreach ($bucket in $my_buckets) {
    Set-Location $bucket
    if (Test-Path .\bin\checkver.ps1) {
        Write-Host "Check Bucket: $_" -ForegroundColor Green
        Get-ChildItem .\*.json | ForEach-Object {
            $json = $_.Name
            .\bin\checkver.ps1 $json -u
            if ($(git diff $json)) {
                Write-Host "  => Update: $json" -ForegroundColor Blue
                git commit -a -m "Update: $json"
            }
        }
        if ($(git diff)) {
            Write-Host "  => Push bucket..."
            git push
        }
    }
}

Set-Location $prompt_current_dir
