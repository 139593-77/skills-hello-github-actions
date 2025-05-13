def fortify_sub_path = ""
pipeline {
   agent {
      label 'enterprise_devops&&windows'
   }

    options {
		buildDiscarder(logRotator(numToKeepStr:'5'))
		disableConcurrentBuilds()
	}
  environment {
		  JAVA_HOME = 'C:\\Program Files\\Java\\jdk-11.0.15.1'
      MAVEN_HOME = 'F:\\data\\buildTools\\apache-maven-3.8.2\\apache-maven-3.8.2\\bin'
    }
  stages {

      stage('Checkout') {
         steps {
            deleteDir()
                git branch: '$BRANCH_NAME', credentialsId: 'Jenkins', url: 'ssh://git@bitbucket.srv.westpac.com.au/hq-001/accrualsmonitor.git'
		      }
      }

      stage("Buildname"){
            steps {
                script {

                    currentBuild.displayName = ("$BRANCH_NAME")+ "#" +(currentBuild.number)
                 }
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
                        "pattern": "A001C7_LOANIQ_JAVA_SNAPSHOT/maven_settings.xml",
                        "target": "${env.WORKSPACE}/.m2/"
                     }]
                  }"""
                  server.download(downloadSpec)
          }
          }
      }


    // stage ('Sonar analysis') {
    //          steps {

    //      withSonarQubeEnv('Sonar OBMR') {
    //       bat 'F:\\data\\buildTools\\apache-maven-3.8.2\\apache-maven-3.8.2\\bin\\mvn clean verify -DskipTests sonar:sonar -Dsonar.projectKey=A001C7_LoanIQ-intfc17_LoanFunding -Dsonar.projectName=intfc17_LoanFunding -X -e -Dmaven.repo.local=${WORKSPACE}/.repository --settings .m2/settings.xml ' +
    //        '-f liq-loanfunding-service/pom.xml ' +
    //        '-Dv=$BUILD_ID ' +
    //        '-Db=' + env.BRANCH_NAME.replace('/', '_') + ' ' +
    //        '-Dsonar.login=e4108e933494d2ed2e0601b3f5e88e55608d0f0e ' +
    //        '-Dsonar.host.url=https://sonar.srv.westpac.com.au/ ' +
    //        '-Dsonar.language=java ' +
    //        '-Dsonar.projectVersion=$BRANCH_NAME.$BUILD_ID ' +
    //        '-Dsonar.projectKey=A001C7_LoanIQ-LoaniqDataIngestion'
    //      }
    //   }
    //  }

     stage ('maven build') {
		    steps {
			script{
				def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactoryCreds'
   			def rtMaven = Artifactory.newMavenBuild()
				rtMaven.tool = 'MVN-WIN-3.8.2' // Tool name from Jenkins configuration
  			env.JAVA_HOME = 'C:\\Program Files\\Java\\jdk-11.0.15.1'
        env.MAVEN_HOME = 'F:\\data\\buildTools\\apache-maven-3.8.2\\apache-maven-3.8.2\\bin'
         if("$BRANCH_NAME".toLowerCase().contains('develop') || "$BRANCH_NAME".toLowerCase().contains('feature') || "$BRANCH_NAME".toLowerCase().contains('release')) {
         			 	rtMaven.deployer releaseRepo: 'A001C7_LOANIQ_JAVA_SNAPSHOT/AccrualsMonitor', snapshotRepo: 'A001C7_LOANIQ_JAVA_SNAPSHOT/AccrualsMonitor', server: server
  	  			} else if ("$BRANCH_NAME".toLowerCase().contains('master') ) {
       			   rtMaven.deployer releaseRepo: 'A001C7_LOANIQ_JAVA_RELEASE/AccrualsMonitor', snapshotRepo: 'A001C7_LOANIQ_JAVA_RELEASE/AccrualsMonitor', server: server
  				  }
				buildInfo = Artifactory.newBuildInfo()
				buildInfo.env.capture = true
				// Delete build after 10 days
        readpom = readMavenPom file: 'pom.xml';
          artifactversion = readpom.version;
          echo "${artifactversion}"
				buildInfo.retention maxBuilds: 10, deleteBuildArtifacts: true, async: true
				rtMaven.run pom: 'pom.xml', goals: 'clean install -X -U -e surefire-report:report -Dgmaven.logging=DEBUG -Dmaven.test.skip=true -U -e -Dmaven.repo.local=${WORKSPACE}/.repository dependency:copy-dependencies --settings .m2/maven_settings.xml -Db=' + env.BRANCH_NAME.replace('/', '_') + ' -Dv=${BUILD_NUMBER}', buildInfo: buildInfo
			}
	          }
		}

  //   stage('Zip files for fortify') {
  //  		steps {
  //             script {
  // 			          def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactoryCreds'
  //                  def downloadSpec = """{
  //                       "files": [{
  //                          "pattern": "A001C7_LOANIQ_JAVA_SNAPSHOT/di_zip_package.bat",
  //                          "target": "${env.WORKSPACE}/tmp/"
  //                      }]
  //                    }"""
  //                    server.download(downloadSpec)
  //                  }
  //           bat "tmp/di_zip_package.bat"
  //           //bat "move ${env.WORKSPACE}\\fortifyscan\\liq-loanfunding-service\\liq-loanfunding-service.zip ${env.WORKSPACE}\\fortifyscan\\liq-loanfunding-service_${env.BUILD_NUMBER}.zip"
  //           bat "set PATH='C:\\Program Files\\7-Zip';%PATH%"
  //           bat "7z.exe a -r Accrualsmonitor.zip ${env.WORKSPACE}\\fortifyscan\\Accrualsmonitor\\*"
  //           bat "move ${env.WORKSPACE}\\Accrualsmonitor.zip ${env.WORKSPACE}\\fortifyscan\\Accrualsmonitor${env.BUILD_NUMBER}.zip"
  //        }
  //      }

  //   stage('Upload zip in expected path') {
  //  steps {
  //     script {
  //  	 	 		 def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactoryCreds'
  //               def uploadSpec = """{
  //                   "files": [{
  //                     "pattern": "${env.WORKSPACE}/fortifyscan/Accrualsmonitor${env.BUILD_NUMBER}.zip",
  //                     "target": "A00321_PKG/fortify/"
  //                     }]
  //                     }"""

  //                     server.upload(uploadSpec)
  //                }
  //      	  }
  //     }
  //     stage('Trigger fortify scan job for component loanFundingAdapter') {
  // 	  	   steps {
  // 	  		  script {

  // 	  			build job: 'A001C7_LoanIQ/A001C7_LoanIQ_Fortify', wait: true, parameters: [
  // 	  			//	build job: 'https://jenkins.srv.westpac.com.au/job/A004CF_RMW/job/a004cf_rmw_fortify', wait: true, parameters: [
  // 	  				string(name: 'APP_ID', value: 'A001C7'),
  // 	  				string(name: 'COMPONENT', value: 'Accrualsmonitor'),
  // 	  				string(name: 'PJVERID', value: '15686'),
  // 	  				string(name: 'EMAIL_ADDRESSES', value: 'ratan.ghosh@westpac.com.au,kulal.kumar@westpac.com.au'),
  // 	 				  string(name: 'BUILD_LABEL', value: 'A001C7-Accrualsmonitor'),
  // 	  				string(name: 'CODE_LANGUAGE', value: 'java'),
  // 	  				string(name: 'BRANCH', value: 'prod'),
  // 	 				  string(name: 'AF_LINK', value:"https://artifactory.srv.westpac.com.au/artifactory/A00321_PKG/fortify/LoanIqDataIngestion_${env.BUILD_NUMBER}.zip")
  // 	  			]
  // 	  		}
  // 	 	}
  // 	  }
  //     stage("Fortify approval"){
  //           steps {
  //                   script {
  //  		 			  if("$BRANCH_NAME".toLowerCase().contains('develop') || "$BRANCH_NAME".toLowerCase().contains('feature') ) {
  //          			 	echo "Proceed to next stage "
  //  	   			} else if ("$BRANCH_NAME".toLowerCase().contains('master') || "$BRANCH_NAME".toLowerCase().contains('release') ) {
  //        			      emailext (
  //                         subject: "Build is waiting for your Approval post Fortify Scan!",
  //                         body: """<p>STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
  //                                     <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""",
  //                         recipientProviders: [[$class: 'DevelopersRecipientProvider']],
  //                         mimeType: 'text/html',
  //                         to: 'ratan.ghosh@westpac.com.au'
  //                       )
  //                       def FortifyUserInput = false
  //                       FortifyUserInput = input(id: 'UATDBRefresh', message: 'Is Fortify Scan complete, can we proceed to next stage ? ', parameters: [[$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: 'Please confirm you agree with this']])
  //                       echo 'FortifyUserInput: ' + FortifyUserInput
  //                     if(FortifyUserInput == true) {
  //                      // do action
  //                         echo "Proceed to next stage "

  //                       } else {
  //                         // not do action
  //                         echo "Action was aborted."
  //                       }
  //  		 		  }
  //                     }
  //             }

  //  		     }
    stage('upload to artifactory') {
            steps {
              script {
                def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactoryCreds'
                def uploadSpec = """{
                     "files": [{
                        "pattern": "${env.WORKSPACE}/target/AccrualsMonitor*.jar",
                        "target": "A001C7_LOANIQ_JAVA_SNAPSHOT/AccrualsMonitor/au/com/westpac/debtmarkets/liq/AccrualsMonitor/${artifactversion}/"
                     }]
                  }"""
                  server.upload(uploadSpec)
               }
       }
    }
   }
}
