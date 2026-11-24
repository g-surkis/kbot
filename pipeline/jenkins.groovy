pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: golang
    image: golang:1.27.3
    command: [cat]
    tty: true
'''
        }
    }

    parameters {
        choice(name: 'OS', choices: ['linux', 'darwin', 'windows'], description: 'Target operating system')
        choice(name: 'ARCH', choices: ['amd64', 'arm64'], description: 'Target architecture')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip running tests')
        booleanParam(name: 'SKIP_LINT', defaultValue: false, description: 'Skip running linter')
    }

    stages {
        stage('Prepare') {
            steps {
                container('golang') {
                    sh '''
                        git config --global --add safe.directory "$WORKSPACE"
                        git fetch --tags || true
                        apt-get update -qq && apt-get install -y -qq make
                    '''
                }
            }
        }
        stage('Lint') {
            when { expression { !params.SKIP_LINT } }
            steps {
                container('golang') {
                    sh '''
                        go install golang.org/x/lint/golint@latest
                        export PATH=$PATH:$(go env GOPATH)/bin
                        make lint
                    '''
                }
            }
        }
        stage('Test') {
            when { expression { !params.SKIP_TESTS } }
            steps {
                container('golang') { sh 'make test' }
            }
        }
        stage('Build') {
            steps {
                container('golang') {
                    sh "make build TARGETOS=${params.OS} TARGETARCH=${params.ARCH}"
                }
            }
        }
    }
}