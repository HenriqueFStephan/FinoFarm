# FINOFARM
## Master Game Design & Autonomous Development Charter

**Project:** FinoFarm
**Genre:** Stylized 3D farming simulation, business management and character management
**Primary platform:** PC, targeting Steam
**Secondary platform:** Web browser
**Development engine:** Godot 4, subject to technical validation
**Repository:** https://github.com/HenriqueFStephan/FinoFarm
**Project ambition:** Commercial-quality independent game

---

# PART I — GAME VISION

## 1. The mission

Create FinoFarm, a visually engaging, mechanically rich farming and business-management game inspired by:

- **FarmVille 2:** Accessible farm management, inviting 3D visuals, intuitive interactions, charming characters, customization, crafting, and rewarding progression.
- **Pot Farm: Grass Roots:** The broad thematic inspiration of a cannabis-industry business simulation, adapted into a fictional, abstract management game rather than a real-world production guide.
- **Fallout Shelter:** Character recruitment, individual statistics, worker specialization, progression, and strategic task assignment.
- **Modern automation and management games:** Resource planning, production dependencies, infrastructure upgrades, and increasingly sophisticated management challenges.

These games are references, not templates to duplicate.

FinoFarm must establish its own identity, mechanics, visual assets, interface, characters, and progression systems.

The goal is to build a game that is immediately approachable but develops meaningful depth as players progress.

**The player fantasy:** Start with a small, underdeveloped farm, grow a distinctive agricultural enterprise, assemble a talented team, construct impressive facilities, optimize production systems, and expand into a thriving business.

The gameplay should reward thoughtful decisions, creativity, planning, and experimentation.

## 2. The five design pillars

### Pillar 1 — A living, beautiful farm

The farm must feel like an actual place, not simply a collection of UI buttons.

Players should be able to:
- Navigate a colorful, stylized 3D environment.
- Place and customize buildings, paths, plots, decorations, and infrastructure.
- Watch characters perform their assigned jobs.
- Observe production facilities visibly operating.
- See seasons, time of day, and environmental conditions represented visually.
- Expand and personalize their property.

Interactions should be intuitive, responsive, and satisfying.

### Pillar 2 — Meaningful economic progression

The game must feature an interconnected fictional economy.

Players acquire and manage abstract agricultural resources, operate processing facilities, fulfill orders, and reinvest earnings.

FinoFarm's fictional cannabis-industry theme may inspire its agricultural identity and product categories, such as textiles, industrial goods, and fictional wellness products.

However, game mechanics must remain abstract: do not implement realistic cultivation instructions, drug extraction procedures, dosage guidance, or real-world controlled-substance production methods.

Production should be represented through game-friendly inputs, timers, building levels, quality grades, and fictional recipes.

As the player's operation expands, strategic planning should become increasingly valuable.

### Pillar 3 — Characters that matter

Employees are not decorative NPCs.

Every worker has attributes, personalities, specialties, preferences, and development potential.

Hiring the right character for the right role should influence efficiency, reliability, morale, and overall farm performance.

The best possible team should depend on the player's strategy, rather than a single universally superior set of characters.

### Pillar 4 — Automation as progression

Early gameplay involves direct player interaction.

As the farm grows, the player can unlock systems that automate repetitive actions.

Automation should make the game evolve from a hands-on farming experience into a broader management simulation.

The player should spend less time repeating basic actions and more time making strategic decisions.

### Pillar 5 — A world that responds to decisions

Different starting locations should create different gameplay experiences.

Climate categories, seasons, land prices, infrastructure availability, and local demand should influence business strategy.

These are fictionalized gameplay variables rather than geographically accurate agricultural instructions.

Players choosing different starting regions should face distinct opportunities and challenges.

---

# PART II — CORE GAMEPLAY

## 3. Main gameplay loop

The fundamental gameplay loop is:

**Plan → Operate → Produce → Fulfill Orders → Earn → Improve → Expand → Automate**

Each stage should produce visible or mechanical feedback.

### Early game

