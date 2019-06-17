pipeline {
    agent {
        label 'master'
    }

    parameters {
        string(
            name: "NGINX_VERSION",
            defaultValue: "1.15.9",
            description: "Version of Nginx to Build Dockerfile with"
        )
        string(
            name: "NGINX_PROXY_CONNECT_VERSION",
            defaultValue: "0.1",
            description: "Version of Nginx Proxy Connect Module to Build Dockerfile with"
        )
    }

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
    }

    environment {
        APPLICATION_NAME = 'nginx_proxy_connect'
        ARTIFACT_NAME = 'ngx_http_proxy_connect_module'
        ARTIFACT_EXTENSION = '.o'
    }

    stages {
        stage('Build Nginx Module Artifact') {
            agent {
                dockerfile {
                    label 'docker'
                    additionalBuildArgs "--build-arg ARG_NGINX_VERSION=1.15.9 --build-arg ARG_NGINX_PROXY_CONNECT_VERSION=0.1"
                    args "-u root"
                }
            }
            steps {
                ansiColor('xterm') {
                    sh '/opt/bin/docker-entrypoint.sh'

                    sh "tar cfz ${APPLICATION_NAME}-${params.NGINX_PROXY_CONNECT_VERSION}.tar.gz /usr/lib64/nginx/modules/${ARTIFACT_NAME}${ARTIFACT_EXTENSION}"
                    sh "chown jenkins:jenkins  ${APPLICATION_NAME}-${params.NGINX_PROXY_CONNECT_VERSION}.tar.gz"
                    stash includes: "${APPLICATION_NAME}-*.tar.gz", name: "${env.APPLICATION_NAME}"
                }
            }
        }

        stage('Publish Release Artifact') {
            agent {
                label 'master'
            }
            when {
                anyOf {
                    environment name: 'GIT_BRANCH', value: 'master'
                    environment name: 'GIT_BRANCH', value: 'origin/master'
                }
            }
            stages {
                stage('Publish Artifcat to Nexus'){
                    steps {
                        ansiColor('xterm') {
                            unstash "${env.APPLICATION_NAME}"
                            publishNexusArtifact artifactId: "${env.APPLICATION_NAME}",
                                            classifier: 'module',
                                            file: "${WORKSPACE}/${env.APPLICATION_NAME}-${params.NGINX_PROXY_CONNECT_VERSION}.tar.gz",
                                            groupId: 'com.fanthreesixty',
                                            type: 'tar.gz',
                                            repository: 'fts-artifacts-releases',
                                            version: params.NGINX_PROXY_CONNECT_VERSION
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            notifySlack channel: '#nonprod_deployments'
            logstashSend failBuild: false, maxLines: 0
            cleanWs()
        }
    }
}
