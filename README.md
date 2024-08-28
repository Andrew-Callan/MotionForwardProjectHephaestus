Certainly! Here’s a detailed README file for the “Project Hephaestus” Terraform and Ansible codebase:

---

# Project Hephaestus

**Project Hephaestus** is a robust infrastructure provisioning solution that leverages Terraform and Ansible to create a dynamic cloud networking environment. Designed specifically for red teaming / blue teaming exercises, it sets up machines and networks that simulate increasing levels of difficulty as attackers progress, providing a comprehensive training ground for cybersecurity professionals.

## Table of Contents

1. [Project Title and Description](#project-title-and-description)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Configuration](#configuration)
5. [License](#license)
6. [Contact Information](#contact-information)
7. [Acknowledgements](#acknowledgements)

## Project Title and Description

**Project Hephaestus** is an automated infrastructure provisioning tool built with Terraform and Ansible. It creates a secure cloud environment with a series of virtual machines that are progressively more challenging to compromise. This setup is ideal for red/blue team exercises, penetration testing, and security training.

### Key Features:
- **Automated Provisioning**: Deploy a complete cloud infrastructure with a single command.
- **Progressive Difficulty**: Machines and networks designed with increasing complexity.
- **Red Team Training**: Realistic environment for security assessments and training.
- **Blue Team Training**: Attacks monitored through cyber tools allowing defensive training

## Installation

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.9.5 used for dev)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Python3] (https://www.python.org/downloads/) (Version 3.9.6 used for dev)
- Access to a cloud provider (e.g., AWS, Azure, GCP) and proper credentials set up.

### Clone the Repository

```bash
git clone https://github.com/Andrew-Callan/MotionForwardProjectHephaestus.git
cd MotionForwardProjectHephaestus
```

### Terraform Setup

1. **Initialize Terraform**: 

    ```bash
    terraform init
    ```

2. **Plan the Infrastructure**:

    ```bash
    terraform plan
    ```

3. **Apply the Configuration**:

    ```bash
    terraform apply
    ```

### Variable Configuration

### 1. Extract Terraform Output

First, ensure that your Terraform configuration outputs the necessary values. For example, you might have the following Terraform configuration:

```hcl
# terraform/outputs.tf
output "public_ip" {
  value = aws_instance.example.public_ip
}

output "private_ip" {
  value = aws_instance.example.private_ip
}
```

To extract these outputs, you can use the `terraform output` command:

```bash
terraform output -json > terraform_outputs.json
```

This command will create a `terraform_outputs.json` file containing all the outputs in JSON format.

### 2. Generate Ansible Variables File
```bash
python generate_ansible_vars.py
```

This will generate an `ansible_vars.yml` file with the Terraform outputs in a format that Ansible can use.

### Example YAML Output

The generated `ansible_vars.yml` might look like this:

```yaml
private_ip: "10.0.0.1"
public_ip: "54.123.45.67"
```

### Using the Variables in Ansible

You can now use this file as an inventory or variables file in your Ansible playbooks. For example, you can include it in your `ansible-playbook` command:

```bash
ansible-playbook -i inventory/hosts playbook.yml --extra-vars @ansible_vars.yml
```

### Ansible Setup

1. **Install Ansible Roles**:

    ```bash
    ansible-galaxy install -r requirements.yml
    ```

2. **Run Ansible Playbooks**:

    ```bash
    ansible-playbook -i inventory/hosts playbook.yml
    ```

## Usage

### Terraform Configuration

- **`main.tf`**: Contains the core infrastructure configuration.
- **`variables.tf`**: Defines variables for customization.
- **`outputs.tf`**: Outputs values such as public IPs for easy access.

### Ansible Configuration

- **`playbook.yml`**: Main Ansible playbook for configuring the machines.
- **`roles/`**: Directory containing roles for different configurations.
- **`inventory/hosts`**: Inventory file listing the target machines.

### Example Workflow

1. Provision the infrastructure using Terraform:

    ```bash
    terraform apply
    ```

2. Configure the machines using Ansible:

    ```bash
    ansible-playbook -i inventory/hosts playbook.yml
    ```

## Configuration

Customize the following files to adjust the environment to your needs:

- **`terraform.tfvars`**: Set your cloud provider credentials and other variables.
- **`ansible/roles/`**: Modify role configurations for different machine setups.


## License

This project is licensed under the GNU License - see the [LICENSE](LICENSE) file for details.

## Contact Information

For any questions or support, please reach out to:

- **Email**: andrew@mftechinc.com
- **GitHub Issues**: [Project Hephaestus Issues](https://github.com/yourusername/project-hephaestus/issues)

## Acknowledgements

- **Terraform**: Infrastructure as Code tool that makes provisioning easy.
- **Ansible**: Configuration management tool used for setting up and maintaining the environment.
- **Cloud Providers**: AWS for providing the cloud infrastructure.

---