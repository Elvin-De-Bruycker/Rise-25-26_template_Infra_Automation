node {
    stage('Checkout') {
        checkout scm
    }

    stage('Build and test') {
        sh 'docker build -t riseapp .'
    }

    stage('Deploy staging') {
        // Zorg dat het Docker-netwerk bestaat
        sh 'docker network inspect rise-net >/dev/null 2>&1 || docker network create rise-net'

        // Start de database of maak ze aan
        sh '''
            docker start risedb || docker run -d --name risedb --network rise-net \
                --restart unless-stopped \
                -e MARIADB_ROOT_PASSWORD=wachtwoord1 \
                -e MARIADB_DATABASE=rise \
                -e MARIADB_USER=rise_usr \
                -e MARIADB_PASSWORD=wachtwoord2 \
                -v rise-data:/var/lib/mysql \
                mariadb:11
        '''

        // Verwijder de vorige applicatiecontainer
        sh 'docker rm -f riserunning || true'

        // Start de nieuwe applicatiecontainer
        sh '''
            docker run -d --name riserunning \
                --network rise-net \
                --restart unless-stopped \
                -p 5001:8080 \
                -e "ConnectionStrings__DatabaseConnection=Server=risedb;Port=3306;Database=rise;User=rise_usr;Password=wachtwoord2" \
                riseapp \
                -e ASPNETCORE_ENVIRONMENT=Development \
        '''
    }

    stage('Deploy production') {
        withCredentials([string(credentialsId: 'rise-prod-db-password', variable: 'DB_PASSWORD')]) {
            sshagent(['dmz010-deploy']) {
                // Alle docker-commando's in dit blok draaien op dmz010
                withEnv(['DOCKER_HOST=ssh://elvin@192.0.2.10']) {
                    sh 'docker build -t riseapp .'
                    sh 'docker rm -f riserunning || true'
                    sh '''
                        docker run -d --name riserunning \
                            --restart unless-stopped \
                            -p 5001:8080 \
                            -e "ConnectionStrings__DatabaseConnection=Server=192.0.2.20;Port=3306;Database=db;User=db_usr;Password='$DB_PASSWORD'" \
                            riseapp
                    '''
                }
            }
        }
    }
}
