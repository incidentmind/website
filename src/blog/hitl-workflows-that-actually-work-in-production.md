---
layout: blog-post.liquid
title: "3 Human-in-the-Loop Workflows That Actually Work in Production"
description: "Three production-ready HITL patterns for content approval, incident response, and support escalation, complete with card structures, form schemas, and webhook flows."
permalink: /blog/hitl-workflows-that-actually-work-in-production/
tags:
  - blog
series: "The Human Layer in AI Agent Systems"
part: 3
date: 2026-03-30T12:00:00Z
readTime: "10 min read"
---

*Content approval, incident management, and support escalation — complete with card structures, form schemas, and the webhook flows that close the loop.*

---

*This is Part 3 of a 3-part series on building the human layer in AI agent systems. [← Part 1: The Problem](/blog/ai-agent-human-control-surface/) · [← Part 2: How to Wire It](/blog/how-to-wire-human-layer-into-ai-agent-pipeline/)*

---

## TL;DR

- Three production-ready human-in-the-loop patterns, each using a different combination of kanban-lite capabilities.
- Every workflow includes the board layout, card YAML, form schemas, webhook events, and the orchestrator logic.
- Copy the `.kanban.json` snippets and adapt them to your stack.

---

[Part 1](/blog/ai-agent-human-control-surface/) explained why agent pipelines need a shared human surface. [Part 2](/blog/how-to-wire-human-layer-into-ai-agent-pipeline/) covered the integration wiring. This article puts it all together with three real workflows.

Each one is designed to be copied and adapted, not treated as abstract theory.

---

## Workflow 1: AI Content Pipeline with Editorial Approval

**The scenario**: Agents generate draft articles. Humans review, request revisions, and approve for publishing. Marketing leadership wants queue visibility without understanding the orchestrator.

### Workflow 1 Board Layout

```text
Backlog → Writing → Review → Approved → Published
```

Minimize `Backlog` and `Published` in practice — the active queue is `Writing → Review → Approved`.

### Workflow 1 Card Structure

```yaml
---
id: q3-launch-blog-2026-03-19
status: review
priority: high
assignee: maya
dueDate: 2026-03-25
labels: ["marketing", "agent-generated", "q3-launch"]
actions:
  retry-draft: "Retry with different tone"
  approve: "Approve for Publishing"
forms:
  - name: editorial-review
---

# Q3 Launch Blog Post

Research phase identified 14 sources on developer productivity trends.
Writer agent produced first draft (attached as `draft-v1.md`).

**Word count**: 1,840
**Target audience**: Engineering managers
**Key message**: Platform reduces onboarding time by 40%
```

### Workflow 1 Form Schema

```json
{
  "forms": {
    "editorial-review": {
      "schema": {
        "type": "object",
        "title": "Editorial Review",
        "required": ["tone", "factCheck", "verdict"],
        "properties": {
          "tone": {
            "type": "string",
            "enum": ["on-brand", "too-corporate", "too-casual", "needs-rewrite"]
          },
          "factCheck": { "type": "boolean", "title": "Facts verified?" },
          "verdict": {
            "type": "string",
            "enum": ["approve", "revise", "reject"]
          },
          "revisionNotes": { "type": "string", "title": "Notes for revision" }
        }
      }
    }
  }
}
```

### Workflow 1 Flow

| Step | Actor | Action | Signal |
| ---- | ----- | ------ | ------ |
| 1 | Planner agent | Creates card in `backlog` via MCP | `task.created` |
| 2 | Research agent | Adds log: "Collected 14 sources", attaches notes | `attachment.added` |
| 3 | Writer agent | Uploads draft, moves card to `review` | `task.moved` → status: review |
| 4 | Editor (human) | Opens card, reads draft, submits editorial-review form | `form.submit` |
| 5a | *If verdict = "revise"* | Editor clicks `retry-draft` | Action webhook with revision notes |
| 5b | *If verdict = "approve"* | Editor clicks `approve` | Action webhook → agent moves to `approved` |
| 6 | Publishing agent | Publishes, moves card to `published`, updates actions to `create-social-assets` | `task.moved` |

**What makes this work**: The editor never leaves the card. Draft, sources, discussion, structured review, and approval all live in one place. Marketing leadership opens the board and sees how many items are in `Review` without asking anyone.

### Workflow 1 Dynamic Actions

The orchestrator updates card actions as the card moves through stages:

```typescript
// After approval — replace review actions with publishing actions
await sdk.updateCard(cardId, {
  actions: {
    'publish-now': 'Publish Immediately',
    'schedule': 'Schedule for Tomorrow'
  }
});

// After publishing — add follow-up action
await sdk.updateCard(cardId, {
  actions: {
    'create-social-assets': 'Generate Social Media Posts'
  }
});
```

---

## Workflow 2: Incident Management with Structured Intake

**The scenario**: An AI agent detects anomalies and opens incident cards. On-call engineers triage with a structured form. Resolution steps are logged, and a post-mortem form captures the outcome.

### Workflow 2 Board Layout

```text
Detected → Triaging → Mitigating → Resolved → Post-Mortem Done
```

