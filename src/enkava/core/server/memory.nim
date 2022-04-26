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

import std/tables
import klymene/[cli, util]
import ../../utils

from std/strutils import strip, split
from std/os import extractFilename


type
    Eka = object
        id: string
        bson_rules: string

    Sheet* = object
        id: string
        endpoint: string

    MemoryTable = object
        ## ``MemoryTable`` is a simple ``TableRef`` that stores in memory
        ## all Enkava rules when running ``enkava serve``
        rules: TableRef[string, Eka]

var Memory* {.threadvar.}: MemoryTable
Memory = MemoryTable(rules: newTable[string, Eka]())

proc add[M: MemoryTable](mem: var M, id, bson_path: string) =
    ## Add a new sheet of rules to MemoryTable, both .eka and .bson
    let bsonContents = readBson(bson_path)
    mem.rules[id] = Eka(id: id, bson_rules: bsonContents)

proc indexing*[M: MemoryTable](mem: var M, output: string) =
    ## Finds ``.eka`` and ``.bson`` files inside ``source`` and ``output``
    ## directories specified in given ``enkava.config.yml``
    ## This procedure is called on ``enkava serve`` command for indexing
    ## rules and store in ``MemoryTable`` while server is running.
    var files: seq[string]
    var results = cmd("find", @[output, "-name", "*.bson", "-print"]).strip()
    if results.len == 0:
        display("👉 Could not find any enkava rules", indent=2, br="both")
        quit()
    
    files = results.split("\n")
    for file in files:
        let fileId = extractFilename(file)
        mem.add(fileId[0 .. ^6], file)

proc getAllSheets*[M: MemoryTable](mem: var M): seq[Sheet] =
    ## Returns a ``seq[string]`` containing all Rules from ``MemoryTable``
    for k, sheet in mem.rules:
        result.add(Sheet(id: sheet.id, endpoint: "/check/" & sheet.id))

proc has*[M: MemoryTable](mem: M, id: string): bool =
    ## Determine if ``MemoryTable`` contains an ``Eka object`` by given ``id``
    result = mem.rules.hasKey(id)

proc getBSON*[M: MemoryTable](mem: var M, id: string): string =
    ## 
    result = mem.rules[id].bson_rules
