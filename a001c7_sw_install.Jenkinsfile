properties([
    parameters([
        choice(name: 'Env_Name', choices: ['DEV1_Windows2022', 'DEV2_Windows2022', 'SIT1_Windows2022', 'SIT5_Windows2022', 'UATUI1_Windows2022', 'UATUI2_Windows2022', 'UATB1_Windows2022', 'UATB2_Windows2022'], description: 'Choose the Environment Name'),
        [$class: 'ChoiceParameter', 
            choiceType: 'PT_SINGLE_SELECT', 
            description: 'Select the software from the List',  
            name: 'software',
            script: [
                $class: 'GroovyScript', 
                fallbackScript: [
                    classpath: [], 
                    sandbox: true, 
                    script: 
                        'return[\'Software not available\']'
                ], 
                script: [
                    classpath: [], 
                    sandbox: true, 
                    script: 
                        'return["7-Zip", "Control-M", "Java", "Jinja", "Markupsafe", "Notepadplus", "OracleClient", "Putty", "Python", "PyYAML", "ReflectionClient", "Tomcat", "Oracle_Sqldeveloper", "MQClient", "EnvironmentVariableSetup", "WalletCreation"]'
                ]
            ]
        ], 
        [$class: 'CascadeChoiceParameter', 
            choiceType: 'PT_SINGLE_SELECT', 
            description: 'Select the Version from the Dropdown List', 
            name: 'version',
            referencedParameters: 'software', 
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
                    script: 
                        """ 
                            def listVersions(softwarename){
                              def versions = []
                              switch(softwarename) {
                                case "7-Zip":
                                  versions = ["22.01_X64","24.04_X64"]
                                  break
                                case "Control-M":
                                  versions = ["9.0.20.0_X64"]
                                  break
                                case "Java":
                                  versions = ["11.0.6_X64","21.0.3_X64"]
                                  break
                                case "Jinja":
                                  versions = ["2-2.10-py2"]
                                  break
                                case "Markupsafe":
                                  versions = ["0.23.tar"]
                                  break
                                case "Notepadplus":
                                  versions = ["8.4.9_X64"]
                                  break
                                case "OracleClient":
                                  versions = ["19.0.0_X64"]
                                  break
                                case "Putty":
                                  versions = ["0.79_X64"]
                                  break
                                case "Python":
                                  versions = ["3.6.3_X64"]
                                  break
                                case "PyYAML":
                                  versions = ["3.12.tar"]
                                  break
                                case "ReflectionClient":
                                  versions = ["7.2_X64"]
                                  break
                                case "Oracle_Sqldeveloper":
                                  versions = ["19.1.0_X64"]
                                  break
                                case "Tomcat":
                                  versions = ["9.0.14_X64"]
                              return versions
                              }
                            }
                            def result = listVersions(software)
                            return result
                        """
                ]
            ]
        ],
        [$class: 'CascadeChoiceParameter', 
            choiceType: 'PT_SINGLE_SELECT', 
            description: 'Select the RunList for MQ Client', 
            name: 'Named_RunList',
            referencedParameters: 'software', 
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
                    script: 
                        """ 
                            def runlist(softwarename){
                              def run = []
                              switch(softwarename) {
                                case "MQClient":
                                  run = ["display", "install_93_current", "install_93_minusone", "install_92_current", "install_92_minusone", "migrate_93_current", "migrate_93_minusone", "migrate_92_current", "migrate_92_minusone", "patch_current", "patch_minusone", "uninstall"]
                              return run
                              }
                            }
                            def result = runlist(software)
                            return result
                        """
                ]
            ]
        ]
    ])
])

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
  build job: 'A001C7_LoanIQ/OBM_Chef_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'), string(name: 'POLICY_NAME', value: 'a001c7_Loaniq-software_install'), string(name: 'SERVER_LABEL', value: "${appServer}"), string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), string(name: 'POLICY_GROUP', value: 'default'), string(name: 'ENCRYPTED_DATA_BAG_SECRET', value: 'HG8nqMzghjEnRYgzwQqYVBOREWKALnnFNZW+OHNqQdQ3L7SceUI6r+Ox6EuC0dbOsJ81j7Diw8qmUUJwtDLPgDZqUA5CQ+rxV2XCSAaNgftidWwCQr8YY/L1yVRugRPHaLrsAS6+HwTElmN2yHYNeJn0KzoWQgvBqJmLnNmFmevqRmbf2qvX9ZloZpnH2fTlE+dY8zgr0w39Je8bHjg2uCH6x+dsbLRcDq4cmZ5gF6Cj3RlIz0gm0EjyCRTNkl67Za3y3f+XZUChB9xn2u18ztOLCc1asP8mZDzV93wQaqy/SVoszMa7U+KnFSzpRgySe+bvxr3V1dFTiAyG23CLWlsz+mY1znaO/JdKqInHrUWB2xgRF+hQXJfpc3CtFGmD/8Sl9xQ7kPelaj1YnRhq19AeLlTOfnWn88IyyYnNoG35IXEK29CEcxxgjW1JofKAF1AmidBtGYmcgceVxquYN7PSWqAdczD/TrpMyi8Sebiu/Ypmp5t6sdkTlVJRavqsyMCx1NfE/H5ISVQZRzEDlaetFSyTFn0RpmTvWx0abX0jnoF3HtanfuC/GjVLSP9qKF0fTo6gT/9XbcYu0hjYkX1p+xj08VfQaBPuIREY7lsvFm4p97vqipvSjO2giSBmHzDyMjFqKIvnT2Xx2/I4K56Siw0ip/qaTJqLPj23iPE='), string(name: 'NAMED_RUNLIST', value: 'none'), string(name: 'OVERRIDE_ATTRIBUTES_FILE', value: 'install_uninstall.json')]
  
}

