# /obradi — Auto Brainstorm-and-Build

Chains `/smisli` and `/napravi` into one mostly-autonomous flow: Claude picks a category, brainstorms improvements, auto-selects a small batch, writes them to `todo.md`, then implements them — pausing only at the two real decision points (the `todo.md` plan and the implementation plan) and for deep-dive clarifying questions. Unlike `/smisli`/`/napravi` run separately, the user does not pick category/improvement/task numbers by hand.

## Step 1: Pick a Category

If `/obradi` was invoked with a numeric argument (e.g. `/obradi 5`), use that number directly against the list below. Otherwise, pick the category yourself: skim `todo.md` and the relevant scripts/scenes to find an area that's thin on existing tasks or has an obvious gap, then choose. State which category you picked and a one-sentence reason. **Do not wait for user input here.**

```
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
```

## Step 2: Investigate & Auto-Select Improvements

1. Read the scripts, scenes, and resources relevant to the chosen category. Explore thoroughly to understand what exists and what's missing.
2. Read `todo.md` from the project root. Note all existing tasks so you do not suggest duplicates.
3. Come up with **5-10 concrete, actionable improvements**, grounded in what you actually found in the code.
4. From those, select the **2-4 strongest ones** yourself — favor ideas that are well-scoped, clearly valuable, and implementable in one pass.
5. Print the full generated list with your picks marked, plus a one-sentence rationale for the picks. Example:

```
Category: [Category]

1. **Title** — Description
2. **Title** — Description [PICKED]
3. **Title** — Description
4. **Title** — Description [PICKED]
...

Picked 2/4 because: <one-sentence rationale>
```

**Do not wait for user input here.**

## Step 3: Plan the todo.md Changes (gate)

1. Call **EnterPlanMode**.
2. Read the current `todo.md`.
3. Write a plan showing exactly what will be added:
   - Which existing `## Section` each picked improvement goes into
   - If a new section is needed, its name and placement (before `## Future Ideas`)
   - The exact task text: `- [ ] **Title** — Description`
   - Any potential duplicates with existing tasks
4. Call **ExitPlanMode** to present the plan for approval.

**Do not modify todo.md until the user approves the plan.**

## Step 4: Write to todo.md

1. Append the approved items to the appropriate section(s).
2. Do not duplicate tasks that already exist.
3. Confirm what was added and where.
4. Keep track of exactly which items were just added — they are the working set for the rest of this flow.

## Step 5: Deep-Dive Questions

Do not start implementing yet. Thoroughly investigate the codebase, then ask the user detailed questions via `AskUserQuestion` about the items just added in Step 4. Ask about ALL of the following that are relevant:

1. **Scope & boundaries** — What exactly should be included vs excluded? Edge cases to handle or deliberately ignore?
2. **Behavior & feel** — How should it look/feel/behave? Specific values for timing, sizes, colors, intensities? Reference any existing similar systems?
3. **Integration points** — How should it interact with existing systems? Should it hook into EventBus signals? Which components need to know about it?
4. **Architecture choices** — New component, extend an existing one, or standalone script? New scene or added to existing scene?
5. **Asset requirements** — New sprites/SVGs, audio, shaders, or particles? Placeholders or should you create them?
6. **Configurability** — Which values go into GameConfigData? Reasonable defaults?
7. **Player experience** — Visual/audio feedback? How does the player discover or interact with this?

Ask 3-6 focused questions total (batch up to 4 per `AskUserQuestion` call). If multiple items were added, group related ones and ask combined questions rather than asking separately per item. Wait for answers before proceeding.

## Step 6: Plan the Implementation (gate)

1. Call **EnterPlanMode**.
2. Explore the codebase thoroughly — read the relevant scripts, scenes, and resources to understand existing patterns.
3. Write a detailed implementation plan covering:
   - Which files will be created or modified
   - What each change involves (new nodes, signals, exports, config values, etc.)
   - The order of implementation (dependencies first)
   - How the Step 5 answers are reflected in the plan
4. Call **ExitPlanMode** to present the plan for approval.

**Do not write any code until the user approves the plan.**

## Step 7: Implement

Once approved, for each item added in Step 4:

1. Implement it following the approved plan and the project's architecture and conventions from CLAUDE.md.
2. **Add all tunable values to `game_config_data.gd`:**
   - Every hardcoded gameplay value (speed, duration, damage, range, cooldown, size, color, etc.) MUST become an `@export var` in `scripts/config/game_config_data.gd`
   - Naming convention: `section_property_name` (e.g. `skeleton_speed`, `combat_hit_pause_duration`)
   - Group under the appropriate `@export_group()` (create a new group if needed); use `@export_subgroup()` for sub-categorization
   - Add a `##` doc comment above each exported var explaining what it controls, including units
   - Use the correct type and a sensible default value
   - Read these values from `GameConfig.config.<property>` in implementation scripts — never hardcode tunable numbers
3. Immediately update `todo.md`, changing `- [ ]` to `- [x]` for that item.
4. Continue to the next item.

After all items are done, output the following in order:

1. **Summary** — Brief summary of what was implemented.
2. **Test checklist** — 3-6 manual test items, golden path + key edge cases. Format:
   ```
   Things to test:
   - [ ] Attack an enemy and verify hit flash + screen shake
   - [ ] Check damage numbers appear and float upward
   ...
   ```
3. **Commit message** — A short, copy-pasteable commit message:
   ```
   Commit message: <message here>
   ```

**Important:** Do NOT run any git commands (add, commit, push, etc.) yourself. The user will handle git manually.
