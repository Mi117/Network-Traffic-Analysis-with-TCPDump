#!/bin/bash

export SSLKEYLOGFILE=/home/kali/tcpdump_project/sslkeys
/usr/bin/googe-chrome-stable & 
sudo tcpdump host apod.nasa.gov -w capture.pcap -G 600 -C 1