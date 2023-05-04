#!/bin/bash

# Create an array to store the rules
rules_array=()

UNDER_RULES="false"

# Iterate over each rule and add it to the array
while read -r line; do
  # Check if the line starts with "rules:"
  if [[ $line == rules:* ]]; then
    # Extract the rules section from the line
    UNDER_RULES=true
    continue
  elif [[ $line == -* && $UNDER_RULES == true ]]; then
    # Remove the leading "-" and any leading/trailing whitespace
    rule_line=$(echo "$line" | sed 's/^- *//')
    rules_array[${#rules_array[@]}]="$rule_line"
  elif [[ $line != -* && $UNDER_RULES == true ]]; then
    rules_array[-1]="${rules_array[-1]}
$line"
  fi
done < alerts.yaml


# Output a markdown table
echo "| Alertname | Summary | Priority | On-call |"
echo "| --- | --- | --- | --- |"

# Iterate the loop to read and print each array element
for rule in "${rules_array[@]}"
do
  alertname=""
  summary=""
  mc_tool_rule_priority=""
  mc_tool_rule_on_call_duty=""
  runbook_url=""

  while IFS= read -r line ; do
    if [[ $line == alert:* ]]; then
      alertname=$(echo "$line" | sed 's/.*: //' | tr -d '"')
    elif [[ $line == summary:* ]]; then
      summary=$(echo "$line" | sed 's/.*: //' | tr -d '"')
    elif [[ $line == mc_tool_rule_priority:* ]]; then
      mc_tool_rule_priority=$(echo "$line" | sed 's/.*: //' | tr -d '"')
    elif [[ $line == mc_tool_rule_on_call_duty:* ]]; then
      mc_tool_rule_on_call_duty=$(echo "$line" | sed 's/.*: //' | tr -d '"')
    elif [[ $line == runbook_url:* ]]; then
      runbook_url=$(echo "$line" | sed 's/.*: //' | tr -d '"')
    fi

  done <<< "$rule"

  echo "| [$alertname]($runbook_url) | $summary | ${mc_tool_rule_priority} | $mc_tool_rule_on_call_duty |"
done


