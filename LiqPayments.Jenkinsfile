def fortify_sub_path = ""
pipeline {
   agent {
      label 'LoanIQAgent'
   }

    options {
		buildDiscarder(logRotator(numToKeepStr:'5'))
		disableConcurrentBuilds()
	}
    
    environment {
      JAVA_HOME = 'E:\\jdk-11.0.6'
      MAVEN_HOME = 'C:\\Program Files\\apache-maven-3.3.9'
      PATH = "${env.MAVEN_HOME}\\bin;${env.PATH}"  
   }
  parameters {
    choice(name: 'SKIP_TESTS', choices: ['false', 'true'], description: 'Skip tests during Maven build , choose true to skip tests and false to run tests')
  }
  
  stages {

      stage('Checkout') {
         steps {
            deleteDir()
            cleanWs()
                git branch: '$BRANCH_NAME', credentialsId: 'Jenkins', url: 'ssh://git@bitbucket.srv.westpac.com.au/a001c7/payments.git'
		      }
      }
      
    stage('copy maven settings') {
         steps {
           script{
             bat "mkdir .m2"
             //bat "copy ${env.WORKSPACE}\\maven_settings.xml ${env.WORKSPACE}\\.m2\\maven_settings.xml"
             def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactoryCreds'
             def downloadSpec = """{
                     "files": [{
                        "pattern": "A001C7_LOANIQ_JAVA_SNAPSHOT/settings_artaccess.xml",
                        "target": "${env.WORKSPACE}/.m2/"
                     }]
                  }"""
                  server.download(downloadSpec)
          }
          }
      }

          stage ('SonarQube analysis') {
            steps {
               withSonarQubeEnv('Sonar OBMR') {
                 bat 'mvn clean package -U -Dmaven.repo.local=${WORKSPACE}/.repository --settings .m2/settings_artaccess.xml -DcreateChecksum=true -Dmaven.test.skip=true sonar:sonar ' +
               '-f LiqPayments/pom.xml ' +
                 '-Dv=$BUILD_ID ' +
                 '-Db=' + env.BRANCH_NAME.replace('/', '_') + ' ' +
                 '-Dsonar.issuesReport.html.enable=true' +
                 '-Dsonar.issuesReport.console.enable=true' +
                 '-Dsonar.analysis.mode=preview ' +
                 '-Dsonar.login=e4108e933494d2ed2e0601b3f5e88e55608d0f0e ' +
                 '-Dsonar.host.url=https://sonar.srv.westpac.com.au/ ' +
                 '-Dsonar.language=java ' +
                '-Dsonar.projectVersion=$BRANCH_NAME.$BUILD_ID ' +
                 '-Dsonar.projectKey=A001C7_LoanIQ-Payments'

            }
            }
            }

       
    stage('Update artifactversion in JSON file') {
            steps {
              script {
                //def version = "${params.Dist_version_num}"
                readpom = readMavenPom file: 'LiqPayments/pom.xml';
                artifactversion = readpom.version;
                ADAPTOR_NAME = readpom.name;
                echo "${artifactversion}"
                echo "${ADAPTOR_NAME}"

                writeFile (file: "${env.WORKSPACE}/${ADAPTOR_NAME}_version.json" ,
                text: """\
               {
                   "current_package_version"  : \"${artifactversion}\",
                   "JAVA_ADAPTOR_NAME"  : \"${ADAPTOR_NAME}\"
               }
                 """.stripIndent()
                )
            }
        }
         }
        stage('Upload version JSON to artifactory') {
            steps {
              script {
                if("$BRANCH_NAME".toLowerCase().contains('develop') || "$BRANCH_NAME".toLowerCase().contains('feature') ) {
          			 	version_sub_path = "A001C7_LOANIQ_JAVA_SNAPSHOT"
   	  			} else if ("$BRANCH_NAME".toLowerCase().contains('master') || "$BRANCH_NAME".toLowerCase().contains('release') )
             {
                  version_sub_path = "A001C7_LOANIQ_JAVA_RELEASE"
             }
				         def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactoryCreds'
                 def uploadSpec = """{
                    "files": [{
                       "pattern": "${env.WORKSPACE}/${ADAPTOR_NAME}_version.json",
                       "target": "${version_sub_path}/${ADAPTOR_NAME}/Attributes/",
					             "props": "type=json;status=ready"
                    }]
                 }"""

                 server.upload(uploadSpec)
               }
            }
        }
     stage ('maven build') {
   		    steps {
   			   script{
   				     env.JAVA_HOME = 'E:\\jdk-11.0.6'
					 env.MAVEN_HOME = 'C:\\Program Files\\apache-maven-3.3.9'
					 echo "skiptests: ${params.SKIP_TESTS}"
                  // Convert GString to String explicitly
                    def testFailureIgnoreOption = "-Dmaven.test.failure.ignore=${params.SKIP_TESTS}".toString()
                    def testSkipIgnoreOption = "-Dmaven.test.skip=${params.SKIP_TESTS}".toString()
                    // Log the option for verification
                    echo "testFailureIgnoreOption: ${testFailureIgnoreOption}"
				   // Print Maven version to verify the correct version is being used
					bat 'mvn -version'
					def mavenGoals = 'clean install'
					def pomPath = 'LiqPayments/pom.xml'
					bat """
						\"${env.MAVEN_HOME}\\bin\\mvn\" ${mavenGoals} -f ${pomPath} -Dmaven.repo.local=maven/.repository assembly:single dependency:copy-dependencies -DcreateChecksum=false ${testFailureIgnoreOption} ${testSkipIgnoreOption} -U --settings .m2/settings_artaccess.xml -Db=${env.BRANCH_NAME.replace('/', '_')} -Dv=${env.BUILD_NUMBER}
					   """
               
                  }
   		}
   		}
		stage('Upload JAR in expected path') {
           steps {
               script {
                   def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactoryCreds'
                  if (("$BRANCH_NAME".toLowerCase().contains('release') || "$BRANCH_NAME".toLowerCase().contains('master'))){
                  def uploadSpec = """{
                      "files": [{
                         "pattern": "${env.WORKSPACE}/LiqPayments/target/LiqPayments-${artifactversion}.jar",
                         "target": "A001C7_LOANIQ_JAVA_RELEASE/LiqPayments/au/com/liq/LiqPayments/${artifactversion}/"
                      }]
                   }"""

                   server.upload(uploadSpec)
                  }
                  else{
                   def uploadSpec = """{
                    "files": [{
                         "pattern": "${env.WORKSPACE}/LiqPayments/target/LiqPayments-${artifactversion}.jar",
                         "target": "A001C7_LOANIQ_JAVA_SNAPSHOT/LiqPayments/au/com/liq/LiqPayments/${artifactversion}/"
                      }] 

                   }"""

                   server.upload(uploadSpec)
                  }
                 }
              }
       }
// 	  stage('Prepare and Zip Package for fortify') {
// 		steps {
// 			script {
//             bat """
//     @echo off
//     REM Creating directory structure
//     mkdir fortifyscan\\${ADAPTOR_NAME}\\src

//     REM Remove any previous existing files before copying
//     if exist fortifyscan\\${ADAPTOR_NAME}\\src\\main rmdir /S /Q fortifyscan\\${ADAPTOR_NAME}\\src\\main
//     if exist fortifyscan\\${ADAPTOR_NAME}\\src\\test rmdir /S /Q fortifyscan\\${ADAPTOR_NAME}\\src\\test
//     if exist fortifyscan\\${ADAPTOR_NAME}\\pom.xml del /F /Q fortifyscan\\${ADAPTOR_NAME}\\pom.xml

//     REM Copy src\\main and src\\test to the created src folder
//     xcopy /E /I ${WORKSPACE}\\${ADAPTOR_NAME}\\src\\main fortifyscan\\${ADAPTOR_NAME}\\src\\main
//     xcopy /E /I ${WORKSPACE}\\${ADAPTOR_NAME}\\src\\test fortifyscan\\${ADAPTOR_NAME}\\src\\test
//     xcopy /E /I ${WORKSPACE}\\${ADAPTOR_NAME}\\pom.xml fortifyscan\\${ADAPTOR_NAME}\\

//     pushd fortifyscan\\${ADAPTOR_NAME}

//     REM Delete any existing package
//     if exist ${ADAPTOR_NAME}.zip del /F /Q ${ADAPTOR_NAME}.zip

//     REM Zip the ${ADAPTOR_NAME} folder with src and pom.xml in the root folder
//     powershell -Command "Compress-Archive -Path src, pom.xml -DestinationPath ${env.WORKSPACE}\\fortifyscan\\${ADAPTOR_NAME}_${env.BUILD_NUMBER}.zip"

//     popd

//     REM Check if the ZIP was created correctly
//     if not exist ${env.WORKSPACE}\\fortifyscan\\${ADAPTOR_NAME}_${env.BUILD_NUMBER}.zip (
//         echo ZIP file creation failed
//         exit 1
//     ) else (
//         echo ZIP file created successfully
//     )
// """        }
//     }
// }


 stage('Zip files for fortify') {
    		steps {
              script {
   			       def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactoryCreds'
                   def downloadSpec = """{
                        "files": [{
                           "pattern": "A001C7_LOANIQ_JAVA_SNAPSHOT/fortify_zip_batch/zip_package_payments.bat",
                           "target": "${env.WORKSPACE}/tmp/"
                        }]
                     }"""
                     server.download(downloadSpec)
                   }
            bat "${env.WORKSPACE}\\tmp\\fortify_zip_batch\\zip_package_payments.bat"
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
     }
 }
