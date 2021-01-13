wget https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/CARLA_0.9.9.4.tar.gz
wget https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/AdditionalMaps_0.9.9.4.tar.gz

mv CARLA_0.9.9.4.tar.gz CARLA_0.9.9.tar.gz
mv AdditionalMaps_0.9.9.4.tar.gz AdditionalMaps_0.9.9.tar.gz

docker build -t carla:0.9.9 -f Dockerfile .
