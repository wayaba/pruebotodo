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
		string(name: 'workspacesdir', defaultValue: '/var/jenkins_home/workspace/imagenconbar', description: '')
		string(name: 'appname', defaultValue: 'ApiMascotas', description: '')
		string(name: 'version', defaultValue: '9999', description: '1.0')
		choice(name: 'environment', choices: "desa\ntest\nprod", description: 'selecciona el ambiente' )
    }

	stages {
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
						args '-e LICENSE=accept'
				}
			}
			steps{
					echo "EJECUTO ${params.mqsihome}/server/bin/mqsipackagebar -w ${params.workspacesdir} -a ${params.workspacesdir}/abc.bar -k ${params.appname}"
					sh "${params.mqsihome}/server/bin/mqsipackagebar -w ${params.workspacesdir} -a ${params.workspacesdir}/abc.bar -k ${params.appname}"
				}
					
		}
			/*
		stage('Load Env Parameters')
		{
			steps{
				script{
					loadProperties(params.environment)
				}
			}
		}
		*/
		//stage('Replaces')
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
					sh "docker build -t ace-mascotas --build-arg dbname=${properties.'SQLLOCAL.dbname'} --build-arg dbuser=${properties.'SQLLOCAL.dbuser'} --build-arg dbpass=${properties.'SQLLOCAL.dbpass'} ."
					
					//borro odbc.ini del workspace y del tmp
					sh "rm /tmp/odbc.ini"
					sh "rm ${params.workspacesdir}/odbc.ini"
				}
			}
			/*
		stage('Build Image')
		{
			steps{
				sh "docker build -t ace-mascotas --build-arg dbname=${properties.'SQLLOCAL.dbname'} --build-arg dbuser=${properties.'SQLLOCAL.dbuser'} --build-arg dbpass=${properties.'SQLLOCAL.dbpass'} ."
				
				//borro odbc.ini del workspace y del tmp
				sh "rm /tmp/odbc.ini"
				sh "rm ${params.workspacesdir}/odbc.ini"
				
			}
		}
		*/
		stage('Run Image')
		{
			steps{
				sh "docker run -e LICENSE=accept -d -p ${properties.'API.manageport'}:7600 -p ${properties.'API.port'}:7800 -P --name probando3 ace-mascotas"
			}
		}
		
		/*
		stage('Test')
			{
			
				steps{
						echo 'Ejecuto la validacion de SPOCK'
						//sh 'gradle clean test'
						sh 'gradle resolveProperties'
						
					}
			
				
			}
		*/	
		stage('Tag image')
			{
				steps{
				
					script{
						CONTAINER_ID = sh (
							script: 'docker ps -aqf "name=probando3"',
							returnStdout: true
						).trim()
						echo "El id del container es: ${CONTAINER_ID}"
						VERSION = params.version
						echo "La nueva version es: ${VERSION}"
						sh "docker commit ${CONTAINER_ID} elrepo/ace-mascotas:${VERSION}"
						
						echo 'Stoppeo la instancia'
						sh 'docker stop probando3'
						echo 'Stoppeo la instancia'
						sh 'docker rm probando3'
		
						//Borro la imagen
						sh (script: 'docker rmi ace-mascotas')
					}	
				}
			}
	}
}