The player:
1. Creates a farm.
2. Selects a world region.
3. Receives a starter property.
4. Learns camera controls and farm interactions.
5. Places the first fictional crop plots.
6. Completes a simple harvesting interaction.
7. Uses a basic processing workshop.
8. Fulfills an introductory contract.
9. Earns the first income.
10. Hires the first worker.
11. Unlocks an upgrade.

This sequence must be implemented as a guided, playable tutorial rather than disconnected demonstrations.

### Mid-game

The player expands into:
- Multiple production buildings.
- A larger employee team.
- Specialized character assignments.
- New fictional product categories.
- More complicated orders.
- Infrastructure improvements.
- Automated production stations.
- Strategic resource and financial management.

### Late game

The player manages:
- Large integrated facilities.
- Advanced automation.
- Multiple production chains.
- Specialized management teams.
- Large contracts and regional markets.
- Research and development.
- Multiple properties and expansion projects.
- Long-term business objectives.

Late-game success should depend on organizational decisions rather than repetitive clicking.

---

## 4. Main navigation and game flow

The initial navigation must include at least:

**Main Menu → My Farms → Farm Selector → New Farm → World Map → Location Selection → New Farm Initialization → Interactive Tutorial → Playable Farm**

### Main menu

Create a polished 3D main menu.

The background should show a lively animated farm environment with moving workers, environmental motion, and subtle production activity.

Main actions:

- Continue
- My Farms
- New Game
- Settings
- Credits
- Exit

The menu should feel like the opening screen of a finished PC game.

### Farm selector

Display existing farms as visually attractive save cards.

Each card should include:
- Farm name.
- Starting region.
- Farm level.
- Screenshot or thumbnail.
- Current funds.
- Total playtime.
- Last save date.

Allow multiple independent farms.

### New farm creation

Players select:
- Farm name.
- Starting region.
- Optional farm appearance.
- Difficulty preset, if implemented.
- New game settings.

### World map

Display a navigable world map with stylized regional markers.

The player can select a region and view:
- Climate archetype.
- Seasonal variation.
- Property cost.
- Local economic profile.
- Infrastructure difficulty.
- Special advantages.
- Challenges.
- Recommended gameplay style.

Example starting choices:

**Canada — Northern Homestead**
- Cooler visual setting.
- Pronounced seasons.
- Indoor-facility management emphasis.
- Higher infrastructure upkeep in the fictional game economy.

**Brazil — Tropical Valley**
- Vibrant environment.
- Frequent weather changes.
- Strong seasonal-event opportunities.
- Different infrastructure and logistics tradeoffs.

**Netherlands — Innovation Plains**
- Compact available land.
- Advanced technology progression.
- High-cost infrastructure.
- Strong research-oriented progression.

**Mediterranean Region — Golden Fields**
- Dry, golden scenery.
- Seasonal resource challenges.
- Tourism and premium-market opportunities.
- Attractive decorative building options.

These are illustrative balancing concepts, not real agricultural or legal claims.

All regional bonuses and penalties must be balanced for gameplay.

The system must allow new regions to be added through structured data without rewriting fundamental gameplay logic.

### Tutorial

The first tutorial should introduce the game naturally through character interaction.

Example tutorial storyline:

The player inherits or acquires a neglected farm. A friendly local advisor introduces the region, existing buildings, and basic business opportunities.

Tutorial objectives:
1. Inspect the farm.
2. Learn camera controls.
3. Restore a damaged field.
4. Complete an introductory production cycle.
5. Collect goods.
6. Deliver the first order.
7. Open the finances panel.
8. Hire a farmhand.
9. Assign a job.
10. Purchase an upgrade.

The tutorial must allow the player to experience the game's central loop.

Use contextual prompts, visible highlights, animated indicators, and character dialogue rather than excessive text.

---

# PART III — FARM MANAGEMENT

## 5. Interactive farm world

The farm should use a stylized 3D isometric or three-quarter perspective.

Players must be able to:
- Pan and zoom the camera.
- Rotate the camera where appropriate.
- Select objects.
- Move around the farm.
- Place buildings on a logical grid.
- Move or remove supported structures.
- Inspect buildings and characters.
- Open context-sensitive interactions.

