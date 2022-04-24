# State of the Art 👌 Validation Schema Language
# 
# Enkava is a top-notch language for validating JSON contents
# without dealing with JSON syntax at all.
# 
# Enkava has a RESTful API so it can be used with any HTTP library
# in any programming lanugage.
#
# (c) 2022 Enkava is released under GPLv3 License
#          Made by Humans from OpenPeep
#          
#          https://enkava.co
#          https://github.com/enkava

import supranim, klymene/cli
from klymene import Value, `$`, isNil

include ../core/server/routes
import ./utils

proc runCommand*(configPath: Value) =
    ## Command for starting a Parrot HTTP server powered by Supranim.
    ##
    ## In production mode is recommended to boot your Parrot instance(s)
    ## by passing an absolute path that points to your specific ``parrot.config.yml``.
    ## 
    ## Also, you may want to boot Parrot as a daemon via
    ## ``systemd`` or a similar daemon manager.
    if not configFileExists():
        display("👉 `$1` is missing. Run `parrot init` to generate your config." % [configFileName], indent=2)
        quit()

    let getConfigPath = if configPath.isNil(): "" else: $configPath
    var app = supranim.init(inlineConfigStr = readConfigContents(getConfigPath))
    app.start()