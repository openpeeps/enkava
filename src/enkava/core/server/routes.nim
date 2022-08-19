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
import supranim/router
include ./pages

# GET endpoint to retrieve the app status
Router.get("/")

# POST endpoint to validate JSON contents
# 
# Your request must contain the following parameters
#   slug     Which is the name of a BSON sheet compiled with Enkava
#   body     Only JSON contents that must be validated 
Router.get("/check/{slug}", validateRuleById)