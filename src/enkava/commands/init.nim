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

import klymene/cli
import ./utils
# from ../filters/ip import isIPv4

proc createConfigFile(fields: varargs[string]) =
    let enkavaConfig = """
app:
  address: "$1"         # The address | 127.0.0.1
  port: $2              # Port number | 7550
  threads: $3           # Number of threads
  source: "$4"          # Source path to your .eka rules
  output: "$5"          # Source path to binary rules
"""
    try:
        writeFile(getCurrentDirPath(configFileName), enkavaConfig % fields)
    except:
        display("👉 Could not write the config file.", indent = 2, br = "both")
        quit()

proc runCommand*() =
    ## Command for initializing a new Enkava configuration
    if configFileExists():
        display("👉 `$1` already exists at current location" % [configFileName], indent=2)
        quit()

    display("Creating a new Enkava Configuration", indent=2)

    createConfigFile("127.0.0.1", "1234", "1", "./enkava/rules", "./enkava/bson")
    display("✨ Done!")