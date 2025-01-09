
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
            name: 'Action',
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
                                case "JBOSS":
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
          policyName = "a009b6-Service-Retsart"
          echoHighlightBanner("Input Parameters", ["Env_Name - ${Env_Name}", "ServerType - ${ServerType}", "Host_Name - ${Host_Name}", "Service - ${Service_Name}", "Action - ${Action}", "Policy - ${policyName}"])
          
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
                            "service": ${Service_Name},
                            "env_name": ${Env_Name},
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
                            "jbossEAP-7": {
                                "service_type": "Windows Service"
                            },
                            "JBossEAP-7": {
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
          echo jsonObj

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
            policyName = "a009b6-Service-Retsart"
            triggerJob(policyName, appServer, json, DATA_BAG_SECRET)
            echoHighlightBanner("Please verify the Jenkins Downstream logs at below  ",["https://jenkins.srv.westpac.com.au/job/A00619_EntDevOps/job/OBM/job/OBM_Chef_Deployment/","Search for  in the left side navigation and select the downstream job near to the triggered time to view logs"])
        }// script
      }// steps
    }// Trigger Job

  }//Stages
}//Pipeline


def frameServiceJson(Env_Name_From_Param){
  domain = ""
  account = ""
  password = ""
  switch (Env_Name_From_Param) {
    case "DEV":
      domain = "ESDEVAU"
      account = "SRVC_A009B6_0001_DEV"
      password = "W2azLE94qLdMNelpIYIMl1J70Ps3CvD3"
      break
    case "IAT1":
      domain = "ESTESTAU"
      account = "SRVC_A009B6_0002_TST"
      password = "2Aqi800MAbjTyoFD45Ifwc73TG0LhS32k8crXLNH"
      break
    case "IAT2":
      domain = "ESTESTAU"
      account = "SRVC_A009B6_0003_TST"
      password = "0DE1fEZ6Bxo3K226j61QAK0dY7dpow55nwD5Aye51dnnXy93cFYI"
      break
    case "IAT3":
      domain = "ESTESTAU"
      account = "SRVC_A009B6_0002_TST"
      password = "2Aqi800MAbjTyoFD45Ifwc73TG0LhS32k8crXLNH"
      break
    case "IAT4":
      domain = "ESTESTAU"
      account = "SRVC_A009B6_0008_TST"
      password = "-iEt9ussrMlvjbit"
      break
    case "IAT5":
      domain = "ESTESTAU"
      account = "SRVC_A009B6_0002_TST"
      password = "2Aqi800MAbjTyoFD45Ifwc73TG0LhS32k8crXLNH"
      break
    case "SVP":
      domain = "ESTESTAU"
      account = "SRVC_A009B6_0002_TST"
      password = "2Aqi800MAbjTyoFD45Ifwc73TG0LhS32k8crXLNH"
      break
    case "PROD":
      domain = "ESAU"
      account = "SRVC_A009B6_0001_PRD"
      password = "RSA5'jpbM5[cs3?"
      break
  }
 return [domain, account, password] 
}

def frameClmJson(Env_Name_From_Param){
  env = ""
  mcafeeconfig = ""
  webcrt = ""
  appcrt = ""
  appbrecrt = ""
  appfdimcert = ""
  switch (Env_Name_From_Param) {
    case "DEV":
      env = "dev"
      mcafeeconfig = "OnPrem-WP-DEV-WB-SRV"
      webcrt = "clm-web-dev.westpac.com.au.pfx"
      appcrt = "clm-app-dev.westpac.com.au.pfx"
      appbrecrt = ""
      appfdimcert = ""
      break
    case "IAT1":
      env = "iat"
      mcafeeconfig = "OnPrem-WP-TST-WB-SRV"
      webcrt = "clm-web-iat.westpac.com.au.pfx"
      appcrt = "clm-app-iat.westpac.com.au.pfx"
      appbrecrt = ""
      appfdimcert = ""
      break
    case "IAT2":
      env = "mig"
      mcafeeconfig = "OnPrem-WP-TST-WB-SRV"
      webcrt = "clm-web-mig.westpac.com.au.pfx"
      appcrt = "clm-app-mig.westpac.com.au.pfx"
      appbrecrt = ""
      appfdimcert = ""
      break
    case "IAT3":
      env = "iat2"
      mcafeeconfig = "OnPrem-WP-TST-WB-SRV"
      webcrt = "clm-web-iat2.westpac.com.au.pfx"
      appcrt = "clm-app-iat2.westpac.com.au.pfx"
      appbrecrt = ""
      appfdimcert = ""
      break
    case "IAT4":
      env = "iat4"
      mcafeeconfig = "OnPrem-WP-TST-WB-SRV"
      webcrt = "clm-web-iat4.westpac.com.au.pfx"
      appcrt = "clm-app-iat4.westpac.com.au.pfx"
      appbrecrt = ""
      appfdimcert = ""
      break
    case "IAT5":
      env = "iat5"
      mcafeeconfig = "OnPrem-WP-TST-WB-SRV"
      webcrt = "clm-web-iat5.westpac.com.au.pfx"
      appcrt = "clm-app-iat5.westpac.com.au.pfx"
      appbrecrt = ""
      appfdimcert = ""
      break
    case "SVP":
      env = "svp"
      mcafeeconfig = "OnPrem-WP-TST-WB-SRV"
      webcrt = "clm-web-svp.srv.westpac.com.au.pfx"
      appcrt = ""
      appbrecrt = "clm-appbre-svp.srv.westpac.com.au.pfx"
      appfdimcert = "clm-appfdim-svp.srv.westpac.com.au.pfx"
      break
    case "PROD":
      env = "dev"
      mcafeeconfig = "OnPrem-WP-PRD-WB-SRV"
      webcrt = "clm-web.srv.westpac.com.au.pfx"
      appcrt = ""
      appbrecrt = "clm-appbre-svp.srv.westpac.com.au.pfx"
      appfdimcert = "clm-appfdim-svp.srv.westpac.com.au.pfx"
      break
  }
  return [env, mcafeeconfig, webcrt, appcrt, appbrecrt, appfdimcert]
}

