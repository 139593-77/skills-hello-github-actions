
properties([
    parameters([
         [$class: 'ChoiceParameter', 
            choiceType: 'PT_SINGLE_SELECT', 
            description: 'Select the ENVIRONMENT from the List',  
            name: 'Env_Name',
            script: [
                $class: 'GroovyScript', 
                fallbackScript: [
                    classpath: [], 
                    sandbox: true, 
                    script: 
                        'return[\'Environment not available\']'
                ], 
                script: [
                    classpath: [], 
                    sandbox: true, 
                    script: 
                        'return["DEV", "IAT1", "IAT2", "IAT3", "IAT4", "IAT5", "SVP"]'
                ]
            ]
        ],
        [$class: 'ChoiceParameter', 
            choiceType: 'PT_SINGLE_SELECT', 
            description: 'Select the Server Type from the List',  
            name: 'ServerType',
            script: [
                $class: 'GroovyScript', 
                fallbackScript: [
                    classpath: [], 
                    sandbox: true, 
                    script: 
                        'return[\'Server Type not available\']'
                ], 
                script: [
                    classpath: [], 
                    sandbox: true, 
                    script: 
                        'return["WebServer", "MiddlewareServer", "ELKServer"]'
                ]
            ]
        ],
       [$class: 'CascadeChoiceParameter', 
            choiceType: 'PT_SINGLE_SELECT', 
            description: 'Select the Hostname from the Dropdown List', 
            name: 'Host_Name',
            referencedParameters: 'ServerType,Env_Name',
            script: [
                $class: 'GroovyScript', 
                fallbackScript: [
                    classpath: [], 
                    sandbox: true, 
                    script: 
                        'return[\'None\']'
                ], 
                script: [
                    classpath: [], 
                    sandbox: true, 
                    script: """ 
                        def listHostNames(servertypename, environment) {
                            def servers = []
                            if (environment == "DEV") {
                                switch (servertypename) {
                                    case "WebServer":
                                        servers = ["au2106sde055.esdevau.wbcdevau.westpac.com.au"]
                                        break
                                    case "MiddlewareServer":
                                        servers = ["au2106sde056.esdevau.wbcdevau.westpac.com.au"]
                                        break
                                    case "ELKServer":
                                        servers = ["au2106sde057.esdevau.wbcdevau.westpac.com.au"]
                                        break
                                }
                            }
                            if (environment == "IAT1") {
                                switch (servertypename) {
                                    case "WebServer":
                                        servers = ["twa190708164148.estestau.wbctestau.westpac.com.au"]
                                        break
                                    case "MiddlewareServer":
                                        servers = ["twa190708164614.estestau.wbctestau.westpac.com.au"]
                                        break
                                    case "ELKServer":
                                        servers = ["twa190708172453.estestau.wbctestau.westpac.com.au"]
                                        break
                                }
                            }
                            if (environment == "IAT2") {
                                switch (servertypename) {
                                    case "WebServer":
                                        servers = ["twa190708164511.estestau.wbctestau.westpac.com.au"]
                                        break
                                    case "MiddlewareServer":
                                        servers = ["twa190708172401.estestau.wbctestau.westpac.com.au"]
                                        break
                                    case "ELKServer":
                                        servers = ["twa190708172535.estestau.wbctestau.westpac.com.au"]
                                        break
                                }
                            }
                            if (environment == "IAT3") {
                                switch (servertypename) {
                                    case "WebServer":
                                        servers = ["twa200925103535.estestau.wbctestau.westpac.com.au"]
                                        break
                                    case "MiddlewareServer":
                                        servers = ["twa200925103556.estestau.wbctestau.westpac.com.au"]
                                        break
                                    case "ELKServer":
                                        servers = ["twa190708172619.estestau.wbctestau.westpac.com.au"]
                                        break
                                }
                            }
                            if (environment == "IAT4") {
                                switch (servertypename) {
                                    case "WebServer":
                                        servers = ["tww210426111038.estestau.wbctestau.westpac.com.au"]
                                        break
                                    case "MiddlewareServer":
                                        servers = ["twa210426111032.estestau.wbctestau.westpac.com.au"]
                                        break
                                    case "ELKServer":
                                        servers = ["twa210426111043.estestau.wbctestau.westpac.com.au"]
                                        break
                                }
                            }
                            if (environment == "IAT5") {
                                switch (servertypename) {
                                    case "WebServer":
                                        servers = ["tww220330100723.estestau.wbctestau.westpac.com.au"]
                                        break
                                    case "MiddlewareServer":
                                        servers = ["twa220330100801.estestau.wbctestau.westpac.com.au"]
                                        break
                                    case "ELKServer":
                                        servers = ["twa220330101007.estestau.wbctestau.westpac.com.au"]
                                        break
                                }
                            }
                            if (environment == "SVP") {
                                switch (servertypename) {
                                    case "WebServer":
                                        servers = ["twa200217133131.estestau.wbctestau.westpac.com.au","twa200217133040.estestau.wbctestau.westpac.com.au"]
                                        break
                                    case "MiddlewareServer":
                                        servers = ["twa200217132829.estestau.wbctestau.westpac.com.au","twa200217132707.estestau.wbctestau.westpac.com.au"]
                                        break
                                    case "ELKServer":
                                        servers = ["twa200217130426.estestau.wbctestau.westpac.com.au","twa200217130336.estestau.wbctestau.westpac.com.au","twa200217130335.estestau.wbctestau.westpac.com.au","twa200217120001.estestau.wbctestau.westpac.com.au","twa200217115825.estestau.wbctestau.westpac.com.au","twa200217115405.estestau.wbctestau.westpac.com.au"]
                                        break
                                }
                            }
                            
                            return servers
                        }
                        def hostNames = listHostNames(ServerType, Env_Name)
                        return hostNames
                    """
                ]
            ]
        ],
        [$class: 'CascadeChoiceParameter', 
            choiceType: 'PT_SINGLE_SELECT', 
            description: 'Select the ServiceName from the Dropdown List', 
            name: 'Service_Name',
            referencedParameters: 'ServerType,Env_Name',
            script: [
                $class: 'GroovyScript', 
                fallbackScript: [
                    classpath: [], 
                    sandbox: true, 
                    script: 
                        'return[\'None\']'
                ], 
                script: [
                    classpath: [], 
                    sandbox: true, 
                    script: """ 
                        def listServices(servertypename, environment) {
                            def services = []
                            
                            switch (servertypename) {
                                case "WebServer":
                                    services = ["IIS"]
                                    break
                                case "MiddlewareServer":
                                    if (environment == "SVP") {
                                        services = ["ActiveMQ", "jbossfdim", "jbossEAP-7"]
                                    } else {
                                        services = ["ActiveMQ", "JBossEAP7"]
                                    }
                                    break
                                case "ELKServer":
                                    services = ["ELKService"]
                                    break
                            }
                            
                            return services
                            
                        }
                        def services = listServices(ServerType, Env_Name)
                        return services
                    """
                ]
            ]
        ],
        [$class: 'CascadeChoiceParameter', 
            choiceType: 'PT_SINGLE_SELECT', 
            description: 'Select the Action from the Dropdown List', 
            name: 'StartStop',
            referencedParameters: 'Service_Name',
            script: [
                $class: 'GroovyScript', 
                fallbackScript: [
                    classpath: [], 
                    sandbox: true, 
                    script: 
                        'return[\'None\']'
                ], 
                script: [
                    classpath: [], 
                    sandbox: true, 
                    script: """ 
                        def listActions(servicename) {
                            def actions = []
                            
                            switch (servicename) {
                                case "IIS":
                                    actions = ["Reset"]
                                    break
                                case "ActiveMQ":
                                    actions = ["Start", "Stop"]
                                    break
                                case "JBossEAP7":
                                    actions = ["Start", "Stop"]
                                    break
                                case "ELKService":
                                actions = ["Start", "Stop"]
                                break
                            }
                            
                            return actions
                            
                        }
                        def actions = listActions(Service_Name)
                        return actions
                    """
                ]
            ]
        ]
        
    ])
])

