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
          "characterIds": [5],
          "description": "Long vowel sound 'aa' as in 'father'",
        },
        {
          "characterIds": [18],
          "description": "Diphthong sound 'ua' as in 'guava' (-oowa-)",
        },
        {
          "characterIds": [22],
          "description": "Nasal sound 'an'",
        }
      ],
      "combinations": [
        {
          "characterIds": [24, 5],
          "description": "Combining consonant 'k' with vowel 'aa'",
        },
        {
          "characterIds": [25, 22],
          "description": "Combining consonant 'kh' with vowel 'an'",
        },
        {
          "characterIds": [26, 18],
          "description": "Combining consonant 'kh' with vowel 'ua'",
        },
        {
          "characterIds": [27, 22],
          "description": "Combining consonant 'kh' with vowel 'an'",
        },
        {
          "characterIds": [28, 5],
          "description": "Combining consonant 'ng' with vowel 'aa'",
        },
        {
          "characterIds": [29, 18],
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
          "characterIds": [7],
          "description": "Vowel sound 'i' as in 'see'",
        },
        {
          "characterIds": [23],
          "description": "Vowel with final nasal 'um'",
        },
        {
          "characterIds": [8],
          "description": "Vowel sound 'ue' as in 'food'",
        },
        {
          "characterIds": [16],
          "description": "Diphthong vowel sound 'ia'",
        },
        {
          "characterIds": [4],
          "description": "'aw' as in 'saw'",
        }
      ],
      "combinations": [
        {
          "characterIds": [30, 7],
          "description": "Combining consonant 'ch' with vowel 'i'",
        },
        {
          "characterIds": [31, 23],
          "description": "Combining consonant 'ch' with vowel 'um'",
        },
        {
          "characterIds": [32, 8],
          "description": "Combining consonant 's' with vowel 'ue'",
        },
        {
          "characterIds": [33, 16],
          "description": "Combining consonant 's' with vowel 'u'",
        },
        {
          "characterIds": [34, 4],
          "description": "Combining consonant 'ny' with vowel 'aw'",
        },
        {
          "characterIds": [35, 4],
          "description": "Combining consonant 'ny' with vowel 'aw'",
        },
      ],
      "examples": [
        {
          "characterIds": [32, 8],
        },
        {
          "word": "ꪐꪷ",
          "characterIds": [34, 4],
        },
        {
          "word": "ꪑꪷ",
          "characterIds": [35, 4],
        },
        {
          "word": "ꪎꪸ",
          "characterIds": [32, 16],
        },
        {
          "word": "ꪊꪾ",
          "characterIds": [30, 23],
        },
        {
          "word": "ꪏꪸ",
          "characterIds": [33, 16],
        },
        {
          "word": "ꪎꪲ",
          "characterIds": [32, 7],
        },
        {
          "word": "ꪋꪲ",
          "characterIds": [31, 7],
        },
        {
          "word": "ꪎꪷ",
          "characterIds": [32, 4],
        },
        {
          "word": "ꪋꪾ",
          "characterIds": [31, 23],
        },
        {
          "word": "ꪏꪷ",
          "characterIds": [33, 4],
        },
      ]
    }
  };
}
