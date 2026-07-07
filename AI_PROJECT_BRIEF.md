# AI Project Brief: SQL Quest AI Coach

## Project Positioning

SQL Quest AI Coach is an AI-assisted interview training product for advanced SQL learners who already know basic SQL but lose focus when practice becomes dry, repetitive, and hard to self-diagnose.

The product does not use AI to simply reveal answers. Its AI value is diagnosis:

```text
advanced SQL challenge
-> browser SQLite judge
-> failure type classification
-> AI coach hint / review / interview follow-up
-> badcase log
-> evidence export for iteration and interview defense
```

## Stage Gate Summary

### Gate 1: Scenario and Real Demand

Judgment: Pass.

- User: advanced SQL interview candidate who can write basic SQL but struggles with advanced business SQL under interview conditions.
- Trigger: after a failed query, before checking the answer, or during post-question review.
- Failure cost: the learner cannot tell whether the mistake is syntax, join amplification, grain definition, window ordering, or business metric interpretation.
- Materials: 32 advanced SQL challenges, SQLite data, expected queries, hints, explanations, user SQL attempts, failure traces.
- Feedback loop: each failed attempt becomes a badcase with failure type and next action.

### Gate 2: AI Necessity

Judgment: Pass.

Rules can judge whether the SQL result matches. Rules cannot reliably coach the learner on:

- why the SQL is wrong
- what not to spoil
- how to explain the query in an interview
- what follow-up question an interviewer would ask
- which failure pattern keeps repeating across attempts

AI is used only at the fuzzy judgment and coaching layer. Deterministic SQL execution stays in SQLite.

### Gate 3: AI Product Chain

Architecture: Fixed Workflow with optional AI Coach.

```text
load challenge
-> user writes SQL
-> browser SQLite executes user query and expected query
-> result comparator classifies pass/fail
-> failure classifier assigns badcase type
-> AI Coach receives prompt, user SQL, challenge metadata, and badcase context
-> coach returns non-spoiler hint, review, or interview question
-> localStorage stores progress and badcases
-> evidence export produces offline project artifact
```

Key boundaries:

- SQL execution is local in browser.
- API Key is stored only in the user's browser localStorage.
- The repository does not contain secrets.
- AI Coach defaults to DeepSeek `deepseek-v4-flash`; local fallback still works when no API Key is configured.

### Gate 4: Evaluation Design

First evaluation target: end-to-end training usefulness after a failed SQL attempt.

Eval case fields:

```text
case_id
challenge_id
prompt
user_sql
expected_failure_type
coach_output
score_correctness
score_actionability
score_non_spoiler
score_interview_value
notes
```

MECE rubric:

- Diagnosis correctness: did the coach identify the right failure node?
- Actionability: does it give one next step the learner can do immediately?
- Non-spoiler control: does it avoid dumping the full answer too early?
- Interview value: does it improve explanation or defense ability?

Execution plan:

- Start with 20 failed attempts.
- Manually score coach outputs first.
- Then introduce LLM-as-a-judge only after the human rubric is stable.
- Use the same 20 cases to compare prompt versions.

### Gate 5: Badcase Iteration

Current product already records basic badcases:

- syntax error
- table or column misunderstanding
- result grain mismatch
- returned column mismatch
- join/window/business value mismatch

Recommended next deeper badcases:

1. The SQL result is wrong, but the coach gives a generic hint.
   - Chain node: coach prompt lacks failure trace.
   - Fix: include actual vs expected row count, schema focus, and challenge signal.
   - Retest: actionability score should improve.

2. The SQL is correct, but the learner still cannot explain it in an interview.
   - Chain node: success flow ends too early.
   - Fix: require a short interview-defense question after passing.
   - Retest: interview value score should improve.

### Gate 6: Evidence and Resume Boundary

Can safely claim:

- Built a browser-based SQL challenge prototype with local SQLite judging.
- Designed a DeepSeek-powered AI Coach workflow for non-spoiler hints, failure review, and interview follow-up.
- Added badcase logging and evidence export for offline evaluation.
- Defined an evaluation rubric for diagnosis quality, actionability, non-spoiler behavior, and interview value.

Should not claim unless later evidenced:

- Real users or production launch.
- Improved interview pass rate.
- A/B testing.
- Internal company data access.
- Model training or algorithm optimization.

## 3-7 Day Evidence Plan

Day 1:

- Run 10 questions yourself.
- Intentionally keep failed SQL attempts.
- Export `sql-quest-ai-evidence.json`.

Day 2:

- Create 20 eval cases from real attempts and manual edge cases.
- Label expected failure types.

Day 3:

- Score AI Coach outputs with the four-dimension rubric.
- Pick the lowest scoring dimension.

Day 4:

- Modify the coach prompt or context fields.
- Retest the same 20 cases.

Day 5:

- Write 2 badcase notes:
  - phenomenon
  - diagnosis
  - chain node changed
  - retest metric

Day 6-7:

- Record a 2-minute demo video.
- Add screenshots and one evaluation table to the GitHub README.

## Interview Defense

Likely question 1:

Why do you need AI if the SQL judge can already compare query results?

Defensible answer:

The judge only tells pass or fail. The AI layer addresses the ambiguous coaching problem: why the learner failed, what hint is useful without spoiling the answer, and how to turn the query into an interview explanation.

Likely question 2:

How do you prevent the AI Coach from just leaking answers?

Defensible answer:

The prompt separates hint, review, and answer modes. The default coach prompt asks for failure node, non-spoiler hint, and one next action. The answer remains a separate user action.

Likely question 3:

How would you evaluate whether this AI Coach is actually useful?

Defensible answer:

I would use failed SQL attempts as eval cases and score coach output on diagnosis correctness, actionability, non-spoiler control, and interview value. Then I would compare prompt versions on the same cases and inspect low-score badcases.
