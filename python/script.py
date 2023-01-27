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
        print("Oops... Something very specific happened.\n\
Check your usage: python script.py <foldername>\n\
-h     : print this help message and exit (also -? or --help)")
        sys.exit(0)

    # Check if the user has provided the help argument
    if (sys.argv[1] == "-help" or sys.argv[1] == "-h" or sys.argv[1] == "-?"):
        print("usage : " + os.path.dirname(os.getcwd()) +"\python> python3 script.py <index number>\n\
Options and arguments (and corresponding environment variables):\n\
-E     : Edit .json file\n\
-h     : print this help message and exit (also -? or --help)")
        sys.exit(0)

    if (sys.argv[1] == "-E"):
        print("Editing .json file")
        #ask user for first name
        first_name = input("Enter your first name: ")
        #ask user for last name
        last_name = input("Enter your last name: ")
        #ask for course number
        course_number = input("Enter your course number: ")

        #create json object
        json_object = {"first_name": first_name, "last_name": last_name, "course_number": course_number}

        json_file = glob.glob('*.json') # get json file

        #save json object to file
        with open(str(json_file[0]), "w") as outfile:
            json.dump(json_object, outfile)

        sys.exit(0)

    #Get the folder number from the command line
    return sys.argv[1]

def main():
    user_input()


if __name__ == "__main__":
     main()






