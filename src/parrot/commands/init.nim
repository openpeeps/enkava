import klymene/cli
import ./utils

proc createConfigFile(fields: varargs[string]) =
    let parrotConfig = """
# Give your Parrot a Port number to fly
port: $1
# Source path to your .parrot rules
source: $2
# Path to save the .bson rules
output: $3
"""
    try:
        writeFile(getCurrentDirPath(configFileName), parrotConfig % fields)
    except:
        display("👉 Could not write the config file.", indent = 2, br = "both")
        quit()

proc runCommand*() =
    ## Command for initializing a new Parrot configuration
    ## via Command Line Interface
    if configFileExists():
        display("👉 A `$1` already exists at current location" % [configFileName], indent=2)
        quit()

    display("Creating a new Parrot Configuration", indent=2)
    createConfigFile("1234", "./parrot/rules", "./parrot/bson")
    display("✨ Done!")