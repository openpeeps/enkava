import ./lexer, ./ast

from std/strutils import `%`, join
import std/[json, jsonutils]

type
    Parser* = object
        lexer: Lexer
        prev, current, next: TokenTuple
        error: string
        rules: seq[Rule]
        prevln, currln, nextln: int
        parentPos: seq[int]
        memory: Memory

    Memory = Table[string, Rule]

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
    result = token.expect(expect)
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

proc isEOF[T: Parser](p: var T): bool =
    result = p.current.kind == TK_EOF

proc memorize[T: Parser](p: var T, key: string, rule: var Rule) =
    ## Store given Rule object in memory
    p.memory[key] = rule

proc keyExists[T: Parser](p: T, key: string): bool = 
    ## Determine if specified Rule exists in memory
    result = p.memory.hasKey(key)

proc getRule[T: Parser](p: var T, key: string): Rule =
    ## Retrieve a rule stored in memory. Mostly used for 
    ## initializing `same` reference copies in other Rule Nodes
    result = p.memory[key]

proc keyExists[T: Parser](p: var T, key, message: string): bool =
    ## Determine if specified rule exists in memory, otherwise
    ## set error and return the response
    result = p.keyExists(key)
    if result == false: p.setError(message)

proc isDuplicated[T: Parser](p: var T, key, message: string): bool = 
    ## Prevents duplicated key identifiers
    result = p.keyExists(key)
    if result == true: p.setError(message)

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

template parseIdentifier[T: Parser](p: var T, parentNode: TokenTuple, isChildNode: bool = false): untyped =
    if p.isDuplicated(p.current.value, "Duplicate identifier \"$1\"" % [p.current.value]): break
    elif not p.expect(p.next, {TK_OPT, TK_COLON}, "Missing assignment token"): break
    var rule = Rule()
    let ident = p.current
    if p.next.kind == TK_OPT:
        rule.required = false       # followed by * becomes a required field
        jump p, 3                   # jump TK_OPT, TK_COLON from current
    else:
        rule.required = true
        jump p, 2                 # jump TK_COLON from current

    let typeValue = ast.typeValueByKind(p.current.kind)
    if typeValue == TypeInvalid:
        p.setError("Invalid type value")    # TODO better error message?
        break
    
    rule.node = ast.Node(
        identifier: ident.value,
        typeValue: typeValue,
        typeValueStr: symbolName(typeValue))
    let currRulesLen = if p.rules.len == 0: 0 else: p.rules.len - 1
    rule.meta = (col: ident.col, line: ident.line, wsno: ident.wsno, pos: currRulesLen)
    if isChildNode:
        p.rules[^1].nodes[ident.value] = rule
    else:
        p.rules.add(rule)                  # add rule to rules sequence
    p.memorize(ident.value, rule)          # store in memory

proc isChild[T: Parser](p: var T, childNode, parentNode: TokenTuple): bool =
    if childNode.isIdent():
        result = childNode.col > parentNode.col
        if result == true:
            result = (childNode.col and 1) != 1 and (parentNode.col and 1) != 1
            if result == false:
                p.setError("Invalid indentation. Use 2 or 4 spaces to indent your rules")
    else:
        result = false

proc walk[T: Parser](p: var T) =
    while p.hasError() == false and p.lexer.hasError() == false and not p.isEOF:
        if p.current.isIdent():
            let prevNode = p.prev
            let parentNode = p.current
            p.parseIdentifier(parentNode)
            jump p

            # Handle first level of child nodes
            while p.isChild(p.current, parentNode) and not p.isEOF:
                p.parseIdentifier(parentNode, true)
                jump p

            # Handle deeper levels of child nodes
            echo p.current

        if p.current.expect(TK_SAME):
            ## When an identifier is prefixed by ^ TK_SAME,
            ## it means is a previously declared identifier
            ## used as reference for copying its children nodes
            ## and structure to current identifier. Pretty dope!
            if not p.expect(p.next, TK_IDENTIFIER, "Missing identifier for \"same\" reference"): break
            elif not p.keyExists(p.next.value,
                "Could not set a \"same\" reference for \"$1\"" % [p.next.value]): break
            jump p
            
            let sameRefKey = p.current.value
            let sameRefNode = p.getRule(sameRefKey)
            
            if p.next.kind == TK_LSPAREN:   # Insert/exclude fields to/from pointed reference
                jump p
                if not p.expect(p.next, TK_EXCLUDE, "Missing exclusion token \"!\" "): break
                var origin: TokenTuple = p.current
                var tokens: seq[TokenTuple]
                jump p
                while true:
                    if p.current.kind == TK_RSPAREN: break
                    elif p.current.kind == TK_COMMA:
                        if p.next.kind notin {TK_EXCLUDE, TK_IDENTIFIER}:
                            p.setError("Missing identifier after comma in current enumeration")
                            break
                        jumpAndContinue p
                    elif p.current.line > origin.line:
                        p.setError("EOL reached before end of square bracket")
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
                        p.setError("Unrecognized character in exclusion syntax \"$1\"" % [p.current.value])
                        break
                # if tokens.len != 0:
                    # echo p.rules[order].node.identifier
                    # p.rules[order].nodes[sameRefNode.node.identifier] = sameRefNode
        # jump p

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
    echo pretty(p.rules.toJSON, 2)
    return p

proc parseProgram*(parrotSeq: seq[string], node: JsonNode): Parser =
    ## Parser Program initializer. Reads rules from given seq[string]
    ## This procedure is recommended for validating small JsonNode objects
    parseProgram(parrotSeq.join("\n"), node)