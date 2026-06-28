# /napravi — Todo Task Implementer

Read the `todo.md` file in the project root and guide the user through selecting and implementing tasks. Uses planning mode to ensure alignment before writing any code.

## Step 1: Show Task Groups

1. Read `todo.md` from the project root
2. Parse all `## Section` headings as task groups
3. For each group, count the unchecked tasks (`- [ ]`)
4. Print the following text output (do NOT use AskUserQuestion):

```
--PICK AN OPTION TO START IMPLEMENTING--

1. Phase 1: Combat Juice Overhaul (8 remaining) — Make attacks feel impactful with VFX, particles, screen shake, and SFX
2. Phase 2: Status Effects System (6 remaining) — Add burn, poison, freeze, slow beyond the existing stun
...
```

Each line should have a brief commentary explaining what that group is about. Include every group from todo.md, skip groups with 0 unchecked tasks.

5. Wait for the user to type a number.

## Step 2: Show Individual Tasks

Once the user picks a group number:

1. List all unchecked (`- [ ]`) tasks within that group as a new numbered list
2. Add an extra option at the end: **"All of the above"**
3. Print the list as plain text (do NOT use AskUserQuestion). Example:

```
--PICK TASKS TO IMPLEMENT--

1. Parameterize hit feedback — Add @export shake/pause values to hitbox.gd
2. Wire hit flash shader — Create vfx_helper.gd, call from hurtbox.gd
3. All of the above

Pick a number:
```

4. Wait for the user to type a number.

## Step 3: Deep-Dive Questions

After the user selects tasks, **do NOT start implementing yet**. First, thoroughly investigate the codebase to understand what exists, then ask the user detailed questions about the implementation using AskUserQuestion. Ask about ALL of the following that are relevant:

1. **Scope & boundaries** — What exactly should be included vs excluded? Any edge cases to handle or deliberately ignore?
2. **Behavior & feel** — How should it look/feel/behave? Specific values for timing, sizes, colors, intensities? Reference any existing similar systems?
3. **Integration points** — How should it interact with existing systems? Should it hook into EventBus signals? Which components need to know about it?
4. **Architecture choices** — Should this be a new component, extend an existing one, or be a standalone script? New scene or added to existing scene?
5. **Asset requirements** — Does it need new sprites/SVGs, audio, shaders, or particles? Should placeholders be used or should you create them?
6. **Configurability** — Which values should go into GameConfigData? What are reasonable defaults?
7. **Player experience** — Should there be visual/audio feedback? How does the player discover or interact with this feature?

Ask 3-6 focused questions per task (use AskUserQuestion, batch up to 4 questions per call). Adapt questions to what's relevant — don't ask generic questions, ask specific ones grounded in what you found in the code. Wait for answers before proceeding.

If "All of the above" was selected, group related tasks and ask questions that cover them together rather than asking separately for each task.

## Step 4: Plan

After all questions are answered:

1. Call **EnterPlanMode** to enter planning mode
2. Explore the codebase thoroughly — read the relevant scripts, scenes, and resources to understand existing patterns
3. Write a detailed implementation plan that covers:
   - Which files will be created or modified
   - What each change involves (new nodes, signals, exports, config values, etc.)
   - The order of implementation (dependencies first)
   - How the user's answers from Step 3 are reflected in the plan
4. Call **ExitPlanMode** to present the plan for user approval

**Do not write any code until the user approves the plan.**

## Step 5: Implement

Once the plan is approved, for each selected task:

1. Implement the task following the approved plan and the project's architecture and conventions from CLAUDE.md
2. After completing the task, immediately update `todo.md` by changing `- [ ]` to `- [x]` for that specific item
3. Continue to the next selected task

After all selected tasks are done, give a brief summary of what was implemented.
