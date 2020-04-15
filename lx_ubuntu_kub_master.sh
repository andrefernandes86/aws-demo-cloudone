#!/bin/bash
sudo su
sudo apt-get update
sleep 5
sudo apt-get install python -y
sleep 5
curl -fsSL https://get.docker.com | sh
sleep 5
sudo usermod -aG docker root
sleep 5
