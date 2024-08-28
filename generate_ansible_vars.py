#!/usr/bin/env python3

import json
import yaml

# Load Terraform outputs from the JSON file
with open('terraform_outputs.json', 'r') as f:
    terraform_outputs = json.load(f)

# Transform the JSON data into a format suitable for Ansible variables
ansible_vars = {}
for key, value in terraform_outputs.items():
    ansible_vars[key] = value['value']

# Save the variables to an Ansible-compatible YAML file
with open('ansible_vars.yml', 'w') as f:
    yaml.dump(ansible_vars, f, default_flow_style=False)

print("Ansible variables file created: ansible_vars.yml")