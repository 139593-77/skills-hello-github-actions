import org.apache.commons.io.FilenameUtils

def echoBanner(def ... msgs) {
   echo createBanner(msgs)
}

def errorBanner(def ... msgs) {
   error(createBanner(msgs))
}

// def createBanner(def ... msgs) {
//    return """
//        ===========================================

//        ${msgFlatten(null, msgs).join("\n        ")}

//        ===========================================
//    """
// }
def getPattern(length, caracter) {
  StringBuilder sb= new StringBuilder(length)
  for (int i = 0; i < length; i++) {
      sb.append(caracter)
  }
  return sb.toString()
}
def createBanner(def ... msgs) {
  // msgs[0].length().toInteger()
  spacesEqual = getPattern(msgs[0].length().toInteger(), '=')
   return """
       =================== ${msgs[0]} ========================

       ${msgFlatten(null, msgs[1..-1]).join("\n        ")}

       ====================${spacesEqual}=========================
   """
}
def echoHeader(msgs){
  echo createHeader(msgs)
}
def createHeader(msgs) {
   return """

       ${msgFlatten(null, msgs).join("\n        ")}

   """
}

// flatten function hack included in case Jenkins security
// is set to preclude calling Groovy flatten() static method
// NOTE: works well on all nested collections except a Map
def msgFlatten(def list, def msgs) {
   list = list ?: []
   if (!(msgs instanceof String) && !(msgs instanceof GString)) {
       msgs.each { msg ->
           list = msgFlatten(list, msg)
       }
   }
   else {
       list += msgs
   }

   return  list
}

def triggerJob(policyName, appServer, json){
  // -------------------------- TRIGGER THE PIPELINE  --------------------// 
  final parentJobResult =  build job: 'A005D4_Meerkat/OBM_Chef_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'), 
    string(name: 'SERVER_LABEL', value: "${appServer}"), 
    string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), 
    string(name: 'POLICY_NAME', value: "${policyName}"), 
    string(name: 'POLICY_GROUP', value: 'default'),
    string(name: 'OVERRIDE_ATTRIBUTES_FILE', value: "${json}")]
    //echo "Current Build number is ${currentBuild.number}"
  // echo "parentJobResult number: ${parentJobResult.number}"
}

def targetDrive = "/riskdata/atoti"
def version = ""
pipeline {
  // agent any
  agent {
        node {
          label 'enterprise_devops&&linux'
        }
      }
  
  parameters {
    choice(name: 'Env_Name', choices: ['dev','sit','tst'], description: 'Choose the Environment Name for deployment')
  }

  
  stages { 
    stage('Checkout') {
        steps {
            script {
                // Get code from a BitBucket repository
                deleteDir()
                checkout([$class: 'GitSCM', branches: [
                    [name: '*/initial_setup']
                ], doGenerateSubmoduleConfigurations: false, extensions: [
                    [$class: 'RelativeTargetDirectory', relativeTargetDir: ""]
                ], submoduleCfg: [], userRemoteConfigs: [
                    [credentialsId: 'srvA005D4jenkinsSSHKey', url: "ssh://git@bitbucket.srv.westpac.com.au/a005d4/atoti_scripts.git"]
                ]])
            
            } 
        }
    }   
    stage('Zip the package') {
        steps {
            script {
                version = readFile '.version'
                //zip the project
                sh """
                cd ${WORKSPACE}
                mkdir -p work/config
                cp -r config/* work/config
                mkdir -p work/scripts/wbc
                cp -r scripts/* work/scripts/
				        cp .version work/
                echo "Environment selected::${Env_Name}"
                cp -r env_specific/${Env_Name}/* work/

                cd work
                echo "Version::${version}"
                zip -rq "../Batch-${Env_Name}-${version}.zip" *
                cd ..
                rm -rf work
                """
            } //script
        } //steps
    } //stage
    stage('Create json file') {
      steps {
        script { 
		           
            writeFile (file: "${env.WORKSPACE}/package.json" , 
            text: """\
			{ 
                "wib_devops": {
                "pipeline_type": "package_deploy",
                  "package_deploy": {
                     "source_artifact_url_path": "https://artifactory.srv.westpac.com.au/artifactory/A005D4_Atoti/Batch-Packages/",
                     "current_package_version": "Batch-${Env_Name}-${version}.zip", 
                     "source_json_file_loc": "https://artifactory.srv.westpac.com.au/artifactory/A005D4_Meerkat/Override_Attributes/package.json",
                     "json_file_download_path": "/tmp/wib_devops/artifacts/package.json",
                     "source_artifact_file_loc": "/tmp/wib_devops/artifacts",
                     "json_file_name": "package.json",
                     "deploy_location": "${targetDrive}/scripts/wbc/",
                     "source_artifact_extract_loc": "/tmp/wib_devops/deploy_package",
                     "vault_enabled": true,
                     "vault_art_key": "artifactory-token",
                     "vault_art_key_version": "1",
					           "artifactory_service_account": "SRVC_A005D4_0001_PRD",
                     "user": "atotiadm",
                     "group": "atotiadm",
					           "install_source_drive": ""
                    } 
                }
            }
              """.stripIndent()
            )
			  } //script
      } //steps
    }  //stage
    stage("Upload Package to artifactory") {
      steps {
        script {
          def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'ArtifactoryCreds'
            def uploadSpec = """{
                    "files": [{
                       "pattern": "${WORKSPACE}/Batch-${Env_Name}-${version}.zip",
                       "target": "A005D4_Atoti/Batch-Packages/",
                            "props": "type=zip;status=ready"
                    },
                    {
                       "pattern": "${WORKSPACE}/package.json",
                       "target": "A005D4_Meerkat/Override_Attributes/",
                            "props": "type=json;status=ready"
                    }]
                 }"""
                 server.upload(uploadSpec)
        }//Script
      }//Steps
    }// Upload Package
    stage('Deploy the package') {
      steps {
        script {
          def appServer = constructTargetServer(Env_Name)
          def policyName = "a005d4_meerkat_batch_deploy"
          def json = "package.json"
          triggerJob(policyName, appServer, json)
        }
      }
    }
  }//stages
}//pipeline

def constructTargetServer(choosenEnv){
  if(choosenEnv == "dev"){
    appServer = "dla240906184813.obm.nix.srv.westpac.com.au"
  }else if(choosenEnv == "sit"){
    appServer = "tla240910110226.obm.nix.srv.westpac.com.au"
  }else if(choosenEnv == "tst"){
    appServer = ""
  }
  return appServer
}
