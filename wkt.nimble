# Package

version       = "0.1.0"
author        = "NiChrosia"
description   = "A program that filters and sorts Wiktionary data for use in other programs."
license       = "Unlicense"
srcDir        = "src"
bin           = @["wkt"]

# Dependencies

requires "nim >= 2.0.0"
requires "argparse >= 4.0.1"
requires "jsony >= 1.1.5"
