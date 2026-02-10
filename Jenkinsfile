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
    // 1. Only run for Prod + Apply/Destroy
    when {
        allOf {
            expression { params.ENVIRONMENT == 'prod' }
            not { expression { params.ACTION == 'plan' } }
        }
    }
    steps {
        script {
            try {
                def userInput = input(
                    id: 'ProdDeployGate', 
                    message: "🚨 PROD DEPLOYMENT GATE", 
                    ok: "Submit Decision", // We rename the button from 'Proceed' to 'Submit Decision'
                    parameters: [
                        choice(name: 'DECISION', 
                               choices: ['Approve Deployment', 'Abort Build'], 
                               description: 'Do you want to proceed with the changes?'),
                        string(name: 'REASON', 
                               defaultValue: '', 
                               description: 'Reason for aborting (Required if Abort is selected)')
                    ]
                )

                // 3. Process the Input
                // The 'userInput' variable now holds a map: [DECISION: '...', REASON: '...']
                
                if (userInput['DECISION'] == 'Abort Build') {
                    // check if they actually typed a reason
                    def stopReason = userInput['REASON'].trim()
                    
                    if (stopReason == "") {
                        stopReason = "No reason provided."
                    }
                    
                    // Log it nicely
                    echo "⛔ Build explicitly aborted by user."
                    echo "📝 Reason: ${stopReason}"
                    
                    // Mark build as Aborted (Gray) or Failed (Red) based on your preference
                    currentBuild.result = 'ABORTED' 
                    currentBuild.description = "Aborted: ${stopReason}"
                    
                    // Stop the pipeline here
                    error("Build stopped by user: ${stopReason}")
                } else {
                    echo "✅ User approved deployment. Proceeding..."
                }

            } catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException e) {
                // This catches if they click the tiny red 'Abort' link instead of using our form
                echo "User clicked the system Abort link (no reason captured)."
                currentBuild.result = 'ABORTED'
                error("System Abort triggered")
            }
        }
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
                        sh "terraform destroy -var-file=tfvars/${params.ENVIRONMENT}.tfvars -auto-approve"
			echo "The bucket name ${params.ENVIRONMENT} was destroyed!"
                    }
                }
            }
        }
	
    }
}