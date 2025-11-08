#!/usr/bin/env python3
"""
Script to add romanization hints to flashcards with soundIpa hints.
Converts IPA notation to English-like romanization approximations.
"""

import json
import re

def ipa_to_romanization(ipa):
    """Convert IPA to English-like romanization approximation."""
    # Remove tone marks and diacritics
    romanized = re.sub(r'[˨˩˦˥˧ˀ]', '', ipa)
    romanized = re.sub(r'[:\(\)\[\]]', '', romanized)
    
    # Convert IPA symbols to romanization
    conversions = {
        'ŋ': 'ng',
        'ɲ': 'ny',
        'ʷ': 'w',
        'ː': '',
        'ɔ': 'aw',
        'ɨ': 'eu',
        'ə': 'uh',
        'ʔ': '',
        'p̚': 'p',
        't̚': 't',
        'k̚': 'k',
        't͡ɕ': 'ch',
        'x': 'kh',
        '̯': '',
    }
    
    for ipa_char, roman in conversions.items():
        romanized = romanized.replace(ipa_char, roman)
    
    # Clean up any remaining special characters
    romanized = re.sub(r'[̚˥˦˧˨˩]', '', romanized)
    
    return romanized.strip()

def process_flashcards(input_file, output_file):
    """Process flashcards JSON and add romanization hints."""
    with open(input_file, 'r', encoding='utf-8') as f:
        flashcards = json.load(f)
    
    modified_count = 0
    
    for flashcard in flashcards:
        if 'hints' not in flashcard or not flashcard['hints']:
            continue
        
        # Check if there's a soundIpa hint
        has_ipa = False
        ipa_content = None
        
        for hint in flashcard['hints']:
            if hint.get('hintType') == 'soundIpa':
                has_ipa = True
                ipa_content = hint.get('content', '')
                # Add hintOrder to soundIpa hints
                if 'hintOrder' not in hint:
                    hint['hintOrder'] = 2
                break
        
        if has_ipa and ipa_content:
            # Check if romanization hint already exists
            has_romanization = any(
                h.get('hintType') == 'romanization' 
                for h in flashcard['hints']
            )
            
            if not has_romanization:
                # Generate romanization
                romanized = ipa_to_romanization(ipa_content)
                
                # Add romanization hint with hintOrder 1 (shown first)
                flashcard['hints'].insert(0, {
                    'hintType': 'romanization',
                    'hintDisplayText': 'Sounds like',
                    'content': romanized,
                    'hintOrder': 1
                })
                modified_count += 1
        
        # Add hintOrder to lao hints if not present
        for hint in flashcard['hints']:
            if hint.get('hintType') == 'lao' and 'hintOrder' not in hint:
                hint['hintOrder'] = 3
            elif hint.get('hintType') == 'romanization' and 'hintOrder' not in hint:
                hint['hintOrder'] = 1
    
    # Write updated flashcards
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(flashcards, f, ensure_ascii=False, indent=2)
    
    print(f"Processed {len(flashcards)} flashcards")
    print(f"Added romanization hints to {modified_count} entries")

if __name__ == '__main__':
    input_file = 'assets/data/flashcards.json'
    output_file = 'assets/data/flashcards.json'
    process_flashcards(input_file, output_file)
