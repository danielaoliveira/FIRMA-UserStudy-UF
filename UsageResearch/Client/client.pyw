import requests, traceback
import os, zipfile, time, sys, hashlib
from random import randint
from sys import exit
import logging

CWD = os.getcwd()

SERVER_URL = 'https://faros.ece.ufl.edu:12380'
#SERVER_URL = 'http://localhost:8080'
USERID_FILE = CWD+'\\UserId.txt'
RECORDS_DIR = 'C:\\Windows\\'
EVENT_RECORDS_DIR = 'C:\\FIRMA_UserStudy\\'
MAX_RETRY = 3
DELAY_INTERVAL = 15

def get_request(url):
    res = requests.get(url)

def sha256_checksum(filename, block_size=65536):
    sha256 = hashlib.sha256()
    with open(filename, 'rb') as f:
        for block in iter(lambda: f.read(block_size), b''):
            sha256.update(block)
    return sha256.hexdigest()

# Helper method to check if the serer is up and accessible from the
def is_server_alive():
    try:
        res = requests.get(SERVER_URL+'/server_status')
        #print(str(res.content))
        if "Hi, I'm Ext2.0 alive!" in str(res.content):
            return True
        else:
            return False
    except: return False

# Check if the server is running and then upload the given file
def send_file(user_id, filepath):
    retry_count = 0
    random_delay = randint(0, DELAY_INTERVAL)
    # Retry connecting to the server with a random backoff 
    while is_server_alive() is False and retry_count<MAX_RETRY:
        time.sleep(random_delay) 
        random_delay = randint(0, DELAY_INTERVAL)
        retry_count = retry_count + 1
    if retry_count == MAX_RETRY and is_server_alive() is False:
        logging.debug('Failed to upload file: %s', filepath)
        logging.warning('Network problem, cannot access the server - Exiting!')
        sys.exit()
    # Include the checksum of the file in the param for ensuring integrity
    checksum = sha256_checksum(filepath)
    with open(filepath, 'rb') as f:
        res = requests.post(SERVER_URL+'/upload', data={'userid':user_id, 'csum':checksum}, files={'file':f})
        #print(res.content)
    if "True" in str(res.content):
        logging.debug('File deleted after uploading it: %s', filepath)
        # Delete the file if it was successfully uploaded to the server
        os.remove(filepath)
        return True
    else:
        return False

# Create a zip with the file in the given directory and uploads it
def zip_and_upload(user_id, directory):
    for (dirpath, dirnames, filenames) in os.walk(directory):
        zipname = str(round(time.time() * 1000))+".zip"
        zipfqdn = os.path.join(dirpath, zipname)
        for f in filenames:
            # Checking if we have a zip file already - which wasn't uploaded to the server earlier
            if ".zip" in f:
                fqdn = os.path.join(dirpath, f)
                logging.debug('Found old zip file, uploading it: %s', fqdn)
                res = send_file(user_id, fqdn)
                logging.info(res)

        zipf = zipfile.ZipFile(zipfqdn, 'w', zipfile.ZIP_DEFLATED)
        for f in filenames:
            if ".zip" not in f:
                fqdn = os.path.join(dirpath, f)
                zipf.write(fqdn, f)
        files = zipf.namelist()
        zipf.close()
        # Deleting the files that were added into the zip - we send this zip to the server
        for f in filenames:
            fqdn = os.path.join(dirpath, f)
            if os.path.exists(fqdn):
                os.remove(fqdn)
        logging.debug('Uploading the file: %s', zipfqdn)
        if not files:
            os.remove(zipfqdn)
        else:
            res = send_file(user_id, zipfqdn)
        break

def main():
    # Read the value of user_id from that file
    with open(USERID_FILE) as f:
        user_id = f.readlines()
    user_id = [x.strip() for x in user_id]
    for i in range(7):
        # Zip and Upload Driver logs
        # zip_and_upload(user_id, RECORDS_DIR+'TestRecord'+str(i))
        # Zip and Upload Event logs
        zip_and_upload(user_id, EVENT_RECORDS_DIR+'EventRecord'+str(i))

if __name__ == "__main__":
    logging.basicConfig(level=logging.WARNING,
                    format='%(asctime)s %(levelname)s %(message)s',
                    filename=CWD+'\\uploader.log',
                    filemode='a+')
    try:
        main()
    except:
        logging.warning('Had an exception while running the client!')
        logging.warning(traceback.format_exc())