### World presentation

The environment should include:
- Terrain variation.
- Roads and paths.
- Decorative vegetation.
- Fences and property boundaries.
- Functional buildings.
- Dynamic characters.
- Ambient animations.
- Appropriate lighting.
- Environmental sound.
- Weather and seasonal presentation.

Avoid producing a flat application with clickable HTML panels in place of an explorable game world.

## 6. Crop and resource management

Implement a fictional, data-driven agricultural simulation.

Each resource has game-oriented properties such as:
- Production category.
- Growth stage.
- Game-cycle duration.
- Base yield.
- Quality grade.
- Resource requirements.
- Visual growth states.
- Seasonal modifier.
- Market value.

The system must support multiple crop and resource categories.

The player should see visual changes while a plot progresses through its growth states.

Harvesting must produce clear animations, particle effects, sound feedback, and inventory updates.

For the initial version, use a limited set of abstract fictional resources to demonstrate the system without implementing real-world cultivation protocols.

## 7. Production and crafting

Different buildings transform abstract resources into fictional commercial goods.

Example building categories:
- Basic Workshop.
- Textile Studio.
- Packaging Center.
- Wellness Goods Workshop.
- Quality Laboratory.
- Distribution Center.
- Research Facility.

Every production building should have:
- Building level.
- Production slots.
- Capacity.
- Upgrade options.
- Operating costs.
- Worker assignments.
- Production progress.
- Animated operating states.

Complex products may depend on goods created by other buildings.

Create meaningful supply-chain decisions without overwhelming the player during the first hours.

## 8. Economy and commerce

Build an integrated virtual economy.

Include:
- Currency.
- Construction expenses.
- Building upkeep.
- Worker salaries.
- Inventory.
- Orders.
- Production costs.
- Profit calculation.
- Business reputation.
- Unlockable contracts.

### Order board

Take inspiration from FarmVille 2's accessible order system.

Present a board containing customer requests with:
- Product icons.
- Required quantities.
- Rewards.
- Availability.
- Completion progress.

Completing contracts unlocks new opportunities.

### Market evolution

Later versions may introduce:
- Regional markets.
- Demand fluctuations.
- Customer preferences.
- Contract specialization.
- Premium product categories.
- Business partnerships.

Balance the economy to prevent either uncontrolled money accumulation or excessive grind.

---

# PART IV — EMPLOYEES AND CHARACTERS

## 9. Employee system

Create an employee management system inspired by Fallout Shelter's character specialization.

Each employee has a persistent identity.

### Core attributes

Use six primary game attributes, initially ranging from 1 to 10.

**Efficiency:** General task completion performance.

**Technical Skill:** Ability with equipment and advanced facilities.

**Creativity:** Contribution to research and product innovation.

**Organization:** Inventory, logistics, and task-management performance.

**Social Skill:** Customer relationships, training, and team collaboration.

**Adaptability:** Performance across changing environments and assignments.

These attributes should meaningfully influence simulated task outcomes.

Do not make the system purely cosmetic.

### Example character

**Alex Morgan**

Role: Junior Technician

Attributes:
- Efficiency: 6
- Technical Skill: 8
- Creativity: 4
- Organization: 5
- Social Skill: 3
- Adaptability: 7

Traits:
- Quick Learner.
- Prefers Technical Work.

The player should quickly understand why assigning Alex to a workshop may be more effective than assigning Alex to customer relations.

### Character development

Employees can:
- Gain experience.
- Improve attributes.
- Develop specializations.
- Unlock traits.
- Receive training.
- Change responsibilities.
- Develop preferences and relationships.

### Character AI

Characters should visibly move around the farm.

Implement navigation and a task-based state machine.

Example states:
- Idle.
- Walking.
- Working.
- Delivering.
- Resting.
- Training.

Workers should not simply disappear into menus when assigned tasks.

Their actions must be represented through in-world movement and animation when practical.

## 10. Hiring and team management

