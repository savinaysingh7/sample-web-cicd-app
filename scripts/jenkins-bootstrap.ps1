param(
    [string]$GithubOwner = "savinaysingh7",
    [string]$GithubRepo = "sample-web-cicd-app",
    [string]$JenkinsJob = "Git-Job"
)

$ErrorActionPreference = "Stop"

function Require-Env([string]$name) {
    $value = [Environment]::GetEnvironmentVariable($name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Missing required environment variable: $name"
    }
    return $value
}

function Get-JenkinsCrumb([string]$baseUrl, [pscredential]$cred) {
    $crumbUrl = "$baseUrl/crumbIssuer/api/json"
    try {
        $crumb = Invoke-RestMethod -Uri $crumbUrl -Credential $cred -Method Get
        return $crumb
    }
    catch {
        throw "Failed to obtain Jenkins crumb from $crumbUrl. $($_.Exception.Message)"
    }
}

function Ensure-GitHubWebhook([string]$owner, [string]$repo, [string]$jenkinsUrl, [string]$secret) {
    $hookUrl = "$jenkinsUrl/github-webhook/"
    $existingHooks = gh api "repos/$owner/$repo/hooks" | ConvertFrom-Json
    $alreadyExists = $existingHooks | Where-Object { $_.config.url -eq $hookUrl }

    if ($alreadyExists) {
        Write-Host "GitHub webhook already exists: $hookUrl"
        return
    }

    if ([string]::IsNullOrWhiteSpace($secret)) {
        gh api "repos/$owner/$repo/hooks" --method POST `
            -f name='web' `
            -f active=true `
            -f events[]='push' `
            -f config.url="$hookUrl" `
            -f config.content_type='json' `
            -f config.insecure_ssl='0' | Out-Null
    }
    else {
        gh api "repos/$owner/$repo/hooks" --method POST `
            -f name='web' `
            -f active=true `
            -f events[]='push' `
            -f config.url="$hookUrl" `
            -f config.content_type='json' `
            -f config.secret="$secret" `
            -f config.insecure_ssl='0' | Out-Null
    }

    Write-Host "Created GitHub webhook: $hookUrl"
}

function Install-StageViewPlugin([string]$baseUrl, [pscredential]$cred, [hashtable]$crumbHeader) {
    $pluginApi = "$baseUrl/pluginManager/installNecessaryPlugins"
    $xml = '<jenkins><install plugin="pipeline-stage-view@latest" /></jenkins>'

    Invoke-WebRequest -Uri $pluginApi -Credential $cred -Method Post -Headers $crumbHeader -Body $xml -ContentType 'text/xml' | Out-Null
    Write-Host "Requested Jenkins plugin install: pipeline-stage-view"
}

function Trigger-JenkinsJob([string]$baseUrl, [string]$jobName, [pscredential]$cred, [hashtable]$crumbHeader) {
    $encoded = [uri]::EscapeDataString($jobName)
    $jobUrl = "$baseUrl/job/$encoded/build"
    Invoke-WebRequest -Uri $jobUrl -Credential $cred -Method Post -Headers $crumbHeader | Out-Null
    Write-Host "Triggered Jenkins job: $jobName"
}

$jenkinsUrl = Require-Env "JENKINS_URL"
$jenkinsUser = Require-Env "JENKINS_USER"
$jenkinsToken = Require-Env "JENKINS_API_TOKEN"
$webhookSecret = [Environment]::GetEnvironmentVariable("JENKINS_WEBHOOK_SECRET")

if ($jenkinsUrl.EndsWith("/")) {
    $jenkinsUrl = $jenkinsUrl.TrimEnd("/")
}

Write-Host "Validating GitHub CLI authentication..."
gh auth status | Out-Null

$secureToken = ConvertTo-SecureString $jenkinsToken -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($jenkinsUser, $secureToken)

Write-Host "Ensuring webhook exists..."
Ensure-GitHubWebhook -owner $GithubOwner -repo $GithubRepo -jenkinsUrl $jenkinsUrl -secret $webhookSecret

Write-Host "Fetching Jenkins CSRF crumb..."
$crumb = Get-JenkinsCrumb -baseUrl $jenkinsUrl -cred $cred
$crumbHeader = @{}
$crumbHeader[$crumb.crumbRequestField] = $crumb.crumb

Write-Host "Installing Pipeline Stage View plugin..."
Install-StageViewPlugin -baseUrl $jenkinsUrl -cred $cred -crumbHeader $crumbHeader

Write-Host "Triggering first job in chain..."
Trigger-JenkinsJob -baseUrl $jenkinsUrl -jobName $JenkinsJob -cred $cred -crumbHeader $crumbHeader

Write-Host "Bootstrap complete. Expected flow: Git-Job > Build-Website > Deploy-Website"
