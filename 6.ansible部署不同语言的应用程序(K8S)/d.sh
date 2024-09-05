1. 使用ansible 制作docker镜像，生成pod 
java ,ruby,node等

2024/9/5 23:09:55

使用 Ansible 制作 Docker 镜像并生成 Pod 的过程可以通过以下步骤实现。我们将为 Java、Ruby 和 Node.js 应用程序创建对应的 Docker 镜像，并使用 Kubernetes 生成 Pods。下面是一个示例工作流以及相关的 Ansible Playbook 配置。

步骤概述
创建 Dockerfile：为每个应用程序创建 Dockerfile。
使用 Ansible 构建 Docker 镜像：使用 Ansible 任务构建 Docker 镜像。
部署到 Kubernetes：通过 Ansible 部署生成的镜像到 Kubernetes 中，创建 Pods。
示例文件结构
project/
├── ansible/
│   ├── playbook.yml
│   └── files/
│       ├── Dockerfile.java
│       ├── Dockerfile.ruby
│       └── Dockerfile.node
└── k8s/
    ├── java-deployment.yaml
    ├── ruby-deployment.yaml
    └── node-deployment.yaml
1. 创建 Dockerfile
Dockerfile.java
dockerfile
FROM openjdk:11
COPY app.jar /usr/src/app/app.jar
WORKDIR /usr/src/app
CMD ["java", "-jar", "app.jar"]
Dockerfile.ruby
dockerfile
FROM ruby:2.7
COPY app.rb /usr/src/app/app.rb
WORKDIR /usr/src/app
CMD ["ruby", "app.rb"]
Dockerfile.node
dockerfile
FROM node:14
COPY app.js /usr/src/app/app.js
WORKDIR /usr/src/app
CMD ["node", "app.js"]
2. 编写 Ansible Playbook
playbook.yml
yaml
- hosts: localhost
  tasks:
    - name: Build Docker image for Java application
      docker_image:
        build:
          path: "{{ playbook_dir }}/files"
          dockerfile: Dockerfile.java
        name: java-app
        tag: latest

    - name: Build Docker image for Ruby application
      docker_image:
        build:
          path: "{{ playbook_dir }}/files"
          dockerfile: Dockerfile.ruby
        name: ruby-app
        tag: latest

    - name: Build Docker image for Node.js application
      docker_image:
        build:
          path: "{{ playbook_dir }}/files"
          dockerfile: Dockerfile.node
        name: node-app
        tag: latest

    - name: Push Docker images to registry (optional)
      docker_image:
        name: "{{ item }}"
        tag: latest
        push: yes
      loop:
        - java-app
        - ruby-app
        - node-app
      when: registry_url is defined

    - name: Deploy Java application to Kubernetes
      kubernetes.core.k8s:
        state: present
        definition: "{{ lookup('file', '../k8s/java-deployment.yaml') }}"

    - name: Deploy Ruby application to Kubernetes
      kubernetes.core.k8s:
        state: present
        definition: "{{ lookup('file', '../k8s/ruby-deployment.yaml') }}"

    - name: Deploy Node.js application to Kubernetes
      kubernetes.core.k8s:
        state: present
        definition: "{{ lookup('file', '../k8s/node-deployment.yaml') }}"
3. Kubernetes Deployment 定义
java-deployment.yaml
yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: java-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: java-app
  template:
    metadata:
      labels:
        app: java-app
    spec:
      containers:
      - name: java-app
        image: java-app:latest
        ports:
        - containerPort: 8080
ruby-deployment.yaml
yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ruby-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ruby-app
  template:
    metadata:
      labels:
        app: ruby-app
    spec:
      containers:
      - name: ruby-app
        image: ruby-app:latest
        ports:
        - containerPort: 4567
node-deployment.yaml
yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: node-app
  template:
    metadata:
      labels:
        app: node-app
    spec:
      containers:
      - name: node-app
        image: node-app:latest
        ports



2024/9/5 23:13:47

也可以用来处理go，python，PHP吧

2024/9/5 23:14:02

是的，Ansible 也可以用于处理 Go、Python 和 PHP 等其他编程语言的 Docker 镜像构建和 Kubernetes 部署。下面是为这三种语言创建相应的 Dockerfile、Ansible Playbook 和 Kubernetes Deployment 配置的示例。

示例文件结构
project/
├── ansible/
│   ├── playbook.yml
│   └── files/
│       ├── Dockerfile.go
│       ├── Dockerfile.python
│       └── Dockerfile.php
└── k8s/
    ├── go-deployment.yaml
    ├── python-deployment.yaml
    └── php-deployment.yaml
1. 创建 Dockerfile
Dockerfile.go
dockerfile
FROM golang:1.17 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp .

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/myapp .
CMD ["./myapp"]
Dockerfile.python
dockerfile
FROM python:3.9
WORKDIR /usr/src/app
COPY app.py .
CMD ["python", "./app.py"]
Dockerfile.php
dockerfile
FROM php:7.4-cli
COPY app.php /usr/src/app/app.php
WORKDIR /usr/src/app
CMD ["php", "app.php"]
2. 编写 Ansible Playbook
playbook.yml
yaml
- hosts: localhost
  tasks:
    - name: Build Docker image for Go application
      docker_image:
        build:
          path: "{{ playbook_dir }}/files"
          dockerfile: Dockerfile.go
        name: go-app
        tag: latest

    - name: Build Docker image for Python application
      docker_image:
        build:
          path: "{{ playbook_dir }}/files"
          dockerfile: Dockerfile.python
        name: python-app
        tag: latest

    - name: Build Docker image for PHP application
      docker_image:
        build:
          path: "{{ playbook_dir }}/files"
          dockerfile: Dockerfile.php
        name: php-app
        tag: latest

    - name: Push Docker images to registry (optional)
      docker_image:
        name: "{{ item }}"
        tag: latest
        push: yes
      loop:
        - go-app
        - python-app
        - php-app
      when: registry_url is defined

    - name: Deploy Go application to Kubernetes
      kubernetes.core.k8s:
        state: present
        definition: "{{ lookup('file', '../k8s/go-deployment.yaml') }}"

    - name: Deploy Python application to Kubernetes
      kubernetes.core.k8s:
        state: present
        definition: "{{ lookup('file', '../k8s/python-deployment.yaml') }}"

    - name: Deploy PHP application to Kubernetes
      kubernetes.core.k8s:
        state: present
        definition: "{{ lookup('file', '../k8s/php-deployment.yaml') }}"
3. Kubernetes Deployment 定义
go-deployment.yaml
yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: go-app
  template:
    metadata:
      labels:
        app: go-app
    spec:
      containers:
      - name: go-app
        image: go-app:latest
        ports:
        - containerPort: 8080
python-deployment.yaml
yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: python-app
  template:
    metadata:
      labels:
        app: python-app
    spec:
      containers:
      - name: python-app
        image: python-app:latest
        ports:
        - containerPort: 5000
php-deployment.yaml
yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php-app
  template:
    metadata:
      labels:
        app: php-app
    spec:
      containers:
      - name: php-app
        image: php-app:latest
        ports:
        - containerPort: 80
总结
通过以上配置，您可以使用 Ansible 来构建 Go、Python 和 PHP 应用程序的 Docker 镜像，并将其部署到 Kubernetes 中。这使得多种编程语言的开发与运维过程变得一致且自动化，提升了
