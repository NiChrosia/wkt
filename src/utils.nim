import json

template defineAbbreviation(abbreviationType: typedesc, abbreviationName, functionName: untyped): untyped =
    proc `abbreviationName`*(json: JsonNode): abbreviationType =
        return json.`functionName`()

defineAbbreviation(int,           i, getInt)
defineAbbreviation(float,         f, getFloat)
defineAbbreviation(string,        s, getStr)
defineAbbreviation(bool,          b, getBool)
defineAbbreviation(seq[JsonNode], l, getElems)
