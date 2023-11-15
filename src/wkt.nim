import argparse, jsony
import std/[strutils, strformat, tables]
import types, parse, index

# commands
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

        words.toJson()

    var outputJson = case posEnum
    of posVerb: processPos(inputLines, Verb)
    of posNoun: processPos(inputLines, Noun)
    of posAdj: processPos(inputLines, Adjective)

    writeFile(output, outputJson)

proc idx(output: string, interleavedInputs: seq[string]) =
    var inputs: seq[(string, PartOfSpeech)]

    var i = 0
    while i < interleavedInputs.len:
        let path = interleavedInputs[i]
        let posStr = interleavedInputs[i + 1]

        if not fileExists(path):
            quit(fmt"Invalid file {path}!", 1)

        let pos = try:
            parseEnum[PartOfSpeech](posStr)
        except ValueError:
            quit(fmt"Invalid part of speech {posStr}!", 1)

        inputs.add((path, pos))

        i += 2

    template processPos(contents: string, T: typedesc) =
        discard contents.fromJson(T)

    for (path, pos) in inputs:
        let contents = readFile(path)
        index.file = path

        case pos
        of posVerb: processPos(contents, seq[IntVerb])
        of posNoun: processPos(contents, seq[IntNoun])
        of posAdj: processPos(contents, seq[IntAdjective])

    writeFile(output, indices.toJson())

var parser = newParser:
    command("pps"):
        help("Preprocess Wiktextract JSON data into a more convenient representation.")

        arg("input", help = "Path to Wiktextract JSON data")
        arg("output", help = "Write path for intermediary data")
        arg("pos", help = "The POS to extract; can be one of \"verb\", \"noun\", \"adj\"")

        run:
            pps(opts.input, opts.output, opts.pos)

    command("idx"):
        help("Indexes an intermediary file for more efficient access at scale.")

        arg("output", help = "Write path for index json")
        arg("inputs", nargs = -1, help = "Paths to intermediary data, alternating between a file's path and its part of speech")

        run:
            idx(opts.output, opts.inputs)
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
