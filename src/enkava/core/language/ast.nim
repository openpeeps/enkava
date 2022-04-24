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

import std/tables
from std/enumutils import symbolName

export tables, symbolName

type
    ParrotTypeValue* = enum
        TypeInvalid
        TypeAscii
        TypeAlphabetical
        TypeBase32
        TypeBase58
        TypeBase64
        TypeBIC
        TypeBTC
        TypeCurrency
        TypeDate
        TypeDigit
        TypeEAN
        TypeEhterum
        TypeEmail
        TypeHash
        TypeHex
        TypeHexcolor
        TypeHSL
        TypeIP
        TypeIBAN
        TypeISBN
        TypeISIN
        TypeLowercase
        TypeMacAddress
        TypeMagnetURI
        TypeMD5
        TypeNumerical
        TypeURL
        TypeUppercase
        TypeArray
        TypeBool
        TypeFloat
        TypeInt
        TypeObject
        TypeNull
        TypeString

    SizeRule* = ref tuple[min, max: int]

    Node* = ref object
        ident*: string
            ## Identifier string representation
        typeValue*: ParrotTypeValue
            ## The type of the node
        symbolName*: string
            ## The symbol name representing the type of the node
        required*: bool
            ## Whether the node is a required field
        size*: SizeRule
            ## Whether node has a min/max size specified, otherwise nil
        defaultValue*: string
            ## Whether node has a default value
        nodes*: OrderedTable[string, Node]
            ## An ordered table holding multi dimensional nodes
            ## based on the rules indentations
        meta*: tuple[kind: TokenKind, line, col, wsno, level: int]

proc isObject*(node: Node): bool =
    result = node.typeValue == TypeObject

proc typeValueByKind*(kind: TokenKind): ParrotTypeValue =
    return case kind:
        of TK_ASCII:           TypeAscii
        of TK_ALPHABETICAL:    TypeAlphabetical
        of TK_BASE32:          TypeBase32
        of TK_BASE58:          TypeBase58
        of TK_BASE64:          TypeBase64
        of TK_BIC:             TypeBIC
        of TK_BTC:             TypeBTC
        of TK_CURRENCY:        TypeCurrency
        of TK_DATE:            TypeDate
        of TK_DIGIT:           TypeDigit
        of TK_EAN:             TypeEAN
        of TK_ETH:             TypeEhterum
        of TK_EMAIL:           TypeEmail
        of TK_HASH:            TypeHash
        of TK_HEX:             TypeHex
        of TK_HEXCOLOR:        TypeHexcolor
        of TK_HSL:             TypeHSL
        of TK_IP:              TypeIP
        of TK_IBAN:            TypeIBAN
        of TK_ISBN:            TypeISBN
        of TK_ISIN:            TypeISIN
        of TK_LOWERCASE:       TypeLowercase
        of TK_MACADDRESS:      TypeMacAddress
        of TK_MAGNETURI:       TypeMagnetURI
        of TK_MD5:             TypeMD5
        of TK_NUMERICAL:       TypeNumerical
        of TK_URL:             TypeURL
        of TK_UPPERCASE:       TypeUppercase
        of TK_TYPE_ARRAY:      TypeArray
        of TK_TYPE_BOOL:       TypeBool
        of TK_TYPE_FLOAT:      TypeFloat
        of TK_TYPE_INT:        TypeInt
        of TK_TYPE_OBJECT:     TypeObject
        of TK_TYPE_NULL:       TypeNull
        of TK_TYPE_STRING:     TypeString
        else: TypeInvalid
