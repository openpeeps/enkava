# State of the Art 👌 JSON Content Rules Language,
# HTTP Server, Validator and Generator
#
# (c) 2022 Parrot is released under GPLv3 License
#          Made by Humans from OpenPeep
#          
#          https://parrot.codes
#          https://github.com/openpeep/parrot

import supranim, klymene/cli
from klymene import Value, `$`

include ../core/server/routes
import ./utils

const inlineConfig = """
app:
  address: "127.0.0.1"
  port: 5555
  name: "Parrot"
  threads: 2
"""

proc runCommand*() =
    ## Command for starting a Parrot HTTP server powered by Supranim.
    if not configFileExists():
        display("👉 `$1` is missing. Run `parrot init` to generate your config." % [configFileName], indent=2)
        quit()

    var app = supranim.init(inlineConfigStr = inlineConfig)
    app.start()