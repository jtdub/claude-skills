---
name: engineering-workflow
description: Plan before code across modules. One branch and one PR per unit of work. Tests before API and UI. The spec wins over the prompt.
---

# Engineering workflow

## Plan first

Write a plan before you write code, when the change touches more than one module. Put it in
`docs/plans/<slug>.md`. Wait for approval. A change inside one module needs no plan.

## One unit of work, one branch, one pull request

Open one branch for each unit of work. Open one pull request from it. Do not carry an unrelated
fix along in the same branch. Open a second branch instead.

## Test order

Write the tests for the models and the service layer first. Land them before the API and before
the UI. A model with no test is not ready for a view.

## The spec wins

If the spec and the prompt disagree, follow the spec. Say which line of the spec you followed, and
say what the prompt asked for instead. Do not silently pick one.

## New dependencies

Do not add a dependency without a reason. Put one line in the pull request description: what the
dependency does, and why the standard library does not.

## Boundaries

Never bypass a service layer to make a test pass. Never disable a validator to make a test pass. If
a test cannot pass through the public path, the code is wrong or the test is wrong. Fix one of
them.
