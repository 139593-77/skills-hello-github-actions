import org.apache.commons.io.FilenameUtils
def adaptor_path = ""
def artifact_sub_path = "A001C7_LOANIQ"
def version = ""
def json_file_name = ""
def scheduledParentJobNumber = ""
def scheduledParentJob = ""
def parentDownstreamJobURL = ""
def checksumStatus = ""
def checkSumJobStatus = ""


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
    } else {
        list += msgs
    }
    return list
}

def triggerJob(policyName, app_server, json_file_name) {
    // Determine the job name based on the environment
    def jobName = params.ENV_NAME.contains("UAT") || params.ENV_NAME.contains("SVP") ?
        'A001C7_LoanIQ/Non-Prod/JAVA-Chef_OnDemand_UAT_Deployment' :
        'A001C7_LoanIQ/Non-Prod/JAVA - Chef_OnDemand_NonProd_Deployment'

    // Trigger the job with the specified parameters
    def parentJobResult = build job: jobName, parameters: [
        string(name: 'HOSTING_ENV', value: 'on-premise'),
        string(name: 'SERVER_LABEL', value: app_server),
        string(name: 'POLICY_REPO', value: 'EntChef_Prod_Policy'),
        string(name: 'POLICY_NAME', value: policyName),
        string(name: 'POLICY_GROUP', value: 'default'),
        string(name: 'OVERRIDE_ATTRIBUTES_FILE', value: json_file_name)
    ], waitForStart: true

    // Return the job details
    return [parentJobResult.getFullProjectName(), parentJobResult.number]
}

