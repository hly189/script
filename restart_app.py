#!/usr/bin/env python

import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-g", 
		   help="Machine name such as parser, spliter, writer, etc",
		   default=False,
		   required=True)
parser.add_argument("-a", 
		   help="Application name such as parserapp, spliterapp, etc",
		   default=False,
		   required=True)
args = parser.parse_args()


MACHINE = []
with os.popen("cat"+" " +args.g) as f: 
	MACHINE=[line.split()[0] for line in f]

i = 0
while i < len(MACHINE):
        j=0
        SUB_MACHINE = []
        while j < 3:
                SUB_MACHINE.append(MACHINE[i])
                print (SUB_MACHINE[j])
                i = i+1
                if i >= len(MACHINE)-1: break
                j = j+1
	a = "{}".format(":".join(SUB_MACHINE)) + " " + args.a
	os.system("echo" + " " + a)
	os.system("echo sleep 3 mins")
	os.system("date")
	os.system("sleep 2")
	if (i < len(MACHINE)):
		answer = raw_input("Do you want to continue: (y/n): ")
        	if (answer == "no" or answer == 'n') :
                	break
