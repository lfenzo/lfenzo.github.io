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

<br>

{{< cards >}}
  {{< card link="https://github.com/lfenzo/Impostor.jl" icon="github" title="Source Code" >}}
  {{< card link="https://lfenzo.github.io/Impostor.jl/stable/" icon="book-open" title="Documentation" >}}
  {{< card link="https://discourse.julialang.org/t/ann-impostor-jl-a-highly-versatile-synthetic-data-generator/106166" icon="link" title="Announcement post" >}}
{{< /cards >}}


## Motivation

In a couple courses during my graduation I found myself in a situation where I needed a small script to quickly generate sample tables for a database or generate enough tabular data to perform a load test in some service. After my third rewrite of some of such scripts I decided it was time for something a bit more structured and the idea of a Julia library for that seemed very appealing not only for that apparent "gap" in the functionalities I needed from similar libraries in the Julia ecosystem at the time, but also as an opportunity to learn the process of developing and publishing a Julia package.

As it turns out, it is surprisingly simple to have a package published in the Julia General Registry, provided that you follow the instructions in the [Creating Packages](https://pkgdocs.julialang.org/v1/creating-packages/) page in the Pkg.jl stdlib docs. I was surprised to know that the structure was very straight forward and the publishing process was very simple and direct. For more info on registering Julia packages check [this link](https://pkgdocs.julialang.org/v1/creating-packages/#Registering-packages).

## Examples

Instead of giving a full description of step by step examples building up on complexity (which would only duplicate its [documentation](https://lfenzo.github.io/Impostor.jl/stable/)) I'll provide a more practical use case to show some of its capabilities. Suppose we are mocking some sort of registration system with driver licenses information. The code snippets bellow shows concise ways to do it with Impostor.

### Impostor Templates

```julia {linenos=table, filename="generate_my_data.jl"}
using Impostor
using DataFrames

function generate_mocked_rows(n_rows::Integer) :: DataFrame
    locale = ["en_US"]
    formats = [
        :firstname,
        :surname,
        :occupation,
        :birthdate,
        :state,
        :state_code,
        :city,
        :street,
        :postcode,
    ]

    template = ImpostorTemplate(formats)

    my_data = template(n_rows, DataFrame; locale)
    my_data[:, :license] = render_alphanumeric("^^^-#^##", n_rows)
    my_data[:, :year] = rand(2014:1:2024, n_rows)

    return my_data
end
```

Since we are outputing the resulting table to a dataframe, we must also import the DataFrames.jl package on our top-level scope. Now, by calling this `generate_mocked_rows`, we have the following table:
```julia
generate_mocked_rows(5)
# 5×11 DataFrame
#  Row │ firstname  surname    occupation     birthdate   state           state_code  city            street             postcode     licence   year  
#      │ String     String     String         String      String31        String3     String31        String             String       String    Int64 
# ─────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#    1 │ Stephen    Friedman   Accountant     1946-05-06  Utah            UT          Salt Lake City  Daugherty Avenue   363-646-702  GLU-2A12   2014
#    2 │ Dorothy    Mann       Mathematician  1969-08-29  New York        NY          New York City   Oconnor Road       863-875-466  WHN-0M46   2019
#    3 │ Andrew     Espinoza   Phisician      1947-04-16  South Carolina  SC          Charleston      Olivia Le Alley    541-284-571  UQJ-4H86   2017
#    4 │ Shawn      Patterson  Accountant     1946-05-16  Iowa            IA          Des Moines      Callahan Road      549-716-942  HCN-4H78   2016
#    5 │ Barry      Moran      Phisician      1959-11-25  Alabama         AL          Montgomery      Peterson Driveway  075-858-427  AYA-3L14   2019
```

### General Purpose API

If you prefer to have more control over the data generation process, here is the same example but without `ImpostorTemplate`s, *i.e.* using only the general purpuse [*generator-functions*](https://lfenzo.github.io/Impostor.jl/stable/#Concepts):

```julia {linenos=table, filename="generate_my_data.jl", hl_lines=[13, 14]}
using Impostor
using DataFrames

function generate_mocked_without_template(n_rows::Integer)
    my_data = DataFrame()

    my_data[:, :firstname] = firstname(n_rows)
    my_data[:, :surname] = surname(n_rows)
    my_data[:, :occupation] = occupation(n_rows)
    my_data[:, :birthdate] = birthdate(n_rows)

    my_data[:, :state_code] = state_code(n_rows)
    my_data[:, :state] = state(my_data[:, :state_code]; level = :state_code)
    my_data[:, :city] = city(my_data[:, :state_code]; level = :state_code)

    my_data[:, :street] = street(n_rows)
    my_data[:, :postcode] = postcode(n_rows)

    my_data[:, :licence] = render_alphanumeric("^^^-#^##", n_rows)
    my_data[:, :year] = rand(2014:1:2024, n_rows)

    return my_data
end
```

Note that the lines 13 and 14 (highlighted above) receive as input **a *mask* specifying the state codes in order to generate the matching states names and codes** (number of generated rows is assumed to be the same as `length(mask)`). If for some reason this matching is not necessary/important, you may as well just call the the same functions `state` and `city` passing `n_rows` as the only argument and Julia will dispatch the corresponding methods to generate single data series without filters.

```julia
generate_mocked_without_template(5)
# 5×11 DataFrame
#  Row │ firstname  surname  occupation         birthdate   state_code  state           city        street                   postcode     licence   year  
#      │ String     String   String             String      String      String          String      String                   String       String    Int64 
# ─────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#    1 │ Sonia      Lawson   Sociologist        2011-05-09  CO          Colorado        Denver      West Road                024-483-265  PDC-4H97   2015
#    2 │ Shelly     Walter   Anthropologyst     2005-04-01  WV          West Virginia   Charleston  Tran Driveway            623-875-415  FIC-8B04   2019
#    3 │ Lacey      Marks    Sociologist        2020-02-01  GA          Georgia         Atlanta     Mason Valencia Alley     943-370-619  PDW-2I72   2020
#    4 │ Lance      Day      Aircraft Engineer  2004-01-12  AL          Alabama         Montgomery  Kent Road                002-914-648  KPE-0J59   2021
#    5 │ Gregg      Walsh    Sociologist        1969-08-05  SC          South Carolina  Columbia    Katherine Huff Driveway  058-703-987  DJM-5F65   2018
```
