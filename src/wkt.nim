import argparse, jsony
import std/[strutils, strformat]
import types

type
    PartOfSpeech = enum
        posVerb = "verb",
        posNoun = "noun",

proc pps(input, output: string, pos: string) =
    # validate
    if not fileExists(input):
        quit(fmt"Invalid file {input}!", 1)

    let posEnum = try:
        parseEnum[PartOfSpeech](pos)
    except ValueError:
        quit(fmt"Invalid part of speech {pos}!", 1)

    # process
    let inputLines = input
        .readFile()
        .split("\n")
        .filterIt(it != "")

    var outputJson = case posEnum
    of posVerb:
        var verbs: seq[Verb]

        for line in inputLines:
            let verb = line.fromJson(Verb)

            if verb.senses.len > 0:
                verbs.add(verb)

        toJson(verbs)
    of posNoun:
        var nouns: seq[Noun]

        for line in inputLines:
            let noun = line.fromJson(Noun)

            if noun.senses.len > 0:
                nouns.add(noun)

        toJson(nouns)

    writeFile(output, outputJson)

var parser = newParser:
    command("pps"):
        help("Preprocess Wiktextract JSON data into a more convenient representation.")

        arg("input", help="Path to Wiktextract JSON data")
        arg("output", help="Write path for intermediary data")
        arg("pos", help="The POS to extract; can be one of \"verb\", \"noun\"")

        run:
            pps(opts.input, opts.output, opts.pos)
try:
    let params = commandLineParams()
    parser.run(params)

    if params.len == 0:
        echo parser.help
except ShortCircuit as err:
    if err.flag == "argparse_help":
        echo err.help
        quit(1)
except UsageError:
    stderr.writeLine getCurrentExceptionMsg()
    quit(1)
