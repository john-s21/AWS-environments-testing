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
                script {
                    // 1. Get the User ID safely (Requires 'Build User Vars' plugin, or falls back to 'Jenkins User')
                    def currentUser = "Jenkins User"
                    try {
                        wrap([$class: 'BuildUser']) {
                            currentUser = env.BUILD_USER_ID
                        }
                    } catch (Exception e) {
                        // Plugin not installed or triggered by timer; ignore
                    }

                    // 2. The Input Form
                    // We catch the "System Abort" (the gray button) just in case, but we encourage using the Form.
                    try {
                        def userInput = input(
                            id: 'ProdDeployGate', 
                            message: "🚀 PROD DEPLOYMENT GATE", 
                            ok: "Confirm Decision", // This button submits the form (Approve OR Abort)
                            parameters: [
                                // requirement 5: Show the user
                                string(name: 'DISPLAY_USER', 
                                       defaultValue: currentUser, 
                                       description: 'User authorizing this action (Read Only)', 
                                       trim: true),
                                
                                // requirement 1 & 2: No Dropdown. Use Checkbox for "Abort" logic.
                                booleanParam(name: 'ABORT_BUILD', 
                                             defaultValue: false, 
                                             description: '🔴 Check this box if you want to ABORT/REJECT the build.'),
                                
                                // requirement 3: Reason Text Box
                                string(name: 'REASON', 
                                       defaultValue: '', 
                                       description: 'Reason for decision (MANDATORY if Abort is checked)', 
                                       trim: true)
                            ]
                        )

                        // 3. Validation Logic
                        
                        // Scenario: User checked "Abort"
                        if (userInput['ABORT_BUILD'] == true) {
                            def reason = userInput['REASON']
                            
                            // Check if reason is empty or just spaces
                            if (reason == null || reason.trim() == "") {
                                error("❌ You checked 'Abort' but did not provide a reason! Restart the build and try again.")
                            }
                            
                            // Valid reason provided -> Abort Gracefully
                            echo "⛔ Build explicitly aborted by ${userInput['DISPLAY_USER']}."
                            echo "📝 Reason: ${reason}"
                            currentBuild.result = 'ABORTED'
                            error("Aborted by user: ${reason}")
                        }
                        
                        // Scenario: User did NOT check "Abort" (Approval)
                        // Requirement 4: "if I don't give the reason but hit Apply... build should move on"
                        else {
                            echo "✅ Deployment Approved by ${userInput['DISPLAY_USER']}."
                            if (userInput['REASON']?.trim()) {
                                echo "📝 Note: ${userInput['REASON']}"
                            }
                        }

                    } catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException e) {
                        // This handles the case if they click the tiny gray 'Abort' button
                        echo "⚠️ User clicked the system Abort button. No reason could be captured."
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