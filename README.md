# mikes-elis

**Explain Like I'm Stupid** — a Claude Code skill and `/elis` command that
explains things in a way I can actually process.

Built by a neurodivergent developer to suit his needs. If your brain works in a
similar way, help yourself.

## What it does

Every explanation comes back in the same shape, every time: one-line answer,
ASCII picture, short numbered steps, a table of words, and a "watch out" section
only when something can actually go wrong. Prose is written in
[Bionic Reading](https://bionic-reading.com) — the first half of each word is
bold, which gives the eye a fixation point per word.

Nothing is written to a file. No HTML artifacts, no browser tabs. Everything is
drawn in the terminal where you are already looking.

Why these choices:

| Rule | Reason |
|------|--------|
| Answer first, 120 words of prose, one idea per line | Long narration loses the reader |
| The same five sections, always in the same order | A predictable shape takes no effort to parse |
| Literal words, no idioms, no metaphors that need decoding | Ambiguity costs more than length |
| One answer, not a debate | Arguments and options lists are exhausting to read |
| Diagrams and tables instead of paragraphs | A picture is checkable, a paragraph is not |
| Bionic bolding on prose | Easier to hold onto the line when attention slips |

## Install

As a Claude Code plugin (updates through `/plugin`):

```
/plugin marketplace add stratoghost/mikes-elis
/plugin install mikes-elis@mikes-elis
```

A project can make it a dependency for everyone who trusts the repo, in its
`.claude/settings.json`:

```json
"extraKnownMarketplaces": {
  "mikes-elis": { "source": { "source": "github", "repo": "stratoghost/mikes-elis" } }
},
"enabledPlugins": { "mikes-elis@mikes-elis": true }
```

Or by hand, as symlinks (use one method, not both, or the skill loads twice):

```bash
git clone https://github.com/stratoghost/mikes-elis.git
cd mikes-elis
./install.sh
```

This symlinks the skill and the command into `~/.claude`, so `git pull` updates
them. It will not overwrite anything it did not create. To remove it, run
`./uninstall.sh`.

## Use

```
/elis how does DNS work
/elis what you just did
/elis what you're about to do
/elis                          # explains the last thing discussed
```

Claude also reaches for the skill on its own when you say things like "explain
that simply" or "I don't understand this".

`/elis what you just did` gets a different Steps section — a table of every step
with "changes anything?" and "can it be undone?" columns, because that is the
part worth knowing:

```
| # | What                         | Changes anything?   | Can it be undone?          |
|---|------------------------------|---------------------|----------------------------|
| 1 | `cp config.yml config.yaml`  | Yes, new file       | Yes, delete it             |
| 2 | `rm config.yml`              | Yes, file gone      | Yes — `git checkout`       |
```

It explains only what the session actually shows. If the evidence is not there,
it says so instead of guessing, and it never softens anything that deletes data,
costs money or cannot be undone.

## Layout

```
skills/explain-simply/SKILL.md   all the rules; Claude can also trigger this itself
commands/elis.md                 the /elis command; a thin wrapper that calls the skill
install.sh, uninstall.sh         symlink them into ~/.claude, or remove them
tests/                           offline tests, plus a live eval
```

## Tests

```bash
tests/run.sh          # shellcheck, Bionic rule, install and uninstall. No tokens.
tests/eval.sh "TOPIC" # runs /elis through Claude in a temp project. Uses tokens.
```

`tests/bionic.py` is the reference implementation of the bolding rule. The tests
check the worked example in `SKILL.md` against it, so the example cannot drift.

The live eval checks the real output: correct sections, a diagram of 15 lines or
fewer, no HTML, prose length, and that fewer than 5% of words break the Bionic
rule. A model cannot count letters exactly, so a word bolded one letter either
way passes; a word with no bold prefix, or a bolded acronym, does not.

## Licence

MIT
