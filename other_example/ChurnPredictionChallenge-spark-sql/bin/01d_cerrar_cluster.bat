echo off
FOR /F "tokens=1,2,* delims==" %%G IN (../conf/job.properties) DO ( set %%G=%%H)
call gcloud dataproc --region %CLUSTER_REGION% clusters delete %CLUSTER_NAME% --quiet