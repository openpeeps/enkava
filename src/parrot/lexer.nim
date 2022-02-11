import os, lexbase, streams
from strutils import Whitespace, `%`, replace, indent, startsWith

type
    TokenKind* = enum
        TK_REQ              # *
        TK_SAME             # ^
        TK_OR               # |
        TK_LSPAREN          # [
        TK_RSPAREN          # ]
        TK_COLON            # :
        TK_COMMA            # ,
        TK_COMMENT          # #
        TK_INTEGER
        TK_STRING
        TK_IDENTIFIER

        TK_ASCII
        TK_ALPHABETICAL
        TK_BASE32
        TK_BASE58
        TK_BASE64
        TK_BIC
        TK_BTC
        TK_CURRENCY
        TK_DATE
        TK_DIGIT
        TK_EAN
        TK_ETHERUM
        TK_EMAIL
        TK_HASH
        TK_HEX
        TK_HEXCOLOR
        TK_HSL
        TK_IP
        TK_IBAN
        TK_ISBN
        TK_ISIN
        TK_LOWERCASE
        TK_MACADDRESS
        TK_MAGNETURI
        TK_MD5
        TK_NUMERICAL
        TK_URL
        TK_UPPERCASE

        TK_TYPE_ARRAY
        TK_TYPE_BOOL
        TK_TYPE_FLOAT
        TK_TYPE_INT
        TK_TYPE_OBJECT
        TK_TYPE_NULL
        TK_TYPE_STRING
        TK_INVALID
        TK_EOF

    Lexer* = object of BaseLexer
        kind*: TokenKind
        token*, error*: string
        startPos*: int
        whitespaces: int

    TokenTuple* = tuple[kind: TokenKind, value: string, wsno, col, line: int]

const NUMBERS = {'0'..'9'}
const AZaz = {'a'..'z', 'A'..'Z', '_'}

template setError(l: var Lexer; err: string): untyped =
    l.kind = TK_INVALID
    if l.error.len == 0:
        l.error = err
 
proc hasError[T: Lexer](self: T): bool = self.error.len > 0

proc existsInBuffer[T: Lexer](lex: var T, pos: int, chars:set[char]): bool = 
    lex.buf[pos] in chars

proc hasLetters[T: Lexer](lex: var T, pos: int): bool =
    lex.existsInBuffer(pos, AZaz)

proc hasNumbers[T: Lexer](lex: var T, pos: int): bool =
    lex.existsInBuffer(pos, NUMBERS)

proc init*[T: typedesc[Lexer]](lex: T; fileContents: string): Lexer =
    ## Initialize a new BaseLexer instance with given Stream
    var lex = Lexer()
    lexbase.open(lex, newStringStream(fileContents))
    lex.startPos = 0
    lex.kind = TK_INVALID
    lex.token = ""
    lex.error = ""
    return lex

proc setToken*[T: Lexer](lex: var T, tokenKind: TokenKind, offset = 1) =
    ## Set meta data for current token
    lex.kind = tokenKind
    lex.startPos = lex.getColNumber(lex.bufpos)
    inc(lex.bufpos, offset)

proc nextToEOL[T: Lexer](lex: var T): tuple[pos: int, token: string] =
    # Get entire buffer starting from given position to the end of line
    while true:
        case lex.buf[lex.bufpos]:
        of NewLines: return
        of EndOfFile: return
        else: 
            add lex.token, lex.buf[lex.bufpos]
            inc lex.bufpos
    return (pos: lex.bufpos, token: lex.token)

proc skipToEOL[T: Lexer](lex: var T): int =
    # Get entire buffer starting from given position to the end of line
    while true:
        if lex.buf[lex.bufpos] in NewLines:
            return
        inc lex.bufpos
    return lex.bufpos

proc handleNewLine[T: Lexer](lex: var T) =
    ## Handle new lines
    case lex.buf[lex.bufpos]
    of '\c': lex.bufpos = lex.handleCR(lex.bufpos)
    of '\n': lex.bufpos = lex.handleLF(lex.bufpos)
    else: discard
 
proc skip[T: Lexer](lex: var T) =
    ## Procedure for skipping/offset between columns/positions 
    var wsno: int
    while true:
        case lex.buf[lex.bufpos]
        of Whitespace:
            if lex.buf[lex.bufpos] notin NewLines:
                inc lex.bufpos
                inc wsno
            else: lex.handleNewLine()
        else:
            lex.whitespaces = wsno
            break
 
proc handleSpecial[T: Lexer](lex: var T): char =
    ## Procedure for for handling special escaping tokens
    assert lex.buf[lex.bufpos] == '\\'
    inc lex.bufpos
    case lex.buf[lex.bufpos]
    of 'n':
        lex.token.add "\\n"
        result = '\n'
        inc lex.bufpos
    of '\\':
        lex.token.add "\\\\"
        result = '\\'
        inc lex.bufpos
    else:
        lex.setError("Unknown escape sequence: '\\" & lex.buf[lex.bufpos] & "'")
        result = '\0'
 
proc handleChar[T: Lexer](lex: var T) =
    assert lex.buf[lex.bufpos] == '\''
    lex.startPos = lex.getColNumber(lex.bufpos)
    lex.kind = TK_INVALID
    inc lex.bufpos
    if lex.buf[lex.bufpos] == '\\':
        lex.token = $ord(lex.handleSpecial())
        if lex.hasError(): return
    elif lex.buf[lex.bufpos] == '\'':
        lex.setError("Empty character constant")
        return
    else:
        lex.token = $ord(lex.buf[lex.bufpos])
        inc lex.bufpos
    if lex.buf[lex.bufpos] == '\'':
        lex.kind = TK_INTEGER
        inc lex.bufpos
    else:
        lex.setError("Multi-character constant")
 
