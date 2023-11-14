import jsony
import std/[tables, json, sequtils, sets, strutils]

type
    # word
    Verb* = object
        word*: string

        forms*: seq[WordForm]
        senses*: seq[WordSense]

        sounds*: WordSounds

    Noun* = object
        word*: string

        forms*: seq[WordForm]
        senses*: seq[WordSense]

        sounds*: WordSounds

    Adjective* = object
        word*: string

        forms*: seq[WordForm]
        senses*: seq[WordSense]

        sounds*: WordSounds

    # - sense
    WordSense* = object
        text*: string
        examples*: seq[SenseExample]

    # === example
    SenseExample* = object
        foreign*, english*: string

    # - form
    WordForm* = object
        form*: string
        tags*: seq[string]
    
    # - sound
    WordSounds* = object
        ipa*, homophones*, rhymes*: seq[string]
        files*: seq[FileSound]

    # === file
    FileSound* = object
        audio*, text*: string
        oggUrl*, mp3Url*: string

proc parseHook*(s: string, i: var int, v: var WordSounds) =
    var raw: seq[RawJson]
    parseHook(s, i, raw)

    if raw.len == 0:
        return

    for fileJson in raw:
        let table = fileJson.string.fromJson(Table[string, JsonNode])

        if "ipa" in table:
            v.ipa.add(table["ipa"].getStr())
        elif "audio" in table:
            let sound = fileJson.string.fromJson(FileSound)
            v.files.add(sound)
        elif "homophone" in table:
            v.homophones.add(table["homophone"].getStr())
        elif "rhymes" in table:
            v.rhymes.add(table["rhymes"].getStr())

proc parseHook*(s: string, i: var int, v: var seq[WordForm]) =
    var rawForms: seq[RawJson]
    parseHook(s, i, rawForms)

    var formSet: HashSet[WordForm]

    for rawForm in rawForms:
        let formJson = rawForm.string.fromJson(Table[string, JsonNode])

        # apparently this can happen
        if "tags" notin formJson:
            continue

        let spelling = formJson["form"].getStr()
        let tags = formJson["tags"].getElems().mapIt(it.getStr())

        # metadata - not actual forms
        if spelling == "haben" or
           spelling == "de-conj" or
           "table-tags" in tags or
           "inflection-template" in tags:
            continue

        formSet.incl(WordForm(form: spelling, tags: tags))
    v = formSet.toSeq()

proc parseHook*(s: string, i: var int, v: var seq[WordSense]) =
    var rawDefs: seq[RawJson]
    parseHook(s, i, rawDefs)

    for rawDef in rawDefs:
        let senseJson = rawDef.string.fromJson(JsonNode)

        # alternative form or lacking a definition
        if "find_of" in senseJson or
           "alt_of" in senseJson:
            continue

        var sense: WordSense

        sense.text = if "raw_glosses" in senseJson:
            senseJson["raw_glosses"].getElems()[0].getStr()
        elif "glosses" in senseJson:
            senseJson["glosses"].getElems()[0].getStr()
        else:
            continue

        for exampleJson in senseJson{"examples"}.getElems():
            var ex: SenseExample

            if "english" in exampleJson:
                ex.english = exampleJson["english"].getStr()
                ex.foreign = exampleJson["text"].getStr()
            elif "text" in exampleJson:
                let text = exampleJson["text"].getStr()
                let separator = if "―" in text:
                    "―"
                elif "\n" in text:
                    "\n"
                else:
                    continue

                let parts = text.split(separator)
                ex.foreign = parts[0]
                ex.english = parts[1]
            else:
                continue

            if ex.english == "(please add an English translation of this quotation)":
                continue

            # TODO: remove leading and ending quotation marks, as well as ellipses

            sense.examples.add(ex)
        v.add(sense)
