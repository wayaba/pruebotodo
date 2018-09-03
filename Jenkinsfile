#!/bin/bash


//CLAVEEE INSTALAR ESTE PLUGIN
//Pipeline Utility Steps

properties = null


def loadProperties(String env='tuvieja') {
    node {
        checkout scm
		echo "Archivo leido ${env}.properties"
		def envFile = "${env}.properties"
		properties = readProperties file: envFile
    }
}
				
pipeline {

	agent any

	tools { 
        gradle 'gradle-jenkins' 
    }
	
	parameters {
        string(name: 'mqsihome', defaultValue: '/opt/ibm/ace-11.0.0.0', description: '')
		string(name: 'workspacesdir', defaultValue: '/var/jenkins_home/workspace/pruebotodo', description: '')
		string(name: 'appname', defaultValue: 'ApiMascotas', description: '')
		//string(name: 'version', defaultValue: '1.0', description: '1.0')
		choice(name: 'environment', choices: "desa\ntest\nprod", description: 'selecciona el ambiente' )
    }

	
	
	stages {
		stage('Pruebo leer credenciales') {
			steps {
				withCredentials([[$class:'UsernamePasswordMultiBinding', credentialsId:'GITHUB', usernameVariable:'GIT_USER', passwordVariable:'GIT_PASS']])
				{
					sh 'Usuario: ${GIT_USER} .... Pass: ${GIT_PASS}'
				}
				
			}
		}				
	}
}