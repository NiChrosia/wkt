import sets

type
    Translation* = object
        english*: string
        foreign*: string

    Definition* = object
        text*: string
        translations*: seq[Translation]

    WordForm* = object
        spelling*: string
        tags*: seq[string]

    Verb* = object
        infinitive*: string

        forms*: HashSet[WordForm]
        definitions*: seq[Definition]

    Noun* = object
        lemma*: string

        forms*: HashSet[WordForm]
        definitions*: seq[Definition]