### Workflow 2 Card Structure

```yaml
---
id: incident-api-latency-2026-03-20
status: triaging
priority: critical
assignee: on-call
labels: ["incident", "api", "auto-detected"]
actions:
  escalate-eng: "Escalate to Engineering Lead"
  mark-mitigated: "Mark as Mitigated"
forms:
  - name: incident-triage
  - name: post-mortem
    data:
      detectedAt: "${created}"
      service: "${metadata.service}"
---

# API Latency Spike — P99 > 2s

Anomaly detection agent flagged sustained P99 latency above 2 seconds
on the `/api/tasks` endpoint starting at 14:22 UTC.

**Affected service**: task-api
**Region**: us-east-1
**Duration so far**: 18 minutes
```

### Workflow 2 Form Schemas

```json
{
  "forms": {
    "incident-triage": {
      "schema": {
        "type": "object",
        "title": "Incident Triage",
        "required": ["severity", "category", "customerImpact"],
        "properties": {
          "severity": {
            "type": "string",
            "enum": ["SEV1", "SEV2", "SEV3", "SEV4"]
          },
          "category": {
            "type": "string",
            "enum": ["infrastructure", "application", "data", "security", "third-party"]
          },
          "customerImpact": { "type": "boolean" },
          "estimatedResolution": { "type": "string", "title": "ETA" },
          "initialAssessment": { "type": "string" }
        }
      }
    },
    "post-mortem": {
      "schema": {
        "type": "object",
        "title": "Post-Mortem",
        "required": ["rootCause", "actionItems"],
        "properties": {
          "detectedAt": { "type": "string", "readOnly": true },
          "service": { "type": "string", "readOnly": true },
          "rootCause": { "type": "string" },
          "timeline": { "type": "string", "title": "Timeline summary" },
          "actionItems": { "type": "string", "title": "Follow-up action items" },
          "preventable": { "type": "boolean", "title": "Could this have been prevented?" }
        }
      }
    }
  }
}
```

### Workflow 2 Flow

| Step | Actor | Action | Signal |
| ---- | ----- | ------ | ------ |
| 1 | Detection agent | Creates card in `detected`, attaches metrics snapshot | `task.created` |
| 2 | On-call (human) | Moves to `triaging`, submits incident-triage form | `form.submit` → severity, category |
| 3 | On-call | Adds comment: "Scaling API pods from 3→8" | `comment.created` |
| 4 | Mitigation agent | Adds log: "Auto-scaled to 8 pods, latency dropping" | Background event |
| 5 | On-call | Clicks `mark-mitigated` | Action webhook |
| 6 | Orchestrator | Moves card to `resolved`, updates actions to `write-post-mortem` | `task.moved` |
| 7 | On-call | Submits post-mortem form | `form.submit` → root cause, action items |
| 8 | Orchestrator | Moves to `post-mortem-done`, creates follow-up cards from action items | `task.created` (new cards) |

**What makes this work**: The triage form produces a **validated payload** the system can act on — not a free-text comment that someone parses later. The `${created}` and `${metadata.service}` placeholders in the post-mortem form pre-fill context automatically.

### Workflow 2 Automated Log Trail

Throughout the incident, agents and automations add structured logs:

```bash
kl log add incident-api-latency-2026-03-20 \
  --text "P99 latency returned to normal (180ms)" \
  --source monitoring \
  --object '{"p99_ms": 180, "pod_count": 8}'
```

Every step is timestamped and visible on the card's Logs tab — a built-in audit trail without a separate logging system.

---

## Workflow 3: Support Escalation with Agent-Drafted Replies

**The scenario**: An AI agent summarizes customer issues, drafts replies, and collects related context. A support lead reviews and decides: send, edit, or escalate. Legal review is required for refund-related cases.

### Workflow 3 Board Layout

```text
New → Investigating → Draft Ready → Sending → Closed
```

### Workflow 3 Card Structure

```yaml
---
id: support-refund-dispute-2026-03-20
status: draft-ready
priority: high
assignee: support-lead
labels: ["support", "refund", "agent-drafted"]
actions:
  send-reply: "Send to Customer"
  request-legal: "Request Legal Review"
  redraft: "Ask Agent to Redraft"
forms:
  - name: escalation-review
---

# Refund Dispute — Order #8847

Customer reports unauthorized charge of $299. Account shows
single-use promo code applied correctly. Payment gateway confirms
charge was authorized via 3D Secure.

## Agent-Drafted Reply

> Hi [Customer Name],
>
> Thank you for reaching out. I've reviewed your order #8847 and can
> confirm the charge was processed with 3D Secure authentication.
> The promotional discount was applied as expected.
>
> I'd be happy to walk through the transaction details with you.
> Would you prefer a call or a detailed email breakdown?

**Confidence**: 0.82
**Related tickets**: #8801, #8823 (similar disputes, resolved)
```

### Workflow 3 Form Schema

