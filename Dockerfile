FROM centos:7
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

RUN curl -s -L http://download.opensuse.org/repositories/security://shibboleth/CentOS_7/security:shibboleth.repo > /etc/yum.repos.d/shibboleth.repo
RUN yum -y install httpd mod_ssl shibboleth shibboleth-embedded-ds mod_shib

COPY certificates/hostkey.pem /etc/pki/tls/private/localhost.key
COPY certificates/hostcert.pem /etc/pki/tls/certs/localhost.crt
COPY certificates/igtf-ca-bundle.crt /etc/pki/tls/certs/server-chain.crt
RUN mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.orig && \
    sed 's/#SSLCertificateChainFile/SSLCertificateChainFile/g' /etc/httpd/conf.d/ssl.conf.orig > /etc/httpd/conf.d/ssl.conf && \
    rm -f /etc/httpd/conf.d/ssl.conf.orig && \
    systemctl enable httpd && \
    systemctl enable shibd

ARG SHIBBOLETH_SP_ENTITY_ID=https://seaview.phy.syr.edu/shibboleth-sp
ARG SHIBBOLETH_SP_CERT=certificates/sp-cert.pem
ARG SHIBBOLETH_SP_PRIVKEY=certificates/sp-key.pem
ARG SHIBBOLETH_SP_METADATA_PROVIDER_XML=provider-metadata.xml
ARG SHIBBOLETH_SP_SAMLDS_URL=https://sugwg-jobs.phy.syr.edu/shibboleth-ds/index.html

ARG SP_MD_SERVICENAME="Syracuse University Gravitational Wave Group - Seaview"
ARG SP_MD_SERVICEDESCRIPTION="Duncan Brown\&apos;s IdM Development Machine"
ARG SP_MDUI_DISPLAYNAME="Syracuse University Gravitational Wave Group - Seaview"
ARG SP_MDUI_DESCRIPTION="Duncan Brown\&apos;s IdM Development Machine"
ARG SP_MDUI_INFORMATIONURL="https://dabrown.expressions.syr.edu/"
ARG SP_MDUI_PRIVACYSTATEMENTURL="https://www.syracuse.edu/about/site/privacy-policy/"
ARG SP_MDUI_LOGO_WIDTH="110"
ARG SP_MDUI_LOGO_HEIGHT="150"
ARG SP_MDUI_LOGO_URL="https://shibidp.syr.edu/idp/images/block-s.png"
ARG SP_MD_ORGANIZATION_NAME="Syracuse University"
ARG SP_MD_ORGANIZATIONDISPLAYNAME="Syracuse University"
ARG SP_MD_ORGANIZATIONURL="https://syracuse.edu/"
ARG SP_MD_TECHNICAL_GIVENNAME="Kelly Fallon"
ARG SP_MD_TECHNICAL_EMAILADDRESS="kjfallon@syr.edu"
ARG SP_MD_ADMINISTRATIVE_GIVENNAME="Kelly Fallon"
ARG SP_MD_ADMINISTRATIVE_EMAILADDRESS="kjfallon@syr.edu"
ARG SP_MD_SUPPORT_GIVENNAME="Kelly Fallon"
ARG SP_MD_SUPPORT_EMAILADDRESS="kjfallon@syr.edu"
ARG SP_MD_SECURITY_GIVENNAME="Christopher Croad"
ARG SP_MD_SECURITY_EMAILADDRESS="ccroad@syr.edu"


COPY shibboleth2.xml.tmpl /tmp/shibboleth2.xml.tmpl
COPY ${SHIBBOLETH_SP_METADATA_PROVIDER_XML} /tmp/provider-metadata.xml
COPY ${SHIBBOLETH_SP_CERT} /etc/shibboleth/sp-signing-cert.pem
COPY ${SHIBBOLETH_SP_PRIVKEY} /etc/shibboleth/sp-signing-key.pem
COPY ${SHIBBOLETH_SP_CERT} /etc/shibboleth/sp-encrypt-cert.pem
COPY ${SHIBBOLETH_SP_PRIVKEY} /etc/shibboleth/sp-encrypt-key.pem

