import org.apache.commons.io.FilenameUtils

def echoBanner(def ... msgs) {
   echo createBanner(msgs)
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

def triggerJob(encryptedKey, namedRunList, policyName, appServer, json){
  // -------------------------- TRIGGER THE PIPELINE  --------------------//  
  final parentJobResult =  build job: 'A00232_Credient/Non-Prod/Chef_OnDemand_NonProd_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'), 
    string(name: 'SERVER_LABEL', value: "${appServer}"), 
    string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), 
    string(name: 'POLICY_NAME', value: "${policyName}"), 
    string(name: 'POLICY_GROUP', value: 'default'),
    string(name: 'ENCRYPTED_DATA_BAG_SECRET', value: "${encryptedKey}"),
    string(name: 'NAMED_RUNLIST', value: "${namedRunList}"),
    string(name: 'OVERRIDE_ATTRIBUTES_FILE', value: "${json}")]
  // echo "Current Build number is ${currentBuild.number}"
  // echo "parentJobResult number: ${parentJobResult.number}"
}
def triggerJobWithoutJson(encryptedKey, namedRunList, policyName, appServer){
  // -------------------------- TRIGGER THE PIPELINE  --------------------//  
  final parentJobResult =  build job: 'A00232_Credient/Non-Prod/Chef_OnDemand_NonProd_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'), 
    string(name: 'SERVER_LABEL', value: "${appServer}"), 
    string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), 
    string(name: 'POLICY_NAME', value: "${policyName}"), 
    string(name: 'POLICY_GROUP', value: 'default'), 
    string(name: 'ENCRYPTED_DATA_BAG_SECRET', value: "${encryptedKey}"),
    string(name: 'NAMED_RUNLIST', value: "${namedRunList}")]
  // echo "Current Build number is ${currentBuild.number}"
  // echo "parentJobResult number: ${parentJobResult.number}"
}


