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

# Package

version       = "0.1.0"
author        = "George Lemon"
description   = "State of the Art 👌 Validation Schema Language"
license       = "GPL-3"
srcDir        = "src"
bin           = @["enkava"]
binDir        = "bin"

# Dependencies

requires "nim >= 1.6.0"
requires "toktok"
requires "supranim"
requires "klymene"
requires "bson"

after build:
    exec "clear"

task dev, "Compile for development":
    echo "\n✨ Compiling for dev" & "\n"
    exec "nimble build --gc:arc --threads:on -d:inlineConfig"

task prod, "Compile for production":
    echo "\n✨ Compiling for prod" & "\n"
    exec "nimble build -d:release --gc:arc --threads:on -d:ssl --opt:size -d:danger -d:inlineConfig"