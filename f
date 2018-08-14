[33mcommit 57cd0c46cfe195849648f1e98ad7929489a10c44[m[33m ([m[1;36mHEAD -> [m[1;32mmaster[m[33m, [m[1;31morigin/master[m[33m, [m[1;31morigin/HEAD[m[33m)[m
Author: Pablo Pedraza <Pablo@WKS783L.sofrecom.local>
Date:   Tue Aug 14 15:04:05 2018 -0300

    aa

[1mdiff --git a/Jenkinsfile b/Jenkinsfile[m
[1mindex a2c3722..8ff3de7 100644[m
[1m--- a/Jenkinsfile[m
[1m+++ b/Jenkinsfile[m
[36m@@ -200,7 +200,7 @@[m [mpipeline {[m
 						)[m
 						echo "La nueva version es: ${tagnumber}"[m
 						//sh "git tag -a ${tagnumber} -m 'Tag from Jenkins'"[m
[31m-						sh "git push -u origin master --tags"[m
[32m+[m						[32m//sh "git push -u origin master --tags"[m
 						withCredentials([usernamePassword(credentialsId: 'idGitHub', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {[m
 							sh("git tag -a some_tag23 -m 'Jenkins'")[m
 							sh('git push https://${GIT_USERNAME}:${GIT_PASSWORD}@<REPO> --tags')[m