pipeline {
  // agent any
  agent {
        node {
          label 'enterprise_devops&&linux'
        }
      }
  
  environment {
    JAVA_HOME = '/data/java/jdk1.8.0_73'
  }
  parameters {
    choice(name: 'software', choices: [
      'reflection_client',
      'reflection_server',
      '7zip',
      'Notepad++',
      'Putty',
      'SqlClient2022',
      'ControlM',
      'WinSCP'
      ], description: 'Choose the Software')
    choice(name: 'Env_Name', choices: ['DEV','SIT','UAT'], description: 'Choose the Environment Name')
  }

  stages {    
    stage("Pre-requisties Setup") {
      steps {
        script {
          echoBanner("Software to be Installed","Software Name : ${software}","Environment Name : ${Env_Name}")
          def jsonRequiredSoftwares = ['reflection_client','reflection_server','7zip','Notepad++','Putty','WinSCP']
          // Json update
          if (software in jsonRequiredSoftwares){
            windows_softwares_list = ["${software}"]
            List softwareList = windows_softwares_list.collect{ '"' + it + '"'}

            // Prepare install_uninstall.json
            writeFile (file: "${WORKSPACE}/install_uninstall.json" ,
                  text: """\
                  {"wbg_a00232_riskscape": {
                        "artifactory": {
                            "repo": "https://artifactory.srv.westpac.com.au/artifactory/A00232_RSKSP/"
                        },
                        "current_package_version": "0.1.25",
                        "appid": "a00232",
                        "pipeline_type": "install_uninstall",
                        "install_uninstall": {
                            "local_base_path": "E:/",
                            "local_devops_path": "E:/devops",
                            "local_devops_artifacts_path": "E:/devops/artifacts",
                            "local_devops_powershell_scripts_path": "E:/devops/powershell_scripts",
                            "local_devops_sql_scripts_path": "E:/devops/sql_scripts",
                            "local_devops_windows_softwares_path": "E:/devops/windows_softwares",
                            "source_artifactory_json_file_loc": "https://artifactory.srv.westpac.com.au/artifactory/A00232_RSKSP/Attributes/install_uninstall.json",
                            "local_json_file_download_path": "E:/devops/artifacts/install_uninstall.json",
                            "json_file_name": "install_uninstall.json",
                            "ps_file_list": [
                                "reflection_client.ps1",
                                "reflection_server.ps1",
                                "WinSCP.ps1"
                            ],
                            "ps_sw": [
                                "reflection_client",
                                "reflection_server",
                                "WinSCP"
                            ],
                            "windows_softwares_list": ${softwareList},
                            "7zip": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A00232_RSKSP/Softwares/7z2404-x64.exe",
                                "package_name": "7z2404-x64.exe",
                                "package_type": "exe",
                                "options_list": "/S /D=\\"E:/Program Files/7-Zip\\""
                            },
                            "Notepad++": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A00232_RSKSP/Softwares/npp.8.4.9.Installer.x64.exe",
                                "package_name": "npp.8.4.9.Installer.x64.exe ",
                                "package_type": "exe",
                                "options_list": "/S /D=E:\\\\Program Files\\\\Notepad++"
                            },
                            "Putty": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A00232_RSKSP/Softwares/putty-64bit-0.81-installer.msi",
                                "package_name": "putty-64bit-0.81-installer.msi",
                                "package_type": "msi",
                                "options_list": "INSTALLDIR=\\"E:\\\\Program Files\\\\Putty\\" /qn /L*V C:/temp/Putty.log"
                            }
                        },
                        "services_start_stop": {},
                        "sql_deployment": {},
                        "sqlserver_install": {},
                        "database_refresh": {},
                        "windows_pipeline": {}
                    }
                }
             """.stripIndent()
            )//writeFile

            // Push to artifactory
            def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'Art_Cred'
            def artifact_sub_path = "A00232_RSKSP"
            def uploadSpec = """{
                    "files": [{
                       "pattern": "${WORKSPACE}/install_uninstall.json",
                       "target": "${artifact_sub_path}/Attributes/",
                            "props": "type=json;status=ready"
                    }]
                 }"""
                 //server.upload spec: uploadSpec 
                 server.upload(uploadSpec)

          }//json update required softwares

          
        }//script
      }//steps
    }//Software Installation Stage
    stage("Run Installation") {
      steps {
        script {
          // echoHeader([" Run Installation on ${Env_Name} "])
          appServer = constructTargetServer(Env_Name)
          (namedRunList, jsonRequired) = constructNamedRunList(software)
          policyName = "a00232_installables"
          if(jsonRequired){
            json = "install_uninstall.json"
            echoBanner("Trigger Job","namedRunList: ${namedRunList}","policyName: ${policyName}","appServer: ${appServer}")
            withCredentials([string(credentialsId: 'enckey', variable: 'enckey')]) {
              triggerJob(enckey, namedRunList, policyName, appServer, json)
            }
          }
          else{
            echoBanner("Trigger Job","namedRunList: ${namedRunList}","policyName: ${policyName}","appServer: ${appServer}")
            withCredentials([string(credentialsId: 'enckey', variable: 'enckey')]) {
              triggerJobWithoutJson(enckey, namedRunList, policyName, appServer)
            }

          }
          echoBanner("   Triggered Downstream pipeline - Please verify the logs at below  ","https://jenkins.srv.westpac.com.au/job/A00232_Credient/job/Non-Prod/job/Chef_OnDemand_NonProd_Deployment","https://jenkins.srv.westpac.com.au/job/A00619_EntDevOps/job/OBM/job/Chef_OnDemand_Deployment_Downstream/")
        }//Script
      }//Steps
    }// Run Installation
  }//stages
}//pipeline

def constructTargetServer(choosenEnv){
  if(choosenEnv == "DEV"){
    appServer = "dwa240119002551.esdevau.wbcdevau.westpac.com.au"
    }else if(choosenEnv == "SIT"){
    appServer = "twa240209150221.estestau.wbctestau.westpac.com.au"
  }else if(choosenEnv == "UAT"){
    appServer = "twa240212091945.estestau.wbctestau.westpac.com.au"
  }
  return appServer
}

def constructNamedRunList(software){
  switch(software) {
    case "ControlM":
      namedRunList = "install_control_m"
      jsonRequired = false
      break
    case "SqlClient2022":
      namedRunList = "install_sqlclient"
      jsonRequired = false
      break
    case "reflection_client":
      namedRunList = "install_reflection"
      jsonRequired = true
      break
    case "reflection_server":
      namedRunList = "install_reflection"
      jsonRequired = true
      break
    case "WinSCP":
      namedRunList = "install_WinSCP"
      jsonRequired = true
      break
    case "7zip":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
    case "Notepad++":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
    case "Putty":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
  }
  return [namedRunList, jsonRequired]
}
