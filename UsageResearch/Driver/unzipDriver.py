import zipfile

with zipfile.ZipFile("SignedDriver.zip", "r") as zip_ref:
    zip_ref.extractall()