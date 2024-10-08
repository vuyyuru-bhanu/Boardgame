pipeline {
    agent any //{ 
	    //docker {
        //  image 'bhanu3333/test:4' //need to install docker pipeline
        // args '--user root -v /var/run/docker.sock:/var/run/docker.sock' // mount Docker socket to access the host's Docker daemon
   // } 
	//}
    tools {
        jdk 'jdk11'
        maven 'mvn'
    }
   
    stages {
	    stage('Install trivy') {
            steps {
                sh 'apt update && apt install openjdk-11-jdk -y'
                sh 'wget https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.deb'
                sh 'dpkg -i trivy_0.18.3_Linux-64bit.deb'

            }
        }
        //stage('VCS Checkout') {
        //    steps {
                //git branch: 'main', url: 'https://github.com/vuyyuru-bhanu/Boardgame.git'
        //    }
       // }
		stage('File System Scan') {
            steps {
                sh "trivy fs --format table -o trivy-fs-report.html ."
            }
        }

       //stage("Sonarqube Analysis "){
            // steps{
            //     withSonarQubeEnv('sonar-server') {
              //       sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Boardgame \
               //      -Dsonar.java.binaries=. \
               //      -Dsonar.projectKey=Boardgame '''
              //   }
           //  }
       //  }
       //  stage("quality gate"){
          //   steps {
             //    script {
             //      waitForQualityGate abortPipeline: true, credentialsId: 'Sonar-token' 
            //     }
         //   }
       //  }
        //stage('Artifactory configuration') {
           // steps {
             //   rtServer (
             //       id: "JFROG_OCT22",
             //       url: "http://64.227.190.52:8082/artifactory",
              //      credentialsId: "jfrog"
              //  )

              //  rtMavenDeployer (
               //     id: "rel-snapshots",
                //    serverId: "JFROG_OCT22",
                //    releaseRepo: 'libs-release-local/',
                //    snapshotRepo: 'libs-snapshot-local/'
            //    )
          //  }
       // }

       // stage('Exec Maven') {
        //    steps {
         //       rtMavenRun (
          //          tool: 'mvn', // Tool name from Jenkins configuration
           //         pom: 'pom.xml',
            //        goals: 'clean deploy',
             //       deployerId: "rel-snapshots"
             //   )
          //  }
      //  }

       // stage('Publish build info') {
       //     steps {
         //       rtPublishBuildInfo (
          //          serverId: "JFROG_OCT22"
          //      )
          //  }
       // }
		stage ('Build war file'){
            steps{
                sh 'mvn clean install -DskipTests=true'
            }
        }
         //stage("OWASP Dependency Check"){
          //   steps{
           //      dependencyCheck additionalArguments: '--scan ./ --format XML ', odcInstallation: 'DP-Check'
           //      dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
          //   }
        // }

		stage('Build and Push Docker Image') {
      environment {
        DOCKER_IMAGE = "bhanu3333/boardgame:${BUILD_NUMBER}"
        REGISTRY_CREDENTIALS = credentials('docker')
      }
      steps {
        script {
            sh 'docker build -t ${DOCKER_IMAGE} .'
			sh "trivy image --format table -o trivy-image-report.html ${DOCKER_IMAGE} "
            def dockerImage = docker.image("${DOCKER_IMAGE}")
            docker.withRegistry('https://index.docker.io/v1/', "docker") {
                dockerImage.push()
            }
        }
      }
    }
	stage('Update Deployment File') {
        environment {
            GIT_REPO_NAME = "Boardgame"
            GIT_USER_NAME = "vuyyuru-bhanu"
            DOCKER_IMAGE = "bhanu3333/boardgame:${BUILD_NUMBER}"
        }
        steps {
            withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                sh '''
                    git config user.email "prasad.bhanu59@gmail.com"
                    git config user.name "Bhanu Vuyyuru"
                    BUILD_NUMBER=${BUILD_NUMBER}
                    sed -i "s|image: .*|image: ${DOCKER_IMAGE}|" deployment-service.yaml
                    git add deployment-service.yaml
                    git commit -m "Update deployment image of Boardgame to version ${BUILD_NUMBER}"
                    git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main

					
                '''
            }
        }
    }

	
    }
        post {
    always {
        script {
            def jobName = env.JOB_NAME
            def buildNumber = env.BUILD_NUMBER
            def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
            def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'

            def body = """
                <html>
                <body>
                <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                <h2>${jobName} - Build ${buildNumber}</h2>
                <div style="background-color: ${bannerColor}; padding: 10px;">
                <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                </div>
                <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                </div>
                </body>
                </html>
            """

            emailext (
                subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                body: body,
                to: 'prasad.bhanu59@gmail.com',
                from: 'jenkins@example.com',
                replyTo: 'jenkins@example.com',
                mimeType: 'text/html',
                attachmentsPattern: 'trivy-image-report.html'
            )
        }
    }
}
}
    