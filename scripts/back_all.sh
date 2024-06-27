#!/bin/bash

NOW=$(date +"%Y%m%d-%H%M%S")

config_backup_path="$HOME/backups/bk_config"

# Specify the Docker volume name to back up
container_name="bw"
volume_name="bw"

# Specify the path where the backup will be stored
docker_backup_path="$HOME/backups/bk_docker_vol"
backup_filename="${NOW}_${volume_name}.tar.gz"

# Stop the container
container_status=$(docker inspect --format '{{.State.Running}}' "$container_name")
if [[ $container_status == true ]]; then
  echo "Stopping $container_name ..."
  docker stop "$container_name"
fi

# Create the backup directory if it doesn't exist
mkdir -p "$docker_backup_path"

# Backup the Docker volume
docker run --rm -v "$volume_name:/volume" -v "$docker_backup_path:/backup" alpine \
  tar czf "/backup/$backup_filename" -C "/volume" .

# Start the container
if [[ $container_status == true ]]; then
  echo "Restarting $container_name ..."
  docker start "$container_name"
fi

echo "Backup of $volume_name completed: $docker_backup_path/$backup_filename"


export_gpg_keys.sh

gpg_backup_path="$HOME/backups/bk_gpg"
gpg_backup_filename="${NOW}_gpg.tar.gz"
# Create the tar.gz archive from file.lst
tar -czvf "${gpg_backup_filename}" -T "${gpg_backup_path}/gpg_export_list.lst"

if [ $? -eq 0 ]; then
  echo "Archive created: $gpg_backup_filename"
  
  # Delete file.lst and files in the list
  rm -rf $(cat "${gpg_backup_path}/gpg_export_list.lst")
  rm -f "${gpg_backup_path}/gpg_export_list.lst"
  echo "Files deleted successfully."
else
  echo "Error creating archive!"
  exit 1
fi

# rclone copy ${docker_backup_path} secret1:backups/docker_backup \
#  -P --copy-links \
#  --exclude '.*{/**,}'

# Capture both stdout and stderr into a variable
output=$(tar -czf "${config_backup_path}/${NOW}_secrets.tar.gz" -C "${HOME}" \
  .ssh \
  .config \
  /backups/docker_backup \
  /backups/gpg_keys_backup \
  2>&1)
# Capture the return code
RET_CODE=$?

