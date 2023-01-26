import glob
import json
import os
import sys
import time

def parent_dir():
    # Get the parent directory of the current directory
    return os.path.dirname(os.getcwd())

def create_folder(idx):
    # Create the folder
    foldername = "ece3710-lab" + str(idx) + "-wattsjake"

def check_folder_exists(foldername):
    #check to see if folder already exists
    if os.path.exists(os.path.join(parent_dir, foldername)):
        print("Folder already exists")
        return True
    else:
        return False

def load_json():
    json_file = glob.glob('*.json') # get json file
    # Opening JSON file
    with open(str(json_file[0]), 'r') as json_file:
        # Reading from json file
        json_object = json.load(json_file)
    return json_object

def user_input():
    # Check if the user has provided the correct number of arguments
    if len(sys.argv) != 2:
        print("Usage: python script.py <foldername>")
        sys.exit(0)

    # Check if the user has provided the help argument
    if (sys.argv[1] == "-help" or sys.argv[1] == "-h"):
        print("Usage: python script.py <foldername>")
        sys.exit(0)

    #Get the folder number from the command line
    return sys.argv[1]

def main():
    print("Creating folder...")
    idx = user_input()
    print(idx)


if __name__ == "__main__":
     main()






