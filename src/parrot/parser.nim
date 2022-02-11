import ./lexer

from std/strutils import `%`
from std/os import getCurrentDir
import std/json

type

    ParrotNode = object
        key: string
        value: string

    Parser* = object
        lexer: Lexer
        prev, current, next: TokenTuple
        error: string
        statements: seq[ParrotNode]
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

proc walk[T: Parser](p: var T) =
    while p.hasError() == false and p.current.kind != TK_EOF:
        echo p.current
        jump p

proc validate*(parrotFile: string, node: JsonNode): Parser =
    let parrotContents = readFile(getCurrentDir() & "/sample.parrot")
    var p: Parser = Parser(lexer: Lexer.init(parrotContents))
    p.current = p.lexer.getToken()
    p.next    = p.lexer.getToken()
    p.currln = p.current.line
    p.walk()
    return p