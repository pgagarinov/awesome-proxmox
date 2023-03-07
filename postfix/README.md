# Postfix setup on VMs via Ansible playbooks
  
  These Ansible playbook configures the postfix service on VMs.

## Prerequisites
  ### 1. Install `Ansible` on a certain Linux host from which Ansible playbooks are to be run, this host is called for brevity below `Ansible host`

  For `Debian` Linux

  ```
  sudo apt update
  sudo apt install ansible
  ```

  or follow [step 2](https://github.com/Alliedium/awesome-ansible#setting-up-config-machine) of `Setting up config machine` section to install latest Ansible version

  ### 2. Install Ansible postfix role - [Oefenweb/ansible-postfix](https://github.com/Oefenweb/ansible-postfix)

  - Navigate to `./playbooks/config-postfix`

  ```
  ansible-galaxy install -r ./requirements.yml
  ```

  ![install_postfix_role](./images/install_postfix_role.png)

  Check installed role

  ```
  ansible-galaxy list
  ```

  
## **Ansible-vault**
 
  Ansible vault provides a way to encrypt and manage sensitive data such as passwords. We use Ansible vault to store `pve_postfix_sasl_user` and `pve_postfix_sasl_password` variables

  - Navigate to `./playbooks/config-postfix`
  
  ```
  cd ./playbooks/config-postfix
  ```

  - copy `./secrets-file.enc.example` file to `./secrets-file2.enc` and edit last one
  
  ![secrets](./images/secrets-file.png)

  Encrypt `./secrets-file2.enc`  file and set a password by command

  ```
  ansible-vault encrypt secrets-file2.enc
  ```

  ![encrypt file](./images/secrets-file_1.png)

  `./secrets-file2.enc`  file is encrypted

  ![encrypted_file file](./images/encrypted_file.png)

## **Ansible postfix playbook**

  - copy `./inventory` folder to `./my-inventory`

  - In `./my-inventory/hosts.yml` file replace hosts IP addresses to your hosts IP addresses and edit the path to private key to match it on your machine.

 
  **Run ansible playbook**

  Navigate to `./playbooks/config-postfix` and run command

  ```
  ansible-playbook ./site.yaml -i ../../my-inventory/ -e @secrets-file2.enc --ask-vault-pass
  ```
  
  You can edit the file `./playbooks/config-postfix/run.sh` by pasting the above command in place of the existing one and run
  
  ```
  ./run.sh
  ```
  
  ![run_sh](./images/run_sh.png)