
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
    choice(name: 'Env_Name', choices: ['DEV','SIT','UAT'], description: 'Choose the Environment Name for deployment')
  }

  environment {
		json_file_name = ""
	}

  stages { 
    stage('Deployment Pre-Requisites') {
        steps {
            script {
                //Put code below to call curl command to get latest version json based on environment selection
                sh """
                """
            } //script
        } //steps
    } //stage
    stage('Deploy the package') {
      steps {
        script {
          def appServer = constructTargetServer(Env_Name)
          def policyName = "a0032d_ratesdb"
          triggerJob(policyName, appServer, json_file_name)
        }
      }
    }
  }//stages
}//pipeline

def constructTargetServer(choosenEnv){
  if(choosenEnv == "DEV"){
    appServer = "dla240906184813.obm.nix.srv.westpac.com.au"
  }else if(choosenEnv == "SIT"){
    appServer = "tla240910110226.obm.nix.srv.westpac.com.au"
  }else if(choosenEnv == "UAT"){
    appServer = ""
  }
  return appServer
}
