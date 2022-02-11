<p align="center">
    <img src="https://raw.githubusercontent.com/openpeep/parrot/main/.github/parrot-logo.png" width="170px"><br>
    Fast, Lightweight 👌 JSON Content Rules Language, Validator and Generator<br>
    🦜 It says what you say, if you say so (WIP)
</p>

## 😍 Key Features
- [x] Lightweight & Multi-threading
- [x] Parrot as a `Language` or simple `seq[string]`
- [x] Intuitive & Easy to Learn
- [ ] Generate rules by `JSON` sample | Say what you say ability
- [x] Extension as `.parrot`
- [x] Open Source | `MIT` License

## Installing
```
nimble install parrot
```

## Examples

Minimal example, using Parrot with rules wrapped in a `seq[string]`:

```nim
let example = %*{
    "name": "Trippy Parrot",
    "year": "2022",
    "shopping": [
        "Bananas", "Whatever Juice", "Soda", "Cat food", true
    ]
}

var p = Parrot.init(example,
    rules = @[
        "name*:string",
        "version*:int",
        "url*:string",
        "shopping*:array[5, string]"
    ])

# Check for errors.
if p.hasErrors:
    for e in p.getErrors(asString = true):
        # Set `asString` true for full line in a single string,
        # or remove it and returns a tuple[line, field, expectType, givenType, givenValue: string]
        # for creating your own error message
        echo e

```

Of course, `seq[string]` is no more related when talking about handling big documents with complex rules.

Now, let's see the real power of **Parrot Language**.

<p align="center">
    <img width="700px" alt="Parrot Language" src="https://raw.githubusercontent.com/openpeep/parrot/main/.github/sample.png">
</p>

<details>
    <summary>Show parrot text code</summary>

```parrot
profile*: object
    name*: string
    age: int                                # optional
    website: url                            # optional, when filled it has to be a valid URL
    email_address*: email                   # required, validated as EMAIL
    ip_address: ip | 127.0.0.1              # optional, with a defaullt value
    user_currency: currency
    bank_account: iban
    misc: object
        letters: alphabetical
        numbers: numerical
        one_digit: digit
        hobby: uppercase

# Define your rules for friends. Which is a `required` array
# that can contain only objects, 100 maximum
#
# With Parrot abilities you can simply use same ^ pointer
# followed by a previously declared object and done. 
friends*: array[100, object]                # array of 100 objects, maximum
    ^profile                                # Dont Repeat Yourself

posts: array[object]
```

</details>

## Roadmap
_to add roadmap_

### ❤ Contributions
If you like this project you can contribute to Parrot by opening new issues, fixing bugs, contribute with code, ideas and you can even [donate via PayPal address](https://www.paypal.com/donate/?hosted_button_id=RJK3ZTDWPL55C) 🥰

### 👑 Discover Nim language
<strong>What's Nim?</strong> Nim is a statically typed compiled systems programming language. It combines successful concepts from mature languages like Python, Ada and Modula. [Find out more about Nim language](https://nim-lang.org/)

<strong>Why Nim?</strong> Performance, fast compilation and C-like freedom. We want to keep code clean, readable, concise, and close to our intention. Also a very good language to learn in 2022.

### 🎩 License
Parrot is an Open Source Software released under `MIT` license. [Developed by Humans from OpenPeep](https://github.com/openpeep).<br>
Copyright &copy; 2022 OpenPeep & Contributors &mdash; All rights reserved.
