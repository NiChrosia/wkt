# Disclaimer

Currently, this is highly specialized for (ie, hardcoded for) German verbs, so whether it'll work with other languages is entirely unknown. Thus, use it for German, or at your own risk.

# Usage

The only functionality currently available is converting a list of German verbs into an Anki deck of infinitives to their preterite conjugations.

1. Download the [German verb JSON](https://kaikki.org/dictionary/German/by-pos-verb/kaikki_dot_org-dictionary-German-by-pos-verb.json) from Kaikki.
2. Transform it into the intermediary representation with `python wikt_to_intermediary.py kaikki_dot_org-dictionary-German-by-pos-verb.json intermediary.json`. `--pretty` exists, if you want to look at the format.
3. Compose a list of verbs you want a deck of, and insert them into a newline separated file.
4. Transform it into the JSON preterite representation with `python intermediary_and_verblist_to_preterite.py intermediary.json verblist.txt preterite.json`. `--pretty` can be used here too.
5. Finally, turn it into a deck using `python preterite_to_deck.py preterite.json deck.apkg`. The resulting file can now be imported into Anki.
