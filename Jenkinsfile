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
                    def userDecision = null
                    def promptMessage = "🚀 PROD DEPLOYMENT GATE" 
                    
                    // 1. Get User ID
                    def currentUser = "Unknown"
                    try {
                        wrap([$class: 'BuildUser']) { currentUser = env.BUILD_USER_ID }
                    } catch (Exception e) { currentUser = "System" }

                    try {
                        // 2. The Validation Loop (Forces the BLUE button logic)
                        waitUntil {
                            def userInput = input(
                                id: 'ProdDeployGate', 
                                message: promptMessage, 
                                ok: "Confirm Decision", // The Blue Button
                                parameters: [
                                    string(name: 'DISPLAY_USER', 
                                           defaultValue: currentUser, 
                                           description: 'User authorizing this action (Read Only)', 
                                           trim: true),
                                    
                                    booleanParam(name: 'ABORT_BUILD', 
                                                 defaultValue: false, 
                                                 description: '🔴 Check this box to ABORT/STOP the build.'),
                                    
                                    string(name: 'REASON', 
                                           defaultValue: '', 
                                           description: 'Reason for decision (REQUIRED if Abort is checked)', 
                                           trim: true)
                                ]
                            )

                            // 3. Check Logic
                            if (userInput['ABORT_BUILD'] == true) {
                                if (!userInput['REASON']?.trim()) {
                                    // REJECT: Re-open the prompt
                                    promptMessage = "⚠️ STOP! You checked 'ABORT' but gave no reason.\nPlease enter a reason and click Confirm again."
                                    return false 
                                } else {
                                    // VALID ABORT: Exit loop
                                    userDecision = userInput
                                    return true 
                                }
                            } else {
                                // VALID DEPLOY: Exit loop
                                userDecision = userInput
                                return true 
                            }
                        }

                        // 4. Execution (Only happens if Blue button was used correctly)
                        if (userDecision['ABORT_BUILD'] == true) {
                            echo "⛔ Build explicitly aborted by ${userDecision['DISPLAY_USER']}."
                            currentBuild.result = 'ABORTED'
                            error("Aborted by user: ${userDecision['REASON']}")
                        } else {
                            echo "✅ Deployment Approved by ${userDecision['DISPLAY_USER']}."
                        }

                    } catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException e) {
                        // 5. Catch the GRAY BUTTON click
                        echo "⚠️ WARNING: User clicked the System Abort button (Gray Button)."
                        echo "⚠️ No reason was captured because the user bypassed the form."
                        currentBuild.result = 'ABORTED'
                        // We swallow the error so the pipeline ends cleanly, but logged as 'System Abort'
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