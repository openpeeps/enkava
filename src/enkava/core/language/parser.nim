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

from std/math import splitDecimal
from std/strutils import `%`, join
from std/sequtils import delete

import toktok
import std/[md5, json, jsonutils]

tokens:
    Optional    > '*'                       # Marks the field as optional
    Same        > '^'                       # Enkava DRY feature to reference a field or a group of fields
    Exclude     > '!'                       # Used for when referencing a group of fields but want to ignore some fields
    Or          > '|'                       # Optionally, a default value for given field
    Dot         > '.'
    Range       > ".."                      # Create ranges, from x to y. This works for int and char
    Lpar        > '('
    Rpar        > ')'
    Colon       > ':'
    Comma       > ','
    Comment     > '#' .. EOL                # anything starting with `#` to EndOfLine is a comment
    
    # Built-in string-based tokens that makes Enkava Filters
    Ascii           > "ascii"
    Alphabetical    > "alphabetical"
    Base32          > "base32"
    Base58          > "base58"
    Base64          > "base64"
    Bic             > "bic"
    Btc             > "btc"
    Currency        > "currency"
    Date            > "date"
    Digit           > "digit"
    EAN             > "ean"
    ETH             > "etherum"
    Email           > "email"
    Hash            > "hash"
    Hex             > "hex"
    Hexcolor        > "hexcolor"
    HSL             > "hsl"
    IP              > "ip"
    IBAN            > "iban"
    ISBN            > "isbn"
    ISIN            > "isin"
    Lowercase       > "lowercase"
    MacAddress      > "macaddress"
    MagnetURI       > "magneturi"
    MD5             > "md5"
    Numerical       > "numerical"
    URL             > "url"
    Uppercase       > "uppercase"
    Uuid            > "UUID"
    Uuid_v1         > "UUIDv1"
    Uuid_v3         > "UUIDv3"
    Uuid_v4         > "UUIDv4"
    Uuid_v5         > "UUIDv5"

    # Base type
    Type_Array       > "array"
    Type_Bool        > "bool"
    Type_Float       > "float"
    Type_Int         > "int"
    Type_Object      > "object"
    Type_Null        > "null"
    Type_String      > "string"

include ./ast

type
    Error* = enum
        SyntaxError
        TypeError
        IdentError

    Parser* = object
        lexer: Lexer
        prev, prevIdent, current, next: TokenTuple
        prevNode: Node
        error: string
        statements: seq[Node]
        prevln, currln, nextln: int
        parents: seq[Node]
            # A sequence of TokenTuple representing
            # all parents in a multi dimensional order
        indent: int
            # holds and ensure indentations on same level (2 or 4)
        depth: int
        memory: Memory

    PrefixFunction = proc(p: var Parser): Node {.gcsafe.}
    Memory = Table[string, Node]


proc setError[T: Parser](p: var T, typeError: Error, msg: string) =
    ## Set an error message containing TypeError, line, column and the message
    p.error = "$1 ($2:$3): $4" % [$typeError, $p.current.line, $p.current.col, msg]

proc hasError*[T: Parser](p: var T): bool {.inline.} =
    ## Determine if there are any errors
    result = p.error.len != 0

proc getError*[T: Parser](p: var T): string {.inline.} =
    ## Returns the error message, if any
    result = p.error

include ./parseutils

proc parseIdent(p: var Parser): Node =
    if p.isDuplicated(p.current,
        "Duplicate identifier \"$1\"" % [p.current.value], IdentError): return
    elif not p.expect(p.next, {TK_OPTIONAL, TK_COLON},
        "Missing assignment token", TypeError): return

    if p.current.col != 0:
        if p.indent == 0: # first time, set the indent based on first indented line
            if p.current.col in [2, 4]:
                p.indent = p.current.col

        let indentTuple = splitDecimal(p.current.col / p.indent)
        if indentTuple.floatpart != 0:
            p.setError(TypeError, "Bad indentation. Current rules document has a $1 spaces indentation" % [$p.indent])
            return

    var node = Node()
    let ident = p.current
    if p.next.kind == TK_OPTIONAL:
        jump p
        node.required = false       # followed by * becomes an optional field
    else: node.required = true
    jump p, 2

    let typeValue = typeValueByKind(p.current.kind)
    if typeValue == TypeInvalid:
        p.setError(TypeError, "Invalid type for \"$1\" field" % [ident.value])
        return
    
    node.ident = ident.value
    node.typeValue = typeValue
    node.symbolName = symbolName(typeValue)

    p.memorize(getIdentHash ident, node)            # store in memory
    p.prevNode = node                               # make current Rule as previous
    node.meta = (kind: ident.kind, line: ident.line, col: ident.col, wsno: ident.wsno, level: p.depth)
    result = node
    jump p

