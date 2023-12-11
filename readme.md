# Usage

## Installation

First, to get the binary, you can either download it from [the latest release](https://github.com/NiChrosia/wkt/releases/latest) (if you use Linux), or compile it yourself. To do so, clone this repository, and run `nimble build`. If you don't have nimble installed, you can install Nim [from the official website](https://nim-lang.org/install.html) or using [choosenim](https://github.com/dom96/choosenim), and then run the above command.

## CLI

(beware; these steps assume you're using supported data (ie, German nouns, verbs, or adjectives), as anything else is untested)

### Extraction

- Firstly, download the raw JSON data files from [Kaikki](https://kaikki.org/dictionary/) (select a language and a part of speech, scroll down, and you should see text saying "Download JSON data for these senses").
- Secondly, for each JSON file, preprocess it using `wkt pps <input> <output> <pos>`, where input is the path of the JSON file, output is the write path for the intermediary JSON data, and pos is a part of speech (currently, only "verb", "noun", or "adj").
- Thirdly, create an index of every file you preprocessed using `wkt idx <output> <input> <pos> <input> <pos> ...`, where output is the write path for the index JSON, and each pair after that is a space-separated combination of an intermediary JSON file and its part of speech (once again, currently only "verb", "noun", or "adj").
- Next, create a newline-separated list of words you want to extract (their written form must exactly match their form in Wiktionary).
- After that, filter the intermediary data for those words using `wkt fil <index> <list> <output>`, where index is the index file created earlier, list is the wordlist file you just created, and output is the desired write path for the intermediary data for those words.
- Finally, to actually create the deck, run `python create_basic_deck.py [--email <email>] <input> <output>` (`create_basic_deck.py` is from the repository), where input is the path to the intermediary data created in the previous step, and output is the write path to the Anki deck (as an apkg file). The email parameter is optional, but it enables adding sound to decks (the email is required for downloading the sound, as per [Wiktionary's bot guidelines](https://www.mediawiki.org/wiki/API:Etiquette#The_User-Agent_header)).