def echoBanner(def ... msgs) {
   echo createBanner(msgs)
}

def echoHighlightBanner(def ... msgs) {
  // white background black bold letters
  // echo "\033[90m\033[107m\033[1m${createBanner(msgs)}\033[0m"
  // No background Blue bold letters
  echo "\033[34m\033[1m${createBanner(msgs)}\033[0m"
}

def echoRedBanner(def ... msgs) {
  echo "\033[31m\033[107m\033[1m${createBanner(msgs)}\033[0m"
}

def echoGreenBanner(def ... msgs) {
  echo "\033[92m\033[40m\033[1m${createBanner(msgs)}\033[0m"
}

def echoGreenBannerNoBackground(def ... msgs) {
  echo "\033[92m\033[1m${createBanner(msgs)}\033[0m"
}

def echoGreenString(echoString) {
  echo "\033[92m\033[40m\033[1m${echoString}\033[0m"
}

def echoGreenStringNoBackground(echoString){
  echo "\033[92m\033[1m${echoString}\033[0m"
}

def errorBanner(def ... msgs) {
   error(createBanner(msgs))
}

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

def scheduledParentJobNumber
def scheduledParentJob
def parentDownstreamJobURL
def DATA_BAG_SECRET = "clm"

def triggerJob(policyName, appServer, json, DATA_BAG_SECRET){
  // -------------------------- TRIGGER THE PIPELINE  --------------------//

  final parentJobResult =  build job: 'A009B6_WIBCLM/OBM_Chef_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'),
    string(name: 'SERVER_LABEL', value: "${appServer}"),
    string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), 
    string(name: 'POLICY_NAME', value: "${policyName}"), 
    string(name: 'POLICY_GROUP', value: 'default'), 
    password(name: 'ENCRYPTED_DATA_BAG_SECRET', description: 'Enter databag secret if using databgs', value: "${DATA_BAG_SECRET}"),
    string(name: 'OVERRIDE_ATTRIBUTES_FILE', value: "${json}")]
  scheduledParentJobNumber = parentJobResult.number
  scheduledParentJob = parentJobResult.getFullProjectName()
  return [scheduledParentJob, scheduledParentJobNumber]
}

