# Get Workflow Run

Determine the latest workflow run for a given workflow file and commit SHA.

## Example

```yaml
---
jobs:
  test:
    permissions: {}
    runs-on: ubuntu-latest
    steps:
      - uses: beacon-biosignals/download-run-attempt-artifact@v1
        if: ${{ github.run-attempt > 1 }}
        with:
          run-id: ${{ github.run_id }}
          run-attempt: ${{ github.run_attempt }}
          allow-fallback: true
      - name: Show downloaded run-attempt file
        if: ${{ github.run_attempt > 1 }}
        run: |
          cat run-attempt
      - name: Create run-attempt file
        run: |
          echo "${{ github.run_attempt }}" >run-attempt
      - uses: actions/upload-artifact
        with:
          name: my-artifact
          path: run-attempt
```

## Inputs

| Name                 | Description | Required | Example |
|:---------------------|:------------|:---------|:--------|
| `workflow-file`      | The GitHub Actions workflow file name to target. | Yes | `ci.yaml` |
| `commit-sha`         | The Git commit SHA used in the workflow run.  | Yes | `23202e68ee664c345e985910770b7b9b873acfac` |
| `status`             | Filter by the workflow run status. Possible status values can be [anything allowed by this API call](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-repository) and `any`. Defaults to `any`. | No | `any`, `completed`, `skipped` |
| `repository`         | The repository containing the workflow run. | No | `${{ github.token }}` |
| `token`              | The GitHub token used to authenticate with the GitHub API. Need when attempting to access other repositories. | No | `${{ github.token }}` |

## Outputs

| Name          | Description | Example |
|:--------------|:------------|:--------|
| `workflow-id` | The GitHub API ID of the targeted workflow. | `96660010` |
| `run-id`      | The workflow run ID as used by the GitHub API. | `11958836222` |
| `run-attempt` | The workflow run attempt. | `1` |

## Permissions

The following [job permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs) are required to run this action:

```yaml
permissions:
  actions: read
```