Create a recruitment interface with character portraits or 3D previews.

Display:
- Candidate background.
- Attributes.
- Special abilities.
- Salary.
- Preferred jobs.
- Potential for development.

Characters may have different strengths and weaknesses.

The hiring system should involve meaningful decisions.

Later features may include:
- Team synergy.
- Leadership roles.
- Employee satisfaction.
- Employee training.
- Job specialization.
- Staff scheduling.

Avoid unnecessary complexity during the first playable milestone.

---

# PART V — AUTOMATION AND PROGRESSION

## 11. Automation systems

Automation is a central progression mechanic, not a minor upgrade.

The player should gradually move through three operational stages.

### Stage 1 — Manual management

The player handles basic operations directly.

### Stage 2 — Employee delegation

Employees perform assigned jobs.

Efficiency depends on attributes, equipment, and task priorities.

### Stage 3 — Integrated automation

Advanced infrastructure automates compatible tasks.

The player can configure:
- Production priorities.
- Assignment rules.
- Inventory thresholds.
- Delivery schedules.
- Facility operating modes.

The automation interface should be powerful but understandable.

Use visual flows and readable indicators rather than requiring players to understand programming.

## 12. Research and technology

Implement a technology progression system.

Research unlocks:
- New buildings.
- Production improvements.
- Storage capacity.
- More efficient logistics.
- New fictional product categories.
- Employee training.
- Automation technology.
- Farm expansion.

The research tree should present meaningful alternatives rather than a simple linear upgrade sequence.

Some decisions may reflect the player's preferred business model.

## 13. Goals and progression

Progression should use multiple systems.

Examples:
- Farm level.
- Business reputation.
- New building unlocks.
- Regional opportunities.
- Character advancement.
- Technology research.
- Farm expansion.
- Milestone objectives.

Every major unlock should have an identifiable gameplay benefit and visual representation.

Avoid designing progression solely around waiting for timers.

---

# PART VI — VISUAL DESIGN AND ANIMATION

## 14. Art direction

**Target visual style: Cozy Stylized 3D**

Use FarmVille 2 as inspiration for its approachable isometric presentation, but develop FinoFarm's own art direction.

### Visual characteristics

- Stylized 3D models.
- Rounded, friendly geometry.
- Readable silhouettes.
- Expressive characters.
- Soft environmental lighting.
- Colorful, cohesive materials.
- Attractive vegetation.
- Distinctive production buildings.
- High-quality, readable interface elements.
- Pleasant animation and interaction feedback.

### Color language

Use:
- Rich natural greens for the environment.
- Warm earth tones for paths and agricultural structures.
- Cream and neutral colors for interface surfaces.
- Muted teal and blue for technology-oriented buildings.
- Warm amber for rewards and progression.
- Distinct accent colors for player interactions.

The palette must remain cohesive across menus, buildings, characters, and environment assets.

### Visual differentiation

Agricultural buildings should feel rustic and welcoming.

Advanced technology buildings should feel clean, modern, and sophisticated.

As the farm develops, its visual identity should evolve naturally.

### Required artistic consistency

Do not mix:
- Photorealistic characters with cartoon environments.
- Unrelated low-poly styles.
- Inconsistent texture resolutions.
- Random asset packs with incompatible visual languages.
- Placeholder primitive meshes presented as final art.

Establish and document an art bible before large-scale asset production.

## 15. Character design

Characters should have:
- Consistent proportions.
- Recognizable silhouettes.
- Expressive faces.
- Distinguishable outfits.
- Role-related accessories.
- Properly defined materials.
- Rigged skeletons.
- Reusable animation systems.

Aim for an art style that balances visual charm with efficient real-time rendering.

Characters must remain readable from the primary game camera.

### Animation requirements

Implement animations such as:
- Idle.
- Walking.
- Carrying objects.
- Celebrating.
- Resting.
- Interacting with equipment.

Animations must transition smoothly and correspond to actual gameplay actions.

Characters should not simply slide across the terrain or remain motionless while supposedly working.

