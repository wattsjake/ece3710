import sys
import os
import time

# Check if the user has provided the correct number of arguments
if len(sys.argv) != 2:
    print("Usage: python script.py <lab number ##>")
    sys.exit(0)

# Get the parent directory of the current directory
parent_dir = os.path.dirname(os.getcwd())
print("Parent Directory: {}".format(parent_dir))

# get folder number from command line and create foldername
idx = sys.argv[1]
foldername = "ece3710-lab" + str(idx) + "-wattsjake"
print("Filename: {}".format(foldername))

#check to see if folder already exists
if os.path.exists(os.path.join(parent_dir, foldername)):
    print("Folder already exists")
    sys.exit(0)
#otherwise create folder
else:
    os.mkdir(os.path.join(parent_dir, foldername))

# Create README.md file inside foldername
with open(os.path.join(parent_dir, foldername, "README.md"), "w") as f:
    #print date in ISO 8601 format with lab number
    f.write("# Lab " + str(idx) + " - Created - " + time.strftime("%Y-%m-%d", time.gmtime()))

# Create docs folder inside foldername
os.mkdir(os.path.join(parent_dir, foldername, "docs"))




