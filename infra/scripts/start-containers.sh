#! /bin/bash

# Create color variables.
esc_seq="\x1b["
no_color=$esc_seq"39;49;00m"
red_color=$esc_seq"31;01m"
blue_color=$esc_seq"34;01m"
green_color=$esc_seq"32;01m"

# Create requisite variables.
project_root="$( dirname $( dirname $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ) )"
image_name_db="gauntlet-db"
image_name_api="gauntlet-api"
image_name_web="gauntlet-web"
db_volume_name="gauntlet-db-volume"
container_name_db="gauntlet-db"
container_name_api="gauntlet-api"
container_name_web="gauntlet-web"

# Create an exit hook.
function on_premature_exit {
 if [[ "$?" -ne "0" ]]; then
   echo -e "${red_color}✗ Failed to start containers.${no_color}"
 fi
}

# Setup the exit hook.
trap 'on_premature_exit' EXIT

# Exit on error.
set -e

# Create arrays for container metadata.
image_tags=('latest' 'latest' 'latest')
image_names=($image_name_db $image_name_api $image_name_web)
image_paths=("$project_root/infra/images/db" "$project_root/infra/images/api" "$project_root/infra/images/web")
image_run_args=(
  "-v $db_volume_name:/var/lib/postgresql/data"
  "-v $project_root:/go/src/github.com/skeswa/gauntlet --link $container_name_db:$container_name_db"
  "-p 80:3000 -v $project_root:/go/src/github.com/skeswa/gauntlet --link $container_name_api:$container_name_api")
container_names=($container_name_db $container_name_api $container_name_web)

# Start each of the containers.
for (( i=0; i<${#image_tags[@]}; i++ ))
do
  image_tag=${image_tags[i]}
  image_name=${image_names[i]}
  image_path=${image_paths[i]}
  image_run_arg=${image_run_args[i]}
  container_name=${container_names[i]}

  echo -e "${blue_color}ℹ Starting '$container_name'...${no_color}"
  docker run \
    -d \
    $image_run_arg \
    --name "$container_name" \
    "$image_name:$image_tag"
done

# Report success.
echo -e "${green_color}✓ Containers started successfully.${no_color}"