proc handleString[T: Lexer](lex: var T) =
    ## Handle string values wrapped in single or double quotes
    lex.startPos = lex.getColNumber(lex.bufpos)
    lex.token = ""
    inc lex.bufpos
    while true:
        case lex.buf[lex.bufpos]
        of '\\':
            discard lex.handleSpecial()
            if lex.hasError(): return
        of '"':
            lex.kind = TK_STRING
            inc lex.bufpos
            break
        of NewLines:
            lex.setError("EOL reached before end of string")
            return
        of EndOfFile:
            lex.setError("EOF reached before end of string")
            return
        else:
            add lex.token, lex.buf[lex.bufpos]
            inc lex.bufpos

proc handleSequence[T: Lexer](lex: var T) =
    lex.startPos = lex.getColNumber(lex.bufpos)
    lex.token = "["
    inc lex.bufpos
    var errorMessage = "$1 reached before closing the array"
    while true:
        case lex.buf[lex.bufpos]
        of '\\':
            discard lex.handleSpecial()
            if lex.hasError(): return
        of NewLines:
            lex.setError(errorMessage % ["EOL"])
            return
        of EndOfFile:
            lex.setError(errorMessage % ["EOF"])
            return
        else:
            add lex.token, lex.buf[lex.bufpos]
            inc lex.bufpos

proc handleNumber[T: Lexer](lex: var T) =
    lex.startPos = lex.getColNumber(lex.bufpos)
    lex.token = "0"
    while lex.buf[lex.bufpos] == '0':
        inc lex.bufpos
    while true:
        case lex.buf[lex.bufpos]
        of '0'..'9':
            if lex.token == "0":
                setLen(lex.token, 0)
            add lex.token, lex.buf[lex.bufpos]
            inc lex.bufpos
        of 'a'..'z', 'A'..'Z', '_':
            lex.setError("Invalid number")
            return
        else:
            lex.setToken(TK_INTEGER)
            break

proc handleIdent[T: Lexer](lex: var T) =
    lex.startPos = lex.getColNumber(lex.bufpos)
    setLen(lex.token, 0)
    while true:
        if lex.hasLetters(lex.bufpos):
            add lex.token, lex.buf[lex.bufpos]
            inc lex.bufpos
        elif lex.hasNumbers(lex.bufpos):
            add lex.token, lex.buf[lex.bufpos]
            inc lex.bufpos
        else: break

    skip lex
    lex.kind = case lex.token
        of "array": TK_TYPE_ARRAY
        of "bool": TK_TYPE_BOOL
        of "int": TK_TYPE_INT
        of "null": TK_TYPE_NULL
        of "float": TK_TYPE_FLOAT
        of "object": TK_TYPE_OBJECT
        of "string": TK_TYPE_STRING

        # Token Filters
        of "alphabetical": TK_ALPHABETICAL
        of "ascii": TK_ASCII
        of "base32": TK_BASE32
        of "base58": TK_BASE58
        of "base64": TK_BASE64
        of "bic": TK_BIC
        of "btc": TK_BTC
        of "currency": TK_CURRENCY
        of "date": TK_DATE
        of "digit": TK_DIGIT
        of "email": TK_EMAIL
        of "etherum": TK_ETHERUM
        of "hash": TK_HASH
        of "hex": TK_HEX
        of "hexcolor": TK_HEXCOLOR
        of "hsl": TK_HSL
        of "iban": TK_IBAN
        of "isbn": TK_ISBN
        of "isin": TK_ISIN
        of "ip": TK_IP
        of "macaddress": TK_MACADDRESS
        of "magneturi": TK_MAGNETURI
        of "numerical": TK_NUMERICAL
        of "md5": TK_MD5
        of "url": TK_URL
        of "uppercase": TK_UPPERCASE

        else: TK_IDENTIFIER

proc getToken*[T: Lexer](lex: var T): TokenTuple =
    ## Parsing through available tokens
    lex.kind = TK_INVALID
    setLen(lex.token, 0)
    skip lex
    case lex.buf[lex.bufpos]
    of EndOfFile:
        lex.startPos = lex.getColNumber(lex.bufpos)
        lex.kind = TK_EOF
    of '#':
        lex.setToken(TK_COMMENT, lex.nextToEOL().pos)
    of '*': lex.setToken(TK_REQ)
    of ',': lex.setToken(TK_COMMA)
    of '^': lex.setToken(TK_SAME)
    of '[': lex.setToken(TK_LSPAREN)
    of ']': lex.setToken(TK_RSPAREN)
    of '|': lex.setToken(TK_OR)
    of ':': lex.setToken(TK_COLON)
    # of '\'': lex.handleChar()
    of '0'..'9': lex.handleNumber()
    of 'a'..'z', 'A'..'Z', '_', '-': lex.handleIdent()
    of '"', '\'': lex.handleString()
    else:
        lex.setError("Unrecognized character $1" % [lex.token])
    if lex.kind == TK_COMMENT:
        return lex.getToken()
    result = (kind: lex.kind, value: lex.token, wsno: lex.whitespaces, col: lex.startPos, line: lex.lineNumber)
