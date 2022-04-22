# State of the Art 👌 JSON Content Rules Language,
# HTTP Server, Validator and Generator
#
# (c) 2022 Parrot is released under GPLv3 License
#          Made by Humans from OpenPeep
#          
#          https://parrot.codes
#          https://github.com/openpeep/parrot

# Package

version       = "0.1.0"
author        = "George Lemon"
description   = "👌 JSON Content Rules Validator 🦜 It says what you say, if you say so"
license       = "GPL-3"
srcDir        = "src"
bin           = @["parrot"]
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
    exec "nimble build --gc:arc --threads:on -d:ssl --opt:size -d:danger -d:inlineConfig"