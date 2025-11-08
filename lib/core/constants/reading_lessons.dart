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
          "letter": "ꪱ",
          "sound": "aa",
          "description": "Long vowel sound 'aa' as in 'father'",
        },
        {
          "letter": "ꪺ",
          "sounds": "ua",
          "description": "Diphthong sound 'ua' as in 'guava'"
        },
        {
          "letter": "ꪽ",
          "sound": "an",
          "description": "Nasal sound 'an'",
        }
      ],
      "combinations": [
        {
          "components": ["ꪀ", "ꪱ"],
          "result": "ꪀꪱ",
          "romanization": "kaa",
          "description": "Combining consonant 'k' with vowel 'aa'",
        },
        {
          "components": ["ꪁ", "ꪽ"],
          "result": "ꪁꪽ",
          "romanization": "kan",
          "description": "Combining consonant 'kh' with vowel 'an'",
        },
        {
          "components": ["ꪄ", "ꪺ"],
          "result": "ꪄꪺ",
          "romanization": "khua",
          "description": "Combining consonant 'kh' with vowel 'ua'",
        },
        {
          "components": ["ꪅ", "ꪽ"],
          "result": "ꪅꪽ",
          "romanization": "khan",
          "description": "Combining consonant 'kh' with vowel 'an'",
        },
        {
          "components": ["ꪈ", "ꪱ"],
          "result": "ꪈꪱ",
          "romanization": "ngaa",
          "description": "Combining consonant 'ng' with vowel 'aa'",
        },
        {
          "components": ["ꪉ", "ꪺ"],
          "result": "ꪉꪺ",
          "romanization": "ngua",
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
          "letter": "ꪲ",
          "sound": "i",
          "description": "Vowel sound 'i' as in 'see'",
        },
        {
          "letter": "ꪾ",
          "sound": "am",
          "description": "Vowel with final nasal 'am'",
        },
        {
          "letter": "ꪳ",
          "sound": "u",
          "description": "Vowel sound 'u' as in 'food'",
        },
        {
          "letter": "ꪸ",
          "sound": "ie",
          "description": "Diphthong vowel sound 'ie'",
        },
        {
          "letter": "ꪷ",
          "sound": "o",
          "description": "Vowel sound 'o'",
        }
      ],
      "combinations": [
        {
          "components": ["ꪊ", "\uAAB2"],
          "result": "ꪊꪲ",
          "romanization": "chi",
          "description": "Combining consonant 'ch' with vowel 'i'",
        },
        {
          "components": ["ꪋ", "\uAABE"],
          "result": "ꪋꪾ",
          "romanization": "cham",
          "description": "Combining consonant 'ch' with vowel 'am'",
        },
        {
          "components": ["ꪎ", "\uAAB3"],
          "result": "ꪎꪳ",
          "romanization": "su",
          "description": "Combining consonant 's' with vowel 'u'",
        },
        {
          "components": ["ꪏ", "\uAAB8"],
          "result": "ꪏ",
          "romanization": "sie",
          "description": "Combining consonant 's' with vowel 'u'",
        },
        {
          "components": ["ꪐ", "\uAAB7"],
          "result": "ꪐꪷ",
          "romanization": "hgno",
          "description": "Combining consonant 'hg' with vowel 'o'",
        },
        {
          "components": ["ꪑ", "\uAAB7"],
          "result": "ꪑꪷ",
          "romanization": "gno",
          "description": "Combining consonant 'g' with vowel 'o'",
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
          "romanization": "sie",
        },
        {
          "word": "ꪊꪾ",
          "romanization": "cham",
        },
        {
          "word": "ꪏꪸ",
          "romanization": "sie",
        },
        {
          "word": "ꪎꪲ",
          "romanization": "si",
        },
        {
          "word": "ꪋꪲ",
          "romanization": "chi",
        },
        {
          "word": "ꪎꪷ",
          "romanization": "so",
        },
        {
          "word": "ꪋꪾ",
          "romanization": "cham",
        },
        {
          "word": "ꪏꪷ",
          "romanization": "so",
        },
      ]
    }
  };
}
