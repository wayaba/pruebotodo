# Integración Continua con Jenkins
[![][ButlerImage]][website]

 - Integración continua manejada con pipeline de Jenkins.

## Prerrequisitos

* Jenkins debe tener instalado docker.
  - Para el ejemplo se usa la imagen modificada de jenkins oficial: 
    [ppedraza/jenkins](https://hub.docker.com/r/ppedraza/jenkins/)

```
docker pull ppedraza/jenkins
docker run --name jenkins -p 8080:8080 -p 50000:50000 -P ppedraza/jenkins
```

* Servidor de SonarQube instalado con plugin de ESQL (es un jar).
  - El server lo obtengo de una image de docker 
   [sonarqube](https://hub.docker.com/_/sonarqube/)
```
docker pull sonarqube
docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 sonarqube
```

Una vez que sonarqube este running, pegar el jar [(esql-plugin-2.3.3.jar)](https://github.com/EXXETA/sonar-esql-plugin/releases/download/2.3.3/esql-plugin-2.3.3.jar) en la carpeta plugins
```
docker cp "C:\tmp\esql-plugin-2.3.3.jar" sonarqube:/opt/sonarqube/extensions/plugins
```
## Pasos :feet:

## <a name="configsonar"></a>Configuración de Sonarqube
En SonarQube crear un nuevo proyecto
Administration->Projects->Management->Create Project

Ingresar Datos para la creación (Ejemplo)
```
 Name : projSonarDoc
 Key  : projSonarDoc
 Visibility: Public
```
Por otro lado dentro de SonarQube crear un nuevo usuario con token
Administration->Security->Users->Create User

Ingresar Datos para la creación (Ejemplo)
```
 Login: Userjenkins
 Name: Userjenkins
 Pass: Userjenkins
```
Luego de crearlo ir a "Update Tokens" dentro del usuario

En Generate Tokens ingresar la key del proyeto creado anteriormente "projSonarDoc" y generar
```
Token generado: 31ee76df78c1475c4b347aa0db46498a987c28ed
```
## <a name="sonarjenkins"></a>Configuración Sonarqube en Jenkins

### <a name="sonarjenkins1">Configuración de plugin SonarQube

Dentro de Manage Jenikins->Manage Plugins, buscar e instalar el plugin ["SonarQube Scanner"](https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner+for+Jenkins)


Una vez hecho esto, dentro de Manage Jenkins->Global Tool Configuration
En la seccion SonarQube Scanner agregar un SonarQube Scanner presionando el boton de Add
Ingresar (por ejemplo)
```
Name : sonnar-jenkins
```
- [x] Install automatically

y guardar los cambios :heavy_check_mark:

### <a name="sonarjenkins2"> Configurar vinculo entre Jenkins y server de SonarQube

Dentro de Manage Jenkins->Configure System, en la seccion SonarQube servers agregar los datos del servidor (por ejemplo)
- Environment variables
- [x]  Enable injection of SonarQube server configuration as build environment variables

- SonarQube installations
```
 Name : sonarqube
 Server URL : http://192.168.99.100:9000
 Server authentication token : 31ee76df78c1475c4b347aa0db46498a987c28ed (el token generado anteriormente en el server de sonar)
```
y guardar los cambios :heavy_check_mark:

## Generación nuevo item en Jenkins

En Jenkins->New Item
Ingresar Nombre del nuevo item y seleccionar el tipo Pipeline

La idea es que el codigo del pipeline este escrito dentro del codigo descargado de git en cada proyecto

Una vez creado el nuevo item, bajar hasta la seccion Pipeline y seleccionar lo siguiente:

```
Definition : Pipeline script from SCM
SCM : Git

Repositories
	Repository URL : https://github.com/repo/proyecto.git
	Credentials : (cargar las credenciales de git cargadas en Jenkins)
Branches to build
	Branch Specifier (blank for 'any') : */master 
Repository browser: (Auto)
Script Path : Jenkinsfile (el nombre del archivo con el pipeline en el root del proyecto)
Lightweight checkout: checked
```
y guardar los cambios :heavy_check_mark:

## Codificación de Jenkinsfile con pipeline

En el pipeline se definen los stages que indican los pasos a seguir en la integración. Si falla uno, da FAILURE y no se continua con los siguientes.

### Parametros
Se escribe al comienzo del pipeline y especifica los parametros de entrada para la llamada desde jenkins
Los valores por defecto deberian cambiar con cada proyecto

Ejemplo:
```Groovy
parameters {	
	string(name: 'mqsihome', defaultValue: '/opt/ibm/ace-11.0.0.0', description: '')
	string(name: 'workspacesdir', defaultValue: '/var/jenkins_home/workspace/imagenconbar', description: '')
	string(name: 'appname', defaultValue: 'ApiMascotas', description: '')
	string(name: 'version', defaultValue: '9999', description: '1.0')
	choice(name: 'environment', choices: "desa\ntest\nprod", description: 'selecciona el ambiente' )
	}
```

### Stage SonarQube :satellite:
Dentro de este stage se configura la vinculación del proyecto de sonar con el server configurado en jenkins

De esta forma los valores del ejemplo corresponden a:

 - sonnar-jenkins : Nombre del sonar scanner configurado dentro de Jenkins [Link](#sonarjenkins1)
 - sonarqube : Nombre del servidor de Sonar configurado dentro de Jenkins [Link](#sonarjenkins2)
 - Dsonar.projectKey : Key creado dentro del proyecto en el servidor de SonarQube [Link](#configsonar)
 - Dsonar.projectname : Key creado dentro del proyecto en el servidor de SonarQube [Link](#configsonar)
 - Dsonar.sources : Indica la ruta dentro del proyecto los archivos a escanear
 - Dsonar.language : el lenguaje que se quiere validar. En este caso ESQL (esql-plugin-2.3.3.jar)

Ejemplo:
```Groovy
steps {	
	script {
		def scannerHome = tool 'sonnar-jenkins'
		withSonarQubeEnv('sonarqube') {
			sh "${scannerHome}/bin/sonar-scanner \
			-Dsonar.projectKey=projSonarDoc \
			-Dsonar.projectname=ProjSonarDoc \
			-Dsonar.projectVersion=1 \
			-Dsonar.sources=. \
			-Dsonar.language=esql"
		}
	}
}
```

### Stage Compilación :package:
En este stage con el codigo bajado de Git, se genera para el BAR a deployar

Se ejecuta la llamada a la imagen de broker oficial v11 [ibmcom/ace](https://hub.docker.com/r/ibmcom/ace/)
Para armar el entorno de ejecución y poder correr el comando [mqsipackagebar](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/bc31720_.htm)
A este comando se le pasan los siguientes parametros

- -w : ruta del workspace de trabajo (parametro desde Jenkins)
- -a : nombre del bar (el nombre es lo de menos, lo importante es la ruta donde se va a crear. En este caso en el workspace)
- -k : el nombre de la aplicación a compilar dentro del workspace

Ejemplo
```Groovy
stage('Compilación')
{
	agent {
		docker { image 'ibmcom/ace:latest' 
			args '-e LICENSE=accept'
			}
		}
	steps{
		sh "${params.mqsihome}/server/bin/mqsipackagebar -w ${params.workspacesdir} -a ${params.workspacesdir}/abc.bar -k ${params.appname}"
		}
					
}
```
NOTA: Una vez que termina el stage compilación, el entorno generado con la llamada al docker de Ibm se cierra.

### Stage Build Image :nut_and_bolt:

Lo primero que se debe hacer en este step es la carga de las variables de entorno, para que a la hora de armar la imagen, quede la misma con la configuración que corresponda al ambiente donde se requiere utilizarla.

Para esto deben existir archivos de propiedades por ambiente.
Los mismos estan actualmente situados en el root del proyecto
Ej.

- desa.properties
- test.properties
- prod.properties

```
|-- ProjectName
    |-- desa.properties
    |-- test.properties
    |-- prod.properties
    |-- README.md
    |-- Dockerfile
    |-- Jenkinsfile
    |-- build.gradle
    |-- App
        |-- swagger.json
        |-- restapi.descriptor
```

> El formato dentro de cada archivo para alojar las variables es el de nombre = valor

```Ini
#configuracion servicio
API.port = 7810
API.manageport = 7610

#configuracion de conexion SQLLOCAL
SQLLOCAL.database=master
SQLLOCAL.hostname=192.168.99.100
SQLLOCAL.port=1433
SQLLOCAL.dbname=SQLLOCAL
```

### Lectura de archivos de properties

Para la lectura de los archivos de properties dentro del Jenkinsfile es necesario instalar un el plugin [Pipeline Utility Steps](https://wiki.jenkins.io/display/JENKINS/Pipeline+Utility+Steps+Plugin) dentro de Jenkins

Una vez instalado, dentro del Jenkins file, al comienzo del archivo fuera del contexto de pipeline, se define la variable que contendra la referencia al archivo de propiedades

```Groovy
properties = null
```

debajo de esa definición se escribe la función que lee las propiedades del archivo

```Groovy
def loadProperties(String env='desa') {
    node {
        checkout scm
		echo "Archivo leido ${env}.properties"
		def envFile = "${env}.properties"
		properties = readProperties file: envFile
    }
}
```

Dentro del pipeline para la carga de la variable properties, lo que se debe hacer es la llamada de la función dentro de un step.

> El valor de params.environment viene como parametro de entrada del front-end de Jenkins a la hora de la invocación de la Tarea

```Groovy
steps{
	echo "Cargo propiedades"
	script{
		loadProperties(params.environment)
	}
}
```

Una vez invocada la función, a forma de referenciar las propiedades es la siguiente:

```Groovy
${properties.'SQLLOCAL.port'}
```

### Modificacion odbc.ini

Para la configuración de las conexiones es necesario modificar el odbc.ini de la imagen a generar.
Para esto, cada proyecto debe contener dentro de la carpeta connections un odbc.ini preparado para realizar replace de las conexiones a utilizar

La estructura seria la siguiente:
```
|-- ProjectName
    |-- desa.properties
    |-- ...
    |-- ...
    |-- App
	|-- ...
	|-- ...
        |-- connections
	        |-- odbc.ini
```

El odbc.ini debería tener esta estructura:

```Ini
[SQLLOCAL]
Driver=#SQLLOCAL.installdir#/server/ODBC/drivers/lib/UKsqls95.so
Description=Conexion SQL para docker local de serverSQL
AnsiNPW=1
LoginTimeout=0
QueryTimeout=0
Database=#SQLLOCAL.database#
HostName=#SQLLOCAL.hostname#
PortNumber=#SQLLOCAL.port#
```

Donde #SQLLOCAL.database# es el string a reemplazar por el valor de la misma variable en el archivo desa.properties

```Ini
SQLLOCAL.database=master
```

 Una manera de realizar los reemplazos en el pipeline es la siguiente:

```Groovy
echo "Realizo replace en odbc.ini"
sh "cat ${params.workspacesdir}/${params.appname}/connections/odbc.ini | \
	sed -e 's,#SQLLOCAL.port#,${properties.'SQLLOCAL.port'},' \
	-e 's,#SQLLOCAL.database#,${properties.'SQLLOCAL.database'},' \
	-e 's,#SQLLOCAL.hostname#,${properties.'SQLLOCAL.hostname'},' \
	-e 's,#SQLLOCAL.installdir#,${params.mqsihome},' \
	> /tmp/odbc.ini"				
sh "cp /tmp/odbc.ini ${params.workspacesdir}"
```

### <a name="buildimagen"></a>Build de la imagen

El build se realiza desde el mismo pipeline invocando al DockerFile contenido en el mismo root del proyecto

> Al ejecutar el build, se crea una imagen temporal del broker con el bar embebido.

```Groovy
sh "docker build -t ace-mascotas --build-arg dbname=${properties.'SQLLOCAL.dbname'} --build-arg dbuser=${properties.'SQLLOCAL.dbuser'} --build-arg dbpass=${properties.'SQLLOCAL.dbpass'} ."
```

Luego del build se limpian los archivos temporales

```Groovy
//borro odbc.ini del workspace y del tmp
sh "rm /tmp/odbc.ini"
sh "rm ${params.workspacesdir}/odbc.ini"
```
### Dockerfile
El Dockerfile es sobre el que se realiza el build.
En el mismo se indica que la contrucción de la imagen se realiza en base a la imagen [ppedraza/ace](https://hub.docker.com/r/ppedraza/ace/)

```Dockerfile
FROM ppedraza/ace
```
Este archivo recibe por parámetros los datos para la conexion con la DB

```Dockerfile
ARG dbname
ARG dbuser
ARG dbpass
```

Al final del mismo luego de copiar el odbc.ini y el bar en sus directorios correspondientes se ejecuta el [mqsisetdbparms](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/an09155_.htm) para el seteo de la conexión

```Dockerfile
RUN bash -c 'mqsisetdbparms -w /home/aceuser/ace-server -n $dbname -u $dbuser -p $dbpass'
```
### <a name="runimage"></a>Stage Run Image :runner:

Es este momento se levanta una instancia de la imagen previamente generada.

```Groovy
steps{
	sh "docker run -e LICENSE=accept -d -p ${properties.'API.manageport'}:7600 -p ${properties.'API.port'}:7800 -P --name app-running ace-mascotas"
}
```
> Los puertos son parametrizados con la configuración seteada en el archivo de properties.

### Stage Testing :see_no_evil:

En este stage se corren test programados en SPOKE para corroborar el correcto funcionamiento de la imagen.

Para poder correr un test con el framework Spock, es necesario la ejecución de Gradle

Dentro del Jenkinsfile en la seccion del pipeline se debe invocar la referencia a la herramienta

```Groovy
tools { 
        gradle 'gradle-jenkins' 
    }
```
De esta forma tenemos acceso al comando *gradle* dentro del step para ejecutar la llamada al groovy que contiene el spock.

```Groovy
steps{
	echo 'Ejecuto la validacion de SPOCK'
	sh 'gradle clean test'
}
```

### Referencias para ejecutar SPOCK

Es importante que dentro del root exista el archivo *build.gradle*
El mismo contiene las dependencias necesarias para poder ejecutar el codigo en el archivo .groovy que contiene las validaciones.

```
|-- ProjectName
    |-- build.gradle
    |-- ...
    |-- ...
    |-- App
	|-- ...
	|-- ...
        |-- test
	        |-- groovy
		        |-- Specification.groovy
```

> Un detalle a tener en cuenta es la ruta de donde se aloja el archivo groovy.
> Si no esta en el root, se debe especificar la misma a traves del siguiente código en el *build.gradle*

```Groovy
sourceSets {
    test {
        groovy {
            srcDirs= ['ApiDir/test/groovy']
        }
    }
}
```



### Stage Tag :pushpin:

Una vez que todos los pasos anteriores fueron exitosos, se procede a la generación del Tag de la imagen y la limpieza del entorno para una próxima corrida.

```Groovy
steps{			
	script{
		CONTAINER_ID = sh (script: 'docker ps -aqf "name=app-running"', returnStdout: true).trim()
		echo "El id del container es: ${CONTAINER_ID}"
		VERSION = params.version
		echo "La nueva version es: ${VERSION}"
		sh "docker commit ${CONTAINER_ID} elrepo/ace-mascotas:${VERSION}"				
		echo 'Stoppeo la instancia'
		sh 'docker stop app-running'
		echo 'Stoppeo la instancia'
		sh 'docker rm app-running'
		
		//Borro la imagen
		sh (script: 'docker rmi ace-mascotas')
		}	
	}
```

En el código anterior lo primero que se hace es obtener el id del container que se corrió en el stage [run](#runimage).
Con ese id, se genera el tagueo de la versión realizando un *commit*

Una vez tagueado se stoppea la instancia y se borra la misma.

Por último se borra la imagen temporal generada en el paso del [build](#buildimagen)

[ButlerImage]: https://jenkins.io/sites/default/files/jenkins_logo.png
[website]: https://jenkins.io/
