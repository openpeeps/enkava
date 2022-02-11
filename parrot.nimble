# Package

version       = "0.1.0"
author        = "George Lemon"
description   = "👌 JSON Content Rules Validator 🦜 It says what you say, if you say so"
license       = "MIT"
srcDir        = "src"
bin           = @["parrot"]
binDir        = "bin"

# Dependencies

requires "nim >= 1.6.0"

task dev, "Compile for development":
    echo "\n✨ Compiling for dev" & "\n"
    exec "nimble build --gc:arc -d:useMalloc"