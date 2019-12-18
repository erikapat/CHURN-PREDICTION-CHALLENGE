echo off
FOR /F "tokens=1,2,* delims==" %%G IN (../conf/job.properties) DO ( set %%G=%%H)

echo Setting project %PROJECT_ID%
call gcloud config set project  %PROJECT_ID%
set INITPATH=gs://%STORAGE_NAME%/jupyter.sh
call gsutil cp -r ../conf/jupyter.sh %INITPATH%

call gcloud dataproc --region %CLUSTER_REGION% clusters create %CLUSTER_NAME% --bucket %STORAGE_NAME% --subnet default  --image-version 1.1 --zone %CLUSTER_ZONE% --master-machine-type n1-highmem-2 --master-boot-disk-size 500 --num-workers 3 --worker-machine-type n1-highmem-2  --worker-boot-disk-size 500  --scopes "https://www.googleapis.com/auth/cloud-platform" --project  %PROJECT_ID% --initialization-actions %INITPATH%