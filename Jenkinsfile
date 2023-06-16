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
        container('node') {
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





  }
    post {
      always {
        container('docker') {
          sh 'docker logout'
      }
      }
    }
}