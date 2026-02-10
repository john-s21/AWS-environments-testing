pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'sit', 'prod'], description: 'Select the Environment to Deploy')
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Do you want to Build (apply) or Delete (destroy)?')
    }

    stages {
        stage('Terraform Init') {
            steps {
                echo "Initializing for environment: ${params.ENVIRONMENT}"
                sh "terraform init -backend-config=backend/${params.ENVIRONMENT}.conf -reconfigure"
            }
        }
	stage('Terraform Check') {
            steps {
                echo "Validating terraform code: ${params.ENVIRONMENT}"
                sh "terraform validate"
            }
        }
        stage('Terraform Plan') {
            steps {
                echo "Planning changes for: ${params.ENVIRONMENT}"
                sh "terraform plan -var-file=tfvars/${params.ENVIRONMENT}.tfvars"
            }
        }

	stage('Production Approval') {
            when {
                allOf {
                    expression { params.ENVIRONMENT == 'prod' }
                    not { expression { params.ACTION == 'plan' } }
                }
            }
            steps {
                input message: "Confirm the action?", ok: "Confirm"
            }
        }
	
        stage('Terraform Action') {
            steps {
                script {
                    if (params.ACTION == 'apply') {
                        sh "terraform apply -var-file=tfvars/${params.ENVIRONMENT}.tfvars -auto-approve"
			echo "Verifying S3 Buckets in AWS..."
                        sh "aws s3 ls | grep ${params.ENVIRONMENT} || true"
			echo "If you see the bucket name above, the deployment was a success!"
                    } 
                    else if (params.ACTION == 'destroy') { 
			def destroyLog = sh(
                            script: "terraform destroy -var-file=tfvars/${params.ENVIRONMENT}.tfvars -auto-approve", 
                            returnStdout: true
                        ).trim()

                        echo destroyLog

                        if (destroyLog.contains("Resources: 0 destroyed")) {
                            echo "⚠️ Info: No resources needed to be destroyed."
                        } else {
                            echo "🗑️ SUCCESS: The bucket ${params.ENVIRONMENT} was destroyed!"
                        }
                    }
                }
            }
        }	
    }
}