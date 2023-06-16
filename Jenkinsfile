String VERSION = ""
pipeline {
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: node
            image: node:gallium-alpine3.18
            command:
            - cat
            tty: true
          - name: helm
            image: alpine/helm
            command:
            - cat
            tty: true
          - name: checkmarx
            image: checkmarx/kics:latest
            command:
            - cat
            tty: true
          - name: docker
            image: docker:latest
            command:
            - cat
            tty: true
            volumeMounts:
             - mountPath: /var/run/docker.sock
               name: docker-sock
          volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock    
        '''
    }
  }
  stages {

    stage('Checkmarx IaC Analysis') {
      steps {
        container('checkmarx') {
          sh('/app/bin/kics scan -p ${WORKSPACE} --ci --report-formats html -o ${WORKSPACE} --ignore-on-exit results')
          archiveArtifacts(artifacts: 'results.html', fingerprint: true)
        }
      }
    }  

    stage('Install dependencies') {
      steps {
        container('node') {
          sh "npm install"
        }
      }
    }  

    stage('Lint Code') {
      steps {
        container('node') {
          sh "npm run lint"
        }
      }
    }  

    stage('Unit Test') {
      steps {
        container('node') {
          sh "npm run test"
        }
      }
    }  

    stage('Build Image') {
      steps {
        container('docker') {
            script {
                sh "apk add --no-cache jq"
                env.VERSION = sh(returnStdout: true, script:"jq -r .version package.json")
                VERSION = env.VERSION
                sh "docker build -t gtnode:\${VERSION} ."
            }

        }
      }
    }  

    stage('Publish Image') {
      steps {
        container('docker') {
            withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                sh "docker login -u ${USER} -p ${PASS}"
                sh "docker tag gtnode:\${VERSION} pruebagerentet/gtnode:\${VERSION}"
                sh "docker push pruebagerentet/gtnode:\${VERSION}"
            }
        }
      }
    }  

    

  }

}