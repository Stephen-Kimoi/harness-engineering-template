# Evaluator Rubric

<!-- L11: Use this to score a completed sprint before marking a feature as passing.
     Every dimension must reach the minimum threshold — a high score in one
     dimension does not compensate for a failing score in another.
     The evaluator scores against runtime evidence, not code review. -->

## Scoring

| Dimension | A — Pass | B — Warn | C — Fail | D — Block |
|-----------|----------|----------|---------|-----------|
| **Code correctness** | All tests pass, layer 3 passes | Main flow passes, edge cases skip | Partial pass; some tests fail | Build fails or layer 1 fails |
| **Architecture compliance** | Fully compliant with arch rules | Minor deviations; no new patterns | Obvious violations; pattern copied wrong | Serious violations; `make check-arch` fails |
| **Test coverage** | Main path + edge cases + e2e | Main path tests only | Skeleton tests (placeholder assertions) | No tests written |
| **Verification evidence** | All three layers pass with evidence | Layers 1–2 pass; layer 3 not required | Layer 1 only; no runtime verification | No verification run; agent self-declared |

**Minimum passing threshold:** every dimension must be A or B.
Any C or D in any dimension = sprint fails; generator receives the feedback and iterates.

---

## How to Use

1. Run the sprint's verification layers: `make verify-feature F=FXX`
2. Score each dimension based on the output — not based on the code's appearance
3. If all dimensions are A or B: feature transitions to `passing`
4. If any dimension is C or D: write specific, evidence-backed feedback

---

## Feedback Format

Feedback to the generator must be specific. Vague feedback produces vague fixes.

**Bad:** "The feature doesn't feel complete."

**Good:** "Dimension: Test coverage — C. The e2e scenario 'add item to cart' is stubbed with a `pending` call (line 42 of test/e2e/cart_test.exs). The scenario must execute the full user flow: browse → add → view cart → confirm total. See the sprint contract Evaluator Briefing for the edge cases to cover."

**Required elements in failure feedback:**
- Which dimension failed and what score it received
- The specific file, line, or output that shows the failure
- What the correct behavior should be (quote the sprint contract criterion)
- The exact command the generator should run to verify the fix

---

## Evaluator Calibration

If your evaluator dismisses real issues:
1. Read the evaluator's session trace (`.harness/traces/traces.jsonl`)
2. Find the decision point where its judgment diverged from the sprint contract
3. Update this rubric or the sprint contract to be more explicit at that decision point
4. Re-run the evaluation — rubrics improve through iteration, not upfront design