def fetchDownstreamJobUrl(scheduledParentJob, scheduledParentJobNumber, policyName){
  // --------------- FIND THE DOWNSTREAM JOB OF PIPELINE 1 -------------------------//
  // println scheduledParentJob
  // println scheduledParentJobNumber
  def filteredParentDownstreamJobArray = []
  withCredentials([usernamePassword(credentialsId: 'SRV-WIB-DEVOPS', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
    def parentDownstreamJob = sh(script: 'curl -u $USERNAME:$PASSWORD -X GET -H Content-Type:application/json -g https://jenkins.srv.westpac.com.au/job/A00619_EntDevOps/job/OBM/job/Chef_OnDemand_Deployment_Downstream/api/json?tree=builds[url,actions[parameters[name,value],causes[upstreamBuild,upstreamProject,upstreamUrl]],result,building,number,duration,estimatedDuration]\\{0,15\\}', returnStdout: true)
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
      println filteredParentDownstreamJobArray.url[0].getClass()
      if (filteredParentDownstreamJobArray.url[0]?.trim()) {
        if (!(filteredParentDownstreamJobArray.isEmpty())){
          if (!(filteredParentDownstreamJobArray.url[0].getClass().equals(net.sf.json.JSONNull))) {
            // println filteredParentDownstreamJobArray.url[0].getClass()
            break
          }//notnull
        }//notempty
      }//presence
    }// while loop
  parentDownstreamJobURL = filteredParentDownstreamJobArray.url[0]
  return parentDownstreamJobURL
}

def parseParentDownstreamJobURL(parentDownstreamJobURL){
  withCredentials([usernamePassword(credentialsId: 'SRV-WIB-DEVOPS', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
    while (true) {
      echo "${String.format('%tF %<tH:%<tM', java.time.LocalDateTime.now())} - SLEEP"
      sleep(60)
      echo "parentDownstreamJobURL - ${parentDownstreamJobURL}"
      echo "Type of parentDownstreamJobURL - ${parentDownstreamJobURL.getClass()}"
      if (parentDownstreamJobURL?.trim()){
        if (!(parentDownstreamJobURL.isEmpty())){
          def parentDownstreamJobResponse = sh(script: "curl -u $USERNAME:$PASSWORD -X GET -H Content-Type:application/json -g ${parentDownstreamJobURL}api/json", returnStdout: true)
          parentDownstreamjsonObj = readJSON text: parentDownstreamJobResponse
          //Uncomment below when chef root element issue gets resolved
          //echo "Result - ${parentDownstreamjsonObj.result}"
          /*if (!(parentDownstreamjsonObj.result.getClass().equals(net.sf.json.JSONNull))) {
            echoGreenString("${String.format('%tF %<tH:%<tM', java.time.LocalDateTime.now())} - Result came")
            echoGreenString("${parentDownstreamjsonObj.result}")
            break
          }*/
          break
        }
      }//if
      sleep(30)
    }// while loop

    if(parentDownstreamjsonObj.result){
      parentJobExecStatus = ""
      parentJobExecStatus = parentDownstreamjsonObj.result
      //Uncomment below when chef root element issue gets resolved
      //println(parentJobExecStatus)
      echoGreenBannerNoBackground(" JAVA CD Result at ${String.format('%tF %<tH:%<tM', java.time.LocalDateTime.now())}", ["${parentDownstreamJobURL}/console"])
    }//only when the Job execution is completed, read the consoleLog to parse
    else{
      echoHeader("          ********** ELSE **********")
    }
  }//withCred
  return [parentJobExecStatus]
}//parseParentDownstreamJobURL

def parseDownstreamConsole(downStreamJobUrl, Env_Name){
  // downStreamJobUrl = ""
  def l = [:]
  withCredentials([usernamePassword(credentialsId: 'SRV-WIB-DEVOPS', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
    //sleep(60)
    def downstreamJobConsoleResponse = sh(script: "curl -u $USERNAME:$PASSWORD -X GET -H Content-Type:application/json -g ${downStreamJobUrl}/logText/progressiveText", returnStdout: true)
      // echo "parentDownstreamJobConsoleResponse - ${parentDownstreamJobConsoleResponse}"

    String[] logsArr = downstreamJobConsoleResponse.split("\n");
    length = logsArr.length
    parentJobExecStatus = ""
    srcBakFileforRestorePath = ""
    dBRefreshOutfilePath = ""
    shortened_env_name = ''

    incidentString = "${Env_Name}_SnowIncident="
    // println incidentString
    for(line in logsArr){
      incidentStatus = ""
      if (line.contains(incidentString)){
        // println "Present"
        incidentStatus = line.split("${Env_Name}_SnowIncident=")[1].replaceAll("=","")
        // println incidentStatus
        incidentStatus = incidentStatus.trim()
        // println incidentStatus
        l = Eval.me(incidentStatus)
        println l
        for(item in l){
          fileName = item[0]
          fileContent = item[1].replaceAll(",","")
          baseName = item[2]
          envName = item[3]
        }
      }
    }
  }
  return l
}//parseDownstreamConsole

import groovy.json.*

pipeline {
    agent {
        label 'enterprise_devops&&linux'
    }

    options {
        ansiColor('xterm')
        disableConcurrentBuilds()
    }

    environment {
        JAVA_HOME = 'E:\\jdk-11.0.6'
        policy_repo = "EntChef_Prod_Policy"
    }

    parameters {
        choice(
            name: 'ENV_NAME',
            choices: [
                "Dev1 - au2106sde042.esdevau.wbcdevau.westpac.com.au",
                "Dev2 - au2106sde043.esdevau.wbcdevau.westpac.com.au",
                "Dev3 - au2106sde044.esdevau.wbcdevau.westpac.com.au",
                "Dev4 - au2106sde045.esdevau.wbcdevau.westpac.com.au",
                "Dev5 - au2106sde046.esdevau.wbcdevau.westpac.com.au",
                "Dev6 - au2106sde047.esdevau.wbcdevau.westpac.com.au",
                "SIT1 - twa200625165534.estestau.wbctestau.westpac.com.au",
                "SIT2 - twa200625165603.estestau.wbctestau.westpac.com.au",
                "SIT3 - twa200625165624.estestau.wbctestau.westpac.com.au",
                "SIT4 - twa200629154846.estestau.wbctestau.westpac.com.au",
                "UATB1 - au2106ste458.estestau.wbctestau.westpac.com.au",
                "UATB2 - au2106ste459.estestau.wbctestau.westpac.com.au",
                "UATU1 - au2106ste460.estestau.wbctestau.westpac.com.au",
                "UATU2 - au2106ste461.estestau.wbctestau.westpac.com.au",
                "SVPB1 - au2004ste374.estestau.wbctestau.westpac.com.au",
                "SVPB2 - au2004ste375.estestau.wbctestau.westpac.com.au",
                "SVPU1 - au2004ste376.estestau.wbctestau.westpac.com.au",
                "SVPU2 - au2004ste377.estestau.wbctestau.westpac.com.au",
                "DEV1-Windows2022 - dwa240627153059.esdevau.wbcdevau.westpac.com.au",
                "DEV2-Windows2022 - dwa240627153106.esdevau.wbcdevau.westpac.com.au",
                "SIT1-Windows2022 - twa240912135957.estestau.wbctestau.westpac.com.au",
                "SIT5_Windows2022 - twa240912140002.estestau.wbctestau.westpac.com.au",
                "UATB1_Windows2022 - twa250108080451.estestau.wbctestau.westpac.com.au",
                "UATB2_Windows2022 - twa250107153812.estestau.wbctestau.westpac.com.au",
                "UATU1_Windows2022 - twa250108080551.estestau.wbctestau.westpac.com.au",
                "UATU2_Windows2022 - twa250107153807.estestau.wbctestau.westpac.com.au",
                "SVPB1_Windows2022 - twa250304112123.estestau.wbctestau.westpac.com.au",
                "SVPB2_Windows2022 - twa250304112144.estestau.wbctestau.westpac.com.au",
                "SVPU1_Windows2022 - twa250304112139.estestau.wbctestau.westpac.com.au",
                "SVPU2_Windows2022 - twa250304112134.estestau.wbctestau.westpac.com.au",
                "SVPB3_Windows2022 - twa250304112129.estestau.wbctestau.westpac.com.au",
                "SVPB4_Windows2022 - twa250304112132.estestau.wbctestau.westpac.com.au",
                "SVPU3_Windows2022 - twa250304112138.estestau.wbctestau.westpac.com.au",
                "SVPU4_Windows2022 - twa250304112121.estestau.wbctestau.westpac.com.au"
            ]
        )
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
        )
        string(name: 'JAR_package_version', description: "Enter the version manually if specific version or any old built version needs to be deployed")
        string(name: 'CHG_NUMBER', description: "Enter the change number if it is UAT env else you can leave it empty")
    }

    stages {
        stage('Validation'){
            steps{
                script{

                    if (JAR_package_version.isEmpty()) {
                        echoRedBanner("Validation Error", ["JAR_package_version is mandatory"])
                        error("JAR_package_version is mandatory")
                    }
                    envNameFull = "${params.ENV_NAME}"
                    if (envNameFull.contains("-")) {
                        shortened_env_name = envNameFull.split(' - ')[0]
                    } else if (envNameFull.contains("-")) {
                        shortened_env_name = envNameFull.split('_')[0]
                    }

                    echoHighlightBanner("INPUT PARAMS",["ARTIFACTORY_TARGET - A001C7_LOANIQ_JAVA_SNAPSHOT","shortened_env_name - ${shortened_env_name}","Env_Name - ${Env_Name}"])
                
                }// script
            }// steps
        }// Update Json

        stage("Approval") {
            steps {
                script {
                    def env = params.ENV_NAME
                    echo "Environment: ${env}"

                    // Check if the environment requires approval
                    if (env.contains("UAT") || env.contains("SVP")) {
                        // Define email recipients as a list for better maintainability
                        def emailRecipients = [
                            "sinduja.sivaraman@westpac.com.au",
                            "kulal.kumar@westpac.com.au",
                            "ishan.deshpande@westpac.com.au",
                            "mohammed.sattar@westpac.com.au",
                            "vijaykumar.jammikunta@westpac.com.au",
                            "rajeshkumar.panda@westpac.com.au",
                            "arpita.chatterjee@westpac.com.au",
                            "Kavitha.m@westpac.com.au",
                            "Muthukumar.nanjundasamy@westpac.com.au",
                            "akash.jain@westpac.com.au",
                            "hema.mandapati@westpac.com.au"
                        ].join(",")

                        // Send approval email
                        emailext(
                            mimeType: 'text/html',
                            subject: "[Jenkins JAR Pipeline ${env}] ${currentBuild.fullDisplayName}",
                            to: emailRecipients,
                            body: """
                                <html>
                                    <body>
                                        Hi all,
                                        <br><br>
                                        Jar_pipeline for ${env} has been triggered.
                                        <br><br>
                                        <a href="${BUILD_URL}input">Click here to approve/reject the build</a>
                                        <br><br>
                                        <br>
                                        Thanks & Regards,
                                        <br>
                                        DevOps Uplift Team
                                    </body>
                                </html>
                            """
                        )

                        // Wait for approval
                        timeout(time: 1, unit: 'HOURS') {
                            approvalStatus = input(
                                message: 'Do you want to approve this build?',
                                ok: 'Submit',
                                submitter: 'L146939,M059694,L171212,L195701,M061872,L171249,L149713,L197829,L165936,L205704,L205703',
                                submitterParameter: 'approverID'
                            )
                        }

                        echo "Approval status: ${approvalStatus}"
                    }
                }
            }
        }

        stage('Download version.json') {
            steps {
                script {
                    // Determine the artifact sub-path based on the environment
                    artifact_sub_path = params.ENV_NAME.contains("UAT") || params.ENV_NAME.contains("SVP") ?
                        "A001C7_LOANIQ_JAVA_RELEASE" : "A001C7_LOANIQ_JAVA_SNAPSHOT"

                    // Get the user-provided version
                    def userProvidedVersion = params.JAR_package_version?.trim()
                    echo "User provided JAR_PACKAGE_Version: '${userProvidedVersion}'"

                    // Check if the user-provided version is empty or null
                    if (!userProvidedVersion) {
                        echo "No version provided by the user. Downloading version.json from Artifactory..."

                        // Download the version.json from Artifactory
                        def server = Artifactory.newServer(
                            url: 'https://artifactory.srv.westpac.com.au/artifactory/',
                            credentialsId: 'artifactoryCreds'
                        )
                        def downloadSpec = [
                            files: [
                                [
                                    pattern: "${artifact_sub_path}/${params.JAVA_ADAPTOR_NAME}/Attributes/${params.JAVA_ADAPTOR_NAME}_version.json",
                                    target: "${env.WORKSPACE}/"
                                ]
                            ]
                        ]
                        server.download(downloadSpec as String)

                        // Read the version from the downloaded JSON file
                        def jsonFilePath = "${env.WORKSPACE}/${params.JAVA_ADAPTOR_NAME}/Attributes/${params.JAVA_ADAPTOR_NAME}_version.json"
                        def versionInfo = readJSON(file: jsonFilePath)
                        version = versionInfo.current_package_version?.trim()
                        echo "Version from version.json: ${version}"
                    } else {
                        // Use the user-provided version directly
                        version = userProvidedVersion
                        echo "Version from user input: ${version}"
                    }

                    // Log the selected version for deployment
                    echo "Selected version for deployment: ${version}"
                }
            }
        }

        stage('Update JAVA json version file') {
            steps {
                script {
                    def JAVA_NAME = "${params.JAVA_ADAPTOR_NAME}"
                    echo "JAVA_NAME: $JAVA_NAME"

                    // Define a map for JAVA_NAME configurations
                    def javaConfig = [
                        "LiqBaseRatesAdaptor"   : ["au/com/westpac/debtmarkets/liq", "E:/LoanIQ/intfc/bin/LiqAdaptors/LiqBaseRatesAdaptor", "E:/LoanIQ/intfc/bin/LiqAdaptors/LiqBaseRatesAdaptor/LiqBaseRatesAdaptor*.jar"],
                        "BaseRateReport"        : ["au/com/westpac", "E:/LoanIQ/intfc/bin/LiqAdaptors/BaseRateReportAutomation", "E:/LoanIQ/intfc/bin/LiqAdaptors/BaseRateReportAutomation/BaseRateReport*.jar"],
                        "LoanIqReutersRateReview": ["com/loaniq", "E:/LoanIQ/intfc/bin/LiqAdaptors/LoanIqReutersRateReview", "E:/LoanIQ/intfc/bin/LiqAdaptors/LoanIqReutersRateReview/LoanIqReutersRateReview*.jar"],
                        "loanFundingAdapter"    : ["au/com/westpac/liq/loanfunding", "E:/LoanIQ/intfc/bin/LiqAdaptors/LoanFundingService", "E:/LoanIQ/intfc/bin/LiqAdaptors/LoanFundingService/loanFundingAdapter*.jar"],
                        "LoaniqDataIngestion"   : ["au/com/westpac/liq/dataingestion", "E:/LoanIQ/intfc/bin/LiqAdaptors/LoaniqDataIngestion", "E:/LoanIQ/intfc/bin/LiqAdaptors/LoaniqDataIngestion/LoaniqDataIngestion*.jar"],
                        "LoanIQEmailFaxAgent"   : ["au/com/westpac/debtmarkets/liq/emailfaxagent", "E:/LoanIQ/intfc/LoanIQEmailFaxAgent/lib", "E:/LoanIQ/intfc/LoanIQEmailFaxAgent/lib/LoanIQEmailFaxAgent*.jar"],
                        "AccrualsMonitor"       : ["au/com/westpac/debtmarkets/liq", "E:/LoanIQ/intfc/AccrualsMonitor", "E:/LoanIQ/intfc/AccrualsMonitor/AccrualsMonitor*.jar"],
                        "ArchivalAgent"         : ["au/com/westpac/wib/app", "E:/LoanIQ/intfc/ArchiveAgent", "E:/LoanIQ/intfc/ArchiveAgent/ArchivalAgent*.jar"],
                        "LiqFXRatesAdaptor"     : ["/au/com/westpac/debtmarkets/liq", "E:/LoanIQ/intfc/bin/LiqAdaptors/LiqFXAdaptor", "E:/LoanIQ/intfc/bin/LiqAdaptors/LiqFXAdaptor/LiqFXRatesAdaptor.jar"],
                        "FileMonitor"           : ["/au/com/westpac/debtmarkets/liq", "E:/LoanIQ/intfc/FileMonitor", "E:/LoanIQ/intfc/FileMonitor/FileMonitor*.jar"],
                        "LiqPayments"           : ["au/com/liq", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-Payments-Service", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-Payments-Service/LiqPayments*.jar"],
                        "LiqBusinessReports"    : ["au/com/westpac/liq/loaniqbusinessreports", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-BusinessReports-Batch", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-Business_Reports/LiqBusinessReports*.jar"],
                        "LiqDBApi"              : ["com/loaniq/dbapi", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-Integration-Service/Liq-DB-Api", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-Integration-Service/Liq-DB-Api/LiqDBApi*.jar"],
                        "LiqMQApi"              : ["com/loaniq/mqapi", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-Integration-Service/Liq-MQ-Api", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-Integration-Service/Liq-MQ-Api/LiqMQApi*.jar"],
                        "LiqEmailApi"           : ["com/loaniq/emailapi", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-Integration-Service/Liq-Email-Api", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-Integration-Service/Liq-Email-Api/LiqEmailApi*.jar"],
                        "LiqUtilityApi"         : ["com/loaniq/utilityapi", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-Integration-Service/Liq-Utility-Api", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-Integration-Service/Liq-Utility-Api/LiqUtilityApi*.jar"],
                        "LiqProdXref"           : ["au/com/westpac/liq", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-ProdXref-Batch", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-ProdXref-Batch/LiqProdXref*.jar"],
                        "LiqCustomer"           : ["au/com/westpac/liq/customer", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-Customer-Service", "E:/LoanIQ/intfc/bin/JavaAdaptors/Liq-Customer-Service/LiqCustomer*.jar"]
                    ]

                    def package_path = ''
                    def delete_package_path = ''
                    (adaptor_path, package_path, delete_package_path) = javaConfig[JAVA_NAME]

                    // Determine artifact sub-path and JSON file name based on environment
                    artifact_sub_path = params.ENV_NAME.contains("UAT") || params.ENV_NAME.contains("SVP") ?
                        "A001C7_LOANIQ_JAVA_RELEASE" : "A001C7_LOANIQ_JAVA_SNAPSHOT"
                    json_file_name = params.ENV_NAME.contains("UAT") || params.ENV_NAME.contains("SVP") ?
                        "non_prod_UAT_${JAVA_NAME}_jar_pipeline_${BUILD_NUMBER}.json" : "non_prod_${JAVA_NAME}_jar_pipeline_${BUILD_NUMBER}.json"

                    echo "version: $version"
                    echo "java: $JAVA_NAME"
                    echo "json: $json_file_name"
                    echo "artifact_sub_path: $artifact_sub_path"
                    echo "ENV_NAME: ${params.ENV_NAME}"

                    // Write JSON file
                    writeFile(file: "${env.WORKSPACE}/${json_file_name}",
                        text: """\
                        {
                            "wbg_a001c7_loaniq": {
                                "artifactory": {
                                    "repo": "https://artifactory.srv.westpac.com.au/artifactory/${artifact_sub_path}/"
                                },
                                "appid": "a001c7",
                                "pipeline_type": "jar_deployment",
                                "jar_deployment": {
                                    "current_package_version": \"${version}\",
                                    "current_java_adaptor": \"${JAVA_NAME}\",
                                    "current_json_file_name": \"${json_file_name}\",
                                    "environment": "${params.ENV_NAME}",
                                    "package_name": "${JAVA_NAME}-${version}",
                                    "change_num": "${params.CHG_NUMBER}",
                                    "local_base_path": "E:/",
                                    "delete_devops_path": "E:/devops",
                                    "local_devops_path": "E:/devops_backup",
                                    "inspec_path": "E:/devops_backup/JAR_Checksum_backup",
                                    "local_devops_jar_pipeline_path": "E:/devops_backup/jar_pipeline",
                                    "local_devops_jar_pipeline_builds_path": "E:/devops_backup/jar_pipeline/artifacts",
                                    "source_artifact_url_path": "https://artifactory.srv.westpac.com.au/artifactory/${artifact_sub_path}/${JAVA_NAME}/${adaptor_path}/${JAVA_NAME}/${version}/${JAVA_NAME}-${version}.jar",
                                    "source_artifact_package_dir": "E:/devops_backup/jar_pipeline/artifacts/${JAVA_NAME}",
                                    "source_artifact_package_file_loc": "E:/devops_backup/jar_pipeline/artifacts/${JAVA_NAME}/${JAVA_NAME}-${version}.jar",
                                    "source_artifactory_json_file_loc": "https://artifactory.srv.westpac.com.au/artifactory/${artifact_sub_path}/build/0.0.1/${json_file_name}",
                                    "json_file_download_path": "E:/devops_backup/jar_pipeline/artifacts/${json_file_name}",
                                    "project_dir": "${package_path}",
                                    "backup_package_delete": "${delete_package_path}",
                                    "local_encryption_keys_path": "E:/devops/encryption_keys",
                                    "drive": "E:",
                                    "source_databag_srv_act": "a001c7-prd-secrets",
                                    "source_databag_loc": "a001c7-prd-secrets.json"
                                }
                            }
                        }
                        """.stripIndent()
                    )
                }
            }
        }

        stage('Upload JAVA version JSON file to Artifactory') {
            steps {
                script {
                    // Initialize Artifactory server connection
                    def server = Artifactory.newServer(
                        url: 'https://artifactory.srv.westpac.com.au/artifactory/',
                        credentialsId: 'accesscredential'
                    )

                    // Define the upload specification
                    def uploadSpec = """{
                        "files": [
                            {
                                "pattern": "${env.WORKSPACE}/${json_file_name}",
                                "target": "${artifact_sub_path}/build/0.0.1/",
                                "props": "type=json;status=ready"
                            }
                        ]
                    }"""

                    // Upload the JSON file to Artifactory
                    server.upload(uploadSpec)
                }
            }
        }

        stage('Run the Policy') {
            steps {
                script {
                    def env_name = params.ENV_NAME
                    def app_server = mapAppServer(env_name)
                    def policyName = "a001c7_Loaniq-jar-deploy"

                    echo "Running the policy for environment: ${env_name}"
                    //echoBanner("Trigger Job", "policyName: ${policyName}", "appServer: ${app_server}")

                    // Trigger the Checksum validation
                    (scheduledParentJob, scheduledParentJobNumber) = triggerJob(policyName, app_server, json_file_name)

                    // Wait for downstream job to start
                    sleep(120)

                    // Fetch downstream job URL and parse its result
                    def downStreamJobUrl = fetchDownstreamJobUrl(scheduledParentJob, scheduledParentJobNumber, policyName)
                    (jobExecStatus) = parseParentDownstreamJobURL(downStreamJobUrl)

                    //Below block to be uncommented if chef root element issue gets resolved
                    /*echoHighlightBanner("  jobExecStatus ",["${jobExecStatus}"])
                    if (jobExecStatus.contains("SUCCESS")){
                        echoGreenString("          ********** JarCD Job Executed Successfully **********")
                    }
                    else{
                        echoRedString("          ********** JarCD Job Failed **********")
                        error("          ********** JarCD Job Failed **********")
                    }*/
                }
            }
        }
    }
}

def mapAppServer(env_name) {
    println "mapAppServer env_name : ${env_name}"

    // Define a map of environment names to server addresses
    def envToServerMap = [
        "Dev1 - au2106sde042.esdevau.wbcdevau.westpac.com.au" : "au2106sde042.esdevau.wbcdevau.westpac.com.au",
        "Dev2 - au2106sde043.esdevau.wbcdevau.westpac.com.au" : "au2106sde043.esdevau.wbcdevau.westpac.com.au",
        "Dev3 - au2106sde044.esdevau.wbcdevau.westpac.com.au" : "au2106sde044.esdevau.wbcdevau.westpac.com.au",
        "Dev4 - au2106sde045.esdevau.wbcdevau.westpac.com.au" : "au2106sde045.esdevau.wbcdevau.westpac.com.au",
        "Dev5 - au2106sde046.esdevau.wbcdevau.westpac.com.au" : "au2106sde046.esdevau.wbcdevau.westpac.com.au",
        "Dev6 - au2106sde047.esdevau.wbcdevau.westpac.com.au" : "au2106sde047.esdevau.wbcdevau.westpac.com.au",
        "SIT1 - twa200625165534.estestau.wbctestau.westpac.com.au" : "twa200625165534.estestau.wbctestau.westpac.com.au",
        "SIT2 - twa200625165603.estestau.wbctestau.westpac.com.au" : "twa200625165603.estestau.wbctestau.westpac.com.au",
        "SIT3 - twa200625165624.estestau.wbctestau.westpac.com.au" : "twa200625165624.estestau.wbctestau.westpac.com.au",
        "SIT4 - twa200629154846.estestau.wbctestau.westpac.com.au" : "twa200629154846.estestau.wbctestau.westpac.com.au",
        "UATB1 - au2106ste458.estestau.wbctestau.westpac.com.au" : "au2106ste458.estestau.wbctestau.westpac.com.au",
        "UATB2 - au2106ste459.estestau.wbctestau.westpac.com.au" : "au2106ste459.estestau.wbctestau.westpac.com.au",
        "UATU1 - au2106ste460.estestau.wbctestau.westpac.com.au" : "au2106ste460.estestau.wbctestau.westpac.com.au",
        "UATU2 - au2106ste461.estestau.wbctestau.westpac.com.au" : "au2106ste461.estestau.wbctestau.westpac.com.au",
        "SVPB1 - au2004ste374.estestau.wbctestau.westpac.com.au" : "au2004ste374.estestau.wbctestau.westpac.com.au",
        "SVPB2 - au2004ste375.estestau.wbctestau.westpac.com.au" : "au2004ste375.estestau.wbctestau.westpac.com.au",
        "SVPU1 - au2004ste376.estestau.wbctestau.westpac.com.au" : "au2004ste376.estestau.wbctestau.westpac.com.au",
        "SVPU2 - au2004ste377.estestau.wbctestau.westpac.com.au" : "au2004ste377.estestau.wbctestau.westpac.com.au",
        "DEV1-Windows2022 - dwa240627153059.esdevau.wbcdevau.westpac.com.au" : "dwa240627153059.esdevau.wbcdevau.westpac.com.au",
        "DEV2-Windows2022 - dwa240627153106.esdevau.wbcdevau.westpac.com.au" : "dwa240627153106.esdevau.wbcdevau.westpac.com.au",
        "SIT1-Windows2022 - twa240912135957.estestau.wbctestau.westpac.com.au" : "twa240912135957.estestau.wbctestau.westpac.com.au",
        "SIT5_Windows2022 - twa240912140002.estestau.wbctestau.westpac.com.au" : "twa240912140002.estestau.wbctestau.westpac.com.au",
        "UATB1_Windows2022 - twa250108080451.estestau.wbctestau.westpac.com.au" : "twa250108080451.estestau.wbctestau.westpac.com.au",
        "UATB2_Windows2022 - twa250107153812.estestau.wbctestau.westpac.com.au" : "twa250107153812.estestau.wbctestau.westpac.com.au",
        "UATU1_Windows2022 - twa250108080551.estestau.wbctestau.westpac.com.au" : "twa250108080551.estestau.wbctestau.westpac.com.au",
        "UATU2_Windows2022 - twa250107153807.estestau.wbctestau.westpac.com.au" : "twa250107153807.estestau.wbctestau.westpac.com.au",
        "SVPB1_Windows2022 - twa250304112123.estestau.wbctestau.westpac.com.au" : "twa250304112123.estestau.wbctestau.westpac.com.au",
        "SVPB2_Windows2022 - twa250304112144.estestau.wbctestau.westpac.com.au" : "twa250304112144.estestau.wbctestau.westpac.com.au",
        "SVPU1_Windows2022 - twa250304112139.estestau.wbctestau.westpac.com.au" : "twa250304112139.estestau.wbctestau.westpac.com.au",
        "SVPU2_Windows2022 - twa250304112134.estestau.wbctestau.westpac.com.au" : "twa250304112134.estestau.wbctestau.westpac.com.au",
        "SVPB3_Windows2022 - twa250304112129.estestau.wbctestau.westpac.com.au" : "twa250304112129.estestau.wbctestau.westpac.com.au",
        "SVPB4_Windows2022 - twa250304112132.estestau.wbctestau.westpac.com.au" : "twa250304112132.estestau.wbctestau.westpac.com.au",
        "SVPU3_Windows2022 - twa250304112138.estestau.wbctestau.westpac.com.au" : "twa250304112138.estestau.wbctestau.westpac.com.au",
        "SVPU4_Windows2022 - twa250304112121.estestau.wbctestau.westpac.com.au" : "twa250304112121.estestau.wbctestau.westpac.com.au"
    ]

    // Return the server address if the environment name exists in the map
    if (envToServerMap.containsKey(env_name)) {
        return envToServerMap[env_name]
    } else {
        error "Unknown environment: ${env_name}"
    }
}
