   node {
       stage('Checkout') {
           checkout scm
       }
       stage('Build and test') {
           sh 'docker build -t riseapp .'
       }
       stage('Deploy') {
           sh 'docker rm -f riserunning || true'
           sh 'docker run -d --name riserunning -p 5001:8080 riseapp'
       }
   }
