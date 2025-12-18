# Azure VM Terraform Configuration

This Terraform configuration (`main.tf`) deploys a basic Azure infrastructure for a Linux virtual machine with public access.

## What It Does

- Creates an Azure Resource Group in the `polandcentral` region.
- Sets up a Virtual Network (VNet) with a subnet.
- Deploys a Network Security Group (NSG) allowing SSH (port 22) from anywhere.
- Allocates a static Public IP address.
- Creates a Network Interface associated with the subnet and public IP.
- Provisions an Ubuntu 24.04 LTS Linux Virtual Machine with password authentication enabled.

## Prerequisites

- Azure CLI installed and authenticated (`az login`).
- Terraform installed (version ~1.0+).
- Azure subscription with permissions to create resources.
- `secrets.tfvars` file with `admin_password` defined (e.g., `admin_password = "your-password"`).

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Plan the deployment:
   ```bash
   terraform plan -var-file=secrets.tfvars
   ```

3. Apply the configuration:
   ```bash
   terraform apply -var-file=secrets.tfvars
   ```

4. Connect to the VM:
   - Use the output `public_ip` to SSH: `ssh azureuser@<public_ip>`
   - Password: from `secrets.tfvars`

5. Destroy resources when done:
   ```bash
   terraform destroy -var-file=secrets.tfvars
   ```

## Resources Created

- `azurerm_resource_group`: Resource group for all resources.
- `azurerm_virtual_network` & `azurerm_subnet`: Networking setup.
- `azurerm_network_security_group` & association: Security rules for SSH.
- `azurerm_public_ip`: Static public IP for VM access.
- `azurerm_network_interface`: NIC for the VM.
- `azurerm_linux_virtual_machine`: Ubuntu VM with admin access.

## Variables

- `name`: Base name for resources (default: "ca-devops-01").
- `VM_name`: VM instance name (default: "devops-vm-01").
- `admin_password`: VM admin password (sensitive, from `secrets.tfvars`).

## Outputs

- `public_ip`: The public IP address of the VM for SSH access.

## Notes

- The NSG allows SSH from any IP (`*`). For production, restrict to specific IPs.
- VM size is `Standard_B2ats_v2`; adjust in `main.tf` if needed.
- Ensure `secrets.tfvars` is not committed to version control. 

