# Get all the images
$post = 'E:\OneDrive\Documents\GitHub\robsewell\_posts\2017-04-26-powershell-function-validating-a-parameter-depending-on-a-previous-parameter'


$content = Get-Content $post -Raw

$datepart = $post.split('\')[6].split('-')[0..1] -join '/'
$SearchTerm = 'uploads/{0}/' -f $datepart
   # $SearchTerm = 'uploads/2017/03/' # if they are in the wrong place

$regex = ($SearchTerm -replace '/', '\/') + '(.*)' + '\?resize'

$results = ([regex]$regex).Matches($content)

$images = $results.Captures.Foreach{ $_.Groups[1].Value }

$images

<#
$getimages = Get-Content $post | Select-String -Pattern PNG
$Images = $getimages.ForEach{ $_.ToString().Split('/')[-1].Replace(')', '') }
#>
# $images = 'psdayukcover.png'
foreach ($image in $images[0]) {
    $testpath = 'assets\{0}\{1}' -f $SearchTerm, $image
    if (-not (Test-Path $testpath -ErrorAction SilentlyContinue)) {
        $file = 'https://i0.wp.com/sqldbawithabeard.com/wp-content/{0}/{1}' -f $SearchTerm , $Image

        $destpath = 'E:\OneDrive\Documents\GitHub\robsewell\assets\{0}\{1}' -f $SearchTerm , $Image

        Invoke-WebRequest -Uri $file -OutFile $destpath
        git add $destpath
        $message = 'Committing image {0}' -f $image
        git commit -m $message
    }
}
