def echoBanner(def ... msgs) {
   echo createBanner(msgs)
}

def echoHighlightBanner(def ... msgs) {
  // white background black bold letters
  // echo "\033[90m\033[107m\033[1m${createBanner(msgs)}\033[0m"
  // No background Blue bold letters
  echo "\033[34m\033[1m${createBanner(msgs)}\033[0m"
}

def echoRedBanner(def ... msgs) {
  echo "\033[31m${createBanner(msgs)}\033[0m"
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

pipeline {
    agent any
    options {
        ansiColor('xterm')
    }
    parameters {
        string(name: 'PACKAGE_NAME', defaultValue: '', description: 'Enter the package name. For Ex: RDPipeline_feature_MRR-22620_Rename_496.zip')
        string(name: 'WHL_FILE', defaultValue: '', description: 'Enter the whl file name. For Ex: rdpipeline-1.3.11-py2.py3-none-any.whl')
        choice(name: 'ENV_NAME', choices: ['dev', 'sit', 'uat', 'svp', 'prod'], description: 'Choose the Environment Name')
    }
    stages {
        stage('Input Validation Check') {
            steps {
                script {
                    if (!params.PACKAGE_NAME?.trim()) {
                        echoRedBanner("Validation Errors", "Please enter the package name to append in JSON file For Ex: RDPipeline_feature_MRR-22620_Rename_496.zip")
                        error("Invalid Input Error")
                    }
                    if (!params.WHL_FILE?.trim()) {
                        echoRedBanner("Validation Errors", "Please enter the whl file name to append in JSON file For Ex: rdpipeline-1.3.11-py2.py3-none-any.whl")
                        error("Invalid Input Error")
                    }
                    if (!params.PACKAGE_NAME.contains('.zip')) {
                        echoRedBanner("Validation Errors", "Please enter the package name with .zip extension to append in JSON file For Ex: RDPipeline_feature_MRR-22620_Rename_496.zip")
                        error("Invalid Input Error")
                    }
                    if (!params.WHL_FILE.contains('.whl')) {
                        echoRedBanner("Validation Errors", "Please enter the whl file name with .whl extension to append in JSON file For Ex: rdpipeline-1.3.11-py2.py3-none-any.whl")
                        error("Invalid Input Error")
                    }
                }
            }
        }
        stage('JSON Creation and Upload') {
            steps {
                script {
                    def jsonFilePath = "${WORKSPACE}/rdpipeline_deploy_${ENV_NAME}_version_${env.BUILD_NUMBER}.json"
                    writeFile(file: jsonFilePath, text: """\
                    {
                        "ratesdb": {
                            "pkg_name": "${PACKAGE_NAME}",
                            "deploy_path": "/apps/market_data/risk_data/pipelines/batch/rdpipeline/setup",
                            "whl_file": "${WHL_FILE}"
                        }
                    }
                    """.stripIndent())

                    echo "JSON file content:"
                    echo readFile(jsonFilePath)

                    def server = Artifactory.newServer(url: 'https://artifactory.srv.westpac.com.au/artifactory/', credentialsId: 'A0032D_SA_0001_PRD_Art')
                    def artifact_sub_path = "A0032D_RatesDb/Attributes"
                    def uploadSpec = """{
                        "files": [{
                            "pattern": "${jsonFilePath}",
                            "target": "${artifact_sub_path}/",
                            "props": "type=json;status=ready"
                        }]
                    }"""
                    server.upload(uploadSpec)
                    echoBanner("Click the below artifactory link to verify","https://artifactory.srv.westpac.com.au/artifactory/A0032D_RatesDb/Attributes/")

                }
            }
        }
    }
}
    
