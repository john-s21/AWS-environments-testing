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
	
        stage('Terraform Apply/Destroy') {
            when {
                not { expression { params.ACTION == 'plan' } }
            }
            steps {
                script {
                    if (params.ACTION == 'destroy') {
                        // 1. Run Terraform and CAPTURE the output (returnStdout: true)
                        // We use .trim() to clean up whitespace
                        def destroyLog = sh(
                            script: "terraform destroy -var-file=${TFVARS_FILE} -auto-approve", 
                            returnStdout: true
                        ).trim()

                        // 2. Print the log to the console so you can still see the details
                        echo destroyLog

                        // 3. Analyze the text to decide what to print
                        if (destroyLog.contains("Resources: 0 destroyed")) {
                            echo "⚠️ Info: No resources needed to be destroyed (Bucket didn't exist)."
                        } else {
                            // Only prints if something was actually deleted
                            echo "🗑️ SUCCESS: The bucket ${params.ENVIRONMENT} was destroyed!"
                        }
                    } 
                    else if (params.ACTION == 'apply') {
                        // Standard apply logic
                        sh "terraform apply -auto-approve tfplan"
                        echo "✅ Deployment Successful!"
                    }
                }
            }
        }
	
    }
}