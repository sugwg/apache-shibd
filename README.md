# Docker Container for InCommon Federated Apache Server

These instructions require both Docker and [Docker Compose](https://docs.docker.com/compose/install/) to be installed.

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

If you have any additional IdP providers other than those than come through InCommon Federation, create the file `provider-metadata.xml` and add them to this file. The contents of this file are added inside the `<SPConfig>`, so they should just contain the `<MetadataProvider>` section for the additional IdPs. For example, a valid `provider-metdadata.xml` can contain one or more IdPs in the format:
```
<MetadataProvider type="XML" url="https://sugwg-ds.phy.syr.edu/sugwg-orcid-metadata.xml"
    backingFilePath="/var/log/shibboleth/sugwg-orcid-metadata.xml" reloadInterval="82800" legacyOrgNames="true"/>
```
If no additionan IdPs are needed beyone the InCommon federation, create an empty file with
```sh
touch provider-metadata.xml
```

Build the image setting the `--build-arg` to override the defaults as appropriate, for example:
```sh
docker build \
   --build-arg SHIBBOLETH_SP_ENTITY_ID=https://ce-roster.phy.syr.edu/shibboleth-sp \
   --build-arg SHIBBOLETH_SP_SAMLDS_URL=https://dcc.cosmicexplorer.org/shibboleth-ds/index.html \
   --build-arg SP_MD_SERVICENAME="Syracuse University Gravitational Wave Group - CE COmanage" \
   --build-arg SP_MD_SERVICEDESCRIPTION="Cosmic Explorer COmanage Roster" \
   --build-arg SP_MDUI_DISPLAYNAME="Syracuse University Gravitational Wave Group - CE COmanage" \
   --build-arg SP_MDUI_DESCRIPTION="Cosmic Explorer COmanage Roster" \
   --build-arg SP_MDUI_INFORMATIONURL="https://cosmicexplorer.org" \
   --rm -t sugwg/apache-shibd .
```

The container requires the environment variables `HOSTNAME` and `DOMAINNAME` to be set to the host and domain that you want for the container.

Then start the container with
```sh
export DOMAINNAME=phy.syr.edu
docker-compose up --detach
```

You can log into the container with
```sh
docker exec -it apache-shibd_apache-shibd_1 /bin/bash -l
```

The Shibboleth configuration files will be copied to the directory `shibboleth/` for storage on the host and use by other containers.

To shut down the container, run the command:
```sh
docker-compose down
```