## 16. Asset pipeline

Use Blender or another suitable professional asset-creation tool for 3D production.

Where useful, agents may create models through:
- Scripted procedural geometry.
- Parametric modeling.
- Asset-generation tools.
- Appropriately licensed third-party source assets.
- Modifications to existing approved assets.

Maintain editable original files.

Export optimized engine-compatible assets, preferably using glTF/GLB where appropriate.

For every major asset, record:
- Unique asset identifier.
- Source file location.
- Export location.
- Author or generation method.
- External source URL, if applicable.
- License and commercial-use permissions.
- Materials and textures.
- Polygon count where relevant.
- Animation and skeleton dependencies.
- Intended game scenes.
- Validation status.

Do not import untrusted executable code or unsafe downloads.

## 17. Visual quality assurance

Visual quality must be tested, not assumed.

Build representative game scenes for evaluating:
- Characters.
- Buildings.
- Lighting.
- Materials.
- Animation.
- Effects.
- UI components.

For major visual features:
1. Generate the asset.
2. Import it into the actual game engine.
3. Run the appropriate scene.
4. Capture screenshots.
5. Inspect appearance and functionality.
6. Correct inconsistencies.
7. Approve or reject against the art bible.

When supported, collect animation recordings or gameplay videos.

A model file existing in the repository does not prove that the asset works in-game.

---

# PART VII — TECHNICAL ARCHITECTURE

## 18. Game engine

The default architectural choice is Godot 4.

Use GDScript for gameplay unless another language is demonstrably better for a specific subsystem.

The agent must validate:
- The installed engine version.
- Desktop build compatibility.
- Browser export constraints.
- Rendering compatibility.
- Asset import support.
- Testing and automation tools.

Prefer the Godot renderer and engine features that maintain a realistic route to HTML5 compatibility.

Desktop functionality has priority for the first milestone.

Do not substitute a browser-based TypeScript/CSS application for the actual game.

Supporting web applications are permitted for tooling and management purposes.

## 19. System architecture

Separate major responsibilities into clear systems.

Recommended domains:
- Game state and lifecycle.
- Save management.
- World and region configuration.
- Farm construction and placement.
- Inventory and resources.
- Production simulation.
- Economy and contracts.
- Character management.
- Task scheduling.
- Automation.
- Research and progression.
- User interface.
- Audio.
- Animation and presentation.

Use data-driven definitions so content can be expanded without repeatedly modifying the engine's core logic.

Define stable interfaces between systems.

Avoid excessive architecture that prevents rapid iteration.

## 20. Persistence

Support multiple farms and independent saves.

Save data should include:
- Farm identity.
- Selected region.
- World state.
- Buildings.
- Inventory.
- Currency.
- Characters and assignments.
- Upgrades.
- Research.
- Tutorial progression.
- Simulation state.

Implement schema versioning and basic migration strategies.

Test save/load consistency.

## 21. Simulation

Separate simulation logic from visual presentation.

Game economy and progression should be testable without rendering a full scene.

Use deterministic or seeded simulation where practical.

Define clearly how timers, progression, and background processes operate.

Avoid systems whose correctness depends on unpredictable frame rates.

## 22. Performance

Establish explicit performance budgets.

The target is smooth gameplay on reasonably specified PC hardware.

Optimize:
- Draw calls.
- Scene complexity.
- Character updates.
- Pathfinding.
- Asset sizes.
- Texture memory.
- Loading behavior.

Performance must be measured using representative scenes.

Do not prematurely optimize systems that are not yet implemented, but avoid known architectural bottlenecks.

---

# PART VIII — AUTONOMOUS MULTI-AGENT DEVELOPMENT

## 23. Operating model

Develop FinoFarm as a coordinated, long-running software project.

Use Cursor Projects when available.

The Project Coordinator acts as the technical producer and development manager.

The coordinator does not need to implement every task directly.

Its responsibilities include:
- Understanding the full project vision.
- Maintaining the roadmap.
- Decomposing work into executable tasks.
- Assigning work to suitable agents.
- Managing dependencies.
- Preventing duplicate implementation.
- Coordinating integration.
- Tracking quality.
- Presenting significant decisions to the human project director.