def frameConfigJson(Env_Name_From_Param){
  configname = ""
  modulesconfigname = ""
  databagname = ""
  switch (Env_Name_From_Param) {
    case "DEV":
      configname = "WBC_Fenergo_databanked_dev"
      modulesconfigname = "WBC_Fenergo_databanked_modules-dev"
      databagname = "a009b6_db_dev"
      break
    case "IAT1":
      configname = "WBC_Fenergo_databanked_iat"
      modulesconfigname = "WBC_Fenergo_databanked_modules_iat"
      databagname = "a009b6_db_iat"
      break
    case "IAT2":
      configname = "WBC_Fenergo_databanked_mig"
      modulesconfigname = "WBC_Fenergo_databanked_modules_mig"
      databagname = "a009b6_db_mig"
      break
    case "IAT3":
      configname = "WBC_Fenergo_databanked_iat2"
      modulesconfigname = "WBC_Fenergo_databanked_modules_iat2"
      databagname = "a009b6_db_iat2"
      break
    case "IAT4":
      configname = "WBC_Fenergo_databanked_iat4"
      modulesconfigname = "WBC_Fenergo_databanked_modules_iat4"
      databagname = "a009b6_db_iat4"
      break
    case "IAT5":
      configname = "WBC_Fenergo_databanked_iat5"
      modulesconfigname = "WBC_Fenergo_databanked_modules_iat5"
      databagname = "a009b6_db_iat5"
      break
    case "SVP":
      configname = "WBC_Fenergo_databanked_svp"
      modulesconfigname = "WBC_Fenergo_databanked_modules_svp"
      databagname = "a009b6_db_svp"
      break
    case "PROD":
      configname = "WBC_Fenergo_databanked_prd"
      modulesconfigname = "WBC_Fenergo_databanked_modules_prd"
      databagname = "a009b6_db_prd"
      break
  }
  return [configname, modulesconfigname, databagname]
}

