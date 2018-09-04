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
				withCredentials([usernamePassword(credentialsId: 'GITHUB', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
				  // available as an env variable, but will be masked if you try to print it out any which way
				  // note: single quotes prevent Groovy interpolation; expansion is by Bourne Shell, which is what you want
				  sh 'echo $PASSWORD'
				  // also available as a Groovy variable
				  echo USERNAME
				  // or inside double quotes for string interpolation
				  echo "username is $USERNAME"
				}
			}
		}				
	}
}