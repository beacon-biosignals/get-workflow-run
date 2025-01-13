#!/usr/bin/env bash

# Determine the latest workflow run.
#
# Environment variable inputs:
# - `workflow_file`: The workflow file name used with the workflow run.
# - `commit_sha`: The Git commit SHA associated with the workflow run.
# - `status`: Return workflow runs with this status (e.g. "success", "completed"). Defaults
#   to "any" for any status.

set -eo pipefail
set -x

status="${status:-any}"

workflow_id="$(gh api -X GET --paginate "/repos/{owner}/{repo}/actions/workflows" --jq ".workflows[] | select(.path == \".github/workflows/${workflow_file:?}\").id")"
echo "workflow_id=${workflow_id:?}" | tee -a "$GITHUB_OUTPUT"

flags=()
valid_statuses=(completed action_required cancelled failure neutral skipped stale success timed_out in_progress queued requested waiting pending)
if printf '%s\n' "${valid_statuses[@]}" | grep -qw "${status}"; then
    flags+=(-f status="${status:?}")
elif [[ "${status}" != "any" ]]; then
    echo "Invalid status \"$status\". Valid status input include: $(printf '"%s", ' "${valid_statuses[@]}")or \"any\"." >&2
    exit 1
fi

# Determine the latest workflow run associated with the `commit_sha`
# https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-repository
run="$(gh api -X GET --paginate "/repos/{owner}/{repo}/actions/runs" -f head_sha="${commit_sha:?}" "${flags[@]}" --jq ".workflow_runs | map(select(.workflow_id == ${workflow_id:?})) | sort_by(.run_number, .run_attempt) | .[-1]")"
run_id="$(jq -er '.id' <<<"${run}")"
run_attempt="$(jq -er '.run_attempt' <<<"${run}")"
echo "run-id=${run_id:?}" | tee -a "$GITHUB_OUTPUT"
echo "run-attempt=${run_attempt:?}" | tee -a "$GITHUB_OUTPUT"
