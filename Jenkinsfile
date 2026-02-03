
def getRepoName() {
    return scm.getUserRemoteConfigs()[0].getUrl().tokenize('/')[4].split("\\.")[0]
}
pipeline {
  triggers {
    pollSCM('') // Enabling being build on Push
  }
    agent any
    options { disableConcurrentBuilds() }
    stages {
        stage('List workspace') {
            steps {
                sh '''#!/bin/bash
                    ls -la ${workspace}
                    pwd
                    aws --version
                    cat read.txt
                    cat read1.txt
                    cp -r read1.txt read.txt
                    cat read.txt
                    '''
            }
        }
        stage('List workspace test') {
            steps {
                sh '''#!/bin/bash
                    cat read.txt
                    '''
            }
        }
        /*
        stage('Cleanup Workspace') {
            steps {
                // Clean before build
                cleanWs()
                // We need to explicitly checkout from SCM here
                checkout scm
                echo "Building ${env.JOB_NAME}..."
            }
        } */
        stage('AWS IAM User Assume Role - dev Testing') {
            steps {
                withCredentials([usernamePassword(credentialsId: "aws_user", usernameVariable: "AWS_ACCESS_KEY_ID", passwordVariable: "AWS_SECRET_ACCESS_KEY")]) {
                    script {
                        dev_sts_json = sh(
                            script: "aws sts assume-role --role-arn 'arn:aws:iam::1234567890:role/admin-assume-role' --role-session-name test-jenkins",
                            returnStdout: true
                        )
                        dev_sts_json = readJSON(text: dev_sts_json)
                    }
                }
            }
        }
/*        stage('Terraform Download') {
            steps {
                sh '''#!/bin/bash
                    wget https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip
                    unzip terraform_1.0.11_linux_amd64.zip terraform
                    ls -la
                    chmod +x ./terraform
                    ./terraform -version
                    '''
            }
        }
        stage('Terraform Format') {
            steps {
                sh '''#!/bin/bash
                    ./terraform fmt
                    git status
                    git checkout $BRANCH_NAME
                    git add *.tf
                    git commit -am "terraform fmt"
                    git status
                    git push origin $BRANCH_NAME
                    '''
            }
        }
        stage('Terraform Init') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'aws_user', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]){
                        sh '''#!/bin/bash
                            ./terraform init
                            ls
                            '''
                }
            }
        }
        stage('change') {
            when {
                anyOf {
                    changeset "variables.tf"
                    changeset "provider*"
                }
            }
            steps {
                sh "ls -lrt"
            }
        }
        stage('Clone Dockerfile Repo') {
            steps {
                sh '''#!/bin/bash
                    mkdir module
                '''
                dir("./module/") {
                    script {
                        git branch: 'master',
                            credentialsId: 'github',
                            url: 'https://github.com/jam1734/aws-cf-templates.git'
                    }
                    sh '''#!/bin/bash
                        echo env.BITBUCKET_REPOSITORY
                        echo ${getRepoName}
                    '''
                }
            }
        }
/*
        stage('Terraform destroy1') {
            when {branch 'master'}
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'aws_user', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID'),
                    file(credentialsId: "secrets_tfvars", variable: 'secrets_vars')
                    ]) {
                        sh '''#!/bin/bash
                            ./terraform destroy -auto-approve -var-file="./tfvars/dev.tfvars" -var-file="${secrets_vars}"
                            '''
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'aws_user', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID'),
                    file(credentialsId: "secrets_tfvars", variable: 'secrets_vars')
                    ]) {
                        sh '''#!/bin/bash
                            ./terraform plan -var-file="./tfvars/dev.tfvars" -var-file="${secrets_vars}"
                            '''
                }
            }
        }
/*
        stage('Terraform Apply') {
            when {branch 'master'}
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'aws_user', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID'),
                    file(credentialsId: "secrets_tfvars", variable: 'secrets_vars')
                    ]) {
                        sh '''#!/bin/bash
                            ./terraform apply -auto-approve -var-file="./tfvars/dev.tfvars" -var-file="${secrets_vars}"
                            '''
                }
            }
        }
         stage('Terraform destroy') {
            when {branch 'master'}
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'aws_user', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID'),
                    file(credentialsId: "secrets_tfvars", variable: 'secrets_vars')
                    ]) {
                        sh '''#!/bin/bash
                            ./terraform destroy -auto-approve -var-file="./tfvars/dev.tfvars" -var-file="${secrets_vars}"
                            '''
                }
            }
        }
        */
    }
    post {
        cleanup {
            deleteDir()
        }
    }
}


/*
        stage('Terraform Path') {
            steps {
                withEnv(["PATH=${tool 'Terraform'}:$PATH"]) {
                    sh '''
                        terraform version
                        '''
                 }
            }
        }
*/
