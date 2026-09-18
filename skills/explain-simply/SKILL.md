---
name: explain-simply
description: Explain Like I'm Stupid. Short, picture-first, fixed-shape explanations in Bionic Reading, drawn inline in the terminal. Use when the user runs /elis, asks for an ELI5 or ELIS, asks to explain something simply, says they don't understand, or asks what was done or is about to be done in this session.
---

# Explain Like I'm Stupid

Topic: $ARGUMENTS

If the topic is empty, explain the last thing discussed in this session.

## Who is reading

The reader is stressed and has limited attention. Long narration, arguments or
walls of text make them lose track, lose interest, or get confused. They need:

- **The answer first.** No preamble, no restating the question.
- **The same shape every time.** Predictable structure is easier to process
  than a clever one. Never skip, reorder or rename the sections below.
- **Literal words.** No idioms, no metaphors that need decoding, no vague words
  ("basically", "sort of", "kind of", "just", "simply").
- **One idea per line.** Sentences of 15 words or fewer.
- **One answer.** Give the conclusion, not a debate. No "on the other hand",
  no list of pros and cons unless the user asked for a comparison.
- **Pictures over paragraphs.** A diagram or table beats a sentence.

## The shape

Always use these sections, in this order. Nothing before them, nothing after.

1. **In one line** — the whole answer in one sentence.
2. **Picture** — an ASCII diagram. If anything moves (data, requests, files,
   money, messages), draw the flow: boxes, arrows, direction of travel.
3. **Steps** — numbered, 3 to 6 steps, one line each.
4. **Words** — a table of any term the reader might not know:
   `| Word | Means |`. Leave this section out only if there are no such terms.
5. **Watch out** — at most 3 lines, only when something can go wrong or cost
   money. Leave it out when nothing can.

Keep the prose (everything outside diagrams and tables) under 120 words.

## When the topic is this session

For "what you did", "what you're about to do", "what just happened" and
similar, explain from what is actually in the conversation: commands run,
their output, files changed, plans shown.

- Only state what the session shows. If the evidence is not in context
  (for example the plan was never run, or the history was summarised), say so
  in one line. Never guess.
- In **Steps**, use this table instead of a numbered list:

  | # | What | Changes anything? | Can it be undone? |
  |---|------|-------------------|-------------------|

- Never soften danger to keep it simple. Anything that deletes, replaces,
  recreates, costs money or cannot be undone goes in **Watch out**, stated
  plainly, e.g. "This deletes the database and makes a new, empty one."

## Bionic Reading

Write every word of prose in Bionic Reading: bold the first half of the word,
rounded up.

| Letters | Bold | Example |
|---------|------|---------|
| 1 | 1 | **a** |
| 2 | 1 | **i**t |
| 3 | 2 | **th**e |
| 4 | 2 | **co**de |
| 5 | 3 | **pla**ns |
| 6 | 3 | **cha**nge |
| 7+ | half, rounded up | **webs**ite, **Terra**form |

Do not agonise over the exact letter. One letter either way reads the same.
A word with no bold prefix at all does not, so never skip one.

Words with an apostrophe count only the letters before it:
**Terra**form's, **do**n't.

This applies to headings, list items and table cells too.

Leave these plain:

- Acronyms of two or more capitals: DNS, AWS, IP.
- Numbers and punctuation.
- Anything inside code blocks, inline code, diagrams, commands, file paths or
  URLs. Markdown shows the `**` literally there and breaks alignment.

## Diagrams

- Draw them inline in the reply, inside a code block, with ASCII or Unicode box
  drawing.
- Never create a file, an HTML artifact or a published page for an explanation
  unless the user explicitly asks for one.
- Box labels are 1 to 3 words. Arrow labels say what crosses.
- Keep it to 12 lines and 6 boxes. A diagram that needs scrolling has failed.
  Draw the main path only and leave the rare cases out.

## Questions

Never ask a question in prose. If something blocks the explanation, use the
AskUserQuestion tool with real options, recommended option first.

## Example

The user asks: `/elis how does DNS work`

````
**I**n **on**e **li**ne

DNS **tur**ns **a** **webs**ite **na**me **in**to **th**e **num**ber (IP **addr**ess) **yo**ur **comp**uter **nee**ds.

**Pict**ure

```
you type          ┌──────────────┐   "where is      ┌──────────────┐
example.com ────► │ your computer│ ──example.com?─► │  DNS server  │
                  └──────────────┘                  └──────────────┘
                         ▲                                  │
                         └──────── "93.184.215.14" ─────────┘
```

**Ste**ps

1. **Yo**u **ty**pe **a** **na**me.
2. **Yo**ur **comp**uter **as**ks **a** DNS **ser**ver **whe**re **i**t **liv**es.
3. **Th**e **ser**ver **repl**ies **wi**th **a** **num**ber.
4. **Yo**ur **comp**uter **conn**ects **t**o **th**at **num**ber.

**Wor**ds

| **Wo**rd | **Mea**ns |
|------|-------|
| DNS | **A** **li**st **th**at **matc**hes **nam**es **t**o **numb**ers |
| IP **addr**ess | **Th**e **num**ber **th**at **fin**ds **a** **comp**uter |
````

There is no **Watch out** section in the example, because nothing in it can go wrong.
