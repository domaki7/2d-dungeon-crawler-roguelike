# /smisli — Improvement Brainstormer

Brainstorm and suggest improvements for Dungeon Descent. Investigate the codebase for a chosen category, present actionable ideas, and write selected ones to `todo.md`. Uses planning mode to ensure alignment before modifying todo.md.

## Step 1: Show Categories

Print the following exactly, then wait for the user to type a number:

```
--THESE ARE THE OPTIONS TO WORK UPON--

 1. Melee Combat — sword swings, hit feedback, combos, attack variety
 2. Ranged Combat — projectiles, aiming, arrow types, bow mechanics
 3. Enemy AI & Behavior — patrol patterns, group tactics, awareness, telegraphing
 4. Abilities & Cooldowns — new abilities, visual feedback, ability synergies
 5. VFX & Particles — hit effects, death effects, environmental particles
 6. Screen Effects — screen shake, flash, camera work, transitions
 7. Animation & Sprites — new animations, smoother transitions, idle variety
 8. Audio & Music — SFX variation, ambient sounds, music layers, dynamic audio
 9. HUD & Health Bars — enemy health bars, buff icons, damage direction indicators
10. Inventory & Equipment — stat comparison, sorting, tooltips, equipment preview
11. Menus & Navigation — pause menu, settings, class selection polish
12. Minimap & Info — room icons, legend, exploration tracking, fog of war
13. Items & Loot — item variety, set bonuses, cursed items, unique effects
14. Difficulty & Balance — scaling, elite enemies, challenge modifiers
15. Room & Level Design — room variety, environmental hazards, secrets, traps
16. Meta-Progression — unlocks, achievements, persistent upgrades, run history

Type a number to pick a category:
```

**Do not continue until the user replies with a number.**

## Step 2: Investigate & Suggest Improvements

Once the user picks a category:

1. Read the scripts, scenes, and resources relevant to that category. Explore the codebase thoroughly to understand what currently exists and what's missing.
2. Read `todo.md` from the project root. Note all existing tasks so you do not suggest duplicates.
3. Come up with **5-10 concrete, actionable improvements** for the chosen category. Each improvement should be specific enough to implement directly — not vague wishes. Ground them in what you actually found in the code.
4. Print a numbered list of improvements. Each entry should have a **bold title** and a brief description (one sentence). Example:

```
Here are the improvements I found for [Category]:

1. **Title** — Description of what to add/change and why
2. **Title** — Description of what to add/change and why
...

Type the numbers you want to add (comma-separated, e.g. 1,3,5):
```

**Do not continue until the user replies with their selection.**

## Step 3: Plan the todo.md Changes

Once the user picks improvements:

1. Call **EnterPlanMode** to enter planning mode
2. Read the current `todo.md`
3. Write a plan that shows exactly what will be added to `todo.md`:
   - Which existing `## Section` each improvement will be placed in
   - If a new section is needed, what it will be called and where it will go (before `## Future Ideas`)
   - The exact task text for each item: `- [ ] **Title** — Description`
   - Flag any potential duplicates with existing tasks
4. Call **ExitPlanMode** to present the plan for user approval

**Do not modify todo.md until the user approves the plan.**

## Step 4: Write to todo.md

Once the plan is approved:

1. Append selected improvements to the appropriate section(s) as planned
2. Do not duplicate tasks that already exist in `todo.md`
3. Confirm what was added and where
