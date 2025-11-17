abstract class ReadingLessons {
  static const Map<String, dynamic> lesson1 = {
    "lesson": {
      "number": 1,
      "title": "After consonants",
      "shortDescription": "Vowels can be on the right side of consonants.",
      "description":
          "In Tai Dam, a syllable starts with a consonant. If the vowel is a post-position form, it's written right next to the consonant, without any space in between. Imagine a right-vowel syllable that looks like this: 𝐶 + 𝑉.\nSo:\n  ꪀ + ꪱ becomes ꪀꪱ (\"kaa\"),\n  ꪁ + ꪽ becomes ꪁꪽ (\"kan\"),\nand\n  ꪉ + ꪺ becomes ꪉꪺ (\"ngua\").",
      "goals": [
        {
          "letter": {
            "character": "ꪱ",
            "characterId": 5,
          },
          "sound": "aa",
          "description": "Long vowel sound 'aa' as in 'father'",
        },
        {
          "letter": {
            "character": "ꪺ",
            "characterId": 18,
          },
          "sound": "ua",
          "description": "Diphthong sound 'ua' as in 'guava' (-oowa-)",
        },
        {
          "letter": {
            "character": "ꪽ",
            "characterId": 22,
          },
          "sound": "an",
          "description": "Nasal sound 'an'",
        }
      ],
      "combinations": [
        {
          "components": [
            {
              "character": "ꪀ",
              "characterId": 24,
            },
            {
              "character": "ꪱ",
              "characterId": 5,
            }
          ],
          "result": "ꪀꪱ",
          "description": "Combining consonant 'k' with vowel 'aa'",
        },
        {
          "components": [
            {
              "character": "ꪁ",
              "characterId": 25,
            },
            {
              "character": "ꪽ",
              "characterId": 22,
            }
          ],
          "result": "ꪁꪽ",
          "description": "Combining consonant 'kh' with vowel 'an'",
        },
        {
          "components": [
            {
              "character": "ꪄ",
              "characterId": 26,
            },
            {
              "character": "ꪺ",
              "characterId": 18,
            }
          ],
          "result": "ꪄꪺ",
          "romanization": "khua",
          "description": "Combining consonant 'kh' with vowel 'ua'",
        },
        {
          "components": [
            {
              "character": "ꪅ",
              "characterId": 27,
            },
            {
              "character": "ꪽ",
              "characterId": 22,
            }
          ],
          "result": "ꪅꪽ",
          "description": "Combining consonant 'kh' with vowel 'an'",
        },
        {
          "components": [
            {
              "character": "ꪈ",
              "characterId": 28,
            },
            {
              "character": "ꪱ",
              "characterId": 5,
            }
          ],
          "result": "ꪈꪱ",
          "description": "Combining consonant 'ng' with vowel 'aa'",
        },
        {
          "components": [
            {
              "character": "ꪉ",
              "characterId": 29,
            },
            {
              "character": "ꪺ",
              "characterId": 18,
            }
          ],
          "result": "ꪉꪺ",
          "description": "Combining consonant 'ng' with vowel 'ua'",
        }
      ]
    }
  };

  static const Map<String, dynamic> lesson2 = {
    "lesson": {
      "number": 2,
      "title": "Above consonants",
      "shortDescription": "Vowels can appear above consonants in syllables.",
      "description":
          "Some Tai Dam vowels can sit above the consonant they follow. Start with the base consonant on the writing line, then place the vowel sign directly above it to finish the syllable—no extra marks are added to the left or right. For example,\n  ꪊ + ꪲ becomes ꪊꪲ (\"chi\")\n  ꪎ + ꪳ becomes ꪎꪳ (\"su\"),\nand\n  ꪐ + ꪷ becomes ꪐꪷ (\"hgno\").",
      "goals": [
        {
          "letter": {
            "character": "ꪲ",
            "characterId": 7,
          },
          "sound": "i",
          "description": "Vowel sound 'i' as in 'see'",
        },
        {
          "letter": {
            "character": "ꪾ",
            "characterId": 23,
          },
          "sound": "am",
          "description": "Vowel with final nasal 'um'",
        },
        {
          "letter": {
            "character": "ꪳ",
            "characterId": 8,
          },
          "sound": "ue",
          "description": "Vowel sound 'ue' as in 'food'",
        },
        {
          "letter": {
            "character": "ꪸ",
            "characterId": 16,
          },
          "sound": "ia",
          "description": "Diphthong vowel sound 'ia'",
        },
        {
          "letter": {
            "character": "ꪷ",
            "characterId": 4,
          },
          "sound": "-aw",
          "description": "'aw' as in 'saw'",
        }
      ],
      "combinations": [
        {
          "components": [
            {
              "character": "ꪊ",
              "characterId": 30,
            },
            {
              "character": "ꪲ",
              "characterId": 7,
            }
          ],
          "result": "ꪊꪲ",
          "romanization": "chi",
          "description": "Combining consonant 'ch' with vowel 'i'",
        },
        {
          "components": [
            {
              "character": "ꪋ",
              "characterId": 31,
            },
            {
              "character": "ꪾ",
              "characterId": 23,
            }
          ],
          "result": "ꪋꪾ",
          "romanization": "'chum",
          "description": "Combining consonant 'ch' with vowel 'um'",
        },
        {
          "components": [
            {
              "character": "ꪎ",
              "characterId": 32,
            },
            {
              "character": "ꪳ",
              "characterId": 8,
            }
          ],
          "result": "ꪎꪳ",
          "romanization": "sue",
          "description": "Combining consonant 's' with vowel 'ue'",
        },
        {
          "components": [
            {
              "character": "ꪏ",
              "characterId": 33,
            },
            {
              "character": "ꪸ",
              "characterId": 16,
            }
          ],
          "result": "ꪏꪸ",
          "romanization": "'sia",
          "description": "Combining consonant 's' with vowel 'u'",
        },
        {
          "components": [
            {
              "character": "ꪐ",
              "characterId": 34,
            },
            {
              "character": "ꪷ",
              "characterId": 4,
            }
          ],
          "result": "ꪐꪷ",
          "romanization": "nyaw",
          "description": "Combining consonant 'ny' with vowel 'aw'",
        },
        {
          "components": [
            {
              "character": "ꪑ",
              "characterId": 35,
            },
            {
              "character": "ꪷ",
              "characterId": 4,
            }
          ],
          "result": "ꪑꪷ",
          "romanization": "'nyaw",
          "description": "Combining consonant 'ny' with vowel 'aw'",
        },
      ],
      "examples": [
        {
          "word": "ꪎꪳ",
          "romanization": "su",
        },
        {
          "word": "ꪐꪷ",
          "romanization": "hgno",
        },
        {
          "word": "ꪑꪷ",
          "romanization": "gno",
        },
        {
          "word": "ꪎꪸ",
          "romanization": "sia",
        },
        {
          "word": "ꪊꪾ",
          "romanization": "cham",
        },
        {
          "word": "ꪏꪸ",
          "romanization": "'sia",
        },
        {
          "word": "ꪎꪲ",
          "romanization": "si",
        },
        {
          "word": "ꪋꪲ",
          "romanization": "'chi",
        },
        {
          "word": "ꪎꪷ",
          "romanization": "saw",
        },
        {
          "word": "ꪋꪾ",
          "romanization": "'cham",
        },
        {
          "word": "ꪏꪷ",
          "romanization": "'saw",
        },
      ]
    }
  };
}
