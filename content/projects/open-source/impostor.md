+++
title = 'Impostor.jl - the highly versatile synthetic data generator'
description = "The Julia library to generate various types of synthetic data."
date = 2024-03-28T17:29:05-03:00
type = 'blog'
tags = ['open-source', 'package', 'julia', 'synthetic data']
+++

## Introduction

Impostor.jl is a Julia package which eases the generation of synthetic tabular data using a flexible yet concise API. Built from scratch upon Julia’s Multiple Dispatch paradigm with simplicity in mind, Impostor is the concretization of a software engineering project from its data back-end and API design; to its packaging, registration and distribution via the [Julia General Registry](https://github.com/JuliaRegistries/General).

Its main selling point is the capability to generate cohesive relations between table columns from templated objects but it also provides several generator and utility functions to generate standalone data series from a pre-selected set of entries. Check out the [API reference](https://lfenzo.github.io/Impostor.jl/stable/api_reference/) for a complete list.

Some of the interesting features present in Impostor are:
- **Support for cohesion across columns** in the generated tables.
- **Support for generic table templates** via the `ImpostorTemplate` object.
- **Multi-locale support**, for both per-method calls and current session.
- **Compliance with Julia's [multiple dispatch paradigm](https://docs.julialang.org/en/v1/manual/methods/)**, allowing for more control over data series generation.
- **Consise and simple helper functions**.

{{< callout >}}
A couple of noteworthy differences between Impostor.jl and [Faker.jl](https://github.com/neomatrixcode/Faker.jl) are highlighted [here](https://discourse.julialang.org/t/ann-impostor-jl-a-highly-versatile-synthetic-data-generator/106166/3).
{{< /callout >}}

{{< cards >}}
  {{< card link="https://github.com/lfenzo/Impostor.jl" icon="github" title="Source Code" >}}
  {{< card link="https://lfenzo.github.io/Impostor.jl/stable/" icon="book-open" title="Documentation" >}}
  {{< card link="https://discourse.julialang.org/t/ann-impostor-jl-a-highly-versatile-synthetic-data-generator/106166" icon="link" title="Announcement post" >}}
{{< /cards >}}


## Motivation

During a couple courses during my graduation I found myself in a situation where I needed a small script to quickly generate sample tables for a database or generate enough tabular data to perform a load test in some service. After my third rewrite of some of such scripts I decided it was time to have something a bit more structured and the idea of a Julia library for that seemed very appealing not only for that apparent "gap" in the functionalities I needed from similar libraries in the Julia ecosystem at the time, but also as an opportunity to learn the process of developing and publishing a Julia package.

As it turns out, it is surprisingly simple to have a package published in the Julia General Registry, provided that you follow the instructions in the [Creating Packages](https://pkgdocs.julialang.org/v1/creating-packages/) page in the Pkg.jl stdlib docs. I was surprised to know that the structure was very straight forward and the publishing process was very simple and direct.

## Examples

As Impostor supports outputting the generated tables into a sink object, we are also importing the [DataFrames](https://github.com/JuliaData/DataFrames.jl) package in order use the `DataFrame` type.

```julia
using Impostor
using DataFrames
```

The easiest way to get started is to generate a single entry from the *[generator functions](https://lfenzo.github.io/Impostor.jl/stable/#Generator-Functions)*. The value listed below is a *valid card number* generated from using the same algorithms used to verify the validity of a credit card number.
```julia
credit_card_number(; formatted = true)
# "4767-6731-1326-5309"
```

But if you need to generate a more generic sequence of characters you may want to use the [`render_alphanumeric`](https://lfenzo.github.io/Impostor.jl/stable/utilities/templatization/#Impostor.render_alphanumeric) function. We could, for example, generate license plates following a pre-defined template.
```julia
[render_alphanumeric("^^-###-^^^") for _ in 1:5]
# 5-element Vector{String}:
#  "MM-609-QRY"
#  "OR-389-EBT"
#  "CF-245-UEI"
#  "JF-287-MMK"
#  "MV-332-RIC"
```


```julia
template = ImpostorTemplate([:firstname, :surname, :country_code, :state, :city]);

template(3)
# Dict{Any, Any} with 5 entries:
#   :country_code => Union{Missing, String3}[String3("USA"), String3("BRA"), Stri…
#   :state        => Union{Missing, String31}[String31("Georgia"), String31("São …
#   :firstname    => ["Curtis", "Grant", "Jerry"]
#   :surname      => ["Edwards", "Benitez", "Cochran"]
#   :city         => String31["Atlanta", "São Bernardo", "Ibiúna"]

template(5, DataFrame; locale = ["pt_BR", "en_US"])  # optionally provide a `sink` type
# 5×5 DataFrame
#  Row │ firstname   surname  country_code  state         city
#      │ String      String   String3       String31      String31
# ─────┼─────────────────────────────────────────────────────────────
#    1 │ Stacie      Walter   USA           Vermont       Montpelier
#    2 │ Alexa       Walsh    BRA           São Paulo     Sorocaba
#    3 │ Kirk        Joseph   USA           Maryland      Baltimore
#    4 │ Jade        Freeman  BRA           Minas Gerais  Betim
#    5 │ Alexandria  Garcia   USA           Colorado      Denver
```



To set the locale, use the `locale` keyword argument.

```julia
surname(4; locale = ["pt_BR"])
# 4-element Vector{String}:
#  "Feranndes"
#  "Pereira"
#  "Camargo"
#  "Pereira"

firstname(["M"], 4)
# 4-element Vector{String}:
#  "Charles"
#  "Zacharias"
#  "Paul"
#  "Charles"

city(["BRA", "USA"], 4; level=:country_code)
# 4-element Vector{String}:
#  "Curitiba"
#  "Los Angeles"
#  "São Paulo"
#  "Rio de Janeiro"

address(["BRA", "USA", "BRA", "USA"]; level = :country_code)
# 4-element Vector{String}:
#  "Avenida Paulo Lombardi 1834, Ba" ⋯ 25 bytes ⋯ "84-514, Porto Alegre-RS, Brasil"
#  "Abgail Smith Alley, Los Angeles" ⋯ 42 bytes ⋯ "ornia, United States of America"
#  "Avenida Tomas Lins 4324, (Apto " ⋯ 23 bytes ⋯ "orocaba - 89457-346, SP, Brasil"
#  "South-side Street 1st Floor, Li" ⋯ 52 bytes ⋯ "as-AR, United States of America"



template_string = "I know firstname surname, this person is a(n) occupation";

render_template(template_string)
# "I know Charles Jameson, this person is a(n) Mathematician"

println("My new car plate is $(render_alphanumeric("^^^-####"))")
# My new car plate is TXP-9236
```
