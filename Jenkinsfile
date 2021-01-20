#!groovy
pipeline {
    agent any
    options {
        ansiColor('xterm')
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '20', numToKeepStr: '10')
        skipDefaultCheckout true
        disableConcurrentBuilds()
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Image') {
            steps {
                script {
                    sh "make image"
                }
            }
        }
        // stage('Build App') {
        //     steps {
        //         script {
        //             sh "make build"
        //         }
        //     }
        // }
        stage('Release') {
            steps {
                script {
                    sh "make release"
                }
            }
        }
    }
    post {
        always {
            deleteDir()
            ws(pwd() + "@tmp") {
                step([$class: 'WsCleanup'])
            }
            ws(pwd() + "@script") {
                step([$class: 'WsCleanup'])
            }
            ws(pwd() + "@script@tmp") {
                step([$class: 'WsCleanup'])
            }
        }
    }
}