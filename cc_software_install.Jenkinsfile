
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

def triggerJob(namedRunList, policyName, appServer, json){
  // -------------------------- TRIGGER THE PIPELINE  --------------------// 
  final parentJobResult =  build job: 'A004CF_RMW/OBMR/Chef_Ondemand_NonProd_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'), 
    string(name: 'SERVER_LABEL', value: "${appServer}"), 
    string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), 
    string(name: 'POLICY_NAME', value: "${policyName}"), 
    string(name: 'POLICY_GROUP', value: 'default'), 
    string(name: 'NAMED_RUNLIST', value: "${namedRunList}"),
    string(name: 'OVERRIDE_ATTRIBUTES_FILE', value: "${json}")]
  // echo "Current Build number is ${currentBuild.number}"
  // echo "parentJobResult number: ${parentJobResult.number}"
}
def triggerJobWithoutJson(namedRunList, policyName, appServer){
  // -------------------------- TRIGGER THE PIPELINE  --------------------//  
  final parentJobResult =  build job: 'A004CF_RMW/OBMR/Chef_Ondemand_NonProd_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'), 
    string(name: 'SERVER_LABEL', value: "${appServer}"), 
    string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), 
    string(name: 'POLICY_NAME', value: "${policyName}"), 
    string(name: 'POLICY_GROUP', value: 'default'), 
    string(name: 'NAMED_RUNLIST', value: "${namedRunList}")]
  // echo "Current Build number is ${currentBuild.number}"
  // echo "parentJobResult number: ${parentJobResult.number}"
}

