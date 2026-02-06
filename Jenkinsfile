pipeline {
    agent any

    // 1. Ask the user for inputs
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'sit', 'prod'], description: 'Select the Environment to Deploy')
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Do you want to Build (apply) or Delete (destroy)?')
    }

    stages {
        // 2. Setup Terraform
        stage('Terraform Init') {
            steps {
                echo "Initializing for environment: ${params.ENVIRONMENT}"
                // We use the specific backend file for the chosen environment
                sh "terraform init -backend-config=backend/${params.ENVIRONMENT}.conf -reconfigure"
            }
        }
	//3. Terraform Validation
	stage('Terraform Check') {
            steps {
                echo "Validating terraform code: ${params.ENVIRONMENT}"
                sh "terraform validate"
            }
        }


        // 4. Show the Plan
        stage('Terraform Plan') {
            steps {
                echo "Planning changes for: ${params.ENVIRONMENT}"
                sh "terraform plan -var-file=tfvars/${params.ENVIRONMENT}.tfvars"
            }
        }

        // 5. Apply (Build) or Destroy (Delete)
        stage('Terraform Action') {
            steps {
                script {
                    if (params.ACTION == 'apply') {
                        // Build it!
                        sh "terraform apply -var-file=tfvars/${params.ENVIRONMENT}.tfvars -auto-approve"
                    } 
                    else if (params.ACTION == 'destroy') {
                        // Delete it! (With a safety check implies manually via Jenkins input, 
                        // but for now we will keep it simple)
                        sh "terraform destroy -var-file=tfvars/${params.ENVIRONMENT}.tfvars -auto-approve"
                    }
                }
            }
        }
	stage('Verify Buckets') {
            steps {
                script {
                    // Only run this verification if we just applied (built) something
                    if (params.ACTION == 'apply') {
                        echo "Verifying S3 Buckets in AWS..."
                        
                        // List all buckets and highlight the one we just made
                        // We use 'grep' to filter the list for 'dev', 'sit' or 'prod'
                        sh "aws s3 ls | grep ${params.ENVIRONMENT} || true"
                        
                        echo "If you see the bucket name above, the deployment was a success!"
                 }
             }
         }
    }
}