def fetchDownstreamJobUrl(scheduledParentJob, scheduledParentJobNumber, policyName){
  // --------------- FIND THE DOWNSTREAM JOB OF PIPELINE 1 -------------------------//
  // println scheduledParentJob
  // println scheduledParentJobNumber
  def filteredParentDownstreamJobArray = []
  withCredentials([usernamePassword(credentialsId: 'D11', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
    def parentDownstreamJob = sh(script: 'curl -u $USERNAME:$PASSWORD -X GET -H Content-Type:application/json -g https://jenkins.srv.westpac.com.au/job/A00619_EntDevOps/job/OBM/job/OBM_Chef_Deployment/api/json?tree=builds[url,actions[parameters[name,value],causes[upstreamBuild,upstreamProject,upstreamUrl]],result,building,number,duration,estimatedDuration]\\{0,3\\}', returnStdout: true)
    // println parentDownstreamJob
    def jsonObj = readJSON text: parentDownstreamJob
    // println jsonObj['builds']
    jsonObj['builds'].each { key, value ->
        def parameterMatched = false
        def actionMatched = false
        key["actions"].each { actions ->
          
            if (actions["_class"].equals("hudson.model.ParametersAction")) {
                actions["parameters"].each { param ->
                        // Matching policy Name
                        // echo policyName
                        if (param.value == policyName) {
                          // echo "Param matching"
                          parameterMatched = true
                        }
                }//param
            }//paramactionClass
            if (actions["_class"].equals("hudson.model.CauseAction")) {
                actions["causes"].each {action ->
                  // println action
                  if ((action.upstreamProject == scheduledParentJob) && (action.upstreamBuild.toString() == scheduledParentJobNumber.toString())){
                    actionMatched = true
                    // echo "Action match"
                    if (parameterMatched && actionMatched) {
                      filteredParentDownstreamJobArray.push(key)
                      // echo "Action matching"
                    }
                  }
                }//cause
            }// causeAction
        }// key loop
        //echo "Walked through key $key and value $value"
    }//jsonObj

  }// withCred

  // --------------- FIND THE DOWNSTREAM JOB OF PIPELINE 1 STATUS -------------------------//
  while (true) {
      echo ""
      sleep(15)
      // println filteredParentDownstreamJobArray
      // if (filteredParentDownstreamJobArray.url[0]) {
      if (!(filteredParentDownstreamJobArray.url[0].getClass().equals(net.sf.json.JSONNull))) {
        // println filteredParentDownstreamJobArray.url[0].getClass()
        break        
      }
    }// while loop
  parentDownstreamJobURL = filteredParentDownstreamJobArray.url[0]
  return parentDownstreamJobURL
}
def checksumStatus = ""
def parseParentDownstreamJobURL(parentDownstreamJobURL){
  withCredentials([usernamePassword(credentialsId: 'D11', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
    while (true) {
      echo "${String.format('%tF %<tH:%<tM', java.time.LocalDateTime.now())} - SLEEP"
      sleep(1)
      def parentDownstreamJobResponse = sh(script: "curl -u $USERNAME:$PASSWORD -X GET -H Content-Type:application/json -g ${parentDownstreamJobURL}api/json", returnStdout: true)
      parentDownstreamjsonObj = readJSON text: parentDownstreamJobResponse
      if (!(parentDownstreamjsonObj.result.getClass().equals(net.sf.json.JSONNull))) {
        echo "${String.format('%tF %<tH:%<tM', java.time.LocalDateTime.now())} - Result came"
        echo parentDownstreamjsonObj.result
        break
      }
    }// while loop
    
    if(parentDownstreamjsonObj.result){
      def parentDownstreamJobConsoleResponse = sh(script: "curl -u $USERNAME:$PASSWORD -X GET -H Content-Type:application/json -g ${parentDownstreamJobURL}/logText/progressiveText", returnStdout: true)
      // echo "parentDownstreamJobConsoleResponse - ${parentDownstreamJobConsoleResponse}"

      String[] logsArr = parentDownstreamJobConsoleResponse.split("\n");
      parentJobExecStatus = ""
      checksumStatus = ""
      parentJobExecStatus = parentDownstreamjsonObj.result
      println(parentJobExecStatus)
      
    }//only when the Job execution is completed, read the consoleLog to parse
    else{
      echoHeader("          ********** ELSE **********")
    }
  }//withCred
  return [parentJobExecStatus, checksumStatus]
}

//def file_in_workspace
import org.apache.commons.io.FilenameUtils


pipeline {
  // agent any
  agent {
    label 'enterprise_devops&&windows'
  }
  options {
    ansiColor('xterm')
  }
  environment{
      VERSION = "${currentBuild.number}"
  }
  
  stages {
    stage('Input Params'){
      steps {
        script {
          deleteDir()
          policyName = "a009b6_service_restart"
          echoHighlightBanner("Input Parameters", ["Env_Name - ${Env_Name}", "ServerType - ${ServerType}", "Host_Name - ${Host_Name}", "Service - ${Service_Name}", "Action - ${StartStop}", "Policy - ${policyName}"])
          
        }
      }
    }//Input Params
    
    stage('Pre-requisties Setup'){
      steps{
        script{
          // Prepare services.json
            writeFile (file: "${WORKSPACE}/services.json" ,
                  text: """\
                  {"wib_devops": {
                        "artifactory": {
                            "repo": "https://artifactory.srv.westpac.com.au/artifactory/A009B6_WIBCLM/"
                        },
                        "current_package_version": "0.1.0",
                        "appid": "A009B6",
                        "services": {
                            "local_base_path": "E:/",
                            "local_devops_path": "E:/devops",
                            "local_devops_artifacts_path": "E:/devops/artifacts",
                            "source_artifactory_json_file_loc": "https://artifactory.srv.westpac.com.au/artifactory/A009B6_WIBCLM/attributes/services.json",
                            "local_json_file_download_path": "E:/devops/artifacts/services.json",
                            "json_file_name": "services.json",
                            "servicename": \"${Service_Name}\",
                            "env_name": \"${Env_Name}\",
                            "Action": \"${StartStop}\",
                            "IIS": {
                                "service_type": "IIS",
                                "command": "iisreset"
                            },
                            "ActiveMQ": {
                                "service_type": "Windows Service"
                            },
                            "jbossfdim": {
                                "service_type": "Windows Service"
                            },
                            "JBossEAP7": {
                                "service_type": "Windows Service"
                            },
                            "ELKService": {
                                "service_type": "Windows Service"
                            }
                        }
                    }
                }
             """.stripIndent()
            )//writeFile  
        }// script
      }// steps
    }// Pre-requisties Setup
    stage('Upload Json'){
      steps{
        script{
          jsonObj = readFile (file: "${WORKSPACE}/services.json")
          //echo jsonObj

          // Upload to Artifact Config
          def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'ArtifactoryId'
          def uploadSpec = """{
             "files": [
                      {
                         "pattern": "${WORKSPACE}/services.json",
                         "target": "A009B6_WIBCLM/attributes/services.json"
                      }
                  ]
              }"""
          server.upload spec: uploadSpec
        }// script
      }// steps
    }// Upload Json
    stage('Trigger Job'){
      steps{
        script{
            // Trigger the pipeline
            appServer = Host_Name
            echo appServer
            json = "services.json"
            policyName = "a009b6_service_restart"
            triggerJob(policyName, appServer, json, DATA_BAG_SECRET)
            echoHighlightBanner("Please verify the Jenkins Downstream logs at below  ",["https://jenkins.srv.westpac.com.au/job/A00619_EntDevOps/job/OBM/job/OBM_Chef_Deployment/","Search for  in the left side navigation and select the downstream job near to the triggered time to view logs"])
        }// script
      }// steps
    }// Trigger Job

  }//Stages
}//Pipeline
