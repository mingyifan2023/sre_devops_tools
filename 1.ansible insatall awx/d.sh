
Installation Steps
Step 1: Configure Ansible
First, create a directory for your installation, navigate to it, and set up the ansible.cfg file with the following content:

mkdir Lab-Challenge
cd Lab-Challenge/
vim ansible.cfg

# Configure
[defaults]
inventory = ./inventory



Step 2: Create the Ansible Playbook
Create a playbook file named pre-install.yml and add the following content to it:

---
- name: Installing Ansible AWX
  hosts: localhost
  become: true
  tasks:
    - name: Install several packages
      apt:
        name:
          - npm
          - nodejs
          - git
          - pwgen
          - unzip
          - python3-virtualenv
          - python3-pip
        state: present

    - name: Add Docker GPG apt Key
      apt_key:
        url: "https://download.docker.com/linux/ubuntu/gpg"
        state: present

    - name: Add Docker Repository
      apt_repository:
        repo: "deb https://download.docker.com/linux/ubuntu jammy stable"
        state: present

    - name: Install docker-ce, docker-ce-cli, and docker-compose-plugin package
      apt:
        name:
          - docker-ce
          - docker-ce-cli
          - docker-compose-plugin
        state: present
        update_cache: true

    - name: Ensure docker service is started
      service:
        name: docker
        state: started

    - name: Add student user to the docker group
      user:
        name: student
        groups: docker
        append: yes

    - name: Set permissions for Docker socket
      file:
        path: /var/run/docker.sock
        mode: "0666"
        owner: root
        group: docker

    - name: Install docker-compose via pip3
      pip:
        name: docker-compose
        executable: pip3




---
- name: Installing Ansible AWX on CentOS
  hosts: localhost
  become: true
  tasks:
    - name: Install several packages
      yum:
        name:
          - npm
          - git
          - pwgen
          - unzip
          - python3-virtualenv
          - python3-pip
        state: present

    - name: Add Docker YUM repo
      yum_repository:
        name: docker-ce
        description: Docker CE Stable - $basearch
        baseurl: https://download.docker.com/linux/centos/7/$basearch/stable
        gpgcheck: yes
        gpgkey: https://download.docker.com/linux/centos/gpg
        enabled: yes

    - name: Install docker-ce and docker-compose package
      yum:
        name:
          - docker-ce
          - docker-compose
        state: present

    - name: Ensure docker service is started
      service:
        name: docker
        state: started

    - name: Add student user to the docker group
      user:
        name: student
        groups: docker
        append: yes

    - name: Set permissions for Docker socket
      file:
        path: /var/run/docker.sock
        mode: "0666"
        owner: root
        group: docker





Step 3: Generate a Secret Key
Generate a secret key using the pwgen command. This key will be used during the installation process. Save the key to a file named pwgen.txt:

pwgen -N 1 -s 30 > /home/student/Lab-Challenge/pwgen.txt
cat /home/student/Lab-Challenge/pwgen.txt



Step 4: Run the Playbook
Check the syntax of the playbook to ensure there are no errors:

ansible-playbook --syntax-check pre-install.yml
Run playbook to install the required packages and configure your system:

ansible-playbook -v pre-install.yml



Step 5: Download Ansible AWX
Download the Ansible AWX package using the following command:

wget https://codeload.github.com/ansible/awx/zip/refs/tags/17.1.0 -O awx-17.1.0.zip
unzip awx-17.1.0.zip
Step 6: Configure AWX
Edit the AWX inventory file located at awx-17.1.0/installer/inventory and modify the following section:

# This will create or update a default admin (superuser) account in AWX, if not provided
# then these default values are used
admin_user=<your-admin-user>
admin_password=<your-password>
secret_key=<your-secret-key-from-pwgen.txt>


tep 7: Install Ansible AWX
Navigate to the awx-17.1.0/installer/ directory and run the installation playbook:

cd awx-17.1.0/installer/
ansible-playbook -i inventory install.yml
Step 8: Verify the Installation
Check if the Ansible AWX containers are running:

docker ps
