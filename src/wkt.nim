import argparse, jsony
import std/[strutils, strformat]
import types

type
    PartOfSpeech = enum
        posVerb = "verb",
        posNoun = "noun",
        posAdj = "adj",

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

    template processPos(lines: seq[string], T: typedesc): string =
        var words: seq[T]

        for line in inputLines:
            let word = line.fromJson(T)

            if word.forms.len > 0 and word.senses.len > 0:
                words.add(word)

        toJson(words)

    var outputJson = case posEnum
    of posVerb: processPos(inputLines, Verb)
    of posNoun: processPos(inputLines, Noun)
    of posAdj: processPos(inputLines, Adjective)

    writeFile(output, outputJson)

var parser = newParser:
    command("pps"):
        help("Preprocess Wiktextract JSON data into a more convenient representation.")

        arg("input", help="Path to Wiktextract JSON data")
        arg("output", help="Write path for intermediary data")
        arg("pos", help="The POS to extract; can be one of \"verb\", \"noun\", \"adj\"")

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
