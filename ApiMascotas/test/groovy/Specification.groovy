import spock.lang.*
import groovyx.net.http.RESTClient

// Hit 'Run Script' below
class MyFirstSpec extends Specification {
	

    RESTClient restClient = new RESTClient("http://192.168.99.100:7810")
	
	def 'Checkeo getPetsById'() {
		println "Veo que onda"
		given:
        String petid = "2"
		
		when:
        def response = restClient.get( path: '/v2/pet/getPetsById', query: ['petId' : petid])

		then:
            with (response) {
                status == 200
                
            }            
    }
	
	def 'Checkeo get all'() {
		
		when:
        def response = restClient.get(path: '/v2/pet')

		then:
            assert response.status == 200
    }
}