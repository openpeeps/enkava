from ./lexer import TokenKind
# from std/strutils import toUpperAscii
from std/enumutils import symbolName

import std/tables
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

    SizeRule* = tuple[min, max: int]

    Node* = ref object
        ident*: string
        typeValue*: ParrotTypeValue
        typeValueSymbol*: string
        required*: bool
        size*: SizeRule
        defaultValue*: string
        nodes*: OrderedTable[string, Node]

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
        of TK_ETHERUM:         TypeEhterum
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
