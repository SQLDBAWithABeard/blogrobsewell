$posts = Get-ChildItem content/post

foreach($post in $posts){
    $Content = Get-Content $post.FullName
    $date = $post.Name[0..9] -join ''
    #$Content = $Content -replace "header:",""
    $Content = $Content -replace " /assets\/uploads", " assets/uploads"
Set-Content $post.fULLName $Content
git add $post.FullName
}