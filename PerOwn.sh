#!/bin/bash

# Array of folder names
folders=("apps" "data" "files" "images" "logs" "media" "public" "settings" "themes")

# Loop through each folder and execute the commands
for folder in "${folders[@]}"; do
    sudo chown -R ghost:ghost "$folder"
    sudo chmod -R 755 "$folder"
    sudo chown ghost:bitnami "$folder"
done
