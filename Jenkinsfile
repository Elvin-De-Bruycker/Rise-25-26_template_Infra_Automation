   node {
       stage('Checkout') {
           checkout scm
       }
       stage('Build and test') {
           sh 'docker build -t riseapp .'
       }
       stage('Deploy') {
           sh 'docker rm -f riserunning || true'
           sh '''docker start risedb || docker run -d --name risedb --network rise-net \
          -e MARIADB_ROOT_PASSWORD=wachtwoord1 \
          -e MARIADB_DATABASE=rise \
          -e MARIADB_USER=rise_usr \
          -e MARIADB_PASSWORD=wachtwoord2 \
          -v rise-data:/var/lib/mysql mariadb:11'''
        sh 'docker rm -f riserunning || true'
        sh '''docker run -d --name riserunning --network rise-net --restart on-failure -p 5001:8080 \
          -e "ConnectionStrings__DatabaseConnection=Server=risedb;Port=3306;Database=rise;User=rise_usr;Password=wachtwoord2" \
          riseapp'''
       }
   }
