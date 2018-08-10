#!/usr/bin/env python

import os, sys, subprocess

queue= "scec"

full = False

if len(sys.argv) == 2:
	if (sys.argv[1] == "--full"):
		full = True
	else:
		queue = sys.argv[1]

command = "squeue | grep " + queue

proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

output = proc.communicate()

users = []
userQueuedJobs = {}
userRunningJobs = {}
userNodes = {}

queuedJobs = 0
runningJobs = 0
usedNodes = 0

for line1 in output[0].split("\\n"):
	for line in line1.split("\n"):
		split = line.split()
		if len(split) == 8:
			job = split[0]
			user = split[3]
			state = split[4]
			nodes = int(split[6])
			if user not in users:
				users.append(user)
				userQueuedJobs[user] = []
				userRunningJobs[user] = []
				userNodes[user] = 0
			if state == "R":
				userRunningJobs[user].append(job)
				runningJobs += 1
				userNodes[user] += nodes
				usedNodes += nodes
			else:
				userQueuedJobs[user].append(job)
				queuedJobs += 1
		elif len(split) > 0:
			print "bad split (len " + str(len(split)) + "): " + str(split)

print str(len(users))+" users running "+str(runningJobs)+" jobs on "+str(usedNodes)+" nodes, "+str(queuedJobs)+" queued jobs"

totNodes = 0
for user in users:
	runningJobs = userRunningJobs[user]
	queuedJobs = userQueuedJobs[user]
	nodes = userNodes[user]
	print "user: " + user + ",\trunning: " + str(len(runningJobs)) + " (" + str(nodes) + " nodes),\tqueued: " + str(len(queuedJobs))
	totNodes += nodes
print "Total nodes in use: " + str(totNodes)

if full:
	for user in users:
		command = "squeue -u " + user
		proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		out = proc.communicate()[0]
		for line1 in out.split("\\n"):
			print line1
