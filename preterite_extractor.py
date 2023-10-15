import argparse, json, pathlib

parser = argparse.ArgumentParser("preterite extractor")
parser.add_argument("data", help="the path to the verb json data", type=str)
parser.add_argument("verbs", help="the path to the list of verbs to be transformed", type=str)
parser.add_argument("output", help="the path for the extracted json data", type=str)
parser.add_argument("-p", "--pretty", help="whether to store the output with pretty print", action="store_true")

args = parser.parse_args()

data_json = pathlib.Path(args.data).read_text()
data = json.loads(data_json)
all_forms = data[0]

verbs = pathlib.Path(args.verbs).read_text().split("\n")

output = {}

for verb in verbs:
    if verb == "":
        continue

    raw_forms = all_forms[verb]
    forms = [""] * 6

    for form, tags in raw_forms:
        if not ("preterite" in tags) or ("subjunctive" in tags) or ("participle" in tags):
            continue

        person = 0
        if "second-person" in tags:
            person = 1
        elif "third-person" in tags:
            person = 2

        number = 0
        if "plural" in tags:
            number = 1

        index = number * 3 + person
        if forms[index] != "":
            forms[index] += f", "
        forms[index] += form

    output[verb] = forms

indent = 4 if args.pretty else None
output_json = json.dumps(output, indent=indent, ensure_ascii=False)

pathlib.Path(args.output).write_text(output_json)
