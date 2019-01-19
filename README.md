# Check-Active-Directory-for-end-of-life-computers
### https://github.com/border-blaster/Check-Active-Directory-for-end-of-life-computers
#### 2019-01-18

The object of this script is to find out what computer objects joined to an avtive directory domain
have Windows OSs that have passed their end of life or exteneded support. Also, the script lists
computer objects have less than a year until they make it to end of life. 

Useage:
- Run the script with apropiate credintals to read computer object OS and OS versions.
- The script checks the csv hosted on gitup for OS, OS Version, and EOL information, so you 
  will need internet access to run. *Or you can download the csv and import directly.
