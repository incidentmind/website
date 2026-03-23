# IncidentMind Website — Data & Template Reference

## Project overview

Single-page marketing site for **IncidentMind** (Viktor Burdyey, Founder).  
Built with **Eleventy** (11ty) + **Liquid** templating. Zero frameworks, vanilla CSS + JS.

| File | Purpose |
|---|---|
| `src/index.11tydata.yaml` | 100% of page content — all text, icons, colors, links |
| `src/index.html` | Liquid template — reads data from the YAML, outputs HTML |
| `src/css/main.css` | All styles, CSS custom properties, layout |
| `src/js/main.js` | Scroll animations, counter animation, mobile menu |
| `_site/` | Build output (run `npx @11ty/eleventy`) |

## Template engine

Eleventy uses **Liquid** (not Nunjucks, not Handlebars).  
- `{{ key }}` — output a value  
- `{% for item in list %}…{% endfor %}` — loop  
- `{% if condition %}…{% endif %}` — conditional  
- `{% assign x = value %}` — variable assignment  
- `forloop.index` — 1-based loop counter; `forloop.index0` — 0-based  
- `| modulo: N` — Liquid modulo filter for staggered CSS animations  

## Data file: `src/index.11tydata.yaml`

### Top-level keys → HTML sections

| YAML key | HTML section / element | nav link |
|---|---|---|
| `meta` | `<title>` + `<meta description>` | — |
| `nav` | `<nav class="navbar">` | — |
| `hero` | `<section class="hero">` | logo href="#" |
| `problem` | `<section class="problem-section">` | _(none)_ |
| `services` | `<section id="services">` | `#services` |
| `approach` | anonymous `<section>` | _(none)_ |
| `proof` | `<section id="proof">` | `#proof` |
| `positioning` | anonymous `<section>` | _(none)_ |
| `tech` | `<section id="tech">` | `#tech` |
| `openSource` | `<section id="open-source">` | `#open-source` |
| `contact` | `<section id="contact">` | `#contact` |
| `footer` | `<footer>` | — |

---

### `meta`
```yaml
meta:
  title: string        # → <title> tag
  description: string  # → <meta name="description">
```

---

### `nav`
```yaml
nav:
  logo:
    initials: string    # two-letter mark inside .nav-logo-icon div
    text: string        # brand name in .nav-logo-text span
    href: string        # logo link (normally "#")
    ariaLabel: string   # aria-label on the <a>
  links:
    - label: string     # visible link text
      href: string      # in-page anchor (#services, #proof, …)
      cta: bool         # true → adds class="nav-cta" (highlighted CTA button)
```

---

### `hero`
```yaml
hero:
  tagline: string         # pulsing "available" indicator above H1
  heading:
    line1: string         # plain text
    line2: string         # wrapped in <span class="gradient-text">
  description: string     # <p class="hero-description">
  actions:
    - label: string
      href: string
      icon: string        # Font Awesome class (e.g. "fa-solid fa-calendar-check")
      variant: string     # "primary" | "secondary" → class="btn-{variant}"
      target: string      # optional "_blank"; auto-adds rel="noopener"
  proofItems:
    - string              # trust badges with fa-check-circle icon
  metrics:
    - value: number       # JS animates counter from 0 to this value
      prefix: string      # optional (e.g. "$") prepended to number
      suffix: string      # optional (e.g. "%", "M", "GB") appended
      label: string       # caption below the counter
      color: string       # CSS custom property or hex for the value color
  floatCards:
    - title: string
      subtitle: string
      icon: string        # Font Awesome class
      bgColor: string     # rgba inline background on icon wrapper
      iconColor: string   # inline color on icon wrapper
      position: string    # CSS class: "card-1" (upper-left) | "card-2" (lower-right)
```

---

### `problem`
```yaml
problem:
  label: string           # small eyebrow above H2
  title:
    line1: string
    line2: string         # gradient-text
    line3: string
  subtitle: string
  stats:
    - value: string       # pre-formatted (e.g. "$250B") — shown large
      text: string        # supporting description
  cards:
    - icon: string        # Font Awesome class
      bgColor: string     # inline background on icon wrapper
      iconColor: string   # inline color on icon wrapper
      title: string       # <h3>
      body: string        # <p>
```

---

### `services`

**Rendering order** (important — do not re-order without updating the template):
1. Section header
2. `tiers[0..2]` — first 3 tiers in alternating left/right layout (`limit:3`)
3. `platformCards` — 6-card sub-services grid
4. `tiers[3]` — Advisory tier rendered separately (`offset:3 limit:1`)

```yaml
services:
  label: string
  title: { line1, line2 (gradient), line3 }
  subtitle: string
  tiers:
    - badge: string           # pill label
      badgeIcon: string       # Font Awesome class
      badgeVariant: string    # CSS class: badge-flagship | badge-growth | badge-core | badge-advisory
      title: string           # <h3>
      body: string            # <p>
      features:
        - string              # <li> with fa-check icon
      pricing:
        value: string         # gradient-text (price range)
        label: string         # plain text footnote
      visual:
        icon: string          # large icon in the glass visual card
        iconBg: string        # inline background on icon wrapper
        iconColor: string     # inline color on icon wrapper
        label: string         # caption below icon (e.g. "Technology stack")
        tags:
          - string            # <span class="tech-tag"> pills
  platformCards:
    - icon: string
      iconBg: string
      iconColor: string
      title: string           # <h4>
      body: string            # <p>
      price: string           # .platform-card-price (no gradient)
```

