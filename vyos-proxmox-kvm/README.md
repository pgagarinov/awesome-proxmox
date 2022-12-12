# Create Vyos vms on ***<font color="green">Proxmox</font>*** node via Ansible playbooks
  
  These ansible playbooks create `vyos` vms on Proxmox node with certain configured network settings. Also using playbooks you can remove, start or stop them.

## Prerequisites
  ### 1. Install Ansible on `k3s-config` host. We will run ansible playbooks on it.
  ```
  sudo apt update
  sudo apt install ansible
  ```

  ### 2. Install the necessary packages on each node from the ***<font color="green">Proxmox</font>*** cluster
  
  ```
  apt install -y python3-pip python-dev build-essential
  pip install virtualenv
  pip install proxmoxer
  ```

  ### 3. Create `vyos` cloud-init image, using [vyos/vyos-vm-images](https://github.com/vyos/vyos-vm-images/tree/bafe06bbbf4d67a98c78c01f1cef379eb6d13fa1) ansible playbook  and copy it to `~/cloud-init-images` folder of `k3s-config` host.

## Clone [`awesome-proxmox`](https://github.com/Alliedium/awesome-proxmox) project.
  ### 1. Clone `awesome-proxmox` project to your local host
  
  ```
  git clone https://github.com/Alliedium/awesome-proxmox.git
  ```
  ### 2. Go to `vyos-proxmox-kvm` folder
  ### 3. Copy `./inventory/single_vyos` to `./inventory/my-cluster` folder.
  ### 4. Change the variables in the files `./inventory/single_vyos/hosts.yml` and `./inventory/single_vyos/group_vars/all.yml` as you need
  ### 5. Edit files from `./playbooks/roles/prepare_vyos_cloud_init_data_for_vms/templates` folder to  change [current vyos configuration](https://docs.vyos.io/en/latest/automation/cloud-init.html) as you need.
  ### 6. Here an example of data `./inventory/hosts.yml` file for creating 2 `vyos` vms

  ![image](./images/hosts3.jpg)

  Object `vms` includes data for 2 vms.  

## Create and start vms on ***<font color="green">Proxmox</font>*** node.
 
  ### Run ansible playbooks

  ```
  ansible-playbook -i ./inventory ./playbooks/batch-create-start.yml
  ```
## Stop and destroy vms on ***<font color="green">Proxmox</font>*** node.
   ### 1. Run ansible playbooks

  ```
  ansible-playbook -i ./inventory ./playbooks/batch-stop-destroy.yml
  ```

## Other action

   ### create-vms

   ```
   ansible-playbook -i ./inventory ./playbooks/create-vms.yml
   ```

   ### start-vms

   ```
   ansible-playbook -i ./inventory ./playbooks/start-vms.yml
   ```

   ### stop-vms

   ```
   ansible-playbook -i ./inventory ./playbooks/stop-vms.yml
   ```

   ###  remove-vms

   ```
   ansible-playbook -i ./inventory ./playbooks/destroy-vms.yml
   ```