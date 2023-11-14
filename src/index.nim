import jsony
import std/[tables]
import types

var indices*: Table[string, int]
var active* = false

proc parseHook*(s: string, i: var int, v: var IntVerb) =
    if not active:
        jsony.parseHook(s, i, v)
        return

    let initialIndex = i
    jsony.parseHook(s, i, v)

    indices[v.Verb.word] = initialIndex

proc parseHook*(s: string, i: var int, v: var IntNoun) =
    if not active:
        jsony.parseHook(s, i, v)
        return

    let initialIndex = i
    jsony.parseHook(s, i, v)

    indices[v.Noun.word] = initialIndex

proc parseHook*(s: string, i: var int, v: var IntAdjective) =
    if not active:
        jsony.parseHook(s, i, v)
        return

    let initialIndex = i
    jsony.parseHook(s, i, v)

    indices[v.Adjective.word] = initialIndex
