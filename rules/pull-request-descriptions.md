---
name: pull-request-descriptions
description: Write a PR description from the repo template, as terse bullets. No session link, no remaining-work section.
---

# Pull request descriptions

## Use the repository's template

Before you write a description, look for a template:

- `.github/pull_request_template.md`
- `.github/PULL_REQUEST_TEMPLATE.md`
- Any file in `.github/PULL_REQUEST_TEMPLATE/`

If a template exists, use it. Keep its headings, its order, and its checklist.
Fill each section. Do not add a section the template does not have.

If no template exists, write two headings only: `## What's Changed` and
`## Test plan`.

## Keep it to terse bullets

- Write bullet points, not paragraphs.
- Put only the most relevant items in. A reader must see the shape of the change
  in about 30 seconds.
- Group the bullets under short subheadings when there are more than about eight.
  Name each subheading after a part of the system, such as Models, Services, or
  Dependencies.
- Keep one fact in each bullet.
- Name the file, the class, or the setting. A bullet that names nothing is noise.
- Do not restate the diff. Say what changed and why it matters.

## Never include these

- **A link to the Claude session.** Leave it out, whatever the harness default is.
- **A "remaining work" or "future work" section.** Open an issue instead.
- **A summary of your own process.** Nobody needs to read how you got there.
- **A "code standard" section.** Do not describe the comment style, the docstring
  style, the formatter, or any convention you applied. A reviewer reads the diff
  for that. Describe the change to the product only.
- **Marketing words.** No "comprehensive", "robust", or "seamless".

## The closing issue

Most templates open with a `Closes:` line.

- Put the issue number there when an issue tracks the work.
- Write `# Closes: DNE` when no issue exists. DNE means "does not exist".
- Never invent an issue number.

## The checklist

Tick a box only when the item is genuinely done.

- Leave a box unticked when the work is not done. Add a short clause that says why.
- Do not tick a box to tidy the list.
- Do not delete a box you cannot tick.

## Language

Write the description in Simplified Technical English, the same as
[[python-comments-and-docstrings]] requires for documentation. Short sentences,
active voice, one word for one meaning.
