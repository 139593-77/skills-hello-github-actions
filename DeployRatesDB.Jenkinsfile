

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
  final parentJobResult =  build job: 'A0032D_RatesDB/OBM_Chef_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'), 
    string(name: 'SERVER_LABEL', value: "${appServer}"), 
    string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), 
    string(name: 'POLICY_NAME', value: "${policyName}"), 
    string(name: 'POLICY_GROUP', value: 'default'),
    string(name: 'OVERRIDE_ATTRIBUTES_FILE', value: "${json}")]
    //echo "Current Build number is ${currentBuild.number}"
  // echo "parentJobResult number: ${parentJobResult.number}"
}

pipeline {
  // agent any
  agent {
        node {
          label 'enterprise_devops&&linux'
        }
      }
  
  parameters {
    string(name: 'PACKAGE_NAME', defaultValue: '', description: 'Enter the package name. For Ex: RDPipeline_feature_MRR-22620_Rename_496.zip')
    string(name: 'WHL_FILE', defaultValue: '', description: 'Enter the whl file name. For Ex: rdpipeline-1.3.11-py2.py3-none-any.whl')
    choice(name: 'Env_Name', choices: ['dev','sit','uat', 'svp'], description: 'Choose the Environment Name for deployment')
  }

  environment {
		latest_json_name = ""
	}

  stages { 
    stage('Input Validation Check') {
        steps {
            script {
                if (!params.PACKAGE_NAME?.trim()) {
                    echoRedBanner("Validation Errors", "Please enter the package name to append in JSON file For Ex: RDPipeline_feature_MRR-22620_Rename_496.zip")
                    error("Invalid Input Error")
                }
                if (!params.WHL_FILE?.trim()) {
                    echoRedBanner("Validation Errors", "Please enter the whl file name to append in JSON file For Ex: rdpipeline-1.3.11-py2.py3-none-any.whl")
                    error("Invalid Input Error")
                }
                if (!params.PACKAGE_NAME.contains('.zip')) {
                    echoRedBanner("Validation Errors", "Please enter the package name with .zip extension to append in JSON file For Ex: RDPipeline_feature_MRR-22620_Rename_496.zip")
                    error("Invalid Input Error")
                }
                if (!params.WHL_FILE.contains('.whl')) {
                    echoRedBanner("Validation Errors", "Please enter the whl file name with .whl extension to append in JSON file For Ex: rdpipeline-1.3.11-py2.py3-none-any.whl")
                    error("Invalid Input Error")
                }
            }
        }
    }
    stage('JSON Creation and Upload') {
        steps {
            script {
                def jsonFilePath = "${WORKSPACE}/rdpipeline_deploy_${ENV_NAME}_version_${env.BUILD_NUMBER}.json"
                writeFile(file: jsonFilePath, text: """\
                {
                    "ratesdb": {
                        "pkg_name": "${PACKAGE_NAME}",
                        "deploy_path": "/apps/market_data/risk_data/pipelines/batch/rdpipeline/setup",
                        "whl_file": "${WHL_FILE}"
                    }
                }
                """.stripIndent())

                echo "JSON file content:"
                echo readFile(jsonFilePath)

                def server = Artifactory.newServer(url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'A0032D_SA_0001_PRD_Art')
                def artifact_sub_path = "A0032D_RatesDb/Attributes"
                def uploadSpec = """{
                    "files": [{
                        "pattern": "${jsonFilePath}",
                        "target": "${artifact_sub_path}/",
                        "props": "type=json;status=ready"
                    }]
                }"""
                server.upload(uploadSpec)
                echoBanner("Click the below artifactory link to verify","https://artifactory.srv.westpac.com.au/artifactory/A0032D_RatesDb/Attributes/")

            }
        }
    }
    stage('Deployment Pre-Requisites') {
        steps {
            script {
                //Put code below to call curl command to get latest version json based on environment selection
                //Get latest artifactname to be deployed from maven snapshot artifactory
           withCredentials([usernamePassword(credentialsId: 'A0032D_SA_0001_PRD_Art', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
           latest_json_name = sh (returnStdout: true,
                    script:"""#!/bin/bash
                      jarName=`curl -s -u"${USERNAME}":"${PASSWORD}" -XPOST https://artifactory.srv.westpac.com.au/artifactory/api/search/aql -d 'items.find({"repo":{"\$eq": "A0032D_RatesDb"}, "name": {"\$match": "rdpipeline_deploy_${Env_Name}_version_*.json"}}).sort({"\$desc" : ["created"]}).limit(1)' -H "Content-Type: text/plain" | jq .results[0].name |sed -e 's/"//g'`
                      echo -n "\${jarName}"
                      """
           )   
           }
            } //script
        } //steps
    } //stage
    stage('Deploy the package') {
      steps {
        script {
          def appServer = constructTargetServer(Env_Name)
          def policyName = "a0032d_ratesdb"
          triggerJob(policyName, appServer, latest_json_name)
        }
      }
    }
  }//stages
}//pipeline

def constructTargetServer(choosenEnv){
  if(choosenEnv == "dev"){
    appServer = "dla210921173259.obm.nix.srv.westpac.com.au"
  }else if(choosenEnv == "sit"){
    appServer = "tla210923171312.obm.nix.srv.westpac.com.au"
  }else if(choosenEnv == "uat"){
    appServer = "tla210921173329.obm.nix.srv.westpac.com.au"
  }else if(choosenEnv == "svp"){
    appServer = "tla211217163038.obm.nix.srv.westpac.com.au,tla211217163459.obm.nix.srv.westpac.com.au,tla211217163702.obm.nix.srv.westpac.com.au,tla211217164104.obm.nix.srv.westpac.com.au"
  }
  return appServer
}