The human user is the Product Director and has final authority over major design choices.

Routine implementation decisions may be delegated.

## 24. Specialized agent roles

Establish specialized agents where they increase productivity.

### Game Architecture Agent

Responsible for:
- Engine structure.
- Core systems.
- Interface contracts.
- Cross-system integration.
- Performance architecture.

### Gameplay Design Agent

Responsible for:
- Gameplay loops.
- Progression.
- Economy balancing.
- Contracts.
- Game configuration.

### Character Systems Agent

Responsible for:
- Employee statistics.
- Recruitment.
- Assignment systems.
- Character progression.
- Task AI.

### 3D Art Agent

Responsible for:
- Modeling.
- Materials.
- Textures.
- Environmental art.
- Asset exports.

### Animation Agent

Responsible for:
- Character skeletons.
- Animation clips.
- State machines.
- Animation integration.

### UI/UX Agent

Responsible for:
- Navigation.
- HUD.
- Game menus.
- Interaction feedback.
- Interface consistency.

### Testing and QA Agent

Responsible for:
- Test design.
- Automated validation.
- Regression detection.
- Visual inspection.
- Performance testing.

### Build and Release Agent

Responsible for:
- Versioning.
- Continuous integration.
- Packaging.
- Platform builds.
- Release validation.

Do not create agents solely to maximize the number of active workers.

Use parallel agents when their outputs and responsibilities can be clearly separated.

## 25. Shared task-management system

Maintain an accessible, persistent development backlog.

Use GitHub Issues and pull requests, or an equivalent tracked workflow, for durable task management.

Every significant task must record:
- Unique task ID.
- Title.
- Description.
- Assigned agent.
- Status.
- Dependencies.
- Acceptance criteria.
- Execution environment.
- Branch.
- Expected output artifacts.
- Testing requirements.
- Integration status.

### Task ownership

Before starting a task, every agent must check whether it is already assigned or being implemented.

Agents should claim work using a coordinated process.

Do not create parallel implementations of the same feature unless explicitly requested as alternative experiments.

If multiple agents need the same asset or subsystem, agree on an interface first.

### Dependencies

Tasks must form a dependency graph.

Example:

Character Specification
→ Character Model
→ Rigging
→ Animation
→ Engine Import
→ Gameplay Integration
→ Visual QA

Parallelize independent work, not tightly dependent steps without coordination.

## 26. Local and cloud delegation

Select the best execution environment for each task.

**Local Agent:** Work requiring the user's installed tools, project files, GPU, graphical environment, or interactive testing.

**Cloud Agent:** Independent implementation, architecture research, automated tests, and tasks that can execute reliably in a remote environment.

**Parallel Subagents:** Independent tasks with explicit interfaces and low integration risk.

**Specialist Tool Workflow:** Work requiring Blender, game-engine automation, rendering, or external tools.

The coordinator should delegate tasks automatically when the necessary capabilities and permissions are available.

If direct delegation is unavailable, it must produce a complete, ready-to-use handoff prompt.

The handoff must include:
- Task ID.
- Target agent.
- Objective.
- Context.
- Branch.
- Input files.
- Dependencies.
- Required outputs.
- Acceptance criteria.
- Verification commands.
- Integration procedure.

The coordinator must record that a handoff was prepared, rather than falsely claiming that the task is being executed.

## 27. Shared knowledge and context

Important project knowledge must be persisted in version-controlled files.

Maintain:
- Game Design Document.
- Art Bible.
- Technical Architecture Document.
- Roadmap.
- Asset Registry.
- Interface Contracts.
- Task Backlog.
- Architecture Decision Records.
- Testing Strategy.
- Known Issues.
- Build Instructions.

Agents must read the relevant documents before implementing related functionality.

Important decisions must survive agent context resets and different development sessions.

Cursor's shared project context can supplement, but must not replace, durable repository documentation.

## 28. Reusable skills

Create project-specific Agent Skills for:

