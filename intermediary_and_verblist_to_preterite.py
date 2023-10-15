import argparse, json, pathlib

parser = argparse.ArgumentParser("intermediary and verblist to preterite transformer")
parser.add_argument("data", help="intermediary json path", type=str)
parser.add_argument("verbs", help="verblist path", type=str)
parser.add_argument("output", help="preterite output path", type=str)
parser.add_argument("-p", "--pretty", help="whether to use pretty print", action="store_true")

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