def frameFenergoPackageJson(Env_Name_From_Param){
  fenergopackage_configname = ""
  fenergopackage_modulesconfigname = ""
  fenergopackage_canonicalconfigname = ""
  fenergopackage_databag_name = ""
  fenergopackage_certname = ""
  fenergopackage_app_cert = ""
  fenergopackage_activemq_cert = ""
  fenergopackage_appbre_cert = ""
  fenergopackage_appfdim_cert = ""
  switch (Env_Name_From_Param) {
    case "DEV":
      fenergopackage_configname = "WBC_Fenergo_databanked_dev"
      fenergopackage_modulesconfigname = "WBC_Fenergo_databanked_modules-dev"
      fenergopackage_canonicalconfigname = "WBC_Fenergo_databanked_Canonical-dev"
      fenergopackage_databag_name = "a009b6_db_dev"
      fenergopackage_certname = "clm-web-dev.westpac.com.au"
      fenergopackage_app_cert = "clm-app-dev.westpac.com.au"
      fenergopackage_activemq_cert = "clm-activemq-dev.westpac.com.au"
      fenergopackage_appbre_cert = ""
      fenergopackage_appfdim_cert = ""
      break
    case "IAT1":
      fenergopackage_configname = "WBC_Fenergo_databanked_iat"
      fenergopackage_modulesconfigname = "WBC_Fenergo_databanked_modules_iat"
      fenergopackage_canonicalconfigname = "WBC_Fenergo_databanked_canonical_iat"
      fenergopackage_databag_name = "a009b6_db_iat"
      fenergopackage_certname = "clm-web-iat.westpac.com.au"
      fenergopackage_app_cert = "clm-app-iat.westpac.com.au"
      fenergopackage_activemq_cert = "clm-activemq-iat.westpac.com.au"
      fenergopackage_appbre_cert = ""
      fenergopackage_appfdim_cert = ""
      break
    case "IAT2":
      fenergopackage_configname = "WBC_Fenergo_databanked_mig"
      fenergopackage_modulesconfigname = "WBC_Fenergo_databanked_modules_mig"
      fenergopackage_canonicalconfigname = "WBC_Fenergo_databanked_canonical_mig"
      fenergopackage_databag_name = "a009b6_db_mig"
      fenergopackage_certname = "clm-web-mig.westpac.com.au"
      fenergopackage_app_cert = "clm-app-mig.westpac.com.au"
      fenergopackage_activemq_cert = "clm-activemq-mig.westpac.com.au"
      fenergopackage_appbre_cert = ""
      fenergopackage_appfdim_cert = ""
      break
    case "IAT3":
      fenergopackage_configname = "WBC_Fenergo_databanked_iat2"
      fenergopackage_modulesconfigname = "WBC_Fenergo_databanked_modules_iat2"
      fenergopackage_canonicalconfigname = "WBC_Fenergo_databanked_canonical_iat2"
      fenergopackage_databag_name = "a009b6_db_iat2"
      fenergopackage_certname = "clm-web-iat2.westpac.com.au"
      fenergopackage_app_cert = "clm-app-iat2.westpac.com.au"
      fenergopackage_activemq_cert = "clm-activemq-iat2.westpac.com.au"
      fenergopackage_appbre_cert = ""
      fenergopackage_appfdim_cert = ""
      break
    case "IAT4":
      fenergopackage_configname = "WBC_Fenergo_databanked_iat4"
      fenergopackage_modulesconfigname = "WBC_Fenergo_databanked_modules_iat4"
      fenergopackage_canonicalconfigname = "WBC_Fenergo_databanked_canonical_iat4"
      fenergopackage_databag_name = "a009b6_db_iat4"
      fenergopackage_certname = "clm-web-iat4.westpac.com.au"
      fenergopackage_app_cert = "clm-app-iat4.westpac.com.au"
      fenergopackage_activemq_cert = "clm-activemq-iat4.westpac.com.au"
      fenergopackage_appbre_cert = ""
      fenergopackage_appfdim_cert = ""
      break
    case "IAT5":
      fenergopackage_configname = "WBC_Fenergo_databanked_iat5"
      fenergopackage_modulesconfigname = "WBC_Fenergo_databanked_modules_iat5"
      fenergopackage_canonicalconfigname = ""
      fenergopackage_databag_name = "a009b6_db_iat5"
      fenergopackage_certname = "clm-web-iat5.westpac.com.au"
      fenergopackage_app_cert = "clm-app-iat5.westpac.com.au"
      fenergopackage_activemq_cert = "clm-activemq-iat5.westpac.com.au"
      fenergopackage_appbre_cert = ""
      fenergopackage_appfdim_cert = ""
      break
    case "SVP":
      fenergopackage_configname = "WBC_Fenergo_databanked_svp"
      fenergopackage_modulesconfigname = "WBC_Fenergo_databanked_modules_svp"
      fenergopackage_canonicalconfigname = "WBC_Fenergo_databanked_canonical_svp"
      fenergopackage_databag_name = "a009b6_db_svp"
      fenergopackage_certname = "clm-web-svp.srv.westpac.com.au"
      fenergopackage_app_cert = ""
      fenergopackage_activemq_cert = ""
      fenergopackage_appbre_cert = "clm-appbre-svp.srv.westpac.com.au"
      fenergopackage_appfdim_cert = "clm-appfdim-svp.srv.westpac.com.au"
      break
    case "PROD":
      fenergopackage_configname = "WBC_Fenergo_databanked_prd"
      fenergopackage_modulesconfigname = "WBC_Fenergo_databanked_modules_prd"
      fenergopackage_canonicalconfigname = "WBC_Fenergo_databanked_canonical_prd"
      fenergopackage_databag_name = "a009b6_db_prd"
      fenergopackage_certname = "clm-web.srv.westpac.com.au"
      fenergopackage_app_cert = ""
      fenergopackage_activemq_cert = ""
      fenergopackage_appbre_cert = "clm-appbre.srv.westpac.com.au"
      fenergopackage_appfdim_cert = "clm-appfdim.srv.westpac.com.au"
      break
  }
  return [fenergopackage_configname, fenergopackage_modulesconfigname, fenergopackage_canonicalconfigname, fenergopackage_databag_name, fenergopackage_certname, fenergopackage_app_cert, fenergopackage_activemq_cert, fenergopackage_appbre_cert, fenergopackage_appfdim_cert]
}

def frameFenergoPackage_PackageName(PackageType, ServerType, PackageName){
  fenergopackage_name = ""
  fenergopackage_modulesname = ""
  fenergopackage_canonicalname = ""
  if ((PackageType == "Main") && (ServerType == "WebServer")){
    fenergopackage_name = PackageName
    fenergopackage_modulesname = ""
    fenergopackage_canonicalname = ""
  }else if ((PackageType == "Module") && (ServerType == "WebServer")){
    fenergopackage_name = ""
    fenergopackage_modulesname = PackageName
    fenergopackage_canonicalname = ""
  }else if ((PackageType == "Canonical") && (ServerType == "WebServer")){
    fenergopackage_name = ""
    fenergopackage_modulesname = ""
    fenergopackage_canonicalname = PackageName
  }
  echo fenergopackage_name
  echo fenergopackage_modulesname
  echo fenergopackage_canonicalname
  return [fenergopackage_name, fenergopackage_modulesname, fenergopackage_canonicalname]
}

