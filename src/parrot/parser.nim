import ./lexer, ./ast

from std/strutils import `%`
from std/os import getCurrentDir
import std/json

type
    Parser* = object
        lexer: Lexer
        prev, current, next: TokenTuple
        error: string
        rules: seq[Rule]
        prevln, currln, nextln: int

proc setError[T: Parser](p: var T, msg: string) = p.error = "Error ($2:$3): $1" % [msg, $p.current.line, $p.current.col]
proc hasError*[T: Parser](p: var T): bool = p.error.len != 0
proc getError*[T: Parser](p: var T): string = p.error

proc jump[T: Parser](p: var T, offset = 1) =
    var i = 0
    while offset > i: 
        p.prev = p.current
        p.current = p.next
        p.next = p.lexer.getToken()
        inc i

proc expect[T: TokenTuple](token: T, expect: TokenKind): bool =
    ## Determine if token kind is as expected
    result = token.kind == expect

proc expect[P: Parser, T: TokenTuple](p: var P, token: T, expect: TokenKind, message: string): bool =
    ## Determine if given token is as expected based on given TokenKind,
    ## otherwise set a new error and return result
    result = expect(token.kind)
    if result == false: p.setError(message)

proc expect[T: TokenTuple](token: T, expect: set[TokenKind]): bool =
    ## Determine if token kind is as expected based on given set[TokenKind]
    result = token.kind in expect

proc expect[P: Parser, T: TokenTuple](p: var P, token: T, expect: set[TokenKind], message: string): bool =
    ## Determine if given token is as expeted based on given set[TokenKind],
    ## otherwise set a new error and return false
    result = token.expect(expect)
    if result == false: p.setError(message)

proc isIdent[T: TokenTuple](token: T): bool =
    ## Determine if given token is an identifier (type of TK_IDENTIFIER)
    result = token.kind == TK_IDENTIFIER

proc isIdent[T: Parser](p: var T, message: string): bool =
    ## Determine if current token is an identifier (type of TK_IDENTIFIER),
    ## otherwise set a new error and return false.
    result = isIdent(p.current)
    if result == false: p.setError(message)

proc isHeadline[T: Parser](p: var T): bool =
    result = p.current.col == 0

proc walk[T: Parser](p: var T) =
    while p.hasError() == false and p.current.kind != TK_EOF:
        if p.isHeadline:
            if not p.isIdent("Only identifiers are allowed at headline") or
            not p.expect(p.next, {TK_REQ, TK_COLON}, "Missing assignment token"): break
            
            var rule = ast.Rule()           # Initialize a new Rule Node 
            let ident = p.current
            if p.next.kind == TK_REQ:
                rule.required = true
                jump p, 3                   # jump TK_REQ, TK_COLON from current
            else: jump p, 2                 # jump TK_COLON from current

            let typeValue = ast.typeValueByKind(p.current.kind)
            if typeValue == TypeInvalid:
                p.setError("Invalid type value")
                break

            # if p.expect(p.next, TK_LSPAREN):
            #     jump p, 2

            rule.node = ast.Node(identifier: ident.value, typeValue: typeValue)
            p.rules.add(rule)
        else:
            discard
        jump p

proc validate*(parrotFile: string, node: JsonNode): Parser =
    let parrotContents = readFile(getCurrentDir() & "/sample.parrot")
    var p: Parser = Parser(lexer: Lexer.init(parrotContents))
    
    p.current = p.lexer.getToken()
    p.next    = p.lexer.getToken()
    p.prev    = p.current
    p.currln = p.current.line
    
    p.walk()
    echo p.rules
    return p