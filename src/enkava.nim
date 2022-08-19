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

import klymene
import enkava/commands/[init, server, build]
from std/strutils import `%`

const
    appId = "enkava"
    version = "0.1.0"
    commands = """
# Enkava Validation Schema Language #
# Made by Humans from OpenPeep 👉 https://enkava.co #

$2
  $1 new                            # Create a new config file #
  $1 build                          # Generate Binary AST for all Enkava rules #
  $1 serve [<config>]               # Enkava as a REST API Microservice #

$3
  -h --help             # Show this screen. #
  -v --version          # Show version. #
""" % [appId, "\e[1mUsage:\e[0m", "\e[1mOptions:\e[0m"]

let args = newCommandLine(commands, version=version, binaryName=appId)

if   isCommand("new", args):                init.runCommand()
elif isCommand("serve", args):              server.runCommand(args["<config>"])
elif isCommand("build", args):              build.runCommand()


#
# CLI implementation based on Klymene v2
#
# about:
#     "Enkava Validation Schema Language"
#     "Made by Humans from OpenPeep 👉 https://github.com/openpeep/enkava"
# commands:
#     $ "new"                             "Create a new Enkava config file"
#     $ "build"                           "Generate Binary AST for all Enkava rules"
#     $ "serve" ["config"]                "Run Enkava as a REST API microservice"
#     $ "check" ["json", "rules"]         "Validate JSON contents with given rules"