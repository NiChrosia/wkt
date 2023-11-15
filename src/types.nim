type
    PartOfSpeech* = enum
        posVerb = "verb",
        posNoun = "noun",
        posAdj = "adj",

    # word
    Verb* = object
        word*: string

        forms*: seq[WordForm]
        senses*: seq[WordSense]

        sounds*: WordSounds

    Noun* = object
        word*: string

        forms*: seq[WordForm]
        senses*: seq[WordSense]

        sounds*: WordSounds

    Adjective* = object
        word*: string

        forms*: seq[WordForm]
        senses*: seq[WordSense]

        sounds*: WordSounds

    IntVerb* = distinct Verb
    IntNoun* = distinct Noun
    IntAdjective* = distinct Adjective

    # - sense
    WordSense* = object
        text*: string
        examples*: seq[SenseExample]

    # === example
    SenseExample* = object
        foreign*, english*: string

    # - form
    WordForm* = object
        form*: string
        tags*: seq[string]
    
    # - sound
    WordSounds* = object
        ipa*, homophones*, rhymes*: seq[string]
        files*: seq[FileSound]

    # === file
    FileSound* = object
        audio*, text*: string
        oggUrl*, mp3Url*: string

