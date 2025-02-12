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
  def  data_bag_secret = "dLbNbxBhnlA4gMECDrpmJp7IFyL81QuzmnadiZkhWQVX++yqk3RUPXDMc4zsdvuMLsi4nDI4zzNnwsLNUn8s+Hla62qJvtjaxKLVoFpHBhRutFZv8xE9GWrP6+8kFT30id03NTkTHRWJYz/I7CMxs4Li4nsYLze66k71qdJEbx4=" 
  final parentJobResult =  build job: 'A0041A_RTCE/OBM_Chef_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'), 
    string(name: 'SERVER_LABEL', value: "${appServer}"), 
    string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), 
    string(name: 'POLICY_NAME', value: "${policyName}"), 
    string(name: 'POLICY_GROUP', value: 'default'), 
    string(name: 'NAMED_RUNLIST', value: "${namedRunList}"),
    string(name: 'ENCRYPTED_DATA_BAG_SECRET', value: "${data_bag_secret}"),
    string(name: 'OVERRIDE_ATTRIBUTES_FILE', value: "${json}")]
  // echo "Current Build number is ${currentBuild.number}"
  // echo "parentJobResult number: ${parentJobResult.number}"
}

def softwares = "AAStudio,MDT,R-Package,RStudio,RTools,digest,fs,RODBC,XML,zoo"
def targetDrive = "E:"
pipeline {
  // agent any
  agent {
        node {
          label 'enterprise_devops&&windows'
        }
      }
  
  parameters {
    extendedChoice(description: 'Choose Software', multiSelectDelimiter: ',', name: 'software', quoteValue: false, saveJSONParameterToFile: false, type: 'PT_SINGLE_SELECT', value: softwares, visibleItemCount: 8)
    choice(name: 'Env_Name', choices: ['DEV','SIT','UAT'], description: 'Choose the Environment Name')
    choice(name: 'Software_Action', choices: ['Install','Uninstall'], description: 'Select the action for software')
  }

  stages {    
    stage("Pre-requisties Setup") {
      steps {
        script {
          echoBanner("Software to be Installed","Software Name : ${software}","Environment Name : ${Env_Name}")
          // Json update
            windows_softwares_list = ["${software}"]
            List softwareList = windows_softwares_list.collect{ '"' + it + '"'}

            // Prepare install_uninstall.json
            writeFile (file: "${WORKSPACE}/install_uninstall.json" ,
                  text: """\
                  {"wbg_a0041a_rtce": {
                        "artifactory": {
                            "repo": "https://artifactory.srv.westpac.com.au/artifactory/A0041A_RTCE/"
                        },
                        "current_package_version": "0.1.10",
                        "appid": "A0041A",
                        "pipeline_type": "install_uninstall",
                        "install_uninstall": {
                            "targetDrive": "${targetDrive}",
                            "local_base_path": "E:\\\\",
                            "local_devops_path": "E:\\\\devops",
                            "local_devops_artifacts_path": "E:\\\\devops\\\\artifacts",
                            "local_devops_powershell_scripts_path": "E:\\\\devops\\\\powershell_scripts",
                            "local_devops_sql_scripts_path": "E:\\\\devops\\\\sql_scripts",
                            "local_devops_windows_softwares_path": "E:\\\\devops\\\\windows_softwares",
                            "installDir": "E:\\\\Program Files",
                            "source_artifactory_json_file_loc": "https://artifactory.srv.westpac.com.au/artifactory/A0041A_RTCE/Attributes/install_uninstall.json",
                            "local_json_file_download_path": "E:\\\\devops\\\\artifacts\\\\install_uninstall.json",
                            "json_file_name": "install_uninstall.json",
                            "ps_file_list": [],
                            "ps_sw": [],
                            "windows_softwares_list": ${softwareList},
                            "AAStudio": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A0041A_RTCE/Softwares/AA_Studio.zip",
                                "package_name": "AA_Studio.zip",
				                        "installer_name": "AdaptivAnalytics.msi",
                                "package_type": "msi",
                                "options_list": "ADDLOCAL=ALL AA_LICENSE_PATH=\\"E:\\\\devops\\\\windows_softwares\\\\AAStudio\\\\license-Westpac Banking Corporation 1.xml\\" COPYANALYTICSFILE=\\"1\\" ARTIQSTOREPATH=\\"\\" /qn INSTALLLOCATION=\\"E:\\\\Program Files\\\\FIS\\\\Adaptiv Analytics 201\\" /lx E:\\\\devops\\\\AAStudioInstall_log.txt",
                                "uninstall_name": "Adaptive Analytics",
                                "uninstall_options": "wmic product where \\"name='Adaptiv Analytics'\\" call uninstall && rmdir /S /Q \\"E:\\\\Program Files\\\\FIS\\"",
                                "is_rpackage": "no",
				                        "package_path": "\\"E:\\\\Program Files\\\\FIS\\\\Adaptive Analytics 201\\\\\\"",
				                        "registry_key": ""
                            },
                            "MDT": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A0041A_RTCE/Softwares/MDT.msi",
                                "package_name": "MDT.msi",
                                "package_type": "msi",
                                "options_list": "INSTLOC_ADAPTIV=\\"E:\\\\Program Files\\\\FIS\\\\Adaptiv Analytics 201\\\\MDT\\" ADDLOCAL=\\"MDT,AAPLUGIN\\" /L*V E:\\\\devops\\\\MDT-Install.log /qn",
                                "uninstall_name": "Adaptiv Market Data Toolkit",
                                "uninstall_options": "wmic product where \\"name='Adaptiv Market Data Toolkit'\\" call uninstall && rmdir /S /Q \\"E:\\\\Program Files\\\\FIS\\\\Adaptiv Analytics 201\\\\MDT\\"",
                                "is_rpackage": "no",
				                        "package_path": "\\"E:\\\\Program Files\\\\FIS\\\\Adaptive Analytics 201\\\\MDT\\\\\\"",
				                        "registry_key": ""
                            },
                            "R-Package": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A0041A_RTCE/Softwares/R-4.4.1-win.exe",
                                "package_name": "R-4.4.1-win.exe",
                                "package_type": "exe",
                                "options_list": "/SILENT /DIR=\\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\"",
                                "uninstall_name": "R for Windows 4.4.1",
				                        "uninstall_options": "",
                                "is_rpackage": "no",
				                        "package_path": "E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\",
				                        "registry_key": "QuietUninstallString"
                            },
                            "RStudio": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A0041A_RTCE/Softwares/RStudio-2024.09.0-375.exe",
                                "package_name": "RStudio-2024.09.0-375.exe",
                                "package_type": "exe",
                                "options_list": "/S /D=E:\\\\Program Files\\\\RStudio\\\\",
                                "uninstall_name": "RStudio",
				                        "uninstall_options": "powershell.exe -Command \\"& {Start-Process -FilePath 'E:\\\\Program Files\\\\RStudio\\\\Uninstall.exe' -ArgumentList '/S' -Wait}\\"",
                                "is_rpackage": "yes",
				                        "package_path": "E:\\\\Program Files\\\\RStudio\\\\",
				                        "registry_key": ""
                            },
                            "RTools": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A0041A_RTCE/Softwares/rtools44-6104-6039.exe",
                                "package_name": "rtools44-6104-6039.exe",
                                "package_type": "exe",
                                "options_list": "/VERYSILENT /DIR=\\"E:\\\\Program Files\\\\rtools44\\"",
                                "uninstall_name": "Rtools 4.4 (6104-6039)",
				                        "uninstall_options": "",
                                "is_rpackage": "no",
				                        "package_path": "E:\\\\Program Files\\\\rtools44\\\\",
				                        "registry_key": "QuietUninstallString"
                            },
                            "digest": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A0041A_RTCE/Softwares/digest_0.6.37.zip",
                                "package_name": "digest_0.6.37.zip",
                                "package_type": "zip",
                                "options_list": "\\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R\\" CMD INSTALL digest_0.6.37.zip",
				                        "uninstall_name": "",
				                        "uninstall_options": "\\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R\\" CMD REMOVE -l \\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\library\\" digest",
                                "is_rpackage": "yes",
				                        "r_file_path": "E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R.exe\\\\",
				                        "package_path": "E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\library\\\\digest\\\\",
				                        "registry_key": ""
                            },
                            "fs": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A0041A_RTCE/Softwares/fs_1.6.4.zip",
                                "package_name": "fs_1.6.4.zip",
                                "package_type": "zip",
                                "options_list": "\\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R\\" CMD INSTALL fs_1.6.4.zip",
				                        "uninstall_name": "",
				                        "uninstall_options": "\\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R\\" CMD REMOVE -l \\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\library\\" fs",
                                "is_rpackage": "yes",
				                        "r_file_path": "E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R.exe\\\\",
				                        "package_path": "E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\library\\\\fs\\\\",
				                        "registry_key": ""
                            },
                            "RODBC": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A0041A_RTCE/Softwares/RODBC_1.3-23.zip",
                                "package_name": "RODBC_1.3-23.zip",
                                "package_type": "zip",
                                "options_list": "\\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R\\" CMD INSTALL RODBC_1.3-23.zip",
				                        "uninstall_name": "",
				                        "uninstall_options": "\\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R\\" CMD REMOVE -l \\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\library\\" RODBC",
                                "is_rpackage": "yes",
				                        "r_file_path": "E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R.exe\\\\",
				                        "package_path": "E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\library\\\\RODBC\\\\",
				                        "registry_key": ""
                            },
                            "XML": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A0041A_RTCE/Softwares/XML_3.99-0.17.zip",
                                "package_name": "XML_3.99-0.17.zip",
                                "package_type": "zip",
                                "options_list": "\\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R\\" CMD INSTALL XML_3.99-0.17.zip",
				                        "uninstall_name": "",
				                        "uninstall_options": "\\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R\\" CMD REMOVE -l \\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\library\\" XML",
                                "is_rpackage": "yes",
				                        "r_file_path": "E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R.exe\\\\",
				                        "package_path": "E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\library\\\\XML\\\\",
				                        "registry_key": ""
                            },
                            "zoo": {
                                "art_link": "https://artifactory.srv.westpac.com.au/artifactory/A0041A_RTCE/Softwares/zoo_1.8-12.zip",
                                "package_name": "zoo_1.8-12.zip",
                                "package_type": "zip",
                                "options_list": "\\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R\\" CMD INSTALL zoo_1.8-12.zip",
				                        "uninstall_name": "",
				                        "uninstall_options": "\\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R\\" CMD REMOVE -l \\"E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\library\\" zoo",
                                "is_rpackage": "yes",
				                        "r_file_path": "E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\bin\\\\R.exe\\\\",
				                        "package_path": "E:\\\\Program Files\\\\R\\\\R-4.4.1\\\\library\\\\zoo\\\\",
				                        "registry_key": ""
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
            def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'accesscredential'
            def uploadSpec = """{
                    "files": [{
                       "pattern": "${WORKSPACE}/install_uninstall.json",
                       "target": "A0041A_RTCE/Attributes/",
                            "props": "type=json;status=ready"
                    }]
                 }"""
                 //server.upload spec: uploadSpec 
                 server.upload(uploadSpec)


          
        }//script
      }//steps
    }//Software Installation Stage
    stage("Run Installation") {
      steps {
        script {
          // echoHeader([" Run Installation on ${Env_Name} "])
          appServer = constructTargetServer(Env_Name)
          if(Software_Action == "Install"){
            namedRunList = "install_softwares"
          }else{
            namedRunList = "uninstall_softwares"
          }
          policyName = "a0041a_RTCE-install-uninstall"
          json = "install_uninstall.json"
          echoBanner("Trigger Job","namedRunList: ${namedRunList}","policyName: ${policyName}","appServer: ${appServer}")
          triggerJob(namedRunList, policyName, appServer, json)
          
          echoBanner("   Triggered Downstream pipeline - Please verify the logs at below  ","https://jenkins.srv.westpac.com.au/job/A00619_EntDevOps/job/OBM/job/OBM_Chef_Deployment/","Search for a0041a_RTCE-install-uninstall in the left side navigation and select the job and view the console output")
        }//Script
      }//Steps
    }// Run Installation
  }//stages
}//pipeline

def constructTargetServer(choosenEnv){
  if(choosenEnv == "DEV"){
    //appServer = "dwa240828111155.esdevau.wbcdevau.westpac.com.au"
    appServer = "dwa240814095918.esdevau.wbcdevau.westpac.com.au"
  }else if(choosenEnv == "SIT"){
    appServer = "dwa240828111150.esdevau.wbcdevau.westpac.com.au"
  }else if(choosenEnv == "UAT"){
    appServer = "twa250125193021.estestau.wbctestau.westpac.com.au"
  }
  return appServer
}

