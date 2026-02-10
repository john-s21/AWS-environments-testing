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
                    def currentUser = "Unknown User" // Fallback default

                    // 1. FETCH THE REAL USER
                    // We wrap this in a try-catch block so the build doesn't crash 
                    // if the plugin is missing or if the build was triggered by a Timer/SCM.
                    try {
                        wrap([$class: 'BuildUser']) {
                            // This plugin injects the 'BUILD_USER_ID' variable
                            currentUser = env.BUILD_USER_ID
                            // You can also use env.BUILD_USER (Full Name) or env.BUILD_USER_EMAIL
                        }
                    } catch (Exception e) {
                        echo "⚠️ Could not detect user. Is 'Build User Vars Plugin' installed?"
                        currentUser = "System/Timer"
                    }

                    // 2. The Validation Loop
                    waitUntil {
                        def userInput = input(
                            id: 'ProdDeployGate', 
                            message: promptMessage, 
                            ok: "Confirm Decision", 
                            parameters: [
                                // Show the detected user here
                                string(name: 'DISPLAY_USER', 
                                       defaultValue: currentUser, 
                                       description: 'User authorizing this action (Read Only)', 
                                       trim: true),
                                
                                booleanParam(name: 'ABORT_BUILD', 
                                             defaultValue: false, 
                                             description: '🔴 Check this box to ABORT/REJECT the build.'),
                                
                                string(name: 'REASON', 
                                       defaultValue: '', 
                                       description: 'Reason for decision (MANDATORY if Abort is checked)', 
                                       trim: true)
                            ]
                        )

                        // 3. Logic Check
                        if (userInput['ABORT_BUILD'] == true) {
                            if (!userInput['REASON']?.trim()) {
                                promptMessage = "⚠️ ERROR: You checked 'Abort' but provided no reason!\n\nUser detected: ${currentUser}\nPlease provide a reason."
                                return false // Restart Loop
                            } else {
                                userDecision = userInput
                                return true // Exit Loop
                            }
                        } else {
                            userDecision = userInput
                            return true // Exit Loop
                        }
                    }

                    // 4. Execution Logic
                    if (userDecision['ABORT_BUILD'] == true) {
                        echo "⛔ Build explicitly aborted by ${userDecision['DISPLAY_USER']}."
                        currentBuild.result = 'ABORTED'
                        error("Aborted by user: ${userDecision['REASON']}")
                    } else {
                        echo "✅ Deployment Approved by ${userDecision['DISPLAY_USER']}."
                        if (userDecision['REASON']?.trim()) {
                            echo "📝 Note: ${userDecision['REASON']}"
                        }
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