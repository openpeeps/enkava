# State of the Art 👌
# JSON Content Rules Validator Language with built-in REST API
#
# (c) 2022 Parrot is released under GPLv3 License
#          Made by Humans from OpenPeep
#          
#          https://parrot.codes
#          https://github.com/openpeep/parrot

from std/strutils import parseEnum

type
    SchemeURI* = enum
        ## IANA RFC-7595 Uniform Resource Identifiers
        ## https://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml
        Invalid

        Bitcoin = "bitcoin"
            ## Send money to a Bitcoin address
            ## bitcoin:<address>[?[amount=<size>][&][label=<label>][&][message=<message>]]

        BitcoinCash = "bitcoincash"
            ## Send money to a Bitcoin Cash address
            ## bitcoincash:<address>[?[amount=<size>][&][label=<label>][&][message=<message>]]

        Chrome = "chrome"
            ## chrome://<package>/<section>/<path> (Where <section> is either "content", "skin" or "locale")
            ## https://www.iana.org/assignments/uri-schemes/prov/chrome

        ChromeExtension = "chrome-extension"
            ## chrome-extension://<extensionID>/<pageName>.html (Where <extensionID> is the
            ## ID given to the extension by "Chrome Web Store" and <pageName> is the location of an HTML page)
            ## Management of setting of extensions which have been installed.

        FaceTime = "facetime"
            ## facetime://<address>|<MSISDN>|<mobile number>
            ## example: facetime://+19995551234

        MongoDB = "mongodb"
            ## mongodb://[username:password@]host1[:port1][,host2[:port2],...[,hostN[:portN]]][/[database][?options]]

converter toSchemeURI(i: string): SchemeURI =
    try:
        result = parseEnum[SchemeURI](i)
    except ValueError:
        result = SchemeURI.Invalid

proc getScheme*(input: string) =
    ## Determine URI scheme from given input based on SchemeURI enumeration.
    echo toSchemeURI(input)