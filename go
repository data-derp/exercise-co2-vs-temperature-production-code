#!/usr/bin/env bash

set -e
script_dir=$(cd "$(dirname "$0")" ; pwd -P)

goal_fetch-data() {
    ingestion_input_dir="${script_dir}/datasets/ingestion/inputs"
    mkdir -p ${ingestion_input_dir}
    curl -o "${ingestion_input_dir}/EmissionsByCountry.csv" "https://raw.githubusercontent.com/data-derp/exercise-co2-vs-temperature-databricks/master/data-ingestion/input-data/EmissionsByCountry.csv"
    curl -o "${ingestion_input_dir}/GlobalTemperatures.csv" "https://raw.githubusercontent.com/data-derp/exercise-co2-vs-temperature-databricks/master/data-ingestion/input-data/GlobalTemperatures.csv"
    curl -o "${ingestion_input_dir}/TemperaturesByCountry.csv" "https://raw.githubusercontent.com/data-derp/exercise-co2-vs-temperature-databricks/master/data-ingestion/input-data/TemperaturesByCountry.csv"

    transformation_input_dir="${script_dir}/datasets/transformation/inputs"
    mkdir -p ${transformation_input_dir}
    mkdir -p ${transformation_input_dir}/EmissionsByCountry.parquet
    mkdir -p ${transformation_input_dir}/GlobalTemperatures.parquet
    mkdir -p ${transformation_input_dir}/TemperaturesByCountry.parquet
    curl -o "${transformation_input_dir}/EmissionsByCountry.parquet/part-00000-a5120099-3f2e-437a-98c6-feb2845cdf28-c000.snappy.parquet" -L "https://github.com/data-derp/exercise-co2-vs-temperature-databricks/blob/master/data-transformation/input-data/EmissionsByCountry.parquet/part-00000-a5120099-3f2e-437a-98c6-feb2845cdf28-c000.snappy.parquet?raw=true"
    curl -o "${transformation_input_dir}/GlobalTemperatures.parquet/part-00000-f77d0e73-78da-48a2-be74-681dd35a82cf-c000.snappy.parquet" -L "https://github.com/data-derp/exercise-co2-vs-temperature-databricks/blob/master/data-transformation/input-data/GlobalTemperatures.parquet/part-00000-f77d0e73-78da-48a2-be74-681dd35a82cf-c000.snappy.parquet?raw=true"
    curl -o "${transformation_input_dir}/TemperaturesByCountry.parquet/part-00000-b9e4293b-b7a5-4582-86d1-eccf44649b40-c000.snappy.parquet" -L "https://github.com/data-derp/exercise-co2-vs-temperature-databricks/blob/master/data-transformation/input-data/TemperaturesByCountry.parquet/part-00000-b9e4293b-b7a5-4582-86d1-eccf44649b40-c000.snappy.parquet?raw=true"
}

goal_setup-workflow() {
  ${script_dir}/setup-workflow "$@"
}

goal_pull-dev-container() {
  pushd "${script_dir}" > /dev/null
    docker pull ghcr.io/data-derp/dev-container:master
  popd > /dev/null
}

TARGET=${1:-}
if type -t "goal_${TARGET}" &>/dev/null; then
  "goal_${TARGET}" ${@:2}
else
  echo "Usage: $0 <goal>

goal:
    fetch-data                            - Fetches input data
    setup-workflow                        - Sets up Github Actions workflow
    pull-dev-container                    - Pulls dev container
"
  exit 1
fi