def mqtriggerJob(policyName, appServer, namedrunlist){
  // -------------------------- TRIGGER THE PIPELINE  --------------------//  
  build job: 'A001C7_LoanIQ/Non-Prod/MQ_OBM_Chef_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'), string(name: 'POLICY_NAME', value: 'a001c7_mq_master_mqclient_windows'), string(name: 'SERVER_LABEL', value: "${appServer}"), string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), string(name: 'POLICY_GROUP', value: 'default'), string(name: 'NAMED_RUNLIST', value: "${namedrunlist}"), string(name: 'OVERRIDE_ATTRIBUTES_FILE', value: 'none')]
  
}

def envsetuptriggerJob(policyName, appServer){
  // -------------------------- TRIGGER THE PIPELINE  --------------------//  
  build job: 'A001C7_LoanIQ/OBM_Chef_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'), string(name: 'POLICY_NAME', value: 'a001c7_Loaniq-environment_variables_setup'), string(name: 'SERVER_LABEL', value: "${appServer}"), string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), string(name: 'POLICY_GROUP', value: 'default'), string(name: 'ENCRYPTED_DATA_BAG_SECRET', value: 'HG8nqMzghjEnRYgzwQqYVBOREWKALnnFNZW+OHNqQdQ3L7SceUI6r+Ox6EuC0dbOsJ81j7Diw8qmUUJwtDLPgDZqUA5CQ+rxV2XCSAaNgftidWwCQr8YY/L1yVRugRPHaLrsAS6+HwTElmN2yHYNeJn0KzoWQgvBqJmLnNmFmevqRmbf2qvX9ZloZpnH2fTlE+dY8zgr0w39Je8bHjg2uCH6x+dsbLRcDq4cmZ5gF6Cj3RlIz0gm0EjyCRTNkl67Za3y3f+XZUChB9xn2u18ztOLCc1asP8mZDzV93wQaqy/SVoszMa7U+KnFSzpRgySe+bvxr3V1dFTiAyG23CLWlsz+mY1znaO/JdKqInHrUWB2xgRF+hQXJfpc3CtFGmD/8Sl9xQ7kPelaj1YnRhq19AeLlTOfnWn88IyyYnNoG35IXEK29CEcxxgjW1JofKAF1AmidBtGYmcgceVxquYN7PSWqAdczD/TrpMyi8Sebiu/Ypmp5t6sdkTlVJRavqsyMCx1NfE/H5ISVQZRzEDlaetFSyTFn0RpmTvWx0abX0jnoF3HtanfuC/GjVLSP9qKF0fTo6gT/9XbcYu0hjYkX1p+xj08VfQaBPuIREY7lsvFm4p97vqipvSjO2giSBmHzDyMjFqKIvnT2Xx2/I4K56Siw0ip/qaTJqLPj23iPE='), string(name: 'NAMED_RUNLIST', value: 'none'), string(name: 'OVERRIDE_ATTRIBUTES_FILE', value: 'none')]
  
}

