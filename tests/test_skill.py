"""Checks the skill and command files against each other and the Bionic rule."""

import re
import unittest
from pathlib import Path

from bionic import bionic_line, bionic_word, cut_errors, strip_bold

REPO = Path(__file__).resolve().parent.parent
SKILL = REPO / "skills" / "explain-simply" / "SKILL.md"
COMMAND = REPO / "commands" / "elis.md"


def frontmatter(path: Path) -> dict[str, str]:
    text = path.read_text()
    match = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
    if not match:
        raise AssertionError(f"{path} has no frontmatter")
    return dict(line.split(": ", 1) for line in match.group(1).splitlines())


def example_prose_lines() -> list[str]:
    """Prose lines of the worked example: outside diagrams, not table rules."""
    text = SKILL.read_text()
    example = text.split("## Example", 1)[1].split("````")[1]
    lines, in_diagram = [], False
    for line in example.splitlines():
        if line.startswith("```"):
            in_diagram = not in_diagram
            continue
        if in_diagram or not line.strip() or re.fullmatch(r"\|[-|]+\|", line):
            continue
        lines.append(line)
    return lines


class BionicRule(unittest.TestCase):
    def test_word_lengths(self):
        cases = {
            "a": "**a**",
            "it": "**i**t",
            "the": "**th**e",
            "code": "**co**de",
            "plans": "**pla**ns",
            "change": "**cha**nge",
            "website": "**webs**ite",
            "Terraform": "**Terra**form",
            "Terraform's": "**Terra**form's",
            "don't": "**do**n't",
        }
        for word, expected in cases.items():
            with self.subTest(word=word):
                self.assertEqual(bionic_word(word), expected)

    def test_acronyms_numbers_and_punctuation_stay_plain(self):
        self.assertEqual(bionic_line("DNS (IP) 93.184"), "DNS (IP) 93.184")

    def test_rule_table_examples_match_reference(self):
        table = SKILL.read_text().split("## Bionic Reading", 1)[1].split("Leave these plain")[0]
        examples = re.findall(r"\*\*\w+\*\*\w*", table)
        self.assertGreaterEqual(len(examples), 8)
        for example in examples:
            with self.subTest(example=example):
                self.assertEqual(bionic_word(strip_bold(example)), example)

    def test_cut_errors_flags_missing_bold_and_bolded_acronyms(self):
        self.assertEqual(cut_errors("**th**e **co**de"), [])
        self.assertEqual(cut_errors("**t**he **cod**e"), [])  # one letter out is fine
        self.assertIn("plain", cut_errors("plain **co**de")[0])
        self.assertIn("**DN**S", cut_errors("**DN**S **lo**oks **i**t **u**p")[0])
        self.assertEqual(cut_errors("**ru**ns `terraform plan` **no**w"), [])
        self.assertEqual(cut_errors("**as**ks **th**e .com **ser**ver"), [])
        self.assertEqual(cut_errors("**re**ads skills/explain-simply/SKILL.md"), [])

    def test_worked_example_is_correct_bionic(self):
        lines = example_prose_lines()
        self.assertGreaterEqual(len(lines), 10)
        for line in lines:
            with self.subTest(line=line):
                self.assertEqual(line, bionic_line(strip_bold(line)))


class Wiring(unittest.TestCase):
    def test_skill_name_matches_directory(self):
        self.assertEqual(frontmatter(SKILL)["name"], SKILL.parent.name)

    def test_command_invokes_the_skill_by_its_name(self):
        name = frontmatter(SKILL)["name"]
        self.assertIn(f"`{name}` skill", COMMAND.read_text())

    def test_command_and_skill_take_arguments(self):
        self.assertIn("$ARGUMENTS", COMMAND.read_text())
        self.assertIn("$ARGUMENTS", SKILL.read_text())
        self.assertIn("argument-hint", frontmatter(COMMAND))

    def test_skill_never_asks_for_artifacts(self):
        self.assertIn("Never create a file, an HTML artifact", SKILL.read_text())


if __name__ == "__main__":
    unittest.main()
