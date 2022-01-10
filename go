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
    curl -o "${transformation_input_dir}/EmissionsByCountry.parquet" "https://raw.githubusercontent.com/data-derp/exercise-co2-vs-temperature-databricks/master/data-transformation/input-data/EmissionsByCountry.parquet"
    curl -o "${transformation_input_dir}/GlobalTemperatures.parquet" "https://raw.githubusercontent.com/data-derp/exercise-co2-vs-temperature-databricks/master/data-transformation/input-data/GlobalTemperatures.parquet"
    curl -o "${transformation_input_dir}/TemperaturesByCountry.parquet" "https://raw.githubusercontent.com/data-derp/exercise-co2-vs-temperature-databricks/master/data-transformation/input-data/TemperaturesByCountry.parquet"
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
