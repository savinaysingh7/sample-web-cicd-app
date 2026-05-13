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
