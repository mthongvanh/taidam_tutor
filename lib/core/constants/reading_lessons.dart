abstract class ReadingLessons {
  static const Map<String, dynamic> lesson1 = {
    "lesson": {
      "number": 1,
      "title": "Lesson 1",
      "description": "Final sounds: come at the end of syllables",
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
      "title": "ꪛꪱꪥ 2",
      "titleRomanization": "baaj 2",
      "description": "Introduction to Tai Dam vowels and consonants",
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
