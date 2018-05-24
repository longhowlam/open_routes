## packages die eerst geinstalleerd moeten worden

sudo apt-get install libsecret-1-dev 
sudo apt-get install -y libprotobuf-dev protobuf-compiler
sudo apt-get install libv8-3.14-dev 
sudo add-apt-repository -y ppa:opencpu/jq
sudo apt-get update
sudo apt-get install libjq-dev
sudo apt-get install libgdal1-dev libgdal-dev libgeos-c1 libproj-dev
sudo apt-get install libudunits2-dev

sudo add-apt-repository ppa:ubuntugis/ppa && sudo apt-get update
sudo apt-get remove gdal-bin
sudo apt-get install gdal-bin
gdal-config --version
## remember unlock key ring in "Password&Keys"otherwise apikey cannot be saved in keyring
