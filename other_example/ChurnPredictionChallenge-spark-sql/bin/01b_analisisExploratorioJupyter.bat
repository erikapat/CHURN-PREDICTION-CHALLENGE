FOR /F "tokens=1,2,* delims==" %%G IN (../conf/job.properties) DO ( set %%G=%%H)
call chrome.exe http://%CLUSTER_NAME%-m:8123/tree --proxy-server="socks5://localhost:1080"  --host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE localhost"  --user-data-dir=/tmp/%CLUSTER_NAME%-m
