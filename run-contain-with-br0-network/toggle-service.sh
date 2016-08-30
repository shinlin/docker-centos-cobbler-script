#!/bin/bash

systemctl stop firewalld
systemctl disable firewalld
systemctl stop NetworkManager
systemctl disable NetworkManager
#systemctl stop iptables