RUN echo > /tmp/provider-metadata.sed '/%%SHIBBOLETH_SP_METADATA_PROVIDER_XML%%/ { r /tmp/provider-metadata.xml ' > /tmp/provider-metadata.sed && \
    echo 'd }' >> /tmp/provider-metadata.sed && \
    sed -e s+%%SHIBBOLETH_SP_ENTITY_ID%%+"${SHIBBOLETH_SP_ENTITY_ID}"+ /tmp/shibboleth2.xml.tmpl | \
    sed -e s+%%SHIBBOLETH_SP_SAMLDS_URL%%+"${SHIBBOLETH_SP_SAMLDS_URL}"+ | \
    sed -e s+%%SP_MD_SERVICENAME%%+"${SP_MD_SERVICENAME}"+ | \
    sed -e s+%%SP_MD_SERVICEDESCRIPTION%%+"${SP_MD_SERVICEDESCRIPTION}"+ | \
    sed -e s+%%SP_MDUI_DISPLAYNAME%%+"${SP_MDUI_DISPLAYNAME}"+ | \
    sed -e s+%%SP_MDUI_DESCRIPTION%%+"${SP_MDUI_DESCRIPTION}"+ | \
    sed -e s+%%SP_MDUI_INFORMATIONURL%%+"${SP_MDUI_INFORMATIONURL}"+ | \
    sed -e s+%%SP_MDUI_PRIVACYSTATEMENTURL%%+"${SP_MDUI_PRIVACYSTATEMENTURL}"+ | \
    sed -e s+%%SP_MDUI_LOGO_WIDTH%%+"${SP_MDUI_LOGO_WIDTH}"+ | \
    sed -e s+%%SP_MDUI_LOGO_HEIGHT%%+"${SP_MDUI_LOGO_HEIGHT}"+ | \
    sed -e s+%%SP_MDUI_LOGO_URL%%+"${SP_MDUI_LOGO_URL}"+ | \
    sed -e s+%%SP_MD_ORGANIZATION_NAME%%+"${SP_MD_ORGANIZATION_NAME}"+ | \
    sed -e s+%%SP_MD_ORGANIZATIONDISPLAYNAME%%+"${SP_MD_ORGANIZATIONDISPLAYNAME}"+ | \
    sed -e s+%%SP_MD_ORGANIZATIONURL%%+"${SP_MD_ORGANIZATIONURL}"+ | \
    sed -e s+%%SP_MD_TECHNICAL_GIVENNAME%%+"${SP_MD_TECHNICAL_GIVENNAME}"+ | \
    sed -e s+%%SP_MD_TECHNICAL_EMAILADDRESS%%+"${SP_MD_TECHNICAL_EMAILADDRESS}"+ | \
    sed -e s+%%SP_MD_ADMINISTRATIVE_GIVENNAME%%+"${SP_MD_ADMINISTRATIVE_GIVENNAME}"+ | \
    sed -e s+%%SP_MD_ADMINISTRATIVE_EMAILADDRESS%%+"${SP_MD_ADMINISTRATIVE_EMAILADDRESS}"+ | \
    sed -e s+%%SP_MD_SUPPORT_GIVENNAME%%+"${SP_MD_SUPPORT_GIVENNAME}"+ | \
    sed -e s+%%SP_MD_SUPPORT_EMAILADDRESS%%+"${SP_MD_SUPPORT_EMAILADDRESS}"+ | \
    sed -e s+%%SP_MD_SECURITY_GIVENNAME%%+"${SP_MD_SECURITY_GIVENNAME}"+ | \
    sed -e s+%%SP_MD_SECURITY_EMAILADDRESS%%+"${SP_MD_SECURITY_EMAILADDRESS}"+ | \
    sed -f /tmp/provider-metadata.sed > /etc/shibboleth/shibboleth2.xml && \
    curl -L -s https://ds.incommon.org/certs/inc-md-cert.pem > /etc/shibboleth/inc-md-cert.pem && \
    chown shibd:shibd /etc/shibboleth/sp*pem

CMD ["/usr/sbin/init"]