def softwares = "7zip,Notepad++,Putty,SSMS,DotNet,SqlClient2022,ControlM,WinSCP,reflection_client,reflection_server,msoledb_18,jdk_11,teradata"
def targetDrive = "C:"
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
    extendedChoice(description: 'Choose Software', multiSelectDelimiter: ',', name: 'software', quoteValue: false, saveJSONParameterToFile: false, type: 'PT_SINGLE_SELECT', value: softwares, visibleItemCount: 8)
    choice(name: 'Env_Name', choices: ['DEV01','DEV02','DEV03','DEV04','TEST01','TEST02','TEST03','TEST04'], description: 'Choose the Environment Name')
  }

  stages {    
    stage("Pre-requisties Setup") {
      steps {
        script {
          echoBanner("Software to be Installed","Software Name : ${software}","Environment Name : ${Env_Name}")
          def jsonRequiredSoftwares = ['7zip','Notepad++','Putty','SqlClient2022','WinSCP','reflection_client','reflection_server','msoledb_18','SSMS','jdk_11','teradata','DotNet','Config']
          // Json update
          if (software in jsonRequiredSoftwares){
            windows_softwares_list = ["${software}"]
            List softwareList = windows_softwares_list.collect{ '"' + it + '"'}

            // Prepare install_uninstall.json
            writeFile (file: "${WORKSPACE}/install_uninstall_${Env_Name}.json" ,
                  text: """\
                  {"wib_devops": {
                        "artifactory": {
                            "repo": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_RMW/"
                        },
                        "current_package_version": "0.1.10",
                        "appid": "A004CF",
                        "pipeline_type": "install_uninstall",
                        "install_uninstall": {
                            "vault_enabled": true,
                            "vault_art_key": "artifactory-token",
                            "vault_art_key_version": "1",
                            "current_json_file_name": "install_uninstall_${Env_Name}.json",
                            "drive": "E:",
                            "targetDrive": "${targetDrive}",
                            "local_base_path": "E:/",
                            "local_devops_path": "E:/devops",
                            "local_devops_artifacts_path": "E:/devops/artifacts",
                            "local_devops_powershell_scripts_path": "E:/devops/powershell_scripts",
                            "local_devops_sql_scripts_path": "E:/devops/sql_scripts",
                            "local_devops_sql_logs_path": "E:/devops/sql_logs",
                            "local_encryption_keys_path": "E:/devops/encryption_keys",
                            "local_devops_windows_softwares_path": "E:/devops/windows_softwares",
                            "source_artifactory_json_file_loc": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_RMW/attributes_npr/install_uninstall_${Env_Name}.json",
                            "local_json_file_download_path": "E:/devops/artifacts/install_uninstall_${Env_Name}.json",
                            "json_file_name": "install_uninstall_${Env_Name}.json",
                            "source_ps_file_list_file_path": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_SQL_SNAP/Config.ps1",
                            "ps_file_list": [
                                "reflection_client.ps1",
                                "reflection_server.ps1",
                                "WinSCP.ps1",
                                "SqlClient2022.ps1",
                                "software_verification.ps1",
                                "jdk_11.ps1",
                                "teradata.ps1",
                                "winzip.ps1",
                                "msoledb_18.ps1",
                                "Config.ps1"
                            ],
                            "ps_sw": [
                                "reflection_client",
                                "reflection_server",
                                "WinSCP",
                                "SqlClient2022",
                                "software_verification",
                                "jdk_11",
                                "teradata",
                                "winzip",
                                "msoledb_18",
                                "Config"
                            ],
                            "windows_softwares_list": ${softwareList},
                            "7zip": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_SQL_SNAP/Softwares/7z2409-x64.msi",
                                "package_name": "7z2409-x64.msi",
                                "package_type": "msi",
                                "options_list": "/q INSTALLDIR=\\"C:\\\\Program Files\\\\7-Zip\\""
                            },
                            "Notepad++": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_SQL_SNAP/Softwares/npp.8.4.9.Installer.x64.exe",
                                "package_name": "npp.8.4.9.Installer.x64.exe ",
                                "package_type": "exe",
                                "options_list": "/S /D=C:\\\\Program Files\\\\Notepad++"
                            },
                            "Putty": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_SQL_SNAP/Softwares/putty-64bit-0.81-installer.msi",
                                "package_name": "putty-64bit-0.81-installer.msi",
                                "package_type": "msi",
                                "options_list": "INSTALLDIR=\\"C:\\\\Program Files\\\\Putty\\" /qn /L*V C:/temp/Putty.log"
                            },
                            "SSMS": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_SQL_SNAP/Softwares/SSMS-Setup-ENU-20.1.exe",
                                "package_name": "SSMS-Setup-ENU-20.1.exe",
                                "package_type": "exe",
                                "options_list": "/S /D=\\"C:/Program Files/ssms201\\""
                            },
                            "DotNet": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_SQL_SNAP/Softwares/dotNetFx40_Full_setup.exe",
                                "package_name": "dotNetFx40_Full_setup.exe",
                                "package_type": "exe",
                                "options_list": "/s /INSTALLDIR=\\"C:\\\\Program Files\\\\dotNetFx40_Full_setup\\""
                            },
                            "OracleClient": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_SQL_SNAP/Softwares/OracleClient_19.0.0_X64.zip",
                                "response_link": "https://artifactory.srv.westpac.com.au/artifactory/A004CF_SQL_SNAP/Softwares/OracleClient_19.0.0_X64_response.rsp",
                                "response_file": "OracleClient_19.0.0_X64_response.rsp",
                                "package_name": "OracleClient_19.0.0_X64.zip",
                                "resource_type": "batch",
                                "tnsnames_flag": "true",
                                "installation_dir": "E:\\\\Oracle_19c",
                                "deinstall_path": "E:\\\\Oracle_19c\\\\product\\\\19.0.0\\\\client_1\\\\deinstall"
                            }
                        },
                        "services_start_stop": {},
                        "sql_deployment": {},
                        "sqlserver_install": {},
                        "database_refresh": {},
                        "windows_pipeline": {},
                        "local_devops_path": "E:/devops",
                        "local_devops_artifacts_path": "E:/devops/artifacts",
                        "local_devops_powershell_scripts_path": "E:/devops/powershell_scripts",
                        "local_devops_sql_scripts_path": "E:/devops/sql_scripts",
                        "local_devops_sql_logs_path": "E:/devops/sql_logs",
                        "local_encryption_keys_path": "E:/devops/encryption_keys"
                    }
                }
             """.stripIndent()
            )//writeFile

            // Push to artifactory
            def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactory_encrypted'
            def artifact_sub_path = "A004CF_RMW"
            def uploadSpec = """{
                    "files": [{
                       "pattern": "${WORKSPACE}/install_uninstall_${Env_Name}.json",
                       "target": "${artifact_sub_path}/attributes_npr/",
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
          policyName = "a004cf_installables"
          if(jsonRequired){
            json = "install_uninstall_${Env_Name}.json"
            echoBanner("Trigger Job","namedRunList: ${namedRunList}","policyName: ${policyName}","appServer: ${appServer}")
            triggerJob(namedRunList, policyName, appServer, json)
          }
          else{
            echoBanner("Trigger Job","namedRunList: ${namedRunList}","policyName: ${policyName}","appServer: ${appServer}")
            triggerJobWithoutJson(namedRunList, policyName, appServer)
          }
          echoBanner("   Triggered Downstream pipeline - Please verify the logs at below  ","https://jenkins.srv.westpac.com.au/job/A00619_EntDevOps/job/OBM/job/Chef_OnDemand_Deployment_Downstream/","Search for a004cf_installables in the left side navigation and select the job and view the console output")
        }//Script
      }//Steps
    }// Run Installation
  }//stages
}//pipeline

def constructTargetServer(choosenEnv){
  if(choosenEnv == "DEV01"){
    appServer = "dwa240828111155.esdevau.wbcdevau.westpac.com.au"
  }else if(choosenEnv == "DEV02"){
    appServer = "dwa240828111150.esdevau.wbcdevau.westpac.com.au"
  }else if(choosenEnv == "DEV03"){
    appServer = "dwa240927152006.esdevau.wbcdevau.westpac.com.au"
  }else if(choosenEnv == "DEV04"){
    appServer = "dwa240927151926.esdevau.wbcdevau.westpac.com.au"
  }else if(choosenEnv == "TEST01"){
    appServer = "twa241114132136.estestau.wbctestau.westpac.com.au"
  }else if(choosenEnv == "TEST02"){
    appServer = "twa241114132133.estestau.wbctestau.westpac.com.au"
  }else if(choosenEnv == "TEST03"){
    appServer = "twa241114132140.estestau.wbctestau.westpac.com.au"
  }else if(choosenEnv == "TEST04"){
    appServer = "twa241114132127.estestau.wbctestau.westpac.com.au"
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
    case "Ghostscript":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
    case "msoledb_18":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
    case "SSMS":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
    case "jdk_11":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
    case "teradata":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
    case "winzip":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
    case "DotNet":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
    case "Config":
      namedRunList = "install_softwares"
      jsonRequired = true
      break
  }
  return [namedRunList, jsonRequired]
}