1. Godot scene construction.
2. Blender procedural modeling.
3. Character rigging and animation export.
4. Asset import validation.
5. Gameplay feature implementation.
6. Simulation test generation.
7. Visual regression testing.
8. Save/load validation.
9. Project status reporting.
10. Cloud-agent task handoffs.
11. Build and export verification.

Each skill should contain practical steps, scripts, examples, known constraints, and validation commands.

Avoid vague instructions that merely describe desirable behavior.

## 29. GitHub and branching

Use the existing GitHub repository.

Inspect the repository before modifying it.

Preserve valuable existing work.

Use:
- Feature branches.
- Pull requests.
- Automated checks.
- Clear commit history.
- Protected integration workflows where available.

Avoid multiple agents directly modifying the same working tree.

Use Git LFS or appropriate storage for large binary assets.

Do not merge work that fails required validation.

Human approval is required before destructive repository actions, major architecture replacement, significant external expenditure, or publishing releases.

## 30. Continuous integration and validation

Establish automated validation as early as possible.

The project should support:
- Headless engine import checks.
- Syntax and resource validation.
- Simulation unit tests.
- Save/load tests.
- Scene-loading checks.
- Asset integrity checks.
- Desktop build checks.
- Browser build checks when applicable.

Visual tests should be performed in a suitable graphical environment.

Require evidence of actual successful execution.

Never report tests as passing unless they were run.

---

# PART IX — QUALITY AND AUTONOMY

## 31. Definition of done

A feature is finished only when:

1. It works within the actual game.
2. It satisfies its documented acceptance criteria.
3. It integrates with related systems.
4. Its visuals match the established art direction.
5. Relevant animations function correctly.
6. Tests pass.
7. The game loads and runs successfully.
8. Any required visual inspection is completed.
9. No known critical regression remains.
10. Documentation and task status are updated.

Temporary assets must be labeled clearly.

Placeholder functionality must not be described as finished.

A successful compilation is not equivalent to a successfully completed game feature.

## 32. Production quality over superficial completion

Do not optimize for the appearance of rapid task completion.

Avoid:
- Static illustrations substituted for playable scenes.
- Primitive placeholder characters passed off as final assets.
- Menus that have no underlying systems.
- Hard-coded demonstrations presented as scalable architecture.
- Features that cannot be tested.
- Unnecessary code generation.
- Artificially inflated amounts of code.
- Incomplete features incorrectly marked complete.

Prefer a smaller, coherent, polished playable experience over a large set of disconnected systems.

## 33. Proactive decision-making

Do not depend on the user providing every technical instruction.

Actively identify:
- Missing gameplay requirements.
- Architecture risks.
- Visual inconsistencies.
- Better workflows.
- Parallelizable tasks.
- Automation opportunities.
- Performance concerns.
- Missing tests.
- Potential design improvements.

Research relevant documentation and established game-development techniques when helpful.

Present significant alternatives with advantages, disadvantages, and a recommendation.

Routine low-risk decisions should not unnecessarily interrupt development.

## 34. Autonomous execution

For every milestone:

1. Review current project state.
2. Determine the most valuable unblocked work.
3. Plan tasks and dependencies.
4. Delegate independent work.
5. Implement functionality.
6. Generate or integrate necessary assets.
7. Execute tests.
8. Run the game.
9. Inspect results.
10. Repair defects.
11. Review integration.
12. Update documentation and backlog.
13. Continue with the next approved task.

Continue executing work while the relevant agent session, runtime, permissions, and resources allow.

If execution is interrupted, persist state and prepare a resumable handoff.

Do not assume an agent can run indefinitely or automatically resume unless its execution platform supports that behavior.

## 35. Project reporting

Maintain concise milestone reports.

Reports should include:
- Completed features.
- Active tasks and assigned agents.
- Verified game builds.
- New screenshots or recordings.
- Known problems.
- Design decisions.
- Upcoming dependencies.
- Next milestone.

Avoid excessive status updates that do not convey meaningful progress.

---

