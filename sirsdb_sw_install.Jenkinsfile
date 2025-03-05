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

def triggerJob(encryptedKey, namedRunList, policyName, appServer, json){
  // -------------------------- TRIGGER THE PIPELINE  --------------------//  
  final parentJobResult =  build job: 'A00152_SIRSDB/OBM_Chef_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'), 
    string(name: 'SERVER_LABEL', value: "${appServer}"), 
    string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), 
    string(name: 'POLICY_NAME', value: "${policyName}"), 
    string(name: 'POLICY_GROUP', value: 'default'), 
    string(name: 'NAMED_RUNLIST', value: "${namedRunList}"),
    string(name: 'ENCRYPTED_DATA_BAG_SECRET', value: "${encryptedKey}"),
    string(name: 'OVERRIDE_ATTRIBUTES_FILE', value: "${json}")]
  // echo "Current Build number is ${currentBuild.number}"
  // echo "parentJobResult number: ${parentJobResult.number}"
}
def triggerJobWithoutJson(encryptedKey, namedRunList, policyName, appServer){
  // -------------------------- TRIGGER THE PIPELINE  --------------------// 
  final parentJobResult =  build job: 'A00152_SIRSDB/OBM_Chef_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'), 
    string(name: 'SERVER_LABEL', value: "${appServer}"), 
    string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), 
    string(name: 'POLICY_NAME', value: "${policyName}"), 
    string(name: 'POLICY_GROUP', value: 'default'),
    string(name: 'ENCRYPTED_DATA_BAG_SECRET', value: "${encryptedKey}"),
    string(name: 'NAMED_RUNLIST', value: "${namedRunList}")]
  // echo "Current Build number is ${currentBuild.number}"
  // echo "parentJobResult number: ${parentJobResult.number}"
}

def targetDrive = "E:"
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
      '7zip',
      'Notepad++',
      'Putty',
      'SqlClient2022',
      'ControlM',
      'WinSCP',
	  'dotnet-sdk'	  
      ], description: 'Choose the Software')
    choice(name: 'Env_Name', choices: ['DEV','SIT','UAT'], description: 'Choose the Environment Name')
  }

  stages {    
    stage("Pre-requisties Setup") {
      steps {
        script {
          echoBanner("Software to be Installed","Software Name : ${software}","Environment Name : ${Env_Name}")
          def jsonRequiredSoftwares = ['reflection_client','reflection_server','7zip','Notepad++','Putty','WinSCP','SqlClient2022','Config','dotnet-sdk']
          // Json update
          if (software in jsonRequiredSoftwares){
            windows_softwares_list = ["${software}"]
            List softwareList = windows_softwares_list.collect{ '"' + it + '"'}

            // Prepare install_uninstall.json
            writeFile (file: "${WORKSPACE}/install_uninstall.json" ,
                  text: """\
                  {"wib_devops": {
                        "artifactory": {
                            "repo": "https://artifactory.srv.westpac.com.au/artifactory/A00152_SIRSDB/"
                        },
                        "current_package_version": "0.1.10",
                        "appid": "A00152",
                        "pipeline_type": "install_uninstall",
                        "install_uninstall": {
                            "targetDrive": "${targetDrive}",
                            "local_base_path": "E:/",
                            "local_devops_path": "E:/devops",
                            "local_devops_artifacts_path": "E:/devops/artifacts",
                            "local_devops_powershell_scripts_path": "E:/devops/powershell_scripts",
                            "local_devops_sql_scripts_path": "E:/devops/sql_scripts",
                            "local_devops_windows_softwares_path": "E:/devops/windows_softwares",
                            "source_artifactory_json_file_loc": "https://artifactory.srv.westpac.com.au/artifactory/A00152_SIRSDB/Attributes/install_uninstall.json",
                            "local_json_file_download_path": "E:/devops/artifacts/install_uninstall.json",
                            "source_ps_file_list_file_path": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_SQL_SNAP/Config.ps1",
                            "json_file_name": "install_uninstall.json",
                            "ps_file_list": [
                                "reflection_client.ps1",
                                "reflection_server.ps1",
                                "WinSCP.ps1",
                                "SqlClient2022.ps1",
                                "software_verification.ps1",
                                "Config.ps1"
                            ],
                            "ps_sw": [
                                "reflection_client",
                                "reflection_server",
                                "WinSCP",
                                "SqlClient2022",
                                "software_verification",
                                "Config"
                            ],
                            "windows_softwares_list": ${softwareList},
                            "7zip": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_SQL_SNAP/Softwares/7z2404-x64.exe",
                                "package_name": "7z2404-x64.exe",
                                "package_type": "exe",
                                "options_list": "/S /D=\\"E:/Program Files/7-Zip\\""
                            },
                            "Notepad++": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_SQL_SNAP/Softwares/npp.8.4.9.Installer.x64.exe",
                                "package_name": "npp.8.4.9.Installer.x64.exe ",
                                "package_type": "exe",
                                "options_list": "/S /D=E:\\\\Program Files\\\\Notepad++"
                            },
                            "Putty": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_SQL_SNAP/Softwares/putty-64bit-0.81-installer.msi",
                                "package_name": "putty-64bit-0.81-installer.msi",
                                "package_type": "msi",
                                "options_list": "INSTALLDIR=\\"E:\\\\Program Files\\\\Putty\\" /qn /L*V C:/temp/Putty.log"
                            },
						                "dotnet-sdk": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A0113E_DVOPAAS/Software/dotnet-sdk-8.0.403-win-x64.exe",
                                "package_name": "dotnet-sdk-8.0.403-win-x64.exe",
                                "package_type": "exe",
                                "resource_type": "windows_package",
                                "options_list": "/s INSTALLDIR=\\"E:\\\\dotnet\\""
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
            def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'c257434e-e94d-48a8-a1a4-1b334e6902fa'
            def artifact_sub_path = "A00152_SIRSDB"
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
          policyName = "a00152_installables"
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
          echoBanner("   Triggered Downstream pipeline - Please verify the logs at below  ","https://jenkins.srv.westpac.com.au/job/A00152_SIRSDB/job/Non-Prod/job/InstallSoftware/","https://jenkins.srv.westpac.com.au/job/A00619_EntDevOps/job/OBM/job/OBM_Chef_Deployment/")
        }//Script
      }//Steps
    }// Run Installation
  }//stages
}//pipeline

def constructTargetServer(choosenEnv){
  if(choosenEnv == "DEV"){
    // appServer = "dwa240814095918.esdevau.wbcdevau.westpac.com.au"
    appServer = "dwa240916104211.esdevau.wbcdevau.westpac.com.au"
    }else if(choosenEnv == "SIT"){
    appServer = "twa241113132606.estestau.wbctestau.westpac.com.au"
  }else if(choosenEnv == "UAT"){
    appServer = "twa241212091055.estestau.wbctestau.westpac.com.au"
  }
  return appServer
}

def constructNamedRunList(software){
  switch(software) {
    case "ControlM":
      namedRunList = "install_control_m_new"
      jsonRequired = false
      break
    case "SqlClient2022":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
    case "reflection_client":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
    case "reflection_server":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
    case "WinSCP":
      namedRunList = "install_softwares"
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
    case "Config":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
	  case "dotnet-sdk":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
  }
  return [namedRunList, jsonRequired]
}
