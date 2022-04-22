<p align="center">
    <img src="https://raw.githubusercontent.com/openpeep/parrot/main/.github/parrot-logo.png" width="170px"><br>
    State of the Art 👌 JSON Content Rules Language, Server, Validator & Generator<br>
    🦜 It says what you say, if you say so (WIP)
</p>

<p align="center">
    <img width="700px" alt="Parrot Language" src="https://raw.githubusercontent.com/openpeep/parrot/main/.github/sample.png">
</p>

## 😍 Key Features
- [x] Lightweight & Multi-threading
- [x] Parrot as a Language
- [x] Command Line Interface
- [x] Built-in REST API | Supporting `Http` & `WebSockets` (soon)
- [x] 👍 for Validating damn-complex forms and data 🧐
- [x] 💪 for Validating any kind of JSON-based configs
- [x] Validate, validate, over and over... 😲
- [ ] Generate rules by `JSON` sample | `Say what you say` ability
- [x] Extension as `.parrot`
- [x] [Parrot Syntax for Sublime Text 4](#parrot-syntax-for-your-code-editor)
- [x] Made for Unix systems
- [x] Open Source | `GPLv3` License

## Why
1. Because regular JSON Schema validators are slow and boring, requires writing JSON 🙄 which is boring too.

## Installing
```
nimble install parrot
```

## Examples
<details>
    <summary>Show sample Parrot Rules</summary>

```parrot
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

    # Parrot recommends to keep it DRY (Don't Repeat Yourself)
    #
    # So, instead of rewriting rules, we can use `^` same reference operator
    # which tells Parrot that `friends` array can contain only `object` rules
    # similar to `profile` object. Pretty cool, right?
    ^profile

posts: array[object]            # simple array of (any kind) objects, no min/max

# Yeah. This is a comment
```

</details>

## Parrot Syntax for your Code editor

<details>
    <summary>Sublime Text 4 Syntax (WIP)</summary>

```yaml
%YAML 1.2
---
# See http://www.sublimetext.com/docs/syntax.html
file_extensions:
  - parrot
scope: source.parrot
variables:
  ident: '[A-Za-z_][A-Za-z_0-9]*'
contexts:
  main:
    # Strings begin and end with quotes, and use backslashes as an escape
    # character
    - match: '"'
      scope: punctuation.definition.string.begin.parrot
      push: double_quoted_string

    # Comments begin with a '//' and finish at the end of the line
    - match: '#'
      scope: punctuation.definition.comment.parrot
      push: line_comment

    - match: '\|'
      scope: markup.bold keyword.operator.logical

    - match: '\*'
      scope: entity.name.tag

    # Keywords are if, else for and while.
    # Note that blackslashes don't need to be escaped within single quoted
    # strings in YAML. When using single quoted strings, only single quotes
    # need to be escaped: this is done by using two single quotes next to each
    # other.
    - match: '\b(array|bool|float|int|object|null|string)\b'
      scope: keyword.control.parrot

    # to document
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
      scope: constant.numeric.parrot

    - match: '\b{{ident}}\b'
      scope: punctuation.definition

  double_quoted_string:
    - meta_scope: string.quoted.double.parrot
    - match: '\\.'
      scope: constant.character.escape.parrot
    - match: '"'
      scope: punctuation.definition.string.end.parrot
      pop: true

  line_comment:
    - meta_scope: comment.line.parrot
    - match: $
      pop: true
```

</details>


## Roadmap

### `0.1.0`
- [x] Lexer, Parser, AST Node 
- [ ] JsonNode based Validator
- [ ] Special Validations via Parrot Filters
- [ ] Finalize Sublime Syntax
- [ ] Create a Syntax for VSCode (yak)
- [ ] Talk about it on ycombinator / stackoverflow / producthunt

### ❤ Contributions
If you like this project you can contribute to Parrot by opening new issues, fixing bugs, contribute with code, ideas and you can even [donate via PayPal address](https://www.paypal.com/donate/?hosted_button_id=RJK3ZTDWPL55C) 🥰

### 👑 Discover Nim language
<strong>What's Nim?</strong> Nim is a statically typed compiled systems programming language. It combines successful concepts from mature languages like Python, Ada and Modula. [Find out more about Nim language](https://nim-lang.org/)

<strong>Why Nim?</strong> Performance, fast compilation and C-like freedom. We want to keep code clean, readable, concise, and close to our intention. Also a very good language to learn in 2022.

### 🎩 License
Parrot is an Open Source Software released under `GPLv3` license. [Made by Humans from OpenPeep](https://github.com/openpeep).<br>
Copyright &copy; 2022 OpenPeep & Contributors &mdash; All rights reserved.
