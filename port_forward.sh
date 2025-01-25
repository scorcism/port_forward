#!/bin/bash

# Validate Ip format
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        for octet in $(echo $ip | tr '.' ' '); do
            if [[ $octet -lt 0 || $octet -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# Validate port number
validate_port() {
    local port=$1
    if [[ $port =~ ^[0-9]+$ ]] && [ $port -ge 1 ] && [ $port -le 65535 ]; then
        return 0
    else
        return 1
    fi
}

# Vlaid file if user selects ssh 
validate_file() {
    if [ -f "$1" ] && [ -r "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Clear the screen
clear

echo "=== SSH Port Forwarding Setup - scor32k:scor32.com ==="
echo "This script will help you set up port forwarding from your local machine to a remote server."

# get local port number from user and validate it
while true; do
    read -p "Enter the local port number your application is running on(between 1 and 65535): " local_port
    if validate_port "$local_port"; then
        break
    else
        echo "Error: Invalid port number. Please enter a number between 1 and 65535."
    fi
done

# get remote port and validate
while true; do
    read -p "Enter the remote port number you want to expose: " remote_port
    if validate_port "$remote_port"; then
        break
    else
        echo "Error: Invalid port number. Please enter a number between 1 and 65535."
    fi
done

# get and validate remote port
while true; do
    read -p "Enter the remote server's IP address: " remote_ip
    if validate_ip "$remote_ip"; then
        break
    else
        echo "Error: Invalid IP address format. Please use format: xxx.xxx.xxx.xxx"
    fi
done

# Get username for remote server
read -p "Enter the username for the remote server: " remote_user

# Ask for authentication method
echo -e "\nSelect SSH authentication method:"
echo "1. Password authentication"
echo "2. SSH key authentication"
read -p "Enter your choice (1 or 2): " auth_choice

ssh_command="ssh -R $remote_port:localhost:$local_port"

case $auth_choice in
    1)
        # Password authentication
        echo "Using password authentication"
        ssh_command="$ssh_command $remote_user@$remote_ip -N -v"
        ;;
    2)
        # SSH key authentication
        while true; do
            read -p "Enter the path to your SSH private key: " key_path
            if validate_file "$key_path"; then
                break
            else
                echo "Error: SSH key file not found or not readable at: $key_path"
            fi
        done
        echo "Using SSH key authentication"
        ssh_command="$ssh_command -i $key_path $remote_user@$remote_ip -N -v"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Display details
echo -e "\nConnection details:"
echo "Local port: $local_port"
echo "Remote port: $remote_port"
echo "Remote IP: $remote_ip"
echo "Remote user: $remote_user"
echo "Authentication: $([ $auth_choice -eq 1 ] && echo 'Password' || echo 'SSH key')"

# Stablish ssh tunnel
echo -e "\nEstablishing SSH tunnel..."
eval $ssh_command

# If fails provide error details
if [ $? -ne 0 ]; then
    echo "Error: Failed to establish SSH tunnel. Please check:"
    echo "1. SSH service is running on the remote server"
    echo "2. Your authentication credentials are correct"
    echo "3. The remote port is not already in use"
    echo "4. Your firewall settings allow this connection"
    exit 1
fi
