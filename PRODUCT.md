# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Primary readers are practitioners in the Microsoft data and automation community, arriving mostly from search, social, or conference references while trying to solve a concrete problem or follow a technique:

- **SQL Server DBAs and data professionals** looking for practical how-tos, automation, and troubleshooting.
- **PowerShell practitioners** — dbatools / dbachecks users, module authors, and scripters automating their work.
- **Microsoft Fabric and Azure data folk** exploring APIs, the FabricTools module, workspaces, lakehouses, warehouses, and SQL databases.
- **Community peers, speakers, and mentees** — people connected through SQLBits, PSConfEU, Data Saturdays, and T-SQL Tuesday.

They typically land mid-task: copying real code, following a multi-part series, or reproducing a fix.

## Product Purpose

Rob Sewell's personal technical blog, "Rob Sewell (aka SQL DBA With A Beard)". It exists to:

- **Share and teach** — give back to the community with real code, real errors, and honest workarounds.
- Serve as a **durable personal knowledge base** — a findable record of how things were solved, for Rob and for others.
- Provide a demonstrable **body of work supporting Microsoft MVP renewal** and professional reputation.
- Raise **visibility for Sewells Consulting** and generate inbound interest.

Success is a reader who solves their problem, trusts the source, and comes back — while the archive keeps compounding as evidence of expertise.

## Positioning

A long-running (since 2014), high-frequency personal blog built on lived, first-person practitioner experience — not vendor marketing or abstract theory. The differentiator is the voice and the honesty: real code, real screenshots, admitted mistakes, and generous crediting of collaborators and mentees. The "SQL DBA With A Beard" persona and the community relationships behind it are the moat a neighbouring blog cannot truthfully copy.

## Operating Context

- **Hugo static site** using the [hugo-theme-stack](https://github.com/CaiJimmy/hugo-theme-stack) theme (v3), loaded via Hugo modules; deployed to GitHub Pages, served at `https://blog.robsewell.com` (CNAME). ~280 posts.
- **Content model:** posts at `content/post/YYYY-MM-DD-slug.md`; images under `content/assets/uploads/YYYY/` (optionally `/MM/`). Front matter, image, link, and social-link conventions are codified in `CLAUDE.md` and are binding.
- **Taxonomies:** categories and tags drive homepage widgets (search, archives, categories, tag cloud) and per-post table of contents.
- **Reading scene:** readers often work along with a post in a second window (VS Code, a PowerShell console, a Fabric/SQL portal), so copyable code blocks and clear step ordering matter more than decoration.
- CC BY-NC-SA 4.0 licensing shown on articles; Disqus comments; RSS enabled.

## Capabilities and Constraints

- Static Hugo build — no server-side runtime; interactivity is limited to theme features (search widget, colour-scheme toggle, TOC) and third-party embeds (Disqus).
- Multi-part post series are a recurring structure (e.g. the MicrosoftFabricMgmt and FabricTools series); navigation and continuity across a series matter.
- Code samples span PowerShell, SQL, and shell; syntax highlighting with line numbers is configured and expected.
- Reference folder `s:/clonedforked/fabric-toolbox/` is **read-only** and must never be modified.

## Brand Commitments

- **Identity:** "SQL DBA With A Beard" — preserve the name, the beard persona, the avatar, and the purple 💜 accent (sidebar emoji).
- **Voice:** conversational, practical, community-focused, first-person, honest and self-deprecating, light humour; never corporate, padded, or self-promotional without substance. Full voice guidance lives in `CLAUDE.md`.
- **Binding conventions:** `CLAUDE.md` is the authoritative rulebook for this blog — front matter shape, image alt-text-and-self-link rules, the `?WT.mc_id=DP-MVP-5002693` MVP tracking tag on Microsoft links, and the standard people/tool social-link formats. Future work must not contradict it.
- Established social presence: GitHub (SqlDbaWithABeard, JessandRob), Bluesky, Mastodon (tech.lgbt), LinkedIn.

## Evidence on Hand

- ~280 real published posts under `content/post/`, the genuine body of work.
- Real code, screenshots, and error output embedded throughout posts; real collaborators are named and linked (Jess Pomfret, Chrissy LeMaire, and others per `CLAUDE.md`).
- Avatar image and favicon assets in the theme/static.
- No fabricated testimonials, metrics, customer names, or benchmarks exist — future work must not invent them.

## Product Principles

1. **Practical over theoretical** — every post earns its place with real, runnable code and real outcomes, including the failures.
2. **Honest and generous** — admit mistakes, show the workaround, and credit the people and projects involved.
3. **Findable and durable** — structure content (series, taxonomies, TOC, descriptive titles) so a reader mid-problem can locate and reuse it later.
4. **Keep the voice human** — conversational first-person tone is the brand; never let it drift corporate.
5. **Respect the conventions** — CLAUDE.md's rules (links, images, tracking tags, front matter) are non-negotiable guardrails.

## Accessibility & Inclusion

Accessibility is a real, ongoing requirement, not just habit: every image must carry suitable descriptive alt text and link to its full-size self (per `CLAUDE.md`). The theme supports light/dark colour-scheme toggle. Content should remain readable and navigable for assistive-technology users.
