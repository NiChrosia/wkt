import argparse, jsony
import std/[strutils, strformat, tables, streams]
import types, parse, index

proc validateFiles(files: varargs[string]) =
    for file in files:
        if not fileExists(file):
            quit(fmt"Invalid file {file}!", 1)

proc parsePos(raw: string): PartOfSpeech =
    return try:
        parseEnum[PartOfSpeech](raw)
    except ValueError:
        quit(fmt"Invalid part of speech {raw}!", 1)

# commands
proc pps(input, output: string, pos: string) =
    # validate
    validateFiles(input)
    let posEnum = parsePos(pos)

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

        validateFiles(path)
        let pos = parsePos(posStr)

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

proc fil(index, list, output: string) =
    validateFiles(index, list)

    let indices = index
        .readFile()
        .fromJson(Table[string, Index])

    let words = list
        .readFile()
        .split("\n")
        .filterIt(it != "")

    template process[T](index: Index, stream: Stream): T =
        var size = 1000

        var result: T
        var invalid = true

        while invalid:
            stream.setPosition(index.index)

            try:
                let s = stream.readStr(size)
                var i = 0

                parseHook(s, i, result)
                invalid = false
            except ValueError:
                size *= 2
            except IOError:
                discard stream.readLine()
                size = stream.getPosition() - index.index + 1

        result

    # streams for the intermediary files
    var intStreams: Table[string, FileStream]
    var wordObjs: seq[Noun]

    for word in words:
        if word notin indices:
            quit(fmt"Word '{word}' not in indices!", 1)

        let index = indices[word]
        let file = index.file

        validateFiles(file)

        if file notin intStreams:
            intStreams[file] = newFileStream(file)

        var stream = intStreams[file]

        # casting everything to a noun is a cursed solution, but it works for now
        # since nouns, verbs, and adjectives are almost structurally identical

        # TODO: find some solution to this, or, if you can, eliminate the
        # word typing altogether
        let wordObj = case index.pos
        of posNoun: process[IntNoun](index, stream).Noun
        of posVerb: cast[Noun](process[IntVerb](index, stream).Verb)
        of posAdj: cast[Noun](process[IntAdjective](index, stream).Adjective)

        wordObjs.add(wordObj)

    for stream in intStreams.values:
        stream.close()

    writeFile(output, wordObjs.toJson())

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

    command("fil"):
        help("Filters words from an index file into a new hybrid intermediary file.")

        arg("index", help = "Path to index json")
        arg("list", help = "Path to newline-separated word list")
        arg("output", help = "Write path for hybrid intermediary file")

        run:
            fil(opts.index, opts.list, opts.output)
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
