$Exports = Import-Csv export-all-urls-930916.csv

[xml]$sitemap = Get-Content sitemap.xml
[array]$BlogGenerated = $sitemap.urlset.url.loc

$SqlDbaWithABeard = foreach ($Export in $Exports) {

    # First we create the request.
    $HTTP_Request = [System.Net.WebRequest]::Create($Export.Urls)

    try {
        # We then get a response from the site.
        $HTTP_Response = $HTTP_Request.GetResponse()
        # We then get the HTTP code as an integer.
        $HTTP_Status = [int]$HTTP_Response.StatusCode
    } catch {
        $HTTP_Status = 'Error'
    } finally {
        # Finally, we clean up the http request by closing it.
        If ($HTTP_Response -eq $null) { } 
        Else { $HTTP_Response.Close() }
    }

    if ($HTTP_Status -ne 'Error') {
        $bloguri = $BlogGenerated | Where-Object { $_ -match $Export.URLs.Split('/')[-2] }

        if ($bloguri) {
            $Blog_HTTP_Request = [System.Net.WebRequest]::Create($bloguri)
        }

        try {
            $Blog_HTTP_Response = $Blog_HTTP_Request.GetResponse()
            $Blog_HTTP_Status = [int]$Blog_HTTP_Response.StatusCode
        } catch {
            $Blog_HTTP_Status = 'Error'
        } finally {
            # Finally, we clean up the http request by closing it.
            If ($Blog_HTTP_Response -eq $null) { } 
            Else { $Blog_HTTP_Response.Close() }
        }
    }

    [PSCustomObject]@{
        postid        = $Export.'post id'
        uri           = $Export.Urls
        status        = $HTTP_Status
        title         = $Export.Title
        bloguri       = $bloguri
        bloguristatus = $Blog_HTTP_Status
    }
}

$SqlDbaWithABeard | ForEach-Object {
    $object = $PSItem

    if ($object.status -eq 'Error') {
        $object | Export-Csv errors.csv -Append
    } elseif ($object.bloguristatus -eq 'Error') {
        $object | Export-Csv blogerrors.csv -Append
    } elseif ($object.status -eq '200' -and $object.bloguristatus -eq '200') {
        $Bearduri = $object.uri.replace('https://sqldbawithabeard.com/', '')
        $NewLine = '{0},{1},{2},{3}' -f '301', $Bearduri , $object.bloguri, $x 
        $NewLine| Out-File redirects.csv -Append 
        $x ++
    }

}