```json
{
  "forms": {
    "escalation-review": {
      "schema": {
        "type": "object",
        "title": "Escalation Review",
        "required": ["replyApproved", "refundRisk"],
        "properties": {
          "replyApproved": {
            "type": "string",
            "enum": ["approved", "needs-edit", "rejected"]
          },
          "refundRisk": {
            "type": "string",
            "enum": ["none", "low", "medium", "high"]
          },
          "legalReviewRequired": { "type": "boolean" },
          "editInstructions": { "type": "string", "title": "Instructions for redraft" },
          "internalNotes": { "type": "string" }
        }
      }
    }
  }
}
```

### Workflow 3 Flow

| Step | Actor | Action | Signal |
| ---- | ----- | ------ | ------ |
| 1 | Intake agent | Creates card in `new`, adds summary and related tickets | `task.created` |
| 2 | Research agent | Attaches payment trace, adds log with confidence score | `attachment.added` |
| 3 | Writer agent | Drafts reply in card body, moves to `draft-ready` | `task.moved` |
| 4 | Support lead | Reviews draft, submits escalation-review form | `form.submit` |
| 5a | *If legalReviewRequired* | Lead clicks `request-legal` | Action webhook → orchestrator adds `legal-review` label, notifies legal |
| 5b | *If replyApproved = "approved"* | Lead clicks `send-reply` | Action webhook → send agent dispatches reply |
| 5c | *If replyApproved = "needs-edit"* | Lead clicks `redraft` | Action webhook → writer agent re-drafts with `editInstructions` from form |
| 6 | Send agent | Dispatches reply, moves card to `closed`, adds log | `task.moved` |

**What makes this work**: The support lead's decision is captured in a **structured form**, not a Slack thread. The orchestrator knows the refund risk level, whether legal review is needed, and the exact edit instructions — all as typed, validated fields.

---

## Pattern Summary

All three workflows share the same architecture:

```text
Agent creates/updates card
    ↓
Human reviews on the board
    ↓
Human acts (form submit / action click / move card)
    ↓
Webhook carries signal to orchestrator
    ↓
Orchestrator reacts (next agent step / update card / close loop)
```

The differences are in the **form schemas** and **action definitions**, not in the plumbing.

| Capability | Content Pipeline | Incidents | Support |
| ---------- | :--------------: | :-------: | :-----: |
| Card actions | ✓ | ✓ | ✓ |
| Dynamic action updates | ✓ | ✓ | |
| Structured forms | ✓ | ✓✓ | ✓ |
| Placeholder interpolation | | ✓ | |
| Agent-drafted content | ✓ | | ✓ |
| Structured logs | | ✓ | ✓ |
| Multi-form per card | | ✓ | |
| File attachments | ✓ | ✓ | ✓ |

---

### Getting Started

Pick one workflow, adapt the schemas to your domain, and wire the two webhook endpoints ([Part 2](/blog/how-to-wire-human-layer-into-ai-agent-pipeline/) has the setup). The initial investment is small:

```bash
npm install -g kanban-lite
kl init
kl serve

# Register your orchestrator
kl webhooks add --url https://your-app.example.com/events \
  --events task.moved,form.submit,comment.created
```

In `.kanban.json`, add your action endpoint and form definitions:

```json
{
  "actionWebhookUrl": "https://your-app.example.com/card-actions",
  "forms": {
    "your-review-form": {
      "schema": { "..." }
    }
  }
}
```

For AI agents, add the board skill in one command:

```bash
npx skills add https://github.com/borgius/kanban-lite
```

---

### The Series at a Glance

1. **[Part 1: Your AI Agent Pipeline Needs a Human Control Surface](/blog/ai-agent-human-control-surface/)** — the problem and the idea.
2. **[Part 2: How to Wire a Human Layer Into Any AI Agent Pipeline](/blog/how-to-wire-human-layer-into-ai-agent-pipeline/)** — the integration surfaces and signal types.
3. **Part 3 (this article)** — three production-ready workflows you can copy and adapt.

The board is open source, MIT-licensed, and built for teams that need humans and agents working on the same surface.

These are the same patterns I implement when building custom AI automation at [IncidentMind](https://incidentmind.com). The incident workflow in particular comes from real experience — I built an AI-powered incident response platform at Fidelity that automated detection, classification, context gathering, and LLM-assisted root-cause analysis. The human layer was always the hardest part to get right. If you're designing HITL workflows for your team and want to talk architecture, reach out — I enjoy this kind of problem.

---

*Viktor Burdyey builds AI automation systems at [IncidentMind](https://incidentmind.com) — custom agents, MCP servers, and workflow systems for teams that need secure, company-owned automation. Previously CTO at EAT24 (acquired by Yelp for $134M) and Senior Platform Engineer at Fidelity, where he built an AI-powered incident response platform. Open to senior/staff engineering roles and consulting engagements. [LinkedIn](https://www.linkedin.com/in/burdyey) · [GitHub](https://github.com/borgius)*

🔗 [kanban-lite on GitHub](https://github.com/borgius/kanban-lite) · [npm](https://www.npmjs.com/package/kanban-lite/) · [Documentation](https://borgius.github.io/kanban-lite/) · MIT License