---

### `approach`
```yaml
approach:
  label: string
  title:
    line1: string
    line2: string             # gradient-text
  subtitle: string
  steps:
    - title: string           # <h4> in .approach-step card
      body: string            # <p>
```

---

### `proof`
```yaml
proof:
  label: string
  title: { line1, line2 (gradient) }
  subtitle: string
  items:
    - date: string            # eyebrow date range (e.g. "2007 – 2015 · EAT24")
      dateColor: string       # inline color on .proof-date
      timelineDotColor: string  # reserved for timeline connector dot (future CSS use)
      title: string           # <h3>
      body: string            # <p>
      metrics:
        - value: string       # pre-formatted large stat
          label: string       # caption
          color: string       # inline color
      highlights:
        - string              # <li> with fa-check icon (right column)
```

---

### `positioning`
```yaml
positioning:
  label: string
  title: { line1, line2 (gradient) }
  quadrant:
    axes:
      top: string             # "Custom / Owned"
      bottom: string          # "SaaS Subscription"
      left: string            # "High-Touch"
      right: string           # "Self-Serve"
    cells:                    # 4 cells in reading order: top-left, top-right, bottom-left, bottom-right
      - label: string         # optional bold name (only on IncidentMind cell)
        sublabel: string
        highlight: bool       # true → adds .quadrant-highlight CSS class
  text:
    heading: string           # <h3>
    body: string              # <p>
    list:
      - icon: string          # Font Awesome class
        text: string
```

---

### `tech`
```yaml
tech:
  label: string
  title: { line1, line2 (gradient) }
  subtitle: string
  categories:
    - icon: string            # Font Awesome class in <h4> heading
      title: string           # <h4> text
      items:
        - string              # <span class="tech-item"> pills
```

---

### `openSource`
```yaml
openSource:
  label: string
  title: { line1, line2 (gradient) }
  subtitle: string
  projects:
    - name: string            # <h4>
      icon: string            # Font Awesome class in .oss-card-icon
      description: string     # <p>
      github: string          # URL for "View on GitHub" link (target="_blank" in HTML)
```

---

### `contact`
```yaml
contact:
  label: string               # eyebrow label
  heading:
    line1: string
    line2: string             # plain text (e.g. "and")
    line2Gradient: string     # appended with .gradient-text (e.g. "ship faster?")
  body: string                # <p>
  actions:
    - label, href, icon, variant, target   # same as hero.actions
  info:
    - icon: string
      text: string
      href: string            # optional (tel:, mailto:, https:)
      target: string          # optional "_blank"
```

---

### `footer`
```yaml
footer:
  copyright: string           # plain text in .footer-copy
  links:
    - icon: string            # Font Awesome class (icon-only)
      href: string
      label: string           # used as aria-label on <a>
      target: string          # optional "_blank"
```

---

## CSS custom properties (color palette)

Defined in `src/css/main.css` — used as `color` values throughout the YAML:

| Variable | Hex | Usage |
|---|---|---|
| `var(--accent-emerald)` | `#10b981` | Green — MTTR, Fidelity metrics |
| `var(--accent-blue)` | `#6366f1` | Indigo — primary CTA, EAT24 |
| `var(--accent-violet)` | `#8b5cf6` | Purple — MCP/agents tier |
| `var(--accent-cyan)` | `#06b6d4` | Cyan — Advisory, ETL |
| `--text-muted` | — | Used in HTML inline styles for secondary text |

Gradient text is applied via `.gradient-text` class (blue→violet CSS gradient).

---

## JavaScript (src/js/main.js)

- **Counter animation**: triggered on scroll-into-view for `.counter` spans.  
  Reads `data-target` (number), `data-prefix`, `data-suffix` from the element.  
  These are set from `hero.metrics[].value/prefix/suffix`.
- **Reveal animations**: `.reveal`, `.reveal-left`, `.reveal-right` classes animate in via IntersectionObserver. Stagger delay via `.stagger-1` through `.stagger-4`.
- **Mobile menu**: `.nav-toggle` button toggles `.nav-links` open/closed.

---

## Common editing patterns

| Task | What to change |
|---|---|
| Update hero stats | `hero.metrics[].value/label/suffix` |
| Add a nav link | Append to `nav.links[]` |
| Add a service tier | Append to `services.tiers[]` — note: tiers 1–3 use `limit:3`, tier 4 uses `offset:3 limit:1` in template |
| Add a platform card | Append to `services.platformCards[]` |
| Add an OSS project | Append to `openSource.projects[]` |
| Add a contact info row | Append to `contact.info[]` |
| Change pricing | Edit `services.tiers[].pricing.value` / `.label` |
| Change proof metrics | Edit `proof.items[].metrics[]` |
| Update SEO | Edit `meta.title` and `meta.description` |
