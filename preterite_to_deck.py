import argparse, json, pathlib, genanki, random

parser = argparse.ArgumentParser("preterite to deck transformer")
parser.add_argument("data", help="preterite json path", type=str)
parser.add_argument("output", help="deck output path", type=str)

args = parser.parse_args()

data_json = pathlib.Path(args.data).read_text()
data = json.loads(data_json)

preterite_model = genanki.Model(
    1231017661,
    "Preterite Conjugation",
    fields=[
        {"name": "Infinitive"},
        {"name": "1s"},
        {"name": "2s"},
        {"name": "3s"},
        {"name": "1p"},
        {"name": "2p"},
        {"name": "3p"},
    ],
    templates=[
        {
            "name": "Card 1",
            "qfmt": "{{Infinitive}}",
            "afmt": """{{FrontSide}}
<hr id=\"answer\">
<table>
    <tr>
        <th></th>
        <th>Singular</th>
        <th>Plural</th>
    </tr>
    <tr>
        <th>1st Person</th>
        <td>{{1s}}</td>
        <td>{{1p}}</td>
    </tr>
    <tr>
        <th>2nd Person</th>
        <td>{{2s}}</td>
        <td>{{2p}}</td>
    </tr>
    <tr>
        <th>3rd Person</th>
        <td>{{3s}}</td>
        <td>{{3p}}</td>
    </tr>
</table>"""
        }
    ]
)

deck_id = random.randrange(1 << 30, 1 << 31)
preterite_deck = genanki.Deck(deck_id, 'Preterite')

for infinitive, fields in data.items():
    note = genanki.Note(model=preterite_model, fields=[infinitive] + fields)
    preterite_deck.add_note(note)

genanki.Package(preterite_deck).write_to_file(args.output)
