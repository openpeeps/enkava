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

import std/json
import jsony
from std/os import getCurrentDir
from std/strutils import parseEnum

from ./parser import TokenKind
include ./ast

import ../../filters/[email, ip, str, uuid]

type
    Status = enum
        None, FieldError, GeneralError, InternalError, Valid

    Field* = ref object
        id: string
            ## Identifier name of the field
        hint: string
            ## Field that can contain a hint message explaining the error
        private_exception: string

    InterpreterError* = ref object
        case error_type: Status
            of InternalError:
                public_internal_error: string
                    ## A public error message to display on client side via REST API
                private_internal_error: string
                    ## Holds an error message that is displayed on internal errors.
                    ## For example, parsing an invalid stringified JSON with ``parseJson``,
                    ## a bson file is missing from disk, and so on.
                private_internal_exception: string
                    ## Holds an Exception message. For example ``JsonParsingError``
            of GeneralError:
                public_general_error: string
                private_general_reason: string
            of FieldError:
                fields: seq[Field]
                    ## A sequence representing fields that contains invalid contents
            else: discard

    Interpreter* = object
        status: Status
            ## Status of current Interpreter instance
            ## It can be either ``Invalid`` or ``Valid``
        total_errors: int8
            ## Holds the number of total errors
        errors: InterpreterError
            ## Discovers parsing errors and other Nim exceptions
            ## and store as ``InternalError``
        content: JsonNode
            ## Holds the JSON content that needs to be validated
        nodes: JsonNode
            ## Holds the Abstract Syntax Tree representation of Enkava rules

proc newInternalError*[I: Interpreter](interp: var I, public, private, exception: string) =
    ## Set a new ``InterpreterError`` of type ``InternalError``
    interp.status = InternalError
    interp.errors = InterpreterError(
        error_type: InternalError,
        public_internal_error: public,
        private_internal_error: private,
        private_internal_exception: exception
    )

proc newGeneralError*[I: Interpreter](interp: var I, msg, reason: string) =
    ## Set a new ``InterpreterError`` of type ``GeneralError`
    interp.total_errors = 1
    interp.status = GeneralError
    interp.errors = InterpreterError(
        error_type: GeneralError,
        public_general_error: msg,
        private_general_reason: reason
    )

proc hasErrors*[I: Interpreter](interp: I): bool =
    ## Determine if current Interpreter has any internal or general erros
    result = interp.total_errors != 0 and interp.errors != nil

proc getErrors*[I: Interpreter](interp: I): InterpreterError =
    ## Return ``InterpreterError`` instance, if not nil
    result = interp.errors

proc addError*[I: Interpreter](interp: var I, id, msg, exception: string) =
    ## Add a new Field to ``error_fields``
    var field = Field(id: id, hint: msg, private_exception: exception)
    if interp.errors != nil:
        interp.errors.fields.add(field)
    else:
        interp.errors = InterpreterError(error_type: FieldError)
        interp.errors.fields.add(field)
    inc interp.total_errors

proc init*[I: typedesc[Interpreter]](interp: I, content, rules: string): Interpreter =
    ## Initialize a new Interpreter instance followed by stringified JSON
    ## on ``content`` and ``rules`` parameters.
    try:
        let
            ekaRules: JsonNode = parseJson(rules)
            contentBody: JsonNode = parseJson(readFile(getCurrentDir() & "/test.json"))
        result = interp(nodes: ekaRules, content: contentBody)
    except:
        result = interp()
        result.newInternalError(
            "Could not process your submission. Please, try again.",
            getCurrentExceptionMsg(), $(ReadIOEffect)
        )

const stringBasedSymbols = [
    "TypeAscii", "TypeAlphabetical", "TypeBase32", "TypeBase58", "TypeBase64",
    "TypeEmail", "TypeString", "TypeUUID", "TypeUUIDv1", "TypeUUIDv3", "TypeUUIDv4", "TypeUUIDv5"
]

proc kindBySymbol(symbolName: string): JsonNodeKind =
    if symbolName in stringBasedSymbols:
        result = JString
    elif symbolName == "TypeBool":
        result = JBool
    elif symbolName == "TypeObject":
        result = JObject
    elif symbolName == "TypeInt":
        result = JInt

proc getKind(a: JsonNode): string {.inline.} =
    result = a["symbolName"].getStr

proc check_kind[A, B: JsonNode](a: A, b: B): bool = 
    ## Check the ``JsonNodeKind`` between `A` and `B`
    result = b.kind == kindBySymbol(a.getKind)

proc check_length[A, B: JsonNode](a: A, b: B): bool =
    ## Check ``JsonNode`` length betwen `A` and `B`
    result = a.len == b.len

proc check_requirement[A, B: JsonNode](a: A, b: B): bool =
    ## Check A has ``required`` field set to true, so
    ## it can check B field if has any value
    if a["required"].getBool == true:
        result = b.getStr.len != 0
    else: result = true

proc check_name[A: JsonNode, B: string](a: A, b: B): bool =
    ## Check if a field exists based on its name key
    result = a["ident"].getStr == b

proc check_string_kind[A, B: JsonNode](a: A, b: B): tuple[status: bool, hint: string] = 
    ## Main procedure that validates a string-based inputs
    ## depending on their ``EnkavaTypeValue``.
    let kind = parseEnum[EnkavaTypeValue](a.getKind)
    let input = b.getStr
    case kind:
    of TypeEmail:
        result.status   = email.isValid input
    of TypeIP:
        result.status   = ip.isIPv4 input
    of TypeAlphabetical:
        result.status   = str.isAlpha input
    of TypeLowercase:
        result.status   = str.isLowercase input
    of TypeUppercase:
        result.status   = str.isUppercase input
    of TypeDigit:
        result.status   = str.isDigits input
    of TypeUUID:
        result.status   = uuid.isValid input
    of TypeUUIDv1:
        result.status   = uuid.isValid(input, V1)
    of TypeUUIDv3:
        result.status   = uuid.isValid(input, V3)
    of TypeUUIDv4:
        result.status   = uuid.isValid(input, V4)
    of TypeUUIDv5:
        result.status   = uuid.isValid(input, V5)
    # of TypeIBAN:
    #     result.status   = iban.isValid(input)
    else: result.status = true

proc getFieldId(field: JsonNode): string {.inline.} =
    ## Returns a stringified identifier key of the field
    result = field["ident"].getStr

proc validate*[I: Interpreter](interp: var I) =
    ## Procedure for starting the validation
    if not check_length(interp.nodes, interp.content[0]):
        # General checks first
        interp.newGeneralError(
            "Invalid submission. Please, try again", "Validation failed on check_length")
        return

    var i = 0
    let lenNodes = interp.nodes.len
    for fk, fv in pairs(interp.content[0]):
        let rule: JsonNode = interp.nodes[i]
        inc i
        let id = rule.getFieldId
        if not check_name(rule, fk):
            interp.addError(id, "Field $1 does not exist" % [id], "check_name")
            continue
        if not check_kind(rule, fv):
            interp.addError(id, "Field $1 expects a value of type..." % [id], "check_kind")
            continue
        
        if not check_requirement(rule, fv):
            # When required, checks if current field is filled
            interp.addError(id, "Required field" % [id], "check_requirement")
            continue

        let stringKind = check_string_kind(rule, fv)
        if stringKind.status == false:
            # When field is based on a string filter, will validate given input.
            # This verification incldues many string-based filters. Check ``EnkavaTypeValue``
            # from ``ast`` file.
            interp.addError(id, "Field is not valid", "check_string_kind")
            continue
        