def wallettriggerJob(policyName, appServer){
  // -------------------------- TRIGGER THE PIPELINE  --------------------//  
  build job: 'A001C7_LoanIQ/OBM_Chef_Deployment', parameters: [string(name: 'HOSTING_ENV', value: 'on-premise'), string(name: 'POLICY_NAME', value: 'a001c7_Loaniq-certificate_install'), string(name: 'SERVER_LABEL', value: "${appServer}"), string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'), string(name: 'POLICY_GROUP', value: 'default'), string(name: 'ENCRYPTED_DATA_BAG_SECRET', value: 'HG8nqMzghjEnRYgzwQqYVBOREWKALnnFNZW+OHNqQdQ3L7SceUI6r+Ox6EuC0dbOsJ81j7Diw8qmUUJwtDLPgDZqUA5CQ+rxV2XCSAaNgftidWwCQr8YY/L1yVRugRPHaLrsAS6+HwTElmN2yHYNeJn0KzoWQgvBqJmLnNmFmevqRmbf2qvX9ZloZpnH2fTlE+dY8zgr0w39Je8bHjg2uCH6x+dsbLRcDq4cmZ5gF6Cj3RlIz0gm0EjyCRTNkl67Za3y3f+XZUChB9xn2u18ztOLCc1asP8mZDzV93wQaqy/SVoszMa7U+KnFSzpRgySe+bvxr3V1dFTiAyG23CLWlsz+mY1znaO/JdKqInHrUWB2xgRF+hQXJfpc3CtFGmD/8Sl9xQ7kPelaj1YnRhq19AeLlTOfnWn88IyyYnNoG35IXEK29CEcxxgjW1JofKAF1AmidBtGYmcgceVxquYN7PSWqAdczD/TrpMyi8Sebiu/Ypmp5t6sdkTlVJRavqsyMCx1NfE/H5ISVQZRzEDlaetFSyTFn0RpmTvWx0abX0jnoF3HtanfuC/GjVLSP9qKF0fTo6gT/9XbcYu0hjYkX1p+xj08VfQaBPuIREY7lsvFm4p97vqipvSjO2giSBmHzDyMjFqKIvnT2Xx2/I4K56Siw0ip/qaTJqLPj23iPE='), string(name: 'NAMED_RUNLIST', value: 'none'), string(name: 'OVERRIDE_ATTRIBUTES_FILE', value: 'none')]
  
}


pipeline {
  // agent any
  agent {
        node {
          // label 'enterprise_devops&&windows'
          label 'a00619_edp_pwa210318171124_obm_prod'
        }
      }

  stages {    
    stage("Pre-requisties Setup") {
      steps {
        script {
          software_name = "${software}"
          if (software_name == 'EnvironmentVariableSetup') {
            // Prepare environment_variables.json
            writeFile (file: "${WORKSPACE}/a001c7_environment_variables.json" ,
                  text: """\
                  {"variables": {
                      "CLASSPATH": "e:\\\\Apps\\\\WebSphere MQ\\\\java\\\\lib\\\\com.ibm.mqjms.jar;e:\\\\Apps\\\\WebSphere MQ\\\\java\\\\lib\\\\com.ibm.mq.jar",
                      "EXE4J_JAVA_HOME": "E:\\\\Java",
                      "JAVA_HOME": "E:\\\\Java",
                      "LOANIQ_DBNAME": "LIQ_${Env_Name}_SSL",
                      "MAN_JAVA_HOME": "E:\\\\Java",
                      "Path": "E:\\\\Java\\\\bin;E:\\\\OracleClient\\\\product\\\\12.2.0\\\\client_1\\\\bin;E:\\\\Apps\\\\Attachmate\\\\Rsecure\\\\;E:\\\\LoanIQ\\\\intfc\\\\services;E:\\\\LoanIQ\\\\intfc\\\\bin\\\\ICIS-DR;E:\\\\LoanIQ\\\\python;E:\\\\LoanIQ\\\\python\\\\Scripts;C:\\\\opscode\\\\chef\\\\bin\\\\;",
                      "WBC_DATA": "E:\\\\Data",
                      "WBC_LOANIQ": "E:\\\\LoanIQ",
                      "ORACLE_HOME": "E:\\\\OracleClient\\\\product\\\\12.2.0\\\\client_1",
                      "wbg_environment": "${Env_Name}"
                    }
                  }
               """.stripIndent()
            )//writeFile
            // Push to artifactory
            def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'ArtifactoryCreds'
            def artifact_sub_path = "A001C7_LOANIQ/install-packages/7.5/interfaces"
            def uploadSpec = """{
                    "files": [{
                       "pattern": "${WORKSPACE}/a001c7_environment_variables.json",
                       "target": "${artifact_sub_path}/attributes/",
                       "props": "type=json;status=ready"
                    }]
            }"""
            server.upload(uploadSpec)
          }//if
          else {
            software_version_name = "${software}_${version}"
            echoBanner("Software to be Installed","Software Name : ${software_version_name}","Environment Name : ${Env_Name}")
            def targetDrive = "E:"
            def artifactory_packages_folder = "https://artifactory.srv.westpac.com.au/artifactory/A001C7_LOANIQ/install-packages/7.7/software_install_packages"
            // Json update
            windows_softwares_list = ["${software}"]
            List softwareList = windows_softwares_list.collect{ '"' + it + '"'}
            // Prepare install_uninstall.json
            writeFile (file: "${WORKSPACE}/install_uninstall.json" ,
                  text: """\
                  {"wbg_a001c7_loaniq": {
                        "artifactory": {
                            "repo": "https://artifactory.srv.westpac.com.au/artifactory/A001C7_LOANIQ/Attributes/"
                        },
                        "pipeline_type": "install_uninstall",
                        "install_uninstall": {
                            "targetDrive": "${targetDrive}",
                            "local_devops_windows_softwares_path": "${targetDrive}\\\\devops",
                            "source_artifactory_json_file_loc": "https://artifactory.srv.westpac.com.au/artifactory/A001C7_LOANIQ/Attributes/install_uninstall.json",
                            "local_json_file_download_path": "${targetDrive}\\\\devops\\\\install_uninstall.json",
                            "json_file_name": "install_uninstall.json",
                            "softwares_list": "${software}",
                            "7-Zip": {
                                "art_link": "${artifactory_packages_folder}/${software_version_name}.exe",
                                "package_name": "${software_version_name}.exe",
                                "package_type": "exe",
                                "resource_type": "windows_package",
                                "options_list": "/S /D=\\"${targetDrive}\\\\Program Files\\\\7-Zip\\""
                            },
                            "Java": {
                                "art_link": "${artifactory_packages_folder}/${software_version_name}.exe",
                                "package_name": "${software_version_name}.exe",
                                "package_type": "exe",
                                "resource_type": "windows_package",
                                "options_list": "/s INSTALLDIR=\\"${targetDrive}\\\\Java\\""
                            },
                            "Jinja": {
                                "art_link": "${artifactory_packages_folder}/${software_version_name}.py3-none-any.whl",
                                "package_name": "${software_version_name}.py3-none-any.whl",
                                "resource_type": "python",
                                "command": "${targetDrive}\\\\LoanIQ\\\\python\\\\python -m pip install ${software_version_name}.py3-none-any.whl -f ./ --no-index"
                            },
                            "Markupsafe": {
                                "art_link": "${artifactory_packages_folder}/${software_version_name}.gz",
                                "package_name": "${software_version_name}.gz",
                                "resource_type": "python",
                                "command": "${targetDrive}\\\\LoanIQ\\\\python\\\\python -m pip install ${software_version_name}.gz"
                            },
                            "Notepadplus": {
                                "art_link": "${artifactory_packages_folder}/${software_version_name}.exe",
                                "package_name": "${software_version_name}.exe",
                                "package_type": "exe",
                                "resource_type": "windows_package",
                                "options_list": "/S /D=\\"${targetDrive}\\\\Program Files\\\\Notepad++\\""
                            },
                            "OracleClient": {
                                "art_link": "${artifactory_packages_folder}/${software_version_name}.zip",
                                "response_link": "${artifactory_packages_folder}/OracleClient_responsefiles/${software_version_name}_response.rsp",
                                "response_file": "${software_version_name}_response.rsp",
                                "package_name": "${software_version_name}.zip",
                                "resource_type": "batch",
                                "installation_dir": "${targetDrive}\\\\OracleClient",
                                "deinstall_path": "${targetDrive}\\\\OracleClient\\\\product\\\\12.2.0\\\\client_1\\\\deinstall"
                            },
                            "Putty": {
                                "art_link": "${artifactory_packages_folder}/${software_version_name}.msi",
                                "package_name": "${software_version_name}.msi",
                                "package_type": "msi",
                                "resource_type": "windows_package",
                                "options_list": "INSTALLDIR=\\"${targetDrive}\\\\Program Files\\\\Putty\\" /qn /L*V ${targetDrive}\\\\devops\\\\Putty.log"
                            },
                            "Python": {
                                "art_link": "${artifactory_packages_folder}/${software_version_name}.exe",
                                "package_name": "${software_version_name}.exe",
                                "package_type": "exe",
                                "resource_type": "windows_package",
                                "options_list": "/quiet InstallAllUsers=1 PrependPath=1 TargetDir=${targetDrive}\\\\LoanIQ\\\\python"
                            },
                            "PyYAML": {
                                "art_link": "${artifactory_packages_folder}/${software_version_name}.gz",
                                "package_name": "${software_version_name}.gz",
                                "resource_type": "python",
                                "command": "${targetDrive}\\\\LoanIQ\\\\python\\\\python -m pip install ${software_version_name}.gz -f ./ --no-index"
                            },
                            "ReflectionClient": {
                                "art_link": "${artifactory_packages_folder}/${software_version_name}.zip",
                                "patch_art_link": "${artifactory_packages_folder}/p724254.zip",
                                "package_name": "rsshc720.msi",
                                "patch_package_name": "P724254.msp",
                                "resource_type": "batch",
                                "options_list": "/quiet INSTALLDIR=\\"${targetDrive}\\\\Apps\\\\Attachmate\\\\RSecure\\" ALLUSERS=1 REBOOT=ReallySuppress /l*v ${targetDrive}\\\\devops\\\\Client.log /qn",
                                "patch_options_list": "/quiet /norestart"
                            },
                            "Oracle_Sqldeveloper": {
                              "art_link": "${artifactory_packages_folder}/${software_version_name}.zip",
                              "package_name": "${software_version_name}.zip",
                              "resources_type": "zip",
                              "Install_dir": "${targetDrive}\\\\OracleClient\\\\product\\\\19.0.0\\\\client_1\\\\${software_version_name}"
                            },
                            "Tomcat": {
                                "art_link": "${artifactory_packages_folder}/${software_version_name}.zip",
                                "package_name": "${software_version_name}.zip",
                                "resources_type": "zip",
                                "options_list": ""
                            }
                        }
                    }
                }
                """.stripIndent()
               )//writeFile
               // Push to artifactory
               def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'ArtifactoryCreds'
               def artifact_sub_path = "A001C7_LOANIQ"
               def uploadSpec = """{
                       "files": [{
                          "pattern": "${WORKSPACE}/install_uninstall.json",
                          "target": "${artifact_sub_path}/Attributes/",
                          "props": "type=json;status=ready"
                        }]
              }"""
              server.upload(uploadSpec)
          }//else
        }//script
      }//steps
    }//Software Installation Stage
    stage("Run Installation") {
      steps {
        script {
          appServer = constructTargetServer(Env_Name)
          software_name = "${software}"
          if(software_name == 'MQClient') {
            policyName = "a001c7_mq_master_mqclient_windows"
            echoBanner("Trigger Job","policyName: ${policyName}","appServer: ${appServer}")
            namedrunlist = "${Named_RunList}"
            mqtriggerJob(policyName, appServer, namedrunlist)
            echoBanner("   Triggered Downstream pipeline - Please verify the logs at below  ","https://jenkins.srv.westpac.com.au/job/A001C7_LoanIQ/job/Non-Prod/job/MQ_OBM_Chef_Deployment/","https://jenkins.srv.westpac.com.au/job/A00619_EntDevOps/job/OBM/job/OBM_Chef_Deployment/")
          }
          else if (software_name == 'EnvironmentVariableSetup') {
            policyName = "a001c7_Loaniq-environment_variables_setup"
            echoBanner("Trigger Job","policyName: ${policyName}","appServer: ${appServer}")
            envsetuptriggerJob(policyName, appServer)
            echoBanner("   Triggered Downstream pipeline - Please verify the logs at below  ","https://jenkins.srv.westpac.com.au/job/A001C7_LoanIQ/job/OBM_Chef_Deployment/","https://jenkins.srv.westpac.com.au/job/A00619_EntDevOps/job/OBM/job/OBM_Chef_Deployment/")
          }
          else if (software_name == 'WalletCreation') {
            policyName = "a001c7_Loaniq-certificate_install"
            echoBanner("Trigger Job","policyName: ${policyName}","appServer: ${appServer}")
            wallettriggerJob(policyName, appServer)
            echoBanner("   Triggered Downstream pipeline - Please verify the logs at below  ","https://jenkins.srv.westpac.com.au/job/A001C7_LoanIQ/job/OBM_Chef_Deployment/","https://jenkins.srv.westpac.com.au/job/A00619_EntDevOps/job/OBM/job/OBM_Chef_Deployment/")
          }
          else {
            policyName = "a001c7_Loaniq-software_install"
            json = "install_uninstall.json"
            echoBanner("Trigger Job","policyName: ${policyName}","appServer: ${appServer}")
            triggerJob(policyName, appServer, json)
            echoBanner("   Triggered Downstream pipeline - Please verify the logs at below  ","https://jenkins.srv.westpac.com.au/job/A001C7_LoanIQ/job/OBM_Chef_Deployment/","https://jenkins.srv.westpac.com.au/job/A00619_EntDevOps/job/OBM/job/OBM_Chef_Deployment/")
          }
        }//Script
      }//Steps
    }// Run Installation
  }//stages
}//pipeline

def constructTargetServer(choosenEnv){
  if(choosenEnv == "DEV1_Windows2022"){
    appServer = "dwa240627153059.esdevau.wbcdevau.westpac.com.au"
  }else if(choosenEnv == "DEV2_Windows2022"){
    appServer = "dwa240627153106.esdevau.wbcdevau.westpac.com.au"
  }else if(choosenEnv == "SIT1_Windows2022"){
    appServer = "twa240912135957.estestau.wbctestau.westpac.com.au"
  }else if(choosenEnv == "SIT5_Windows2022"){
    appServer = "twa240912140002.estestau.wbctestau.westpac.com.au"
  }else if(choosenEnv == "UATUI1_Windows2022"){
    appServer = "twa250108080551.estestau.wbctestau.westpac.com.au"
  }else if(choosenEnv == "UATUI2_Windows2022"){
    appServer = "twa250107153807.estestau.wbctestau.westpac.com.au"
  }else if(choosenEnv == "UATB1_Windows2022"){
    appServer = "twa250108080451.estestau.wbctestau.westpac.com.au"
  }else if(choosenEnv == "UATB2_Windows2022"){
    appServer = "twa250107153812.estestau.wbctestau.westpac.com.au"
  }
  return appServer
}
