# Multi-Environment AWS Infrastructure (Jenkins Pipeline)

## This project manages Infrastructure-as-Code (IaC) for Dev, SIT, and Prod environments.
## The deployment logic is fully encapsulated within a parameterized Jenkins pipeline, ensuring consistent state management and security guardrails.

🏗 Architecture Overview

* Environments: Dev, SIT, Prod.
* State Management: S3 Backend with dynamic reconfiguration.
* Security: AWS Cross-Account assume_role for all deployments.

🚀 Jenkins Pipeline Workflow:
The pipeline is designed to be interactive and "smart" about how it handles production gates and destruction logs.

1. Build Parameters
   When triggering a Build with Parameters, you must select:
   
     <img width="549" height="103" alt="image" src="https://github.com/user-attachments/assets/ffa15ab7-b918-4f2e-9634-0f6093c701ba" />

     
3. Pipeline Logic & Stages
    
   Stage 1: User Detection 👤
     * Plugin: Uses the Build User Vars Plugin.
     * Logic: Automatically detects the user triggering the build (e.g., admin, john.doe).
     * Fallback: If triggered by a timer or webhook, defaults to "System".
       
   Stage 2: Initialization & Plan
     * Dynamically configures the S3 backend for the selected ENVIRONMENT.
     * Generates a speculative plan using the environment-specific .tfvars file.
       
   Stage 3: Production Gate (Prod Only) 🛡️
     This stage runs only if ENVIRONMENT is Prod and the action is Apply or Destroy.
     *  Prompt: A blocking input box appears: "Confirm the action?".
     *  User Info: Displays the detected username authorizing the change.
     *  Action:
         - Click "Confirm": The pipeline proceeds to execute the changes.
         - Click "Abort": The pipeline stops immediately (Status: ABORTED).
           
   Stage 4: Execution (Smart Apply/Destroy) 🧠

     The pipeline executes the changes and intelligently parses the output.
      * On Apply:   Auto-approves the creation of resources & Validates success via exit code.
       * On Destroy:
           - Captures the Terraform logs into a variable
           - If logs contain "Resources: 0 destroyed", it prints: ⚠️ Info: No resources needed to be destroyed (Bucket didn't exist).
           - If resources were removed, it prints: 🗑️ SUCCESS: The bucket was destroyed!

📂 Project Structure

  <img width="666" height="395" alt="image" src="https://github.com/user-attachments/assets/a2dcdf93-1a7e-4dc9-be6e-77e08f1fde6f" />

🔌 Prerequisites (Jenkins)
      To run this pipeline successfully, the Jenkins server requires:

   1. Plugins:
       * Build User Vars Plugin: Required to detect the logged-in user for the Prod Gate.
       * Pipeline Utility Steps: For advanced file/log operations.

   2. Credentials:
       * AWS Credentials capable of assuming the target IAM roles.

  3. Tools:
       * Terraform v1.0+ installed on the agent.
       * AWS CLI installed for verification steps.

     
