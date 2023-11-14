import argparse
import std/[strutils, strformat, json, jsonutils]
import preprocess

# this *is* actually used to make toJson(HashSet)
# give a list-like output instead of the raw internals
# of HashSet, but nim doesn't seem to realize that
import std/sets

type
    PartOfSpeech = enum
        posVerb = "verb",
        posNoun = "noun",

proc pps(input, output: string, pos: string, pretty: bool) =
    # validate
    if not fileExists(input):
        quit(fmt"Invalid file {input}!", 1)

    # process
    let inputJson = input
        .readFile()
        .split("\n")
        .filterIt(it != "")
        .mapIt(parseJson(it))

    let posEnum = try:
        parseEnum[PartOfSpeech](pos)
    except ValueError:
        quit(fmt"Invalid part of speech {pos}!", 1)

    var outputJson = case posEnum
    of posVerb:
        let verbs = preprocessVerbs(inputJson)
        toJson(verbs)
    of posNoun:
        let nouns = preprocessNouns(inputJson)
        toJson(nouns)

    let outputData = if pretty:
        outputJson.pretty(indent = 4)
    else:
        $outputJson

    writeFile(output, outputData)

var parser = newParser:
    command("pps"):
        help("Preprocess Wiktextract JSON data into a more convenient representation.")

        flag("-p", "--pretty", help="Pretty print")

        arg("input", help="Path to Wiktextract JSON data")
        arg("output", help="Write path for intermediary data")
        arg("pos", help="The POS to extract; can be one of \"verb\", \"noun\"")

        run:
            pps(opts.input, opts.output, opts.pos, opts.pretty)

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
