def echoBanner(def ... msgs) {
   echo createBanner(msgs)
}

def echoHighlightBanner(def ... msgs) {
  // white background black bold letters
  // echo "\033[90m\033[107m\033[1m${createBanner(msgs)}\033[0m"
  // No background Blue bold letters
  echo "\033[34m\033[1m${createBanner(msgs)}\033[0m"
}

def echoRedString(echoString) {
  echo "\033[31m\033[107m\033[1m${echoString}\033[0m"
}

def echoRedBanner(def ... msgs) {
    echo "\033[31m\033[107m\033[1m${createBanner(msgs)}\033[0m"
}

def echoGreenBanner(def ... msgs) {
    echo "\033[32m\033[1m\033[1m${createBanner(msgs)}\033[0m"
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
def fortify_sub_path = ""
pipeline {
  agent {
    label 'enterprise_devops&&windows'
  }
  options {
    ansiColor('xterm')
    buildDiscarder(logRotator(numToKeepStr:'30'))
    disableConcurrentBuilds()
  }
  tools{
    maven '3.9.6'
    jdk '11.0.22'
  }
  environment {
    JAVA_HOME = 'C:\\Program Files\\Java\\jdk1.7.0_80'
    MAVEN_HOME = 'F:\\data\\buildTools\\apache-maven-3.9.6\\apache-maven-3.9.6\\bin'
    ADAPTOR_NAME = "LiqBusinessReports"
  }
  parameters {
    string(name: 'BRANCH_NAME', defaultValue: '', description: 'Give the Git branch to Build, Full feature branch name')
    choice(
            name: 'JAVA_ADAPTOR_NAME',
            choices: [
                "LiqBaseRatesAdaptor",
                "BaseRateReport",
                "LoanIqReutersRateReview",
                "LoaniqDataIngestion",
                "LoanIQEmailFaxAgent",
                "AccrualsMonitor",
                "ArchivalAgent",
                "LiqFXRatesAdaptor",
                "FileMonitor",
                "LiqPayments",
                "LiqBusinessReports",
                "LiqDBApi",
                "LiqEmailApi",
                "LiqMQApi",
                "LiqUtilityApi",
                "LiqProdXref",
                "LiqCustomer"
            ],
            description: 'Select the Java adaptor to build'
  }

  stages {
    stage('Checkout') {
      steps {
        deleteDir()
        git branch: "$BRANCH_NAME", credentialsId: 'Jenkins', url: 'ssh://git@bitbucket.srv.westpac.com.au/a001c7/loaniq_business_reports.git'
      }
    }//checkout
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
    }//copy
    stage ('SonarQube analysis') {
      steps {

          withSonarQubeEnv('Sonar OBMR') {
            bat 'mvn clean package -U -Dmaven.repo.local=${WORKSPACE}/.repository --settings .m2/maven_settings.xml -DcreateChecksum=true -Dmaven.test.skip=true sonar:sonar ' +
          '-f pom.xml ' +
            '-Dv=$BUILD_ID ' +
            '-Db=' + env.BRANCH_NAME.replace('/', '_') + ' ' +
            '-Dsonar.issuesReport.html.enable=true' +
            '-Dsonar.issuesReport.console.enable=true' +
            '-Dsonar.analysis.mode=preview ' +
            '-Dsonar.login=e4108e933494d2ed2e0601b3f5e88e55608d0f0e ' +
            '-Dsonar.host.url=https://sonar.srv.westpac.com.au/ ' +
            '-Dsonar.language=java ' +
           '-Dsonar.projectVersion=$BRANCH_NAME.$BUILD_ID ' +
            '-Dsonar.projectKey=A001C7_LoanIQ-LoanIq_Business_Reports'

        }
      }
    }//sonar
    stage('Update artifactversion in JSON file') {
        steps {
            script {
                //def version = "${params.Dist_version_num}"
                readpom = readMavenPom file: 'pom.xml';
                artifactversion = readpom.version;
                ADAPTOR_NAME = readpom.name;
                echoHighlightBanner("Parameters",["ADAPTOR_NAME - ${ADAPTOR_NAME}","artifactversion - ${artifactversion}"])

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
    }//update
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
    }//upload
    stage ('maven build') {
      steps {
        script{
        def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactoryCreds'
        def rtMaven = Artifactory.newMavenBuild()
        rtMaven.tool = '3.9.6'// Tool name from Jenkins configuration
        //env.JAVA_HOME = 'E:\\jdk-11.0.6'
        //env.MAVEN_HOME = 'C:\\Program Files\\apache-maven-3.3.9'
        if("$BRANCH_NAME".toLowerCase().contains('develop') || "$BRANCH_NAME".toLowerCase().contains('feature') || "$BRANCH_NAME".toLowerCase().contains('release')) {
          rtMaven.deployer releaseRepo: 'A001C7_LOANIQ_JAVA_SNAPSHOT/LiqBusinessReports', snapshotRepo: 'A001C7_LOANIQ_JAVA_SNAPSHOT/LiqBusinessReports', server: server
        } else if ("$BRANCH_NAME".toLowerCase().contains('master') ) {
         rtMaven.deployer releaseRepo: 'A001C7_LOANIQ_JAVA_RELEASE/LiqBusinessReports', snapshotRepo: 'A001C7_LOANIQ_JAVA_RELEASE/LiqBusinessReports', server: server
        }
        buildInfo = Artifactory.newBuildInfo()
        buildInfo.env.capture = true
        // Delete build after 10 days
        buildInfo.retention maxBuilds: 10, deleteBuildArtifacts: true, async: true
        rtMaven.run pom: 'pom.xml', goals: 'clean install -X -U -e -Dmaven.repo.local=${WORKSPACE}/.repository dependency:copy-dependencies -DcreateChecksum=false -Dmaven.test.failure.ignore=true -U --settings .m2/maven_settings.xml -Db=' + env.BRANCH_NAME.replace('/', '_') + ' -Dv=${BUILD_NUMBER}',buildInfo: buildInfo

        }
      }
    }//mavenBuild
    stage('Zip files for fortify') {
      steps {
        script {
          def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactoryCreds'
          def downloadSpec = """{
                        "files": [{
                           "pattern": "A001C7_LOANIQ_JAVA_SNAPSHOT/fortify_zip_batch/zip_package_LoanIqBusinessReports.bat",
                           "target": "${env.WORKSPACE}/tmp/"
                        }]
                     }"""
                     server.download(downloadSpec)
        }
        bat "${env.WORKSPACE}\\tmp\\fortify_zip_batch\\zip_package_LoanIqBusinessReports.bat"
        bat "7z.exe a -r LoanIqBusinessReports.zip ${env.WORKSPACE}\\fortifyscan\\LoanIqBusinessReports\\*"
        bat "move ${env.WORKSPACE}\\LoanIqBusinessReports.zip ${env.WORKSPACE}\\fortifyscan\\LoanIqBusinessReports_${env.BUILD_NUMBER}.zip"
      }
    }//zip
    stage('Upload zip in expected path') {
      steps {
        script {
          def server = Artifactory.newServer url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'artifactoryCreds'
          def uploadSpec = """{
                     "files": [{
                       "pattern": "${env.WORKSPACE}/fortifyscan/LoanIqBusinessReports_${env.BUILD_NUMBER}.zip",
                       "target": "A001C7_LOANIQ/fortifyscan/LoanIqBusinessReports_fortify/"
                       }]
                       }"""

                       server.upload(uploadSpec)
        }
      }
    }//upload
   	stage('Trigger fortify scan job for component LoanIqBusinessReports') {
      steps {
        script {
          build job: 'A001C7_LoanIQ/A001C7_LoanIQ_Fortify', wait: true, parameters: [
          //	build job: 'https://jenkins.srv.westpac.com.au/job/A004CF_RMW/job/a004cf_rmw_fortify', wait: true, parameters: [
          string(name: 'APP_ID', value: 'A001C7_LOANIQ'),
          string(name: 'COMPONENT', value: 'loaniq_business_reports_java'),
          string(name: 'PJVERID', value: '18146'),
          string(name: 'EMAIL_ADDRESSES', value: 'aruna.chinnamuthu@westpac.com.au,sinduja.sivaraman@westpac.com.au,rutul.jhaveri@westpac.com.au,ishan.deshpande@westpac.com.au,kulal.kumar@westpac.com.au,surya.arumugam@westpac.com.au,bhargav.kumar@westpac.com.au,mohammed.sattar@westpac.com.au,priyanka.rajendran@westpac.com.au'),
           string(name: 'BUILD_LABEL', value: 'A001C7-LoanIQ_loaniq_business_reports_java'),
          string(name: 'CODE_LANGUAGE', value: 'java'),
          string(name: 'BRANCH', value: 'prod'),
          string(name: 'AF_LINK', value:"https://artifactory.srv.westpac.com.au/artifactory/A001C7_LOANIQ/fortifyscan/LoanIqBusinessReports_fortify/LoanIqBusinessReports_${env.BUILD_NUMBER}.zip")
          ]
        }
      }
    }//fortify
  }//stages
}//pipeline
