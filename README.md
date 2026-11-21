# Alexandru Amărioarei — academic website

A bilingual (English / Romanian) personal academic website built with [Quarto](https://quarto.org) and published on GitHub Pages.

- English is the default language and lives at the site root (`/`).
- Romanian lives under `/ro/`, with the same page names (`research.html` ↔ `ro/research.html`).
- Every page has a language switch that opens **the same page** in the other language.

## Requirements

- **Quarto 1.11 or newer** (built and tested with 1.11.9). Check with `quarto --version`.
- R only if a page contains executable `{r}` code (see *Blog posts with R code*).

Nothing else to install: fonts, scripts and styles are included in the project.

## Everyday commands

Run these in a terminal opened in this folder (PowerShell, RStudio/Positron terminal, …):

| Task | Command |
|---|---|
| Build the whole site (both languages) into `_site/` | `quarto render` |
| Live preview while editing English pages | `quarto preview` |
| Rebuild only the Romanian pages after editing them | `quarto render ro` |

`quarto render` builds the English site and then, automatically, the Romanian one (a small hook in `scripts/render-ro.ts` that runs with Quarto's own runtime). During `quarto preview`, edits to English pages reload instantly. After editing Romanian pages, run `quarto render ro` and refresh the browser.

## Project layout

```
Alex-Website/
├── _quarto.yml            English site: menu, footer, theme  (default language)
├── index.qmd  research.qmd (tabs: Topics, Publications, Talks)  teaching.qmd
├── projects.qmd  experience.qmd  contact.qmd  404.qmd
├── blog/                  English blog (index.qmd + posts/<date-slug>/index.qmd)
├── ro/                    Romanian site: same files, same names
│   ├── _quarto.yml        Romanian menu and footer
│   └── …                  index.qmd, research.qmd, …, blog/
├── data/                  Shared content, written once for both languages
│   ├── publications.yml
│   ├── talks.yml
│   ├── courses.yml
│   └── projects.yml
├── templates/             How the data files are displayed (lists, cards)
├── theme/                 Colours (light.scss, dark.scss), layout and typography (site.scss),
│                          Romanian interface strings (_language-ro.yml)
├── filters/site.lua       Language-switch targets, hreflang tags, font/script links
├── assets/                Files copied as-is: fonts/, img/, js/, files/ (put PDFs here)
├── scripts/render-ro.ts   Builds the Romanian site after the English one
├── github-actions/publish.yml      Automatic publishing to GitHub Pages (move it, see below)
└── _site/                 The generated website (not edited, not committed)
```

## Updating content

**Placeholders.** Missing information is marked on the pages with a dashed amber box. In the sources these are spans with the class `todo`, so you can find all of them by searching the project for `{.todo}`. Complete or delete them before publishing.

**A publication.** Add a block to `data/publications.yml` (types: `journal`, `chapter`, `proceedings`, `other`, `thesis`, `preprint`). It appears in the Publications tab of the Research page, in both languages. Add `selected: true` to show it on the homepage. The links `doi`, `arxiv`, `url`, `pdf` are optional; for a PDF, put the file in `assets/files/` and write `pdf: assets/files/name.pdf`.

**A talk, seminar or poster.** Add a block to `data/talks.yml`; it appears in the Talks tab of the Research page.

**Linking to a tab.** `research.qmd#topics`, `research.qmd#publications` and `research.qmd#talks` open the Research page on that tab (the same in `ro/`).

**A course website.** Add a block to `data/courses.yml` (a commented template is at the end of the file). Each course has a Romanian and an English title and description (`title` / `title-en`, …). Move a finished course out of the current list with `status: archived`.

**A project.** Add a block to `data/projects.yml`. Use `status: ongoing` or `status: completed`.

**A blog post.**

1. Copy `blog/posts/2026-11-20-exemplu/` to a new folder, e.g. `blog/posts/2027-01-15-runs/`.
2. Edit `index.qmd`: `title`, `description`, `date`, `categories`, and the text.
3. For the Romanian version, create the folder with **the same name** in `ro/blog/posts/`.
4. A post that exists in only one language is fine: its language switch goes to the other language's homepage, and the build prints a warning.

Delete the example post (both folders) whenever you like.

**Blog posts with R code.** Write chunks as ```` ```{r} ```` and render the post on your computer (`quarto render blog/posts/<folder>/index.qmd`, or the Romanian one with `quarto render ro`). The results are stored in `_freeze/`. Commit that folder, so GitHub can rebuild the site without R.

**A new page.** Create `new-page.qmd` in the root and `ro/new-page.qmd`, then add it to the `navbar` in both `_quarto.yml` and `ro/_quarto.yml`. If the two versions must have different file names, put `alt-lang: other-name.qmd` in the page header.

**Photo and CV.** Replace `assets/img/portrait.svg` with a photo, e.g. `assets/img/portrait.jpg`, and change the path in `index.qmd` and `ro/index.qmd`. Put CV PDFs in `assets/files/` and link them from `experience.qmd` / `ro/experience.qmd` (the placeholder there shows the syntax). The Europass CV in your CV folder contains your home address, personal phone and date of birth, so prepare a public version without them.

**Colours and fonts.** Colours are in `theme/light.scss` and `theme/dark.scss`. Fonts, sizes and layout are in `theme/site.scss`.

## Publishing on GitHub Pages

The source is committed. The generated `_site/` is not: GitHub Actions builds it on every push and publishes it.

### 0. Put the publishing workflow in place (once)

GitHub only runs workflows stored in `.github/workflows/`. Create that folder in the project and move `github-actions/publish.yml` into it, so the path is `.github/workflows/publish.yml`. Then delete the empty `github-actions` folder. In PowerShell:

```powershell
New-Item -ItemType Directory -Force .github\workflows
Move-Item github-actions\publish.yml .github\workflows\publish.yml
Remove-Item github-actions
```

### 1. Review first, without touching the current site

Your current site (`alexamarioarei.github.io`) and the course sites (`curs-stat-fmi`, `curs-ps-fmi`) stay unchanged during this step.

1. On GitHub, create a new **empty** repository, e.g. `alex-website`.
2. In this folder:

   ```bash
   git init -b main
   git add .
   git commit -m "New bilingual academic website"
   git remote add origin https://github.com/alexamarioarei/alex-website.git
   git push -u origin main
   ```

3. In the repository: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
4. The **Actions** tab shows the build. After a couple of minutes the site is live at
   `https://alexamarioarei.github.io/alex-website/` for review.

All internal links are relative, so the site works at that address. The exceptions are the 404 page and the absolute URLs used for search engines, which already point to the final address.

### 2. Switch over, once approved

The main site address is served from the repository `alexamarioarei/alexamarioarei.github.io`. Its current content (the old site) is still in its git history.

1. Keep a copy of the old site: in that repository, create a branch or tag (e.g. `legacy-2017`).
2. Replace the repository content with this project (or rename repositories: archive the old one and rename `alex-website` to `alexamarioarei.github.io`).
3. Set **Settings → Pages → Source: GitHub Actions** in that repository.

Course sites (`/curs-stat-fmi/`, `/curs-ps-fmi/`, and future ones) are separate repositories and keep working.

Old addresses such as `/Teaching/2019-2020/…` or `/docs/cv_Alex_en.pdf` will stop working once the old site is replaced. If you want to keep some of them, copy those files into `assets/legacy/` and link to them.

## How the bilingual setup works

- The repository holds two Quarto website projects: the English one at the root and the Romanian one in `ro/`. Which language sits where is declared under `site-langs` in both `_quarto.yml` files. Each has its own menu, search index, sitemap and RSS feed.
- `filters/site.lua` runs on every page. It finds the page with the same path in the other language, falling back to that language's homepage. It writes that target into the page, together with `<link rel="alternate" hreflang>` tags for search engines.
- `assets/js/site.js` points the switcher in the menu to that target (plus a compact `EN`/`RO` button on phones) and draws the scan-statistic lattice on the homepage.
- Shared content (publications, talks, courses, projects) lives once in `data/` and is displayed by the templates in `templates/`. English pages pass `template-params: {lang: en}` to select English labels; Romanian pages pass nothing.
