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

proc jump[T: Parser](p: var T, offset = 1) =
    ## Walk and update prev, current and next group of tokens.
    ## You can jump groups one or many times at once. By default `offset` is `1`.
    var i = 0
    while offset > i: 
        p.prev = p.current
        p.current = p.next
        p.next = p.lexer.getToken()
        inc i

proc expect[T: TokenTuple](token: T, exp: TokenKind): bool =
    ## Determine if token kind is as expected
    result = token.kind == exp

proc expect[P: Parser, T: TokenTuple](p: var P, token: T, exp: TokenKind, message: string, typeError: Error): bool =
    ## Determine if given token is as expected based on given TokenKind,
    ## otherwise set a new error and return result
    result = token.expect(exp)
    if result == false: p.setError(typeError, message)

proc expect[T: TokenTuple](token: T, exp: set[TokenKind]): bool =
    ## Determine if token kind is as expected based on given set[TokenKind]
    result = token.kind in exp

proc expect[P: Parser, T: TokenTuple](p: var P, token: T, exp: set[TokenKind], message: string, typeError: Error): bool =
    ## Determine if given token is as expeted based on given set[TokenKind],
    ## otherwise set a new error and return false
    result = token.expect(exp)
    if result == false: p.setError(typeError, message)

proc isIdent[T: TokenTuple](token: T): bool =
    ## Determine if given token is an identifier (type of TK_IDENTIFIER)
    result = token.kind == TK_IDENTIFIER

proc isIdent[T: Parser](p: var T, message: string): bool =
    ## Determine if current token is an identifier (type of TK_IDENTIFIER),
    ## otherwise set a new error and return false.
    result = isIdent(p.current)
    if result == false:
        p.setError(IdentError, message)

proc isHeadline[T: Parser](p: var T): bool =
    result = p.current.col == 0

proc isEOF[T: Parser](p: var T): bool =
    result = p.current.kind == TK_EOF

proc isComment[T: Parser](p: var T): bool =
    result = p.current.kind == TK_COMMENT

proc getIdentHash(token: TokenTuple): string =
    ## Create a hash key of the identifier for storing in memory table.
    ## Result is a simple md5 hash generated based on token line, col and value
    result = getMD5("$1:$2:$3" % [$token.line, $token.col, token.value])

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

proc isDuplicated[T: Parser](p: var T, token: TokenTuple, message: string, typeError: Error): bool = 
    ## Prevents having duplicated identifier keys
    result = p.keyExists(getIdentHash token)
    if result == true: p.setError(typeError, message)

proc hasMinSize[T: Parser](p: var T) =
    ## Determine if current typed value has a minimum size specified
    discard

proc hasMaxSize[T: Parser](p: var T) =
    ## Determine if current typed value has a maximum size specified
    discard

# proc setSize[T: Parser](p: var T) =
    ## Set a minimum and/or maximum size for current typed value

template jumpAndContinue[T: Parser](p: var T): untyped =
    jump p
    continue

proc isChildOf[P: Parser, T: TokenTuple](p: var P, token: T, prevNode: Node): bool =
    ## Determine if current TokenTuple is child of previous declared Node
    ## This procedure checks for indentation sizes and prints a ``TypeError`` message
    if token.kind == TK_EOF:
        return false
    if prevNode == nil:
        result = false
    else:
        result = (token.col and 1) != 1 and (prevNode.meta.col and 1) != 1
        if result == false:
            p.setError(TypeError, "Bad indentation. Use 2 or 4 spaces to indent your rules")
            return false

        if p.indent == 0: # first time indentation will set the default indent size preference.
            p.indent = token.col

        if prevNode.meta.col == (token.col - 2) or prevNode.meta.col == (token.col - 4):
            result = true
        else:
            # ensure a strict indentation
            # echo prevNode.meta.col # 0
            # echo p.indent          # 4
            # echo p.current.col     # 8

            # echo prevNode.meta.level * p.indent == p.current.col
            result = false