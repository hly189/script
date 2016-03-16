import os
import subprocess
from subprocess import PIPE


#command = os.popen("cat localhosts")
#now = command.read()

MACHINE = []
with os.popen('cat localhosts') as f: 
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
	print('The machines are {}'.format(': '.join(SUB_MACHINE)))
	if (i < len(MACHINE)):
		answer = raw_input("Do you want to show the name of files: (y/n): ")
        	if (answer == "no" or answer == 'n') :
                	break
