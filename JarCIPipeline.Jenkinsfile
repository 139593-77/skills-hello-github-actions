def json_file_name = "jar_deployment.json" 
properties([
    parameters([
        string(name: 'Bitbucket_Repo_URL', description: 'What is the ssh repository url? example : ssh://git@bitbucket.srv.westpac.com.au/<project>/<repo-name>.git',defaultValue: 'ssh://git@bitbucket.srv.westpac.com.au/a005d4/atoti_app.git'),
        string(name: 'Branch_Name', description: 'What is the branch name?',defaultValue: 'test')
    ])
])

import org.apache.commons.io.FilenameUtils


def errorBanner(def ... msgs) {
   def colorStart = "\u001B[32" // Green color start
   def colorEnd = "\u001B[0" // Reset color
  // echo "\033[34m\033[1m${createBanner(msgs)}\033[0m"
   echo "\033[32m\033[1m${createBanner(msgs)}\033[0m"
}

def getPattern(length, caracter) {
  StringBuilder sb= new StringBuilder(length)
  for (int i = 0; i < length; i++) {
      sb.append(caracter)
  }
  return sb.toString()
}

def echoBanner(def ... msgs) {
   def colorStart = "\u001B[32" // Green color start
   def colorEnd = "\u001B[0" // Reset color
   echo "\033[32m\033[1m${createBanner(msgs)}\033[0m"
  // echo "\033[34m\033[1m${createBanner(msgs)}\033[0m"
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


pipeline {
    agent {
        label {
            label 'enterprise_devops&&linux'
        }
    }
        tools {
        maven '3.9.7'
        jdk '21.0.4'
    }
	options {
		buildDiscarder(logRotator(numToKeepStr: '5'))
		disableConcurrentBuilds()
        ansiColor('xterm')
    }
    environment {
        MAVEN_HOME = tool name: '3.9.7', type: 'maven'
        JAVA_HOME = tool name: '21.0.4', type: 'jdk'
    }
    stages {
        stage('Clean workspace') {
            steps{
                cleanWs()
                // checkout scm
            }
        }
     /*   stage('Configure Enterprise Artifactory') {
            steps {
                rtServer id: 'enterprise-artifactory', url: 'https://artifactory.srv.westpac.com.au/artifactory', credentialsId: 'ArtifactoryCreds'
                rtMavenResolver id: 'maven-resolver', serverId: 'enterprise-artifactory', releaseRepo: 'A005D4_activeviam-npm', snapshotRepo: 'A005D4_activeviam-npm'
            }
        } */
		
		
		
		stage('maven settings') {
        steps {
		  //  sh 'rm .m2'
			sh 'mkdir .m2 && curl --insecure https://artifactory.srv.westpac.com.au/artifactory/A005D4_Meerkat/atoti_settings/settings_atoti.xml --output .m2/settings_maven.xml'
	        }
     	}
		
        stage('Clone Code to repository folder') {
            steps {
                script{
                    sh '''
                        echo "****************** Bitbucket repo clone started ******************"
                    '''
                    checkout(
                        [
                            $class: 'GitSCM', 
                            branches: [[name: "${params.Branch_Name}"]], 
                            doGenerateSubmoduleConfigurations: false,
                            extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'Atoti']], 
                            submoduleCfg: [],
                            userRemoteConfigs: [[
                                credentialsId: 'srvA005D4jenkinsSSHKey', 
                                url: "${params.Bitbucket_Repo_URL}"
                            ]]
                        ]
                    )
               
                    sh '''
                        echo "****************** Bitbucket repo clone completed ******************"
                    '''
                }
            }
        } 
		
		stage ('Sonar analysis') {
          steps {

            withSonarQubeEnv('Enterprise SonarQube') {
              echo "${MAVEN_HOME}"
              sh 'mvn clean verify $JAVA_CACERTS -DskipTests sonar:sonar -Dsonar.branch.name=test -Dsonar.projectKey=A005D4_Meerkat-atoti_app -Dsonar.projectName=atoti_app -X -e  --settings .m2/settings_maven.xml ' +
              '-f ${WORKSPACE}/Atoti/pom.xml ' +
              '-DbuildVersion=$BUILD_ID ' +
              '-Db=' + env.BRANCH_NAME.replace('/', '_') + ' ' +
              '-Dsonar.projectVersion=$BRANCH_NAME.$BUILD_ID ' +
              '-Dsonar.language=java '
        }
     }
    }  
	
		stage ('maven build') {
		    steps {
                script{
                    def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'ArtifactoryCreds'
                    def rtMaven = Artifactory.newMavenBuild()

                    rtMaven.tool = '3.9.7'
                    //env.JAVA_HOME = '/data/jenkins-agent/build-tools/jdk-21.0.22'
                    rtMaven.deployer releaseRepo: 'a005d4_atoti-maven-release', snapshotRepo: 'a005d4_atoti-maven-snapshot', server: server
                    //rtMaven.resolver releaseRepo: 'a005d4_atoti-maven-release', snapshotRepo: 'a005d4_atoti-maven-snapshot', server: server
                    buildInfo = Artifactory.newBuildInfo()
                    buildInfo.env.capture = true
                    // Delete build after 10 days
                    buildInfo.retention maxBuilds: 10, deleteBuildArtifacts: true, async: true
                    rtMaven.run pom: 'Atoti/pom.xml', goals: 'clean install  $JAVA_CACERTS surefire-report:report -Dgmaven.logging=DEBUG -DskipTests -U -e  --settings .m2/settings_maven.xml -Db=' + env.BRANCH_NAME.replace('/', '_') + ' -DbuildVersion=1.0.${BUILD_NUMBER}', buildInfo: buildInfo
                }
	        }
		}    
	/*	stage('Create json file') {
         steps {
          script {         
            writeFile (file: "${env.WORKSPACE}/${json_file_name}" , 
            text: """\
          {
            "wib_devops": {
                "pipeline_type": "jar_deployment",
                  "package_deploy": {
                     "source_artifact_url_path": "https://artifactory.srv.westpac.com.au/artifactory/A005D4_Atoti/au/com/westpac/",
                     "current_package_version": "${build_name}", 
                     "source_json_file_loc": "https://artifactory.srv.westpac.com.au/artifactory/A005D4_Atoti/build/1.0.0/jar_deployment.json",
                     "json_file_download_path": "/tmp/devops/artifacts/jar_deployment.json",
                     "source_artifact_file_loc": "/tmp/devops/artifacts/",
                     "json_file_name": "jar_deployment.json",
                     "deploy_location": "/riskdata/atoti/lib/",
                     "source_artifact_extract_loc": "/tmp/devops/deploy_package",
					 "artifactory_service_account": "SRVC_A005D4_0003_DEV",
					 "vault_path": "artifactory-token",
                     "vault_version": "1",
					 "install_source_drive": "/riskdata/"
                    } 
                }
         }
              """.stripIndent()
            )
			} //script
          } //steps
       }  //stage */
	   stage('upload to artifactory') {
            steps {
              script {
                 def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'ArtifactoryCreds'
				readpom = readMavenPom file: 'Atoti/pom.xml';
				groupId = readpom.groupId;
				groupId = groupId.replace(".","/")
				echo "${groupId}"
                 def uploadSpec = """{
					"files": [{
                       "pattern": "${env.WORKSPACE}/${json_file_name}",
                       "target": "A005D4_Meerkat/Override_Attributes/",
					   "props": "type=json;status=ready"
                    }
                    ]
                 }"""
                 server.upload(uploadSpec)
               }
            }
        }

        stage('Zip files for fortify') {
    	    steps {
                /*script {
                    def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactoryCreds'
                    def downloadSpec = """{
                        "files": [{
                        "pattern": "A001C7_LOANIQ_JAVA_SNAPSHOT/fortify_zip_batch/zip_package_payments.bat",
                        "target": "${env.WORKSPACE}/tmp/"
                    }]
                }"""
                server.download(downloadSpec)
            }*/
                sh """
                    for i in atoti_mr atoti_mr_common atoti_mr_content atoti_signoff; do
                        echo "zipping files for $i"
                        mkdir -p fortifyscan/${i}/src
                        mkdir -p fortifyscan/${i}/lib
                        cp -R ${WORKSPACE}/Atoti/${i}/src/main ${WORKSPACE}/fortifyscan/${i}/src
                        cp -R ${WORKSPACE}/Atoti/${i}/target/dependency/*.jar ${WORKSPACE}/fortifyscan/${i}/lib
                        zip -rq "../Batch-${Env_Name}-${version}.zip" *
                    done                    
                """
            powershell '''
                # Define paths
                $zipFile = "${env:WORKSPACE}\\LiqPaymentService.zip"
                $sourcePath = "${env:WORKSPACE}\\fortifyscan\\LiqPaymentService\\*"
                $finalZipFile = "${env:WORKSPACE}\\fortifyscan\\LiqPaymentService_${env:BUILD_NUMBER}.zip"

                # Compress the directory to a ZIP file
                Compress-Archive -Path $sourcePath -DestinationPath $zipFile -Force

                # Rename the ZIP file with the build number
                Move-Item -Path $zipFile -Destination $finalZipFile -Force
               '''
    		 	       }
        }
 stage('Upload zip in expected path') {
    steps {
       script {
    	 	 		 def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactoryCreds'
                 def uploadSpec = """{
                     "files": [{
                       "pattern": "${env.WORKSPACE}/fortifyscan/LiqPaymentService_${env.BUILD_NUMBER}.zip",
                       "target": "A001C7_LOANIQ/fortifyscan/LiqPaymentService_fortify/"
                       }]
                       }"""

                       server.upload(uploadSpec)
                  }
        	  }
    }


   	stage('Trigger fortify scan job for component Payments') {
  	  	   steps {
  	  		  script {

  	  			build job: 'A001C7_LoanIQ/A001C7_LoanIQ_Fortify', wait: true, parameters: [
  	  			//	build job: 'https://jenkins.srv.westpac.com.au/job/A004CF_RMW/job/a004cf_rmw_fortify', wait: true, parameters: [
  	  				string(name: 'APP_ID', value: 'A001C7_LOANIQ'),
  	  				string(name: 'COMPONENT', value: 'Payments'),
  	  				string(name: 'PJVERID', value: '17158'),
  	  				string(name: 'EMAIL_ADDRESSES', value: 'sinduja.sivaraman@westpac.com.au,rutul.jhaveri@westpac.com.au,ishan.deshpande@westpac.com.au,kulal.kumar@westpac.com.au,surya.arumugam@westpac.com.au,bhargav.kumar@westpac.com.au,mohammed.sattar@westpac.com.au'),
  	 			   string(name: 'BUILD_LABEL', value: 'A001C7-LoanIQ_Payments'),
  	  				string(name: 'CODE_LANGUAGE', value: 'java'),
  	  				string(name: 'BRANCH', value: 'prod'),
  	 				string(name: 'AF_LINK', value:"https://artifactory.srv.westpac.com.au/artifactory/A001C7_LOANIQ/fortifyscan/LiqPaymentService_fortify/LiqPaymentService_${env.BUILD_NUMBER}.zip")
  	  			]
  	  		}
  	 	}
  	  }
    
    }//stages		
	

}
