# LinkedIn Post — "Your AI Agent Pipeline Needs a Human Control Surface"

**Platform:** LinkedIn
**Post type:** Thought leadership / article promotion
**Link:** https://incidentmind.com/blog/ai-agent-human-control-surface/

---

Most AI agent pipelines are beautifully wired — until a human needs to step in.

Planner → researcher → writer → evaluator. Looks great on a diagram.

Then someone asks: *"What's waiting on me right now?"*

And the answer is buried in an orchestration UI that only your DevOps lead has open.

---

Here's the gap I keep running into with production agent systems:

Graph-based orchestrators are excellent at machine state. They're usually terrible at **shared human state.**

- Approvals arrive as Slack messages with no durable context
- Comments live in email, not next to the work
- If the service restarts, the "conversation" around a task is scattered across three tools

The humans in your loop — the editor, the PM, the compliance reviewer — need a simple answer to a simple question: **What is waiting on me, what happened already, and what should happen next?**

---

I just published Part 1 of a 3-part series on building the human layer in AI agent systems.

The core idea: give humans and agents **a single board they can both read, write, and act through** — backed by plain markdown, accessible via Web UI, VS Code, CLI, REST API, SDK, MCP, or n8n. Not a new orchestrator. Not a replacement for LangGraph or CrewAI. Just a durable, version-controlled control surface that sits on top of whatever stack you already have.

One thing I found genuinely useful: separating webhook signals into **mutation events** ("this card moved to review") vs. **action events** ("a human explicitly clicked approve"). They look similar on the surface but they're not the same signal — and conflating them makes real workflows messier than they need to be.

---

I've been building agent-to-human integration patterns for years — an AI-powered incident response platform at Fidelity, and now through IncidentMind, where I design custom agent systems and MCP servers for operations teams. kanban-lite is the open-source layer that keeps surfacing as the missing piece.

The full post covers the board model, both webhook types, schema-driven forms for structured approvals, and the honest caveats about what it doesn't do.

👉 Link in comments.

---

I'm also actively looking for my next senior/staff engineering role — ideally somewhere building serious agent infrastructure or AI-powered operations tooling. If your team is working on this space and hiring, or if you're looking for a design partner on a HITL problem, I'd love to connect.

What's the hardest HITL moment in your agent stack right now? Curious where people are still improvising.

---

**Hashtags:**
`#AIAgents` `#HumanInTheLoop` `#HITL` `#AgentSystems` `#AIWorkflows` `#LLMOps` `#EngineeringLeadership` `#AIAutomation` `#IncidentMind`