def frameFDIMPackage_PackageName(PackageType, ServerType, PackageName){
  fdimpackage_name = ""
  fdimpackage_modulesname = ""
  if ((PackageType == "Main") && (ServerType == "MiddlewareServer")){
    fdimpackage_name = PackageName
    fdimpackage_modulesname = ""
  }else if ((PackageType == "Module") && (ServerType == "MiddlewareServer")){
    fdimpackage_name = ""
    fdimpackage_modulesname = PackageName
  }
  return [fdimpackage_name, fdimpackage_modulesname]
}

def frameELKPackage_PackageName(PackageType, ServerType, PackageName){
  elkpackage_name = ""
  if ((PackageType == "Main") && (ServerType == "ELKServer")){
    elkpackage_name = PackageName
  }
  return [elkpackage_name]
}

// Middleware - Other variables update
def frameFDIMPackage_ActiveMq_jBoss_Clm_Java_Config(Env_Name_From_Param){

  switch (Env_Name_From_Param) {
    case "DEV":
      activemq_jdbc_url = "au2106sde937:1435"
      activemq_keyStore = "clm-activemq-dev.westpac.com.au.jks"
      activemq_keyStorealias = "clm-activemq-dev.westpac.com.au"
      jboss_keyStore = "clm-app-dev.westpac.com.au.jks"
      jboss_keyStorealias = "clm-app-dev.westpac.com.au"
      clm_certpassword = "h3P7azgGJM01UPD"
      clm_env = "dev"
      java_home = "E:/Fenergo/Java/jdk-11.0.9"
      fdim_configname = "WBC_Fenergo_databanked_dev"
      fdim_tokens = ["configuration/tokens/token", "configuration/deployment/web/apps/app/applicationPool/section/applicationPoolIdentity/setting", "configuration/deployment/components/component/properties/servers/server/parameters/parameter"]
      fdim_databag_name = "a009b6_db_dev"
      fdim_common_domain = "estestau.wbctestau.westpac.com.au"
      fdim_certname = "clm-web-dev.westpac.com.au"
      fdim_app_cert = "clm-app-dev.westpac.com.au"
      fdim_activemq_cert = "clm-activemq-dev.westpac.com.au"
      break
    case "IAT1":
      activemq_jdbc_url = "AU2106STE1018:1435"
      activemq_keyStore = "clm-activemq-iat.westpac.com.au.jks"
      activemq_keyStorealias = "clm-activemq-iat.westpac.com.au"
      jboss_keyStore = "clm-app-iat.westpac.com.au.jks"
      jboss_keyStorealias = "clm-app-iat.westpac.com.au"
      clm_certpassword = "h3P7azgGJM01UPD"
      clm_env = "iat"
      java_home = "E:/Fenergo/Java/jdk-11.0.9"
      fdim_configname = "WBC_Fenergo_databanked_iat"
      fdim_tokens = ["configuration/tokens/token", "configuration/deployment/web/apps/app/applicationPool/section/applicationPoolIdentity/setting", "configuration/deployment/components/component/properties/servers/server/parameters/parameter"]
      fdim_databag_name = "a009b6_db_iat"
      fdim_common_domain = "estestau.wbctestau.westpac.com.au"
      fdim_certname = "clm-web-iat.westpac.com.au"
      fdim_app_cert = "clm-app-iat.westpac.com.au"
      fdim_activemq_cert = "clm-activemq-iat.westpac.com.au"
      break
    case "IAT2":
      activemq_jdbc_url = "AU2106STE1018:1435"
      activemq_keyStore = "clm-activemq-mig.westpac.com.au.jks"
      activemq_keyStorealias = "clm-activemq-mig.westpac.com.au"
      jboss_keyStore = "clm-app-mig.westpac.com.au.jks"
      jboss_keyStorealias = "clm-app-mig.westpac.com.au"
      clm_certpassword = "h3P7azgGJM01UPD"
      clm_env = "mig"
      java_home = "E:/Fenergo/Java/jdk-11.0.9"
      fdim_configname = "WBC_Fenergo_databanked_mig"
      fdim_tokens = ["configuration/tokens/token", "configuration/deployment/web/apps/app/applicationPool/section/applicationPoolIdentity/setting", "configuration/deployment/components/component/properties/servers/server/parameters/parameter"]
      fdim_databag_name = "a009b6_db_mig"
      fdim_common_domain = "estestau.wbctestau.westpac.com.au"
      fdim_certname = "clm-web-mig.westpac.com.au"
      fdim_app_cert = "clm-app-mig.westpac.com.au"
      fdim_activemq_cert = "clm-activemq-mig.westpac.com.au"
      break
    case "IAT3":
      activemq_jdbc_url = "TWD200929111815:1435"
      activemq_keyStore = "clm-activemq-iat2.westpac.com.au.jks"
      activemq_keyStorealias = "clm-activemq-iat2.westpac.com.au"
      jboss_keyStore = "clm-app-iat2.westpac.com.au.jks"
      jboss_keyStorealias = "clm-app-iat2.westpac.com.au"
      clm_certpassword = "h3P7azgGJM01UPD"
      clm_env = "iat2"
      java_home = "E:/Fenergo/Java/jdk-11.0.9"
      fdim_configname = "WBC_Fenergo_databanked_iat2"
      fdim_tokens = ["configuration/tokens/token", "configuration/deployment/web/apps/app/applicationPool/section/applicationPoolIdentity/setting", "configuration/deployment/components/component/properties/servers/server/parameters/parameter"]
      fdim_databag_name = "a009b6_db_iat2"
      fdim_common_domain = "estestau.wbctestau.westpac.com.au"
      fdim_certname = "clm-web-iat2.westpac.com.au"
      fdim_app_cert = "clm-app-iat2.westpac.com.au"
      fdim_activemq_cert = "clm-activemq-iat2.westpac.com.au"
      break
    case "IAT4":
      activemq_jdbc_url = "TWD210504184535:1435"
      activemq_keyStore = "clm-activemq-iat4.westpac.com.au.jks"
      activemq_keyStorealias = "clm-activemq-iat4.westpac.com.au"
      jboss_keyStore = "clm-app-iat4.westpac.com.au.jks"
      jboss_keyStorealias = "clm-app-iat4.westpac.com.au"
      clm_certpassword = "h3P7azgGJM01UPD"
      clm_env = "iat4"
      java_home = "E:/Fenergo/Java/jdk-11.0.9"
      fdim_configname = "WBC_Fenergo_databanked_iat4"
      fdim_tokens = ["configuration/tokens/token", "configuration/deployment/web/apps/app/applicationPool/section/applicationPoolIdentity/setting", "configuration/deployment/components/component/properties/servers/server/parameters/parameter"]
      fdim_databag_name = "a009b6_db_iat4"
      fdim_common_domain = "estestau.wbctestau.westpac.com.au"
      fdim_certname = "clm-web-iat4.westpac.com.au"
      fdim_app_cert = "clm-app-iat4.westpac.com.au"
      fdim_activemq_cert = "clm-activemq-iat4.westpac.com.au"
      break
    case "IAT5":
      activemq_jdbc_url = "TWD210504184535:1435"
      activemq_keyStore = "clm-activemq-iat5.westpac.com.au.jks"
      activemq_keyStorealias = "clm-activemq-iat5.westpac.com.au"
      jboss_keyStore = "clm-app-iat5.westpac.com.au.jks"
      jboss_keyStorealias = "clm-app-iat5.westpac.com.au"
      clm_certpassword = "h3P7azgGJM01UPD"
      clm_env = "iat5"
      java_home = "E:/Fenergo/Java/jdk-11.0.9"
      fdim_configname = "WBC_Fenergo_databanked_iat5"
      fdim_tokens = ["configuration/tokens/token", "configuration/deployment/web/apps/app/applicationPool/section/applicationPoolIdentity/setting", "configuration/deployment/components/component/properties/servers/server/parameters/parameter"]
      fdim_databag_name = "a009b6_db_iat5"
      fdim_common_domain = "estestau.wbctestau.westpac.com.au"
      fdim_certname = "clm-web-iat5.westpac.com.au"
      fdim_app_cert = "clm-app-iat5.westpac.com.au"
      fdim_activemq_cert = "clm-activemq-iat5.westpac.com.au"
      break
    case "SVP":
      activemq_jdbc_url = "AU2004ITE458.estestau.wbctestau.westpac.com.au:61435"
      activemq_keyStore = "clm-activemqlistener-svp.srv.westpac.com.au.jks"
      activemq_keyStorealias = "clm-activemqlistener-svp.srv.westpac.com.au"
      jboss_keyStore = "clm-appfdim-svp.srv.westpac.com.au.jks"
      jboss_keyStorealias = "clm-appfdim-svp.srv.westpac.com.au"
      clm_certpassword = "h3P7azgGJM01UPD"
      clm_env = "svp"
      java_home = "E:/Fenergo/Java/jdk-11.0.9"
      fdim_configname = "WBC_Fenergo_databanked_svp"
      fdim_tokens = ["configuration/tokens/token", "configuration/deployment/web/apps/app/applicationPool/section/applicationPoolIdentity/setting", "configuration/deployment/components/component/properties/servers/server/parameters/parameter"]
      fdim_databag_name = "a009b6_db_svp"
      fdim_common_domain = "estestau.wbctestau.westpac.com.au"
      fdim_certname = "clm-web-svp.srv.westpac.com.au"
      fdim_app_cert = "clm-appfdim-svp.srv.westpac.com.au"
      fdim_activemq_cert = "clm-activemqlistener-svp.srv.westpac.com.au"
      break
    case "PROD":
      activemq_jdbc_url = "AU2004IPE826.esau.wbcau.westpac.com.au:61435"
      activemq_keyStore = "clm-activemqlistener.srv.westpac.com.au.jks"
      activemq_keyStorealias = "clm-activemqlistener.srv.westpac.com.au"
      jboss_keyStore = "clm-appfdim.srv.westpac.com.au.jks"
      jboss_keyStorealias = "clm-appfdim.srv.westpac.com.au"
      clm_certpassword = "h3P7azgGJM01UPD"
      clm_env = "prd"
      java_home = "E:/Fenergo/Java/jdk-11.0.9"
      fdim_configname = "WBC_Fenergo_databanked_prd"
      fdim_tokens = ["configuration/tokens/token", "configuration/deployment/web/apps/app/applicationPool/section/applicationPoolIdentity/setting", "configuration/deployment/components/component/properties/servers/server/parameters/parameter"]
      fdim_databag_name = "a009b6_db_prd"
      fdim_common_domain = "estestau.wbctestau.westpac.com.au"
      fdim_certname = "clm-web.srv.westpac.com.au"
      fdim_app_cert = "clm-appfdim.srv.westpac.com.au"
      fdim_activemq_cert = "clm-activemqlistener.srv.westpac.com.au"
      break
  }
  return [activemq_jdbc_url, activemq_keyStore, activemq_keyStorealias, jboss_keyStore, jboss_keyStorealias, clm_certpassword, clm_env, java_home, fdim_configname, fdim_tokens, fdim_databag_name, fdim_common_domain, fdim_certname, fdim_app_cert, fdim_activemq_cert]
}
 
