"""Reference implementation of the Bionic Reading rule in SKILL.md.

Bold the first half of each word, rounded up. Words with an apostrophe
count only the letters before it. Acronyms (2+ capitals),
numbers and punctuation stay plain.
"""

import math
import re
import sys

WORD = re.compile(r"[A-Za-z]+(?:'[A-Za-z]+)?")


def bionic_word(word: str) -> str:
    letters = word.replace("'", "")
    if len(letters) >= 2 and letters.isupper():
        return word
    base = word.split("'")[0]
    cut = math.ceil(len(base) / 2)
    return f"**{word[:cut]}**{word[cut:]}"


def bionic_line(line: str) -> str:
    return WORD.sub(lambda m: bionic_word(m.group(0)), line)


def strip_bold(line: str) -> str:
    return line.replace("**", "")


TOKEN = re.compile(r"\*\*[A-Za-z']+\*\*[A-Za-z']*|[A-Za-z']+")


def cut_errors(line: str, tolerance: int = 1) -> list[str]:
    """Words whose bold prefix is more than `tolerance` letters off the rule.

    A missing bold prefix is always an error, and a bolded acronym is always an
    error: both change how the line reads, while a letter either way does not.
    """
    errors = []
    for token in TOKEN.findall(strip_inline_code(line)):
        bolded = token.startswith("**")
        word = strip_bold(token)
        expected = 0 if bionic_word(word) == word else len(bionic_word(word).split("**")[1])
        got = len(token.split("**")[1]) if bolded else 0
        if expected == 0 and bolded:
            errors.append(f"{token} (acronym or number should stay plain)")
        elif expected and not bolded:
            errors.append(f"{token} (no bold prefix)")
        elif abs(got - expected) > tolerance:
            errors.append(f"{token} (bolded {got}, rule says {expected})")
    return errors


PLAIN = re.compile(r"\S*/\S*|[A-Za-z0-9_-]*\.[A-Za-z0-9_.-]+")


def strip_inline_code(line: str) -> str:
    """Remove what the rule leaves plain: code spans, hostnames, paths."""
    return PLAIN.sub("", re.sub(r"`[^`]*`", "", line))


if __name__ == "__main__":
    for raw in sys.stdin:
        print(bionic_line(raw.rstrip("\n")))
