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

type
    Eka = object
        id: string
        eka_path: string
        bson_path: string

    MemoryTable = object
        rules: TableRef[string, Eka]

var Memory* {.threadvar.}: MemoryTable
Memory = MemoryTable(rules: newTable[string, Eka]())

proc add*[M: MemoryTable](mem: var M, id, eka_path, bson_path: string) =
    ## Add a new sheet of rules to MemoryTable, both .eka and .bson
    mem.rules[id] = Eka(id: id, eka_path: eka_path, bson_path: bson_path)

proc has*[M: MemoryTable](mem: M, id: string): bool =
    ## Determine if ``MemoryTable`` contains an ``Eka object`` by given ``id``
    result = mem.rules.hasKey(id)

proc getBsonPath*[M: MemoryTable](mem: var M, id: string): string =
    result = mem.rules[id].bson_path
