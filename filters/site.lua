--[[
  site.lua — shared by the English (root) and Romanian (ro/) projects.

  The languages are declared in each _quarto.yml:
      site-langs:
        default: en    # language at the site root
        other: ro      # language in the subfolder ro/

  For every HTML page it:
    1. works out the path of the same page in the other language
       (same relative path; e.g. research.qmd <-> ro/research.qmd);
       if that page does not exist, it falls back to the other
       language's homepage. A page can override the target with
       `alt-lang: some/page.qmd` in its YAML header (path relative to
       the other language's root);
    2. writes <link rel="alternate" hreflang=...> tags for search engines;
    3. links the self-hosted fonts and the site script (assets/), using
       paths relative to the page so the site works under any base URL.
]]

local function norm(p) return (p:gsub("\\", "/")) end

local function exists(path)
  local f = io.open(path, "r")
  if f then f:close(); return true end
  return false
end

local function str(x)
  if x == nil then return nil end
  return pandoc.utils.stringify(x)
end

local function to_html(p)
  p = p:gsub("%.qmd$", ".html"):gsub("%.md$", ".html"):gsub("%.ipynb$", ".html")
  return p
end

-- "./index.html" -> "index.html";  "a/./b" -> "a/b"
local function tidy(p)
  p = p:gsub("/%./", "/"):gsub("^%./", "")
  return p
end

function Meta(meta)
  if not quarto.doc.is_format("html") then return meta end

  -- Quarto rewrites project-level values that name an existing folder
  -- (e.g. "ro" becomes "../ro" on pages in blog/), so keep the last part only.
  local function code(x, fallback)
    local v = str(x) or fallback
    return (norm(v):match("([^/]+)$")) or fallback
  end
  local langs   = meta["site-langs"] or {}
  local default = code(langs.default, "en")
  local second  = code(langs.other, "ro")
  local lang    = str(meta.lang) or default
  local at_root = (lang == default)

  local projdir = norm(quarto.project.directory or "")
  local input   = norm(quarto.doc.input_file or "")
  local rel     = input:sub(#projdir + 2)        -- e.g. blog/posts/x/index.qmd
  local offset  = quarto.project.offset or "."   -- page -> project root

  local root, other_root, other_dir, other_lang
  if at_root then
    root, other_root, other_dir, other_lang = offset, offset .. "/" .. second, projdir .. "/" .. second, second
  else
    root, other_root, other_dir, other_lang = offset .. "/..", offset .. "/..", projdir .. "/..", default
  end

  local target = str(meta["alt-lang"]) or rel
  local found  = exists(other_dir .. "/" .. target)
  local href   = tidy(other_root .. "/" .. (found and to_html(target) or "index.html"))
  if not found and not meta["alt-lang"] then
    quarto.log.warning("[site.lua] no " .. other_lang .. " counterpart for " .. rel ..
                       " (language switch goes to the homepage)")
  end

  local head = {
    '<link rel="stylesheet" href="' .. tidy(root .. "/assets/fonts/fonts.css") .. '">',
    '<meta name="alt-lang-href" content="' .. href .. '" data-lang="' .. other_lang .. '">',
  }

  local site = str(meta["site-root"])
  if site then
    site = site:gsub("/$", "")
    local here  = to_html(rel)
    local there = found and to_html(target) or "index.html"
    local default_path, second_path
    if at_root then default_path, second_path = here, second .. "/" .. there
    else default_path, second_path = there, second .. "/" .. here end
    local function clean(p) return (p:gsub("index%.html$", "")) end
    table.insert(head, '<link rel="alternate" hreflang="' .. default .. '" href="' .. site .. "/" .. clean(default_path) .. '">')
    table.insert(head, '<link rel="alternate" hreflang="' .. second .. '" href="' .. site .. "/" .. clean(second_path) .. '">')
    table.insert(head, '<link rel="alternate" hreflang="x-default" href="' .. site .. "/" .. clean(default_path) .. '">')
  end

  quarto.doc.include_text("in-header", table.concat(head, "\n"))
  quarto.doc.include_text("after-body",
    '<script src="' .. tidy(root .. "/assets/js/site.js") .. '"></script>')
  return meta
end
