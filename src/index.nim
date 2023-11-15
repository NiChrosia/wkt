import jsony
import std/[tables]
import types

type
    Index* = object
        file*: string
        pos*: PartOfSpeech
        index*: int

var indices*: Table[string, Index]
var file*: string

proc parseHook*(s: string, i: var int, v: var IntVerb) =
    if file == "":
        jsony.parseHook(s, i, v)
        return

    let initialIndex = i
    jsony.parseHook(s, i, v)

    indices[v.Verb.word] = Index(file: file, pos: posVerb, index: initialIndex)

proc parseHook*(s: string, i: var int, v: var IntNoun) =
    if file == "":
        jsony.parseHook(s, i, v)
        return

    let initialIndex = i
    jsony.parseHook(s, i, v)

    indices[v.Noun.word] = Index(file: file, pos: posNoun, index: initialIndex)

proc parseHook*(s: string, i: var int, v: var IntAdjective) =
    if file == "":
        jsony.parseHook(s, i, v)
        return

    let initialIndex = i
    jsony.parseHook(s, i, v)

    indices[v.Adjective.word] = Index(file: file, pos: posAdj, index: initialIndex)
