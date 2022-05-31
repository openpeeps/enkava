<p align="center">
    <!-- <img src="https://raw.githubusercontent.com/openpeep/enkava/main/.github/enkava-logo.png" width="170px"><br> -->
    State of the Art 👌 Schema Validation Language &bullet; Built-in RESTful API<br>
    Enkava is a top-notch language for validating JSON contents without dealing with JSON syntax at all.
</p>

<p align="center">
    <img width="700px" alt="Enkava Schema Validation Language" src="https://raw.githubusercontent.com/openpeep/enkava/main/.github/sample.png">
</p>

## 😍 Key Features
- [x] Lightweight & Multi-threading
- [x] Enkava as a Language
- [x] Command Line Interface
- [x] Built-in REST API | Supporting `Http` & `WebSockets` (soon)
- [x] 👍 for Validating damn-complex forms and data 🧐
- [x] 💪 for Validating any kind of JSON-based configs
- [x] Validate, validate, over and over... 😲
- [ ] Generate rules by `JSON` sample
- [x] Extension as `.eka`
- [x] [Code Syntax for Sublime Text 4](#enkava-syntax-for-your-code-editor)
- [ ] Code Syntax for VSCode (Need help!)
- [x] Made for Unix systems
- [x] Open Source | `GPLv3` License

### Why ?
1. Because regular JSON Schema validators are slow and boring, requires writing JSON 🙄 which is boring too.
2. Human readable, `YAML` like syntax:
```enkava
name: string
```
3. Write once, run it at any levels. `Client` <kbd>></kbd> `Application` <kbd>></kbd> `Database`.
4. Has built-in string-based filters. For example, `email`, `ip`, `currency`, `iban`, `bitcoin`, `uppercase`, and so on.
5. Has a built-in RESTful API.
6. Easy to learn
7. Can be used to build cool things like Quizzes, Q&A and so on.

## Compile from Source
Enkava is written in Nim language. If you want to compile Enkava by yourself first you'll need to
install the latest version of Nim
```
nimble install enkava
```

Installing from Nimble will also compile enkava at the same time. So, that's all!

## Examples
<details>
    <summary>Show sample Enkava Rules</summary>

```enkava
profile: object
    name: string
    age*: int                                # optional
    website*: url                            # optional, when filled it has to be a valid URL
    email_address: email.                    # required, string-based filer with E-mail validation
    ip_address*: ip | 127.0.0.1              # optional, string-based filter with IP validation
    user_currency: currency
    bank_account: iban
    misc: object
        letters: alphabetical
        numbers: numerical
        one_digit: digit
        hobby: uppercase

# Define your rules for friends. Which is a `required` array
# that can contain only objects, 100 maximum

friends: array[100, object]                # array of 100 objects, maximum

    # Enkava recommends to keep it DRY (Don't Repeat Yourself)
    #
    # So, instead of rewriting rules, we can use `^` same reference operator
    # which tells Enkava that `friends` array can contain only `object` rules
    # similar to `profile` object. Pretty cool, right?
    ^profile

posts: array[object]            # simple array of (any kind) objects, no min/max

# Yeah. This is a comment
```

</details>

## Enkava Syntax for your Code editor

<details>
    <summary>Sublime Text 4 Syntax (WIP)</summary>

```yaml
%YAML 1.2
---
# See http://www.sublimetext.com/docs/syntax.html
file_extensions:
  - eka
scope: source.eka
variables:
  ident: '[A-Za-z_][A-Za-z_0-9]*'
contexts:
  main:
    # Strings begin and end with quotes, and use backslashes as an escape
    # character
    - match: '"'
      scope: punctuation.definition.string.begin.eka
      push: double_quoted_string
    
    - match: '#'
      scope: punctuation.definition.comment.eka
      push: line_comment

    - match: '\|'
      scope: markup.bold keyword.operator.logical

    - match: '\*'
      scope: entity.name.tag

    - match: '\b(array|bool|float|int|object|null|string)\b'
      scope: keyword.control.eka

    - match: '\b(ascii|base32|base58|base64|bic|btc|currency|date|ean|etherum|hash|hex|hexcolor|hsl)\b'
      scope: markup.italic support.constant

    - match: '\b(iban|isbn|isin|macaddress|magneturi|md5|)\b'
      scope: markup.italic support.constant

    # https://nim-lang.org/docs/strutils.html
    - match: '\b(alphabetical|numerical|digit|lowercase|uppercase|)\b'
      scope: markup.italic support.constant

    - match: '\b(url|email|phone|zipcode|ip)\b'
      scope: markup.italic support.constant

    # Numbers
    - match: '\b(-)?[0-9.]+\b'
      scope: constant.numeric.eka

    - match: '\b{{ident}}\b'
      scope: punctuation.definition

  double_quoted_string:
    - meta_scope: string.quoted.double.eka
    - match: '\\.'
      scope: constant.character.escape.eka
    - match: '"'
      scope: punctuation.definition.string.end.eka
      pop: true

  line_comment:
    - meta_scope: comment.line.eka
    - match: $
      pop: true
```

</details>

## REST API Endpoints

1. <kbd>GET</kbd> <code>/</code><br>
Returns the status of your Enkava instance followed by a `rules` object that contains current Enkava rules.

Response example:
```json
{
    "status": 200,
    "sheets": [
        {
            "id": "contact",
            "endpoint": "/check/contact"
        },
        {
            "id": "register",
            "endpoint": "/check/register"
        },
        {
            "id": "newsletter",
            "endpoint": "/check/newsletter"
        }
    ]
}
```

2. <kbd>POST</kbd> <code>/check/{slug}</code><br>

Status types: `InternalError`, `GeneralError`, `FieldError`, `Valid`.

1. `InternalError` Response:<br>
Enkava is safe for runtime even when dealing with internal errors.
TOOD Explain

```json
{
    "error_type": "InternalError",
    "public_internal_error": "Your submission could not be processed. Try again",
    "private_internal_error": "Could not find a sheet of rules with this name: `hello2`",
    "private_internal_exception": "ReadIOEffect"
}
```
2. `GeneralError` Response:<br>
TOOD Explain

```json
{
    "error_type": "GeneralError",
    "public_general_error": "Invalid submission. Please, try again",
    "private_general_reason": "Validation failed on check_length"
}
```

3. `FieldError` Response:<br>
TODO Explain

```json
{
    "error_type": "FieldError",
    "fields": [
        {
            "id": "email_address",
            "hint": "Invalid email address"
        }
    ]
}
```



## Roadmap

### `0.1.0`
- [ ] Lexer, Parser, AST Node 
- [ ] JsonNode based Validator
- [ ] Special Validations via Enkava Filters
- [ ] Finalize Sublime Syntax
- [ ] Create a Syntax for VSCode (yak)
- [ ] Talk about it on ycombinator / stackoverflow / producthunt

### ❤ Contributions
If you like this project you can contribute to Enkava by opening new issues, fixing bugs, contribute with code, ideas and you can even [donate via PayPal address](https://www.paypal.com/donate/?hosted_button_id=RJK3ZTDWPL55C) 🥰

### 👑 Discover Nim language
<strong>What's Nim?</strong> Nim is a statically typed compiled systems programming language. It combines successful concepts from mature languages like Python, Ada and Modula. [Find out more about Nim language](https://nim-lang.org/)

<strong>Why Nim?</strong> Performance, fast compilation and C-like freedom. We want to keep code clean, readable, concise, and close to our intention. Also a very good language to learn in 2022.

### 🎩 License
Enkava is an Open Source Software released under `GPLv3` license. [Made by Humans from OpenPeep](https://github.com/openpeep).<br>
Copyright &copy; 2022 OpenPeep & Contributors &mdash; All rights reserved.
