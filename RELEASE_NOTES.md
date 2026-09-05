Using crlDistributionPoints ensures that OpenSSL returns only CRL
information, excluding entries such as OCSP and CA Issuers. This
prevents the wrong URI from being parsed accidentally.
