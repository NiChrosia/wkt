import argparse
import std/[json, sets, strutils]
import ./[types, utils]

# generalized functions
proc extractForms(json: JsonNode): HashSet[WordForm] =
    for formJson in json:
        # apparently this can happen
        if "tags" notin formJson:
            continue

        let spelling = formJson["form"].s()
        let tags = formJson["tags"].l().map(s)

        # metadata - not actual forms
        if spelling == "haben" or
           spelling == "de-conj" or
           "table-tags" in tags or
           "inflection-template" in tags:
            continue

        result.incl(WordForm(spelling: spelling, tags: tags))

proc extractDefs(json: JsonNode): seq[Definition] =
    for defJson in json:
        # alternative form or lacking a definition
        if "find_of" in defJson or
           "alt_of" in defJson:
            continue

        var def: Definition

        def.text = if "raw_glosses" in defJson:
            defJson["raw_glosses"].l()[0].s()
        elif "glosses" in defJson:
            defJson["glosses"].l()[0].s()
        else:
            continue

        for exampleJson in defJson{"examples"}.l():
            var trans: Translation

            if "english" in exampleJson:
                trans.english = exampleJson["english"].s()
                trans.foreign = exampleJson["text"].s()
            elif "text" in exampleJson:
                let text = exampleJson["text"].s()
                let separator = if "―" in text:
                    "―"
                elif "\n" in text:
                    "\n"
                else:
                    continue

                let parts = text.split(separator)
                trans.foreign = parts[0]
                trans.english = parts[1]
            else:
                continue

            if trans.english == "(please add an English translation of this quotation)":
                continue

            # TODO: remove leading and ending quotation marks, as well as ellipses

            def.translations.add(trans)
        result.add(def)

# specialized functions
proc preprocessVerbs*(json: seq[JsonNode]): seq[Verb] =
    for verbJson in json:
        # not an infinitive
        if "forms" notin verbJson:
            continue

        var verb: Verb
        verb.infinitive = verbJson["word"].s()
        verb.forms = extractForms(verbJson["forms"])
        verb.definitions = extractDefs(verbJson["senses"])

        if verb.definitions.len > 0:
            result.add(verb)

proc preprocessNouns*(json: seq[JsonNode]): seq[Noun] =
    for nounJson in json:
        # forms are required
        if "forms" notin nounJson:
            continue

        var noun: Noun
        noun.lemma = nounJson["word"].s()
        noun.forms = extractForms(nounJson["forms"])
        noun.definitions = extractDefs(nounJson["senses"])

        if noun.definitions.len > 0:
            result.add(noun)
