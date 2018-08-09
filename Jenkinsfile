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

def versionNumber = "44"

/*
def versionNumber(){
	return "3"
}
*/
node {
					def deployOptions = 'no\nyes'
					def userInput = input(
					  id: 'userInput', message: 'Are you prepared to deploy?', parameters: [
					  [$class: 'ChoiceParameterDefinition', choices: deployOptions, description: 'Approve/Disallow deployment', name: 'deploy-check']
					  ]
					)
					echo "you selected: ${userInput}"
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
		string(name: 'version', defaultValue: '1.0', description: '1.0')
		//string(name: 'version', defaultValue: ${versionNumber}, description: '1.0')
		choice(name: 'environment', choices: "desa\ntest\nprod", description: 'selecciona el ambiente' )
    }

	
	
	stages {
		stage('probando parametros'){
			steps{
				
			}
		}
	/*
		stage('SonarQube analysis') {
			steps {
				script {
					def scannerHome = tool 'sonnar-jenkins'
					withSonarQubeEnv('sonarqube') {
						sh "${scannerHome}/bin/sonar-scanner \
										-Dsonar.projectKey=esqpipeline \
										-Dsonar.projectname=Esqpipeline \
										-Dsonar.projectVersion=1 \
										-Dsonar.sources=. \
										-Dsonar.language=esql"
					}
				}
			}
		}		
		stage('Compilacion')
		{
			agent {
				docker { image 'ibmcom/ace:latest' 
						args '-e LICENSE=accept'
				}
			}
			steps{
					echo "EJECUTO ${params.mqsihome}/server/bin/mqsipackagebar -w ${params.workspacesdir} -a ${params.workspacesdir}/abc.bar -k ${params.appname}"
					sh "${params.mqsihome}/server/bin/mqsipackagebar -w ${params.workspacesdir} -a ${params.workspacesdir}/abc.bar -k ${params.appname}"
				}
					
		}
		stage('Build Image')
		{
			steps{
				echo "Cargo propiedades"
				script{
					loadProperties(params.environment)
				}
				
				echo "Realizo replace en odbc.ini"
					
				sh "cat ${params.workspacesdir}/${params.appname}/connections/odbc.ini | \
					sed -e 's,#SQLLOCAL.port#,${properties.'SQLLOCAL.port'},' \
						-e 's,#SQLLOCAL.database#,${properties.'SQLLOCAL.database'},' \
						-e 's,#SQLLOCAL.hostname#,${properties.'SQLLOCAL.hostname'},' \
						-e 's,#SQLLOCAL.installdir#,${params.mqsihome},' \
					> /tmp/odbc.ini"
				
				sh "cp /tmp/odbc.ini ${params.workspacesdir}"
				
				echo "Hago el build"
				sh "docker build -t image-temp --build-arg dbname=${properties.'SQLLOCAL.dbname'} --build-arg dbuser=${properties.'SQLLOCAL.dbuser'} --build-arg dbpass=${properties.'SQLLOCAL.dbpass'} ."
				
				//borro odbc.ini del workspace y del tmp
				sh "rm /tmp/odbc.ini"
				sh "rm ${params.workspacesdir}/odbc.ini"
			}
		}
		stage('Run Image')
		{
			steps{
				//antes del run verifico si no existe el container 
				script{
						CONTAINER_ID = sh (
							script: 'docker ps -aqf "name=app-running"',
							returnStdout: true
						).trim()
						
						if ( CONTAINER_ID ) {
							sh 'docker stop app-running'
							echo 'Stoppeo la instancia'
							sh 'docker rm app-running'
						}
					}	
					
				sh "docker run -e LICENSE=accept -d -p ${properties.'API.manageport'}:7600 -p ${properties.'API.port'}:7800 -P --name app-running image-temp"
			}
		}
		
		stage('Test')
			{
			
				steps{
						echo 'Ejecuto la validacion de SPOCK'
						sh 'gradle clean test'
						//sh 'gradle resolveProperties'
						//sh 'gradle -q callspock'
					}
			
				
			}
			
		stage('Tag image')
			{
				steps{
				
					script{
						CONTAINER_ID = sh (
							script: 'docker ps -aqf "name=app-running"',
							returnStdout: true
						).trim()
						echo "El id del container es: ${CONTAINER_ID}"
						VERSION = params.version
						echo "La nueva version es: ${VERSION}"
						sh "docker commit ${CONTAINER_ID} elrepo/ace-mascotas:${VERSION}"
						
						echo 'Stoppeo la instancia'
						sh 'docker stop app-running'
						echo 'Stoppeo la instancia'
						sh 'docker rm app-running'
		
						//Borro la imagen
						sh (script: 'docker rmi image-temp')
					}	
				}
			}
		*/
	}
}