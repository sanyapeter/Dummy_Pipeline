pipeline {
    agent any

    parameters {
        choice(
            name: 'BREAK_MODE',
            choices: ['none', 'missing_dep', 'failing_test', 'bad_config', 'slow_deploy'],
            description: 'Failure to simulate for this run'
        )
    }

    environment {
        BREAK_MODE = "${params.BREAK_MODE}"
    }

    stages {
        stage('Pull Code') {
            steps {
                echo "Pulling commit ${env.GIT_COMMIT}"
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'pip install -r requirements.txt'
                sh 'python -c "import app"'
            }
        }

        stage('Test') {
            steps {
                sh 'pytest tests/ -v'
            }
        }

        stage('Deploy') {
            steps {
                script {
                    if (env.BREAK_MODE == 'bad_config') {
                        sh '''
                            echo "Simulating missing DATABASE_URL at deploy time"
                            unset DATABASE_URL
                            python -c "import os; os.environ.pop('DATABASE_URL', None); exec(open('app.py').read())"
                        '''
                    } else if (env.BREAK_MODE == 'slow_deploy') {
                        sh '''
                            echo "Simulating deploy health check timeout..."
                            sleep 5
                            echo "DEPLOY FAILED: health check timeout after 5s (simulated 300s SLA)"
                            exit 1
                        '''
                    } else {
                        echo "Deploy OK"
                    }
                }
            }
        }
    }

    post {
        failure {
            echo "Pipeline failed -- this is where the webhook to Pipeline Doctor fires."
            // In a real setup: httpRequest to API Gateway with build log + BREAK_MODE + changed files
        }
    }
}
