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

import std/[json, with]
from std/strutils import `%`

type

    Field* = object
        id: string
            ## Identifier name of the field
        hint: string
            ## Field that can contain a hint message explaining the error
    Status = enum
        None, Invalid, Valid

    InternalErrorNotification* = ref object
        public_error: string
            ## A public error message to display on client side via REST API
        private_error: string
            ## Holds an error message that is displayed on internal errors.
            ## For example, parsing an invalid stringified JSON with ``parseJson``,
            ## a bson file is missing from disk, and so on.
        private_exception: string
            ## Holds an Exception message. For example ``JsonParsingError``

    Interpreter* = object
        status: Status
            ## Status of current Interpreter instance
            ## It can be either ``Invalid`` or ``Valid``
        content: JsonNode
            ## Holds the JSON content that needs to be validated
        nodes: JsonNode
            ## Holds the Abstract Syntax Tree representation of Enkava rules
        error_fields: seq[Field]
            ## A sequence representing fields that contains invalid contents
        total_errors: int8
            ## Holds the number of total errors
        internal_error: InternalErrorNotification
            ## a ``ref object`` containing the following string-based fields:
            ## ``public_error``, ``private_error`` ``and private_exception``

proc addError*[I: Interpreter](interp: var I) =
    ## Add a new Field to ``error_fields``
    interp.error_fields.add(Field())
    inc interp.total_errors

proc init*[I: typedesc[Interpreter]](interp: I, content, rules: string): Interpreter =
    ## Initialize a new Interpreter instance followed by stringified JSON
    ## on ``content`` and ``rules`` parameters.
    try:
        let
            ekaRules: JsonNode = parseJson(rules)
            contentBody: JsonNode = parseJson(content)
        result = interp(nodes: ekaRules, content: contentBody)
    except JsonParsingError:
        var interpreter = interp()
        with interpreter:
            internal_error = InternalErrorNotification(
                public_error: "Could not process your submission. Please, try again.",
                private_error: getCurrentExceptionMsg(),
                private_exception: $(JsonParsingError)
            )
        result = interpreter


proc addNotification*[I: Interpreter](interp: var I, msg: string, showTotal: bool) =
    ## Add a general notification message that is
    ## returned in an HTTP response when an error occurs.
    ## 
    ## Set ``showTotal`` true to display total errors in your
    ## general notification message. The substitution variables
    ## (the thing after the $) are enumerated from 1 to a.len.
    ## 
    ## To produce a verbatim ``$``, use ``$$``.
    ## 
    ## The notation ``$#`` can be used to refer to the next substitution variable
    ## https://nim-lang.org/docs/strutils.html#%25%2Cstring%2CopenArray%5Bstring%5D
    if showTotal: interp.notification % [interp.total_errors]
    else: interp.notification = msg

proc hasErrors*[I: Interpreter](interp: I): bool {.inline.} = 
    ## Determine if current Interpreter has any errors
    result = interp.total_errors != 0

proc hasInternalError*[I: Interpreter](interp: I): bool {.inline.} =
    ## Determine if current Interpeter has any internal errors
    result = interp.internal_error != nil

proc getInternalError*[I: Interpreter](interp: I): InternalErrorNotification {.inline.} =
    ## Returns an object of ``InternalErrorNotification``
    result = interp.internal_error

iterator errors*[I: Interpreter](interp: I): tuple[key, message: string] =
    ## Returns a ``seq[Field]`` representing all fields with invalid contents
    ## Iterates over ``errors`` field of current Interpreter instance
    for field in interp.error_fields:
        yield (field.id, field.hint)

proc getErrors*[I: Interpreter](interp: I): seq[Field] =
    ## Retrieve errors from current ``Interpreter`` instance
    result = interp.error_fields

proc check_kind[A, B: JsonNode](a: A, b: B, kind: JsonNodeKind): bool = 
    ## Check the ``JsonNodeKind`` between `A` and `B`
    result = a.kind == kind and b.kind == kind

proc check_length[A, B: JsonNode](a: A, b: B): bool =
    ## Check ``JsonNode`` length betwen `A` and `B`
    result = a.len == b.len

proc validate*[I: Interpreter](interp: var I) =
    ## Procedure for starting the validation
    var i = 0
    let lenNodes = interp.nodes.len
    while i < lenNodes:
        if check_length(interp.nodes, interp.content):
            interp.addError()
        if interp.hasErrors: break
        # echo check_kind(interp.nodes[i], interp.content[i]["user"], JObject)
        inc i

    # for node in interp.nodes.items():
        # check(node["ident"], )