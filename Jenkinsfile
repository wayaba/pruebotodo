#!/bin/bash


//CLAVEEE INSTALAR ESTE PLUGIN
//Pipeline Utility Steps

properties = null
mqsihome = '/opt/ibm/ace-11.0.0.0'
workspacesdir = '/var/lib/jenkins/workspace/'

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
		string(name: 'appname', defaultValue: 'ApiMascotas', description: '')
		choice(name: 'environment', choices: "desa\ntest\nprod", description: 'selecciona el ambiente' )
    }

	

	stages {

	/*
		stage('probando parametros'){
			steps{
				script{
					//LAST_TAG = sh (script: "docker images | grep elrepo/ace-mascotas | awk '{print \$2}'",returnStdout: true).trim()
					//LAST_TAG = sh (script: "docker images | grep elrepo/ace-mascotas",returnStdout: true).trim()
					def deployOptions = sh (script: "docker images | grep elrepo/ace-mascotas | awk '{print \$2}'",returnStdout: true).trim()
					def userInput = input(
					  id: 'userInput', message: 'Are you prepared to deploy?', parameters: [
					  [$class: 'StringParameterDefinition', defaultValue: '0.0', description: deployOptions, name: 'version']
					  ]
					)
					echo "you selected: ${userInput}"
				}
			}
		}
		*/
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
*/

		stage('Compilacion')
		{
			agent {
				docker { image 'ibmcom/ace:latest' 
						args '-e LICENSE=accept -v /var/lib/jenkins/workspace/${JOB_NAME}:/opt/workspace'
				}
			}
			steps{
			        
			       
					echo "EJECUTO ${mqsihome}/server/bin/mqsipackagebar -w /opt/workspace -a /opt/workspace/abc.bar -k ${params.appname}"
					sh "${mqsihome}/server/bin/mqsipackagebar -w /opt/workspace -a /opt/workspace/abc.bar -k ${params.appname}"
				}
					
		}
		stage('Build Image')
		{
			steps{
				echo "Cargo propiedades"
				script{
					loadProperties(params.environment)
					workspacesdir = workspacesdir + "${JOB_NAME}"
				}
				
				echo "${workspacesdir}"
				echo "Realizo replace en odbc.ini"
					
				sh "cat ${workspacesdir}/${params.appname}/connections/odbc.ini | \
					sed -e 's,#SQLLOCAL.port#,${properties.'SQLLOCAL.port'},' \
						-e 's,#SQLLOCAL.database#,${properties.'SQLLOCAL.database'},' \
						-e 's,#SQLLOCAL.hostname#,${properties.'SQLLOCAL.hostname'},' \
						-e 's,#SQLLOCAL.installdir#,${mqsihome},' \
					> /tmp/odbc.ini"
				
				sh "cp /tmp/odbc.ini ${workspacesdir}"
				
				echo "Hago el build"
				sh "docker build -t image-temp --build-arg dbname=${properties.'SQLLOCAL.dbname'} --build-arg dbuser=${properties.'SQLLOCAL.dbuser'} --build-arg dbpass=${properties.'SQLLOCAL.dbpass'} ."
				
				//borro odbc.ini del workspace y del tmp
				sh "rm /tmp/odbc.ini"
				sh "rm ${workspacesdir}/odbc.ini"
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
		/*
		stage('Test')
			{
			
				steps{
						echo 'Ejecuto la validacion de SPOCK'
						sh 'gradle clean test'
						//sh 'gradle resolveProperties'
						//sh 'gradle -q callspock'
					}
			
				
			}
		*/	
		stage('Tag image')
			{
				steps{
				
					script{
						
						
					    def oldtag = sh (script: "git tag",returnStdout: true).trim()
						def tagnumber = input(
								id: 'tagnumber', 
								message: 'Que numero de tag?', 
								parameters: [[$class: 'StringParameterDefinition', 
											defaultValue: '0.0', 
											description: oldtag, 
											name: 'version']
								]
						)
						
						def repo = sh (script: "git config --get remote.origin.url",returnStdout: true).trim()
						echo "La nueva version es: ${tagnumber}"
						echo "El repo es: ${repo}"
						
						repo = repo.replaceAll("https://", "")
						repo = repo.replaceAll("git@", "")
						repo = repo.replaceAll(":", "/")
						
						echo "El repo es: ${repo}"
						
						withCredentials([usernamePassword(credentialsId: 'martes123', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
							sh("git tag -a ${tagnumber} -m 'Tag de Jenkins'")
							sh("git -c http.sslVerify=false push https://${GIT_USERNAME}:${GIT_PASSWORD}@${repo} --tags")
						}
						
					}	
				}
			}
	}
}
