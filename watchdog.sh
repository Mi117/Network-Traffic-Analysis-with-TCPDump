w#!/bin/bash

sudo tcpdump -c 10 host coursera.org -C 1 -G 15 -w capture.pcap 