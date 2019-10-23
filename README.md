# Docker Container for InCommon Federated Apache Server

First generate a key an certificate for Shibboleth to talk to the IdPs:
```sh
pushd certificates
./keygen.sh
popd
```
This will create
```
certificates/sp-cert.pem
certificates/sp-key.pem
```

You will need to request a valid host certificate and key and place them in
```
certificates/hostcert.pem
certificates/hostkey.pem
```

If you have any additional IdP providers other than those than come through InCommon, create the file `provider-metadata.xml` and add them to this file. If not, create an empty file with
```sh
touch provider-metadata.xml
```

Build the image setting the `--build-arg` to override the defaults as appropriate:
```sh
docker build \
   --build-arg SHIBBOLETH_SP_ENTITY_ID=http://ce-roster.phy.syr.edu/shibboleth-sp \
   --build-arg SP_MD_SERVICENAME="Syracuse University Gravitational Wave Group - CE COmanage" \
   --build-arg SP_MDUI_DISPLAYNAME="Cosmic Explorer COmanage Roster" \
   --build-arg SP_MDUI_DISPLAYNAME="Syracuse University Gravitational Wave Group - CE COmanage" \
   --build-arg SP_MDUI_DESCRIPTION="Cosmic Explorer COmanage Roster" \
   --build-arg SP_MDUI_INFORMATIONURL="https://cosmicexplorer.org" \
   --rm -t cosmicexplorer/roster .
```

Then start the container with
```sh
docker run cosmicexplorer/roster
```
