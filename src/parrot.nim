import std/json
# import parrot/validator
# export validator

import parrot/parser

when isMainModule:
    let example: JsonNode = %*{
        "name": "Trippy Parrot",
        "year": "2022",
        "shopping": [
            "Bananas", "Whatever Juice", "Soda", "Cat food", true
        ]
    }

    # Initialize a new Parrot validator,
    # pass your JsonNode and create your rules
    # 
    # Setting `strict` to true, will give you a crazy strict Parrot
    # that once finds an error it will quit the proccess
    # 
    # While in strict mode, if JsonNode has more fields
    # than those listed in rules sequence, it will result in an error
    # var p = Parrot.init(example,
    #     rules = @[
    #         "name*:string",
    #         "version*:int",
    #         "url*:string",
    #         "shopping*:array[5, string]"
    #     ], strictMode = true)

    ## Checking if there are any errors
    ## Note that each error is a tuple[field, expectType, givenType: string, line: string]
    # if p.hasErrors():
        # for e in p.getErrors():
            # echo "($1) \"$2\" field is type of \"$3\", \"$4\" given" % [e.line, e.field, e.expectType, e.givenType]
    discard validate("sample.parrot", %*{"name": "Whatever Parrot, Whatever"})