// Middleware - Other variables update
def frameELKPackage_Config(Env_Name_From_Param){
    switch (Env_Name_From_Param) {
    case "DEV":
      elk_nodename = "clm-elasticnode-dev"
      elk_keyStore = "clm-elasticsearch-dev.westpac.com.au.pfx"
      elk_keyStorealias = "clm-elasticsearch-dev.westpac.com.au"
      elk_keyStorepassword = "h3P7azgGJM01UPD"
      elk_elasticsearch = "clm-elasticsearch-dev.westpac.com.au.pfx"
      elk_truststore = "WBC-Internal-Trust-Chain.pfx"
      elk_ElasticSearchCaCert = "Westpac_SHA2_Root-SSL_CA_WSDC.crt"
      elk_truststorealias = "westpac sha2 root ca wsdc"
      elk_truststore_password = "WBC-Internal-Trust-Chain"
      elk_searchguard = "clm-searchguard-dev.westpac.com.au"
      elk_WBC_Internal = "WBC-Internal-Trust-Chain.jks"
      elk_ElasticSearchUrl = "https://clm-elasticsearch-dev.westpac.com.au:9200"
      elk_discoveryhost = ""
      filebeat_logstashhost = "clm-elasticsearch-dev.westpac.com.au:5044"
      filebeat_ElasticSearchUrl = "https://clm-elasticsearch-dev.westpac.com.au:9200"
      kibana_serverhost = "clm-elasticsearch-dev.westpac.com.au"
      kibana_ElasticSearchUrl = "https://clm-elasticsearch-dev.westpac.com.au:9200"
      jdbcConnectionString = "au2106sde937:1435"
      elasticSearchTruststorePassword = "WBC-Internal-Trust-Chain"
      elkPackage_ElasticSearchUrl = "https://clm-elasticnode-dev.westpac.com.au:9200"
      break
    case "IAT1":
      elk_nodename = "clm-elasticnode-iat"
      elk_keyStore = "clm-elasticsearch-iat.westpac.com.au.pfx"
      elk_keyStorealias = "clm-elasticsearch-iat.westpac.com.au"
      elk_keyStorepassword = "h3P7azgGJM01UPD"
      elk_elasticsearch = "clm-elasticsearch-iat.westpac.com.au.pfx"
      elk_truststore = "WBC-Internal-Trust-Chain.pfx"
      elk_ElasticSearchCaCert = "Westpac_SHA2_Root-SSL_CA_WSDC.crt"
      elk_truststorealias = "westpac sha2 root ca wsdc"
      elk_truststore_password = "WBC-Internal-Trust-Chain"
      elk_searchguard = "clm-searchguard-iat.westpac.com.au"
      elk_WBC_Internal = "WBC-Internal-Trust-Chain.jks"
      elk_ElasticSearchUrl = "https://clm-elasticsearch-iat.westpac.com.au:9200"
      elk_discoveryhost = ""
      filebeat_logstashhost = "clm-elasticsearch-iat.westpac.com.au:5044"
      filebeat_ElasticSearchUrl = "https://clm-elasticsearch-iat.westpac.com.au:9200"
      kibana_serverhost = "clm-elasticsearch-iat.westpac.com.au"
      kibana_ElasticSearchUrl = "https://clm-elasticsearch-iat.westpac.com.au:9200"
      jdbcConnectionString = "AU2106STE1018:1435"
      elasticSearchTruststorePassword = "WBC-Internal-Trust-Chain"
      elkPackage_ElasticSearchUrl = "https://clm-elasticnode-iat.westpac.com.au:9200"
      break
    case "IAT2":
      elk_nodename = "clm-elasticnode-mig"
      elk_keyStore = "clm-elasticsearch-mig.westpac.com.au.pfx"
      elk_keyStorealias = "clm-elasticsearch-mig.westpac.com.au"
      elk_keyStorepassword = "h3P7azgGJM01UPD"
      elk_elasticsearch = "clm-elasticsearch-mig.westpac.com.au.pfx"
      elk_truststore = "WBC-Internal-Trust-Chain.pfx"
      elk_ElasticSearchCaCert = "Westpac_SHA2_Root-SSL_CA_WSDC.crt"
      elk_truststorealias = "westpac sha2 root ca wsdc"
      elk_truststore_password = "WBC-Internal-Trust-Chain"
      elk_searchguard = "clm-searchguard-mig.westpac.com.au"
      elk_WBC_Internal = "WBC-Internal-Trust-Chain.jks"
      elk_ElasticSearchUrl = "https://clm-elasticsearch-mig.westpac.com.au:9200"
      elk_discoveryhost = ""
      filebeat_logstashhost = "clm-elasticsearch-mig.westpac.com.au:5044"
      filebeat_ElasticSearchUrl = "https://clm-elasticsearch-mig.westpac.com.au:9200"
      kibana_serverhost = "clm-elasticsearch-mig.westpac.com.au"
      kibana_ElasticSearchUrl = "https://clm-elasticsearch-mig.westpac.com.au:9200"
      jdbcConnectionString = "AU2106STE1018:1435"
      elasticSearchTruststorePassword = "WBC-Internal-Trust-Chain"
      elkPackage_ElasticSearchUrl = "https://clm-elasticnode-mig.westpac.com.au:9200"
      break
    case "IAT3":
      elk_nodename = "clm-elasticnode-iat2"
      elk_keyStore = "clm-elasticsearch-iat2.westpac.com.au.pfx"
      elk_keyStorealias = "clm-elasticsearch-iat2.westpac.com.au"
      elk_keyStorepassword = "h3P7azgGJM01UPD"
      elk_elasticsearch = "clm-elasticsearch-iat2.westpac.com.au.pfx"
      elk_truststore = "WBC-Internal-Trust-Chain.pfx"
      elk_ElasticSearchCaCert = "Westpac_SHA2_Root-SSL_CA_WSDC.crt"
      elk_truststorealias = "westpac sha2 root ca wsdc"
      elk_truststore_password = "WBC-Internal-Trust-Chain"
      elk_searchguard = "clm-searchguard-iat2.westpac.com.au"
      elk_WBC_Internal = "WBC-Internal-Trust-Chain.jks"
      elk_ElasticSearchUrl = "https://clm-elasticsearch-iat2.westpac.com.au:9200"
      elk_discoveryhost = ""
      filebeat_logstashhost = "clm-elasticsearch-iat2.westpac.com.au:5044"
      filebeat_ElasticSearchUrl = "https://clm-elasticsearch-iat2.westpac.com.au:9200"
      kibana_serverhost = "clm-elasticsearch-iat2.westpac.com.au"
      kibana_ElasticSearchUrl = "https://clm-elasticsearch-iat2.westpac.com.au:9200"
      jdbcConnectionString = "TWD200929111815:1435"
      elasticSearchTruststorePassword = "WBC-Internal-Trust-Chain"
      elkPackage_ElasticSearchUrl = "https://clm-elasticnode-iat2.westpac.com.au:9200"
      break
    case "IAT4":
      elk_nodename = "clm-elasticnode-iat4"
      elk_keyStore = "clm-elasticsearch-iat4.westpac.com.au.pfx"
      elk_keyStorealias = "clm-elasticsearch-iat4.westpac.com.au"
      elk_keyStorepassword = "h3P7azgGJM01UPD"
      elk_elasticsearch = "clm-elasticsearch-iat4.westpac.com.au.pfx"
      elk_truststore = "WBC-Internal-Trust-Chain.pfx"
      elk_ElasticSearchCaCert = "Westpac_SHA2_Root-SSL_CA_WSDC.crt"
      elk_truststorealias = "westpac sha2 root ca wsdc"
      elk_truststore_password = "WBC-Internal-Trust-Chain"
      elk_searchguard = "clm-searchguard-iat4.westpac.com.au"
      elk_WBC_Internal = "WBC-Internal-Trust-Chain.jks"
      elk_ElasticSearchUrl = "https://clm-elasticsearch-iat4.westpac.com.au:9200"
      elk_discoveryhost = ""
      filebeat_logstashhost = "clm-elasticsearch-iat4.westpac.com.au:5044"
      filebeat_ElasticSearchUrl = "https://clm-elasticsearch-iat4.westpac.com.au:9200"
      kibana_serverhost = "clm-elasticsearch-iat4.westpac.com.au"
      kibana_ElasticSearchUrl = "https://clm-elasticsearch-iat4.westpac.com.au:9200"
      jdbcConnectionString = "TWD210504184535:1435"
      elasticSearchTruststorePassword = "WBC-Internal-Trust-Chain"
      elkPackage_ElasticSearchUrl = "https://clm-elasticnode-iat4.westpac.com.au:9200"
      break
    case "IAT5":
      elk_nodename = "clm-elasticnode-iat5"
      elk_keyStore = "clm-elasticsearch-iat5.westpac.com.au.pfx"
      elk_keyStorealias = "clm-elasticsearch-iat5.westpac.com.au"
      elk_keyStorepassword = "h3P7azgGJM01UPD"
      elk_elasticsearch = "clm-elasticsearch-iat5.westpac.com.au.pfx"
      elk_truststore = "WBC-Internal-Trust-Chain.pfx"
      elk_ElasticSearchCaCert = "Westpac_SHA2_Root-SSL_CA_WSDC.crt"
      elk_truststorealias = "westpac sha2 root ca wsdc"
      elk_truststore_password = "WBC-Internal-Trust-Chain"
      elk_searchguard = "clm-searchguard-iat5.westpac.com.au"
      elk_WBC_Internal = "WBC-Internal-Trust-Chain.jks"
      elk_ElasticSearchUrl = "https://clm-elasticsearch-iat5.westpac.com.au:9200"
      elk_discoveryhost = ""
      filebeat_logstashhost = "clm-elasticsearch-iat5.westpac.com.au:5044"
      filebeat_ElasticSearchUrl = "https://clm-elasticsearch-iat5.westpac.com.au:9200"
      kibana_serverhost = "clm-elasticsearch-iat5.westpac.com.au"
      kibana_ElasticSearchUrl = "https://clm-elasticsearch-iat5.westpac.com.au:9200"
      jdbcConnectionString = "TWD210504184535:1435"
      elasticSearchTruststorePassword = "WBC-Internal-Trust-Chain"
      elkPackage_ElasticSearchUrl = "https://clm-elasticnode-iat5.westpac.com.au:9200"
      break
    case "SVP":
      elk_nodename = "node23"
      elk_keyStore = "clm-elasticsearch-svp.srv.westpac.com.au.pfx"
      elk_keyStorealias = "clm-elasticsearch-svp.srv.westpac.com.au"
      elk_keyStorepassword = "h3P7azgGJM01UPD"
      elk_elasticsearch = "clm-elasticsearch-svp.srv.westpac.com.au.pfx"
      elk_truststore = "WBC-Internal-Trust-Chain.pfx"
      elk_ElasticSearchCaCert = "Westpac_SHA2_Root-SSL_CA_WSDC.crt"
      elk_truststorealias = "westpac sha2 root ca wsdc"
      elk_truststore_password = "WBC-Internal-Trust-Chain"
      elk_searchguard = ""
      elk_WBC_Internal = "WBC-Internal-Trust-Chain.jks"
      elk_ElasticSearchUrl = ""
      elk_discoveryhost = ["10.104.176.114", "10.104.176.113", "10.104.176.112"]
      filebeat_logstashhost = ""
      filebeat_ElasticSearchUrl = ""
      kibana_serverhost = ""
      kibana_ElasticSearchUrl = ""
      jdbcConnectionString = "AU2004ITE458.estestau.wbctestau.westpac.com.au:61435"
      elasticSearchTruststorePassword = "WBC-Internal-Trust-Chain"
      elkPackage_ElasticSearchUrl = "https://clm-elasticsearch-svp.srv.westpac.com.au:9200"
      break
    case "PROD":
      elk_nodename = "node11"
      elk_keyStore = "clm-elasticsearch.srv.westpac.com.au.pfx"
      elk_keyStorealias = "clm-elasticsearch.srv.westpac.com.au"
      elk_keyStorepassword = "h3P7azgGJM01UPD"
      elk_elasticsearch = "clm-elasticsearch.srv.westpac.com.au.pfx"
      elk_truststore = "WBC-Internal-Trust-Chain.pfx"
      elk_ElasticSearchCaCert = "Westpac_SHA2_Root-SSL_CA_WSDC.crt"
      elk_truststorealias = "westpac sha2 root ca wsdc"
      elk_truststore_password = "WBC-Internal-Trust-Chain"
      elk_searchguard = ""
      elk_WBC_Internal = "WBC-Internal-Trust-Chain.jks"
      elk_ElasticSearchUrl = ""
      elk_discoveryhost = ["10.100.240.157", "10.100.240.163", "10.100.240.168"]
      filebeat_logstashhost = ""
      filebeat_ElasticSearchUrl = ""
      kibana_serverhost = ""
      kibana_ElasticSearchUrl = ""
      jdbcConnectionString = "AU2004IPE826.esau.wbcau.westpac.com.au:61435"
      elasticSearchTruststorePassword = "WBC-Internal-Trust-Chain"
      elkPackage_ElasticSearchUrl = "https://clm-elasticsearch.srv.westpac.com.au:9200"
      break
    }
    return [elk_nodename, elk_keyStore, elk_keyStorealias, elk_keyStorepassword, elk_elasticsearch, elk_truststore, elk_ElasticSearchCaCert, elk_truststorealias, elk_truststore_password, elk_searchguard, elk_WBC_Internal, elk_ElasticSearchUrl, elk_discoveryhost, filebeat_logstashhost, filebeat_ElasticSearchUrl, kibana_serverhost, kibana_ElasticSearchUrl, jdbcConnectionString, elasticSearchTruststorePassword, elkPackage_ElasticSearchUrl]
}