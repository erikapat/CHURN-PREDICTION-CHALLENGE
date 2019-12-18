#!/bin/bash
set -e


conda install numpy
conda install -c conda-forge google-cloud-bigquery
conda install futures


ROLE=$(/usr/share/google/get_metadata_value attributes/dataproc-role)
if [[ "${ROLE}" == 'Master' ]]
then
  # Esta zona de código, se ejecuta para el nodo Master
  echo "Este node es Master"
else
  # Esta zona de código, se ejecuta para los nodos Worker
  echo "Este node es Worker"
fi