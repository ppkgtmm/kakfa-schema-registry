# this script assumes that python 3.9 and java are installed

# set up
python3.9 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

# cert gen and signing
rm -r secrets
./gen-signed-cert.sh

# start services
docker-compose down -v
docker-compose up -d
