#!/bin/bash

create_projects_directory() {
    local projects_dir="$HOME/projects"

    if [ -d "$projects_dir" ]; then
        echo "Projects directory already exists at $projects_dir."
    else
        echo "Creating projects directory at $projects_dir..."
        mkdir -p "$projects_dir"
        echo "Projects directory created."
    fi
}

create_projects_directory
