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

import supranim/response
import ./memory
import ../language/interpreter

from std/strutils import `%`

type
    Status = object of RootObj
        status: HttpCode

    Field = object
        id: string
        message: string

    ValidStatus = object of Status

    InvalidStatus = object of Status
        fields: seq[Field]

proc getParrotStatus(req: Request, res: Response) =
    ## ``GET`` procedure called on ``/`` endpoint.
    ## This returns a list with all binary eka rules
    ## ``GET`` procedure that returns your Enkava instance
    ## followed by a list of current Eka rules stored in ``MemoryTable``
    type IndexEndpoints = object
            status: HttpCode
            sheets: seq[Sheet]

    var index = IndexEndpoints(
        status: Http200,
        sheets: Memory.getAllSheets()
    )

    res.json(index)

proc validateRuleById(req: Request, res: Response) =
    ## ``POST`` procedure called on ``/validate/{id}`` endpoint.
    ## Use this procedure to validate a JSON based on given ID.
    ##
    ## Note that the requested ID represents an existing Sheet of rules
    ## in your current Parrot instance.
    ##
    ## 200 Code:
    ##      If validation passes, Parrot will return a 200 status code response
    ##
    ## 500 Code:
    ##      If validation fails, a 500 status code will be sent with
    ##      a JSON content containing a group of invalid fields.
    ##
    
    # Looks like Supranim responds faster when using
    # ``return`` instead of ``if/elif`` statements
    var
        interp: Interpreter
        params = req.getParams()
    let sheetId = params[0].str
    if Memory.has(sheetId):
        interp = Interpreter.init("", Memory.getBSON(sheetId))
        
        if interp.hasErrors():                  # check for ``InternalError``
            res.json(interp.getErrors())
            return
        interp.validate()   # Now we can start the validation

        if interp.hasErrors():                  # check for ``GeneralError`` and ``FieldError``
            res.json(interp.getErrors())
            return
        res.json("Ok")
        return

    # Otherwise, initialize Interpreter and
    # returns an Internal Error response
    interp = Interpreter()
    interp.newInternalError(
        "Your submission could not be processed. Try again",
        "Could not find a sheet of rules with this name: `$1`" % [sheetId],
        $(ReadIOEffect)
    )
    res.json_error(interp.getErrors(), Http404)
