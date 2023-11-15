import argparse, pathlib, json, genanki, random, urllib.request

parser = argparse.ArgumentParser("Basic deck creator")
parser.add_argument("email", help="Email to use in the User-Agent field")
parser.add_argument("input", help="Path to hybrid intermediary json")
parser.add_argument("output", help="Write path for Anki deck")

args = parser.parse_args()

input_contents = pathlib.Path(args.input).read_text()
input_json = json.loads(input_contents)

model = genanki.Model(1190423014, "Word, Sound, and Definitions", fields=[
        {"name": "Word"},
        {"name": "Ipa"},
        {"name": "Definitions"},
        {"name": "Sound"},
    ], templates=[{
        "name": "Card 1",
        "qfmt": "<span>{{Word}}{{Ipa}}</span><br>{{Sound}}",
        "afmt": '{{FrontSide}}<hr id="answer">{{Definitions}}',
    }])

deck = genanki.Deck(random.randrange(1 << 30, 1 << 31), "Basic Deck")
full_audio_files = []

pathlib.Path("tmp").mkdir(parents=True, exist_ok=True)

for word in input_json:
    # word
    name = word["word"]

    # ipa
    ipa = ""

    if len(word["sounds"]["ipa"]) > 0:
        ipa = ", ".join(word["sounds"]["ipa"])
        ipa = " - " + ipa

    # audio
    audio_urls = word["sounds"]["files"]

    full_audio_file = ""
    audio_file = ""

    if len(audio_urls) > 0:
        audio_url = audio_urls[0]["oggUrl"]

        parts = audio_url.split("/")
        filename = parts[-1]

        req = urllib.request.Request(audio_url)
        req.add_header("User-Agent", f"WiktionaryAnkiTransformer/0.0 ({args.email})")

        contents = urllib.request.urlopen(req).read()
        pathlib.Path(f"tmp/{filename}").write_bytes(contents)

        full_audio_file = f"./tmp/{filename}"
        audio_file = filename

    full_audio_files.append(full_audio_file)

    # definitions
    definitions = []

    for sense in word["senses"]:
        definition = sense["text"]
        examples = []
        
        for example in sense["examples"]:
            e = example["english"]
            f = example["foreign"]

            html = f"<i>{f}</i><dl><dd><span>{e}</span></dd></dl>"
            examples.append(html)

        html = f"<span>{definition}</span><dl>"

        for example in examples:
            html += "<dd>"
            html += example
            html += "</dd>"

        html += "</dl>"
        definitions.append(html)

    html = "<ol>"

    for definition in definitions:
        html += "<li>"
        html += definition
        html += "</li>"

    html += "</ol>"

    note = genanki.Note(model=model, fields=[name, ipa, html, f"[sound:{audio_file}]"])
    deck.add_note(note)

package = genanki.Package(deck)
package.media_files = full_audio_files

package.write_to_file(args.output)

for file in full_audio_files:
    pathlib.Path(file).unlink(missing_ok=True)

pathlib.Path("tmp").rmdir()