template parseSameStatement[T: Parser](p: var T): untyped =
    ## When identifier is prefixed by ^ TK_SAME, it means is a
    ## previously declared identifier used as reference for copying its
    ## children nodes and structure to current identifier. Pretty dope!
    if not p.expect(p.next, TK_IDENTIFIER,
        "Missing identifier for \"same\" reference", IdentError):
        return
    elif not p.keyExists(p.next.value,
        "Pointing \"same\" reference to non existing identifier \"$1\"" % [p.next.value], IdentError):
        return
    jump p

    let sameRefKey = p.current.value
    let sameRefNode = p.getRule(sameRefKey)
    
    if p.next.kind == TK_LPAR:   # Insert/exclude fields to/from pointed reference
        jump p
        if not p.expect(p.next, TK_EXCLUDE, "Missing exclusion token \"!\"", TypeError):
            return
        var origin: TokenTuple = p.current
        var tokens: seq[TokenTuple]
        jump p
        while true:
            if p.current.kind == TK_RPAR: break
            elif p.current.kind == TK_COMMA:
                if p.next.kind notin {TK_EXCLUDE, TK_IDENTIFIER}:
                    p.setError(TypeError, "Missing identifier after comma in current enumeration")
                    return
                jumpAndContinue p
            elif p.current.line > origin.line:
                p.setError(TypeError, "EOL reached before end of square bracket")
                break
            elif p.current.kind == TK_EXCLUDE:
                var origin: TokenTuple = p.current
                jump p
                while true:
                    if p.current.kind notin {TK_IDENTIFIER, TK_DOT}: break
                    if p.current.kind == TK_DOT:
                        add origin.value, "."
                    else: add origin.value, p.current.value
                    jump p
                tokens.add(origin)
            else:
                p.setError(TypeError, "Unrecognized character in exclusion syntax \"$1\"" % [p.current.value])
                return

template ensureIndent[P: Parser](p: var P): untyped =
    if (p.current.col and 1) != 1:
        p.setError(TypeError, "Invalid indentation. Use 2 or 4 spaces to indent your rules")

proc getPrefixFn(p: var Parser): PrefixFunction =
    ## Parse prefix and return Node representation
    result = case p.current.kind:
        of TK_IDENTIFIER: parseIdent
        else: nil

proc getSuffixFn(p: var Parser): PrefixFunction =
    ## Parse suffix and return Node representation
    result = case p.current.kind:
        of TK_IDENTIFIER: parseIdent
        else: nil

proc createNode(p: var Parser, parentNode: Node, prefixFn: PrefixFunction) =
    ## Create a new nested ``Node`` and add to ``nodes`` field of
    ## type ``seq[Node]`` from given ``parentNode``
    var nestedField = p.prefixFn()
    if nestedField != nil:
        let fieldId = nestedField.ident
        if not parentNode.nodes.hasKey(fieldId):
            parentNode.nodes[fieldId] = nestedField
        else: p.setError(IdentError, "Duplicate identifier \"$1\"" % [fieldId])

proc getLastParent(p: var Parser): Node =
    ## Retrieve the last ``Node`` parent from ``parents`` field
    if p.parents.len != 0:
        result = p.parents[^1]

proc parseExpression(p: var Parser): Node =
    ## Parse rule expression and return Node representation
    var prefixFn = p.getPrefixFn()
    if prefixFn == nil: return

    var field, subfield, nestedField: Node
    field = p.prefixFn()

    if p.hasError(): return

    if p.current.kind == TK_IDENTIFIER:
        while true:
            if p.hasError(): break                  # ensure break the loop in case of error
            if p.isChildOf(p.current, field):
                # Check if current token is nested at the 1st level
                if not field.isObject():
                    p.setError(TypeError, "\"$1\" cannot contain nested fields because is not an object" % [field.ident])
                    break
                subfield = p.prefixFn()
                if subfield != nil:
                    let fieldId = subfield.ident
                    if not field.nodes.hasKey(fieldId):
                        field.nodes[fieldId] = subfield
                    else: p.setError(IdentError, "Duplicate identifier \"$1\"" % [fieldId])
            else:
                # Otherwise, handle multi-dimensional nests
                if p.isChildOf(p.current, p.prevNode):
                    if not p.prevNode.isObject():
                        p.setError(TypeError, "\"$1\" cannot contain nested fields because is not an object" % [p.prevNode.ident])
                        break
                    p.parents.add(p.prevNode)
                    p.createNode(p.prevNode, prefixFn)
                elif p.current.col < p.prevNode.meta.col or p.isEOF:
                    break
                elif p.current.col == p.prevNode.meta.col:
                    if p.parents.len != 0:
                        p.createNode(p.getLastParent(), prefixFn)
                        p.parents.delete(p.parents.high .. p.parents.high)
                    else: break
    result = field

proc walk[T: Parser](p: var T) =
    ## Start walk for parsing tokens
    while p.hasError() == false and p.lexer.hasError == false and not p.isEOF:
        if p.isComment(): p.jumpAndContinue()       # skip comments
        var statement: Node = p.parseExpression()
        if statement != nil:
            p.statements.add(statement)
        else:
            jump p
    if p.hasError():
        p.statements = @[]

proc getStatements*(p: var Parser): string =
    ## Procedure used only for debug purposing. Prints the current
    ## statements to pretty ``JSON``, indented with 2 spaces.
    pretty(p.statements.toJSON, 2)

proc parseProgram*(enkavaContents: string): Parser =
    ## Parser Program initializer. Reads rules of the given Enkava file
    ## This procedure is highly recommended for validation large JsonNode objects
    ## that involves creating complex rules.
    var p: Parser = Parser(lexer: Lexer.init(readFile(enkavaContents)))
    p.current = p.lexer.getToken()
    p.next    = p.lexer.getToken()
    p.prev    = p.current
    p.currln  = p.current.line
    p.walk()
    result = p

proc parseProgram*(enkavaSeq: seq[string]): Parser =
    ## Parser Program initializer. Reads rules from given seq[string]
    ## This procedure is recommended for validating small JsonNode objects
    parseProgram(enkavaSeq.join("\n"))
