#!/bin/bash

set -euo pipefail

get_api_id() {
    for api_id in $(aws apigateway get-rest-apis | jq -r .items[].id); do
        for resource_id in $(aws apigateway get-resources --rest-api-id $api_id | jq -r .items[].id); do
            aws apigateway get-integration --rest-api-id $api_id --resource-id $resource_id --http-method GET >/dev/null 2>&1 || continue
            uri=$(aws apigateway get-integration --rest-api-id $api_id --resource-id $resource_id --http-method GET | jq -r .uri)
            if [[ $uri == *"$lambda_arn"* ]]; then
                echo $api_id
                return
            fi
        done
    done
}

if [[ $# != 1 ]]; then
    echo "Usage: $(basename $0) stage"
    exit 1
fi

export stage=$1
stage_ucase=$(echo $stage | awk '{print toupper($0)}')
deployed_json="$(dirname $0)/.chalice/deployed.json"
config_json="$(dirname $0)/.chalice/config.json"
policy_json="$(dirname $0)/.chalice/policy.json"
stage_policy_json="$(dirname $0)/.chalice/policy-${stage}.json"
export app_name=$(cat "$config_json" | jq -r .app_name)
iam_policy_template="$(dirname $0)/../../iam/policy-templates/${app_name}-lambda.json"
export lambda_name="${app_name}-${stage}"
export account_id=$(aws sts get-caller-identity | jq -r .Account)

export lambda_arn=$(aws lambda list-functions | jq -r '.Functions[] | select(.FunctionName==env.lambda_name) | .FunctionArn')
if [[ -z $lambda_arn ]]; then
    echo "Lambda function $lambda_name not found, resetting Chalice config"
    rm -f "$deployed_json"
else
    export api_id=$(get_api_id)
    jq -n ".$stage.api_handler_name = env.lambda_name | \
           .$stage.api_handler_arn = env.lambda_arn | \
           .$stage.rest_api_id = env.api_id | \
           .$stage.region = env.AWS_DEFAULT_REGION | \
           .$stage.api_gateway_stage = env.stage | \
           .$stage.backend = \"api\" | \
           .$stage.chalice_version = \"1.0.1\" | \
           .$stage.lambda_functions = {}" > "$deployed_json"
fi

for var in $EXPORT_ENV_VARS_TO_LAMBDA; do
    cat "$config_json" | jq .stages.$stage.environment_variables.$var=env.$var | sponge "$config_json"
done

if [[ ${CI:-} == true ]]; then
    account_id=$(aws sts get-caller-identity | jq -r .Account)
    export iam_role_arn="arn:aws:iam::${account_id}:role/hca-logging-test-${stage}"
    cat "$config_json" | jq .manage_iam_role=false | jq .iam_role_arn=env.iam_role_arn | sponge "$config_json"
fi

cat "$iam_policy_template" | envsubst '$TEST_S3_BUCKET $account_id $stage' > "$policy_json"
cp "$policy_json" "$stage_policy_json"
