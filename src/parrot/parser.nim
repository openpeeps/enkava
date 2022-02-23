import ./lexer, ./ast
from std/math import splitDecimal
from std/strutils import `%`, join
import std/[json, jsonutils]

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
        parentPos: seq[int]
        indent: int                             # holds and ensure indentations on same level (2 or 4)
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

proc jump[T: Parser](p: var T, offset = 1) =
    ## Walk and update prev, current and next group of tokens.
    ## You can jump groups one or many times at once. By default `offset` is `1`.
    var i = 0
    while offset > i: 
        p.prev = p.current
        p.current = p.next
        p.next = p.lexer.getToken()
        inc i

proc expect[T: TokenTuple](token: T, expect: TokenKind): bool =
    ## Determine if token kind is as expected
    result = token.kind == expect

proc expect[P: Parser, T: TokenTuple](p: var P, token: T, expect: TokenKind, message: string, typeError: Error): bool =
    ## Determine if given token is as expected based on given TokenKind,
    ## otherwise set a new error and return result
    result = token.expect(expect)
    if result == false: p.setError(typeError, message)

proc expect[T: TokenTuple](token: T, expect: set[TokenKind]): bool =
    ## Determine if token kind is as expected based on given set[TokenKind]
    result = token.kind in expect

proc expect[P: Parser, T: TokenTuple](p: var P, token: T, expect: set[TokenKind], message: string, typeError: Error): bool =
    ## Determine if given token is as expeted based on given set[TokenKind],
    ## otherwise set a new error and return false
    result = token.expect(expect)
    if result == false: p.setError(typeError, message)

proc isIdent[T: TokenTuple](token: T): bool =
    ## Determine if given token is an identifier (type of TK_IDENTIFIER)
    result = token.kind == TK_IDENTIFIER

proc isIdent[T: Parser](p: var T, message: string): bool =
    ## Determine if current token is an identifier (type of TK_IDENTIFIER),
    ## otherwise set a new error and return false.
    result = isIdent(p.current)
    if result == false: p.setError(IdentError, message)

proc isHeadline[T: Parser](p: var T): bool =
    result = p.current.col == 0

proc isEOF[T: Parser](p: var T): bool =
    result = p.current.kind == TK_EOF

proc memorize[T: Parser](p: var T, key: string, node: var Node) =
    ## Store given Rule object in memory
    p.memory[key] = node

proc keyExists[T: Parser](p: T, key: string): bool = 
    ## Determine if specified Rule exists in memory
    result = p.memory.hasKey(key)

proc getRule[T: Parser](p: var T, key: string): Node =
    ## Retrieve a node stored in memory. Mostly used for 
    ## initializing `same` reference copies in other Rule Nodes
    result = p.memory[key]

proc keyExists[T: Parser](p: var T, key, message: string, typeError: Error): bool =
    ## Determine if specified rule exists in memory, otherwise
    ## set error and return the response
    result = p.keyExists(key)
    if result == false: p.setError(typeError, message)

proc isDuplicated[T: Parser](p: var T, key, message: string, typeError: Error): bool = 
    ## Prevents duplicated key identifiers
    result = p.keyExists(key)
    if result == true: p.setError(typeError, message)

proc hasMinSize[T: Parser](p: var T) =
    ## Determine if current typed value has a minimum size specified
    discard

proc hasMaxSize[T: Parser](p: var T) =
    ## Determine if current typed value has a maximum size specified
    discard

proc setSize[T: Parser](p: var T) =
    ## Set a minimum and/or maximum size for current typed value

template jumpAndContinue[T: Parser](p: var T): untyped =
    jump p
    continue

proc isChildOf[P: Parser, T: TokenTuple](p: var P, token: T, prevNode: Node): bool =
    if token.kind == TK_EOF:
        return false

    # echo 18 / 2
    # echo floorMod(4, 2)
    # echo floorMod(4, 4)
    # echo floorMod(6, 4)

    if prevNode == nil:
        result = false
    else:
        result = (token.col and 1) != 1 and (prevNode.meta.col and 1) != 1
        if result == false:
            p.setError(TypeError, "Bad indentation. Use 2 or 4 spaces to indent your rules")
        elif token.col > prevNode.meta.col:
            if p.indent == 0:
                p.indent = token.col        # memorize current indentation preference
            result = true
        else: result = false

proc parseIdent(p: var Parser): Node =
    if p.isDuplicated(p.current.value,
        "Duplicate identifier \"$1\"" % [p.current.value], IdentError): return
    elif not p.expect(p.next, {TK_OPT, TK_COLON},
        "Missing assignment token", TypeError): return

    if p.current.col != 0:
        let indentTuple = splitDecimal(p.current.col / p.indent)
        if indentTuple.floatpart != 0:
            p.setError(TypeError, "Bad indentation. Keep your indent spaces consistent")
            return

    var node = Node()
    let ident = p.current
    if p.next.kind == TK_OPT:
        node.required = false       # followed by * becomes an optional field
        jump p, 3                   # jump TK_OPT, TK_COLON from current
    else: node.required = true
    jump p, 2

    let typeValue = ast.typeValueByKind(p.current.kind)
    if typeValue == TypeInvalid:
        p.setError(TypeError, "Invalid typed value \"$1\"" % [p.current.value])    # TODO better error message?
        return
    
    node.ident = ident.value
    node.typeValue = typeValue
    node.typeValueSymbol = symbolName(typeValue)

    p.memorize(ident.value, node)          # store in memory
    p.prevNode = node                      # make current Rule as previous
    node.meta = (kind: ident.kind, line: ident.line, col: ident.col, wsno: ident.wsno)
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
    
    if p.next.kind == TK_LSPAREN:   # Insert/exclude fields to/from pointed reference
        jump p
        if not p.expect(p.next, TK_EXCLUDE, "Missing exclusion token \"!\"", TypeError):
            return
        var origin: TokenTuple = p.current
        var tokens: seq[TokenTuple]
        jump p
        while true:
            if p.current.kind == TK_RSPAREN: break
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

proc parseExpression(p: var Parser): Node =
    ## Parse rule expression and return Node representation
    var prefixFn = p.getPrefixFn()
    if prefixFn == nil:
        return

    var leftExpression: Node = p.prefixFn()

    if p.isChildOf(p.current, leftExpression):
        if p.hasError(): return
        var suffixFn = p.getSuffixFn()
        if suffixFn == nil:
            return leftExpression

        var rightExpression: Node = p.suffixFn()
        leftExpression.nodes[rightExpression.ident] = rightExpression
        return leftExpression

    return leftExpression

proc walk[T: Parser](p: var T) =
    while p.hasError() == false and p.lexer.hasError == false and not p.isEOF:
        var statement: Node = p.parseExpression()
        if statement != nil:
            p.statements.add(statement)
        else:
            jump p

    if p.hasError():
        p.statements = @[]

proc parseProgram*(parrotContents: string, node: JsonNode): Parser =
    ## Parser Program initializer. Reads rules of the given Parrot file
    ## This procedure is highly recommended for validation large JsonNode objects
    ## that involves creating complex rules.
    var p: Parser = Parser(lexer: Lexer.init(readFile(parrotContents)))
    p.current = p.lexer.getToken()
    p.next    = p.lexer.getToken()
    p.prev    = p.current
    p.currln  = p.current.line
    
    p.walk()
    echo pretty(p.statements.toJSON, 2)
    return p

proc parseProgram*(parrotSeq: seq[string], node: JsonNode): Parser =
    ## Parser Program initializer. Reads rules from given seq[string]
    ## This procedure is recommended for validating small JsonNode objects
    parseProgram(parrotSeq.join("\n"), node)