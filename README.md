# Sample Web CI/CD App

This repository contains a sample web application and a Jenkins CI/CD pipeline configuration.

## Jenkins Setup Checklist

### 1) Initiate Git webhook for Jenkins git-job repository

In your Git repository hosting provider (GitHub/GitLab/Bitbucket), add this webhook:

- Payload URL: `http://<your-jenkins-url>/github-webhook/`
- Content type: `application/json`
- Secret: optional but recommended
- Event: `Just the push event`

In Jenkins job `Git-Job`:

- Source Code Management: set the repository URL for this project.
- Build Triggers: enable `GitHub hook trigger for GITScm polling`.

### 2) Trigger jobs in required sequence

This pipeline is configured to run in the order below:

1. `Git-Job`
2. `Build-Website`
3. `Deploy-Website`

If you use 3 separate freestyle/pipeline jobs instead of one Jenkinsfile pipeline:

- In `Git-Job`, configure a post-build action to trigger `Build-Website`.
- In `Build-Website`, configure a post-build action to trigger `Deploy-Website`.

### 3) Install plugin for pipeline view

Install Jenkins plugin:

- `Pipeline: Stage View`

From Jenkins UI:

1. `Manage Jenkins` -> `Plugins`
2. `Available plugins`
3. Search `Pipeline: Stage View`
4. Install and restart Jenkins if prompted

### 4) Make a change and commit to verify

This repo includes a visible web change in `app.js` to validate deployment after push.

Run locally in repo:

```bash
git add app.js Jenkinsfile README.md
git commit -m "Configure Jenkins webhook flow and update website content"
git push origin <your-branch>
```

After push, webhook should trigger Jenkins and execute:

`Git-Job -> Build-Website -> Deploy-Website`

## One-command bootstrap (Webhook + Plugin + Trigger)

If you have Jenkins URL and API token, run this PowerShell flow from the repo root:

```powershell
$env:JENKINS_URL = "https://<your-jenkins-url>"
$env:JENKINS_USER = "<jenkins-username>"
$env:JENKINS_API_TOKEN = "<jenkins-api-token>"
$env:JENKINS_WEBHOOK_SECRET = "<optional-secret>"

./scripts/jenkins-bootstrap.ps1 -GithubOwner "savinaysingh7" -GithubRepo "sample-web-cicd-app" -JenkinsJob "Git-Job"
```

What this script does:

1. Creates a GitHub push webhook to `JENKINS_URL/github-webhook/` (if missing)
2. Installs Jenkins plugin `Pipeline: Stage View` (`pipeline-stage-view`)
3. Triggers `Git-Job` to start your chain

## Complete Local Jenkins Setup (Automated)

A local Jenkins environment has been configured with the full pipeline chain:

### Running Jenkins Locally

Jenkins is running in Docker at `http://localhost:8080`:

**Access Jenkins:**
- URL: `http://localhost:8080`
- No authentication required (lab setup)

**Pipeline View Plugin:** Installed
- Navigate to `Git-Job` > `Stage View` to visualize the pipeline stages

### Job Chain Status

The following jobs are configured and chained:

1. **Git-Job** (Pipeline job via Jenkinsfile)
   - Trigger: GitHub push via webhook
   - Post-build: Triggers `Build-Website` on SUCCESS
   
2. **Build-Website** (Freestyle job)
   - Verify source code includes latest website change
   - Post-build: Triggers `Deploy-Website` on SUCCESS
   
3. **Deploy-Website** (Freestyle job)
   - Copies app.js to `/var/jenkins_home/deployments/sample-web-cicd-app/`
   - Confirms deployment of changes

### Testing the Pipeline

**Manual trigger:**

```bash
# Access Jenkins CLI (inside container)
docker exec jenkins-local curl -X POST http://localhost:8080/job/Git-Job/build
```

**Via Git push (requires smee relay):**

```bash
# Make a change and push
git add .
git commit -m "Test pipeline trigger"
git push origin main
# Jenkins will automatically trigger Git-Job
```

### View Pipeline Results

1. Open Jenkins: `http://localhost:8080`
2. Click `Git-Job`
3. View recent builds
4. Click a build number to see full pipeline execution
5. Navigate to `Stage View` tab to see Git-Job > Build-Website > Deploy-Website flow

### Verify Deployment

```bash
# Check deployed artifact
docker exec jenkins-local ls -lh /var/jenkins_home/deployments/sample-web-cicd-app/app.js
docker exec jenkins-local cat /var/jenkins_home/deployments/sample-web-cicd-app/app.js | grep "Webhook test"
```
