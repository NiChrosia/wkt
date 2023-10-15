import argparse, json, pathlib, pprint

parser = argparse.ArgumentParser("transformer")
parser.add_argument("input", help="the path to the wiktextract json data", type=str)
parser.add_argument("output", help="the path for the intermediary json data", type=str)
parser.add_argument("-p", "--pretty", help="whether to store the output with pretty print", action="store_true")

args = parser.parse_args()

input_json = pathlib.Path(args.input).read_text()
data = json.loads(input_json)

all_forms = {}
all_senses = {}

infinitive, forms, senses, verb = (None,) * 4

try:
    for verb in data:
        # not an infinitive
        if not ("forms" in verb):
            continue

        infinitive = verb["word"]
        
        # forms - use a list because multiple combinations of tags can correspond to the same form
        forms = []
        for form in verb["forms"]:
            # not actually forms
            if form["form"] in ["haben", "de-conj"] or "table-tags" in form["tags"]:
                continue

            if (form["form"], form["tags"]) in forms:
                continue

            forms.append((form["form"], form["tags"]))

        all_forms[infinitive] = forms

        # senses
        senses = []
        for sense in verb["senses"]:
            if ("find_of" in sense or "alt_of" in sense) or not ("raw_glosses" in sense):
                continue

            definition = sense["raw_glosses"][0]

            examples = []
            if "examples" in sense:
                for example in sense["examples"]:
                    if "english" in example:
                        foreign_text = example["text"]
                        english_text = example["english"]
                    else:
                        text = example["text"]

                        separator = None
                        if "―" in text:
                            separator = "―"
                        elif "\n" in text:
                            separator = "\n"
                        else:
                            continue

                        parts = text.split(separator)
                        foreign_text = parts[0]
                        english_text = parts[1]

                    if english_text == "(please add an English translation of this quotation)":
                        continue

                    examples.append((foreign_text, english_text))

            senses.append({definition: examples})

        all_senses[infinitive] = senses
except Exception as e:
    print(f"infinitive: {infinitive}")
    print(f"forms: {forms}")
    print(f"senses: {senses}")
    print(f"verb: {pprint.pformat(verb, indent=4)}")

    raise e

indent = 4 if args.pretty else None

output_json = json.dumps([all_forms, all_senses], indent=indent, ensure_ascii=False)
pathlib.Path(args.output).write_text(output_json)
