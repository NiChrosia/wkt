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
        
        # forms
        forms = {}
        for form in verb["forms"]:
            forms[form["form"]] = form["tags"]

        all_forms[infinitive] = forms

        # senses
        senses = []
        for sense in verb["senses"]:
            if ("find_of" in sense or "alt_of" in sense) or not ("glosses" in sense):
                continue

            definition = sense["glosses"][0]

            examples = []
            if "examples" in sense:
                for example in sense["examples"]:
                    if "english" in example:
                        foreign_text = example["text"]
                        english_text = example["english"]

                        if english_text == "(please add an English translation of this quotation)":
                            continue
                    else:
                        text = example["text"]

                        separator = None
                        if "―" in text:
                            separator = "―"
                        elif "\n" in text:
                            separator = "\n"

                        parts = text.split(separator)
                        foreign_text = parts[0]
                        english_text = parts[1]

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

output_json = json.dumps([all_forms, all_senses], indent=indent)
pathlib.Path(args.output).write_text(output_json)
