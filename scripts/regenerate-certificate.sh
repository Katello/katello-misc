#!/bin/sh
echo "This script will remove all katello certificates and run katello-configure to regenerate them"
echo "last chance to CTRL+C, hit enter to continue..."
read

rm -rf /root/ssl-build
rm -rf /etc/pki/katello
rm -rf /etc/candlepin/certs/candlepin*
rm -rf /usr/share/katello/candlepin-cert.crt

rpm -e katello-candlepin-cert-key-pair

katello-configure --no-bars

# These lines can be removed when https://bugzilla.redhat.com/show_bug.cgi?id=962700 is resolved
service katello restart
service apache restart
service signo restart

echo "Finished, new certificate should be installed"
echo "showing new certificate and it's fingerprint:"
openssl x509 -in /etc/candlepin/certs/candlepin-ca.crt -fingerprint
