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
          "description": "Sound like 'ah' in 'father'",
        },
        {
          "characterIds": [18],
          "description": "Sounds like 'oo-wah' in 'guava'",
        },
        {
          "characterIds": [22],
          "description": "Nasal sound like at the end of 'man'",
        }
      ],
      "combinations": [
        {
          "characterIds": [24, 5],
          "description": "Sounds like 'cau' in 'cause'",
        },
        {
          "characterIds": [25, 22],
          "description": "Sounds like 'coun' in 'country'",
        },
        {
          "characterIds": [26, 18],
          "description": "Sounds like 'qua' in 'squat'",
        },
        {
          "characterIds": [27, 22],
          "description": "Sounds like 'khan' in 'Genghis Khan'",
        },
        {
          "characterIds": [28, 5],
          "description": "Sounds like 'ng-ah' in 'sung-ah'",
        },
        {
          "characterIds": [29, 18],
          "description": "Sounds like 'ng-ooah' in 'sung-ooah'",
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
          "description": "Sounds like 'ee' as in 'see'",
        },
        {
          "characterIds": [23],
          "description": "Sounds like 'um' in 'sum'",
        },
        {
          "characterIds": [8],
          "description": "Sounds like 'oo' as in 'food'",
        },
        {
          "characterIds": [16],
          "description": "Sounds like 'ee-ya' as in 'see-ya'",
        },
        {
          "characterIds": [4],
          "description": "Sounds like 'aw' as in 'saw'",
        }
      ],
      "combinations": [
        {
          "characterIds": [30, 7],
          "description": "Sounds like 'chea-' in 'cheat'",
        },
        {
          "characterIds": [31, 23],
          "description": "Sounds like 'jum-' in 'jump'",
        },
        {
          "characterIds": [32, 8],
          "description": "Sounds like 'sue' in 'suit'",
        },
        {
          "characterIds": [33, 16],
          "description": "Sounds like 'see-ya'",
        },
        {
          "characterIds": [34, 4],
          "description": "Sounds like 'knee-awe' which rhymes with 'yee-haw'",
        },
        {
          "characterIds": [35, 4],
          "description": "Sounds like 'knee-awe' which rhymes with 'yee-haw'",
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
