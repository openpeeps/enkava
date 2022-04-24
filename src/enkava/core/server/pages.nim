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

import supranim

proc getParrotStatus(req: Request, res: Response) =
    ## ``GET`` procedure called on ``/`` endpoint.
    ## This returns the status of your Parrot instance.
    type 
        Status = object
            code: int
            status: string

    let status = Status(code: 200, status: "Up & running")
    res.json(status)

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
    res.json("Hello")

proc updateRulesCollection(req: Request, res: Response) =
    ## ``UPDATE`` procedure that tells your Parrot instance
    ## that it should refresh its binary collection of rules.
    res.json("Hello")