# PART X — DEVELOPMENT ROADMAP

## Milestone 0 — Project foundation

Deliver:
- Existing-repository audit.
- Engine validation.
- Architecture.
- Cursor agent organization.
- Persistent project documentation.
- GitHub task coordination.
- Initial Art Bible.
- Automated build validation.
- First runnable game-engine scene.

**Acceptance condition:** The real engine project launches, its architecture is documented, and agents can implement tasks without stepping on each other's work.

## Milestone 1 — Beautiful first playable farm

Deliver:
- Main menu.
- Farm selector.
- New farm creation.
- World map.
- Region selection.
- One stylized 3D farm.
- Functional camera.
- Basic placement interaction.
- At least one properly modeled, animated character.
- Basic UI.
- Save/load.

**Acceptance condition:** The player can create a farm and explore a visually coherent, interactive 3D environment.

## Milestone 2 — First complete economic loop

Deliver:
- Basic fictional resource production.
- Inventory.
- One functional workshop.
- Production animations.
- Order board.
- Currency.
- Building purchase or upgrade.
- Guided tutorial.

**Acceptance condition:** The player can complete the full production-to-sale-to-upgrade cycle.

## Milestone 3 — Employee management

Deliver:
- Character attribute system.
- Recruitment.
- Job assignments.
- NPC movement.
- Work animations.
- Character progression.
- Worker-related gameplay effects.

**Acceptance condition:** Different worker assignments generate meaningfully different outcomes, and employees visibly perform their jobs.

## Milestone 4 — Production expansion

Deliver:
- Additional production categories.
- Interconnected fictional supply chains.
- More buildings.
- Building upgrade paths.
- Farm expansion.
- Better inventory management.
- Additional contracts.

**Acceptance condition:** The player must make meaningful decisions about production priorities and resource management.

## Milestone 5 — Automation and strategy

Deliver:
- Automated task assignments.
- More advanced facilities.
- Research tree.
- Business specialization.
- Additional management mechanics.
- Balancing and progression improvements.

**Acceptance condition:** Automation changes the player's responsibilities from direct operation toward strategic management.

## Milestone 6 — Content and polish

Deliver:
- More characters.
- Additional regions.
- More visual assets.
- Environmental variation.
- Improved animations.
- Sound design.
- Performance optimization.
- Accessibility improvements.
- Complete gameplay balancing.

**Acceptance condition:** The game demonstrates a consistent presentation and engaging medium-term progression.

## Milestone 7 — Release preparation

Deliver:
- Stable desktop build.
- Regression testing.
- Save compatibility testing.
- Performance verification.
- Steam integration evaluation.
- Appropriate store and age-rating compliance review.
- Deployment and release documentation.

**Acceptance condition:** A validated release candidate suitable for further distribution review.

---

# PART XI — FIRST EXECUTION DIRECTIVE

You are now responsible for initiating the FinoFarm development workflow.

Begin by inspecting the current GitHub repository and identifying all existing implementation, assets, architecture, and documentation.

Do not discard completed work without justification.

Then perform the following:

1. Evaluate whether the current project architecture supports the intended stylized 3D game.
2. Establish Godot 4 as the playable game foundation unless a demonstrably superior alternative is justified.
3. Produce the initial Game Design Document and Art Bible.
4. Establish persistent repository rules and specialized agent skills.
5. Configure the available Cursor Projects coordination features.
6. Create the development backlog, task dependencies, and ownership rules.
7. Design the first playable vertical slice.
8. Identify which tasks can be delegated to Cloud Agents.
9. Establish the 3D modeling and animation pipeline.
10. Begin implementation with actual game-engine deliverables.

The first major development goal is a playable, attractive 3D farm experience—not a collection of static menus.

Prioritize the visual world, player interaction, and one cohesive gameplay loop.

You are encouraged to improve the game's design beyond this specification, provided changes remain consistent with its identity and are documented.

Act as a responsible development team building a real game intended for an eventual commercial release.

**Success is measured by playable, verified, visually coherent progress—not by the amount of generated code or the number of active agents.**
