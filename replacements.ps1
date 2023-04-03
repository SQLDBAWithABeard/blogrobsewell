$posts = Get-ChildItem content/post/2023-03-19*
$posts = Get-ChildItem content/post/*
foreach($post in $posts){
    $Content = Get-Content $post.FullName
    $date = $post.Name[0..9] -join ''

    if ($content -match 'date:'){
        $message = "Date already exists in {0}" -f $post.Name
        Write-PSFMessage $message -Level Verbose
    } else {
        $message = "Date does not exist in {0}" -f $post.Name
        Write-PSFMessage $message -Level Output
        # add date to header
        $datereplace = 'date: "{0}"
categories:' -f $date
        $Content = $Content -replace 'categories:',$datereplace
        Set-Content $post.FullName $Content

    }
    if ($content -match 'teaser:'){
        $message = "teaser: already exists in {0}" -f $post.Name
        Write-PSFMessage $message -Level Output

        $Content = $Content -replace '  teaser:','image:'
        $Content = $Content -replace 'header:',''
        Set-Content $post.FullName $Content
    } else {
        $message = "teaser: does not exist in {0}" -f $post.Name
        Write-PSFMessage $message -Level verbose
    }
    #$Content = $Content -replace "header:",""
    #$Content = $Content -replace " /assets\/uploads", " assets/uploads"
    #Set-Content $post.fULLName $Content
    git add $post.FullName
}