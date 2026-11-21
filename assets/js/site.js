/* site.js — small enhancements shared by both languages.
   1. Language switcher: points the navbar link to the same page in the
      other language (the target is computed at render time by
      filters/site.lua and stored in <meta name="alt-lang-href">).
   2. Scan lattice on the homepage: a random Bernoulli field on a grid,
      with the m1 x m2 window that contains the most events
      (the two-dimensional discrete scan statistic). Click to redraw. */

(function () {
  "use strict";

  // ---------- 1. Language switcher ----------
  var meta = document.querySelector('meta[name="alt-lang-href"]');
  if (meta) {
    var href = meta.getAttribute("content");
    var otherLang = meta.getAttribute("data-lang");
    var links = document.querySelectorAll('a.nav-link[rel~="alternate"]');
    links.forEach(function (a) {
      a.setAttribute("href", href + (window.location.hash || ""));
      a.setAttribute("hreflang", otherLang);
      a.setAttribute("lang", otherLang);
    });
    // On small screens the menu is collapsed: add a compact switcher
    // next to the search and dark-mode buttons so it stays visible.
    var tools = document.querySelector(".quarto-navbar-tools");
    if (links.length && tools) {
      var c = document.createElement("a");
      c.className = "lang-compact";
      c.href = links[0].getAttribute("href");
      c.hreflang = otherLang;
      c.lang = otherLang;
      c.textContent = otherLang.toUpperCase();
      c.setAttribute("aria-label", links[0].getAttribute("aria-label") || links[0].textContent.trim());
      tools.insertBefore(c, tools.firstChild);
    }
  }

  // ---------- Tabs that can be linked to ----------
  // A page with tabs (e.g. Research: Topics / Publications / Talks) marks
  // each tab with an anchor such as []{#publications}. A link to
  // research.html#publications opens that tab, and choosing a tab updates
  // the address, so the language switch keeps the same tab.
  function paneButton(pane) {
    return pane && document.querySelector('[data-bs-target="#' + pane.id + '"], [href="#' + pane.id + '"][data-bs-toggle="tab"]');
  }
  function openTabFor(hash) {
    if (!hash || hash.length < 2) return;
    var el;
    try { el = document.getElementById(decodeURIComponent(hash.slice(1))); } catch (e) { return; }
    var pane = el && el.closest(".tab-pane");
    var btn = paneButton(pane);
    if (btn && !btn.classList.contains("active")) btn.click();
    if (el) setTimeout(function () { el.scrollIntoView({ block: "start" }); }, 0);
  }
  function syncLangSwitch() {
    if (!meta) return;
    document.querySelectorAll('a.nav-link[rel~="alternate"], a.lang-compact').forEach(function (a) {
      a.setAttribute("href", meta.getAttribute("content") + (window.location.hash || ""));
    });
  }
  document.querySelectorAll('[data-bs-toggle="tab"]').forEach(function (btn) {
    btn.addEventListener("shown.bs.tab", function () {
      var sel = btn.getAttribute("data-bs-target") || btn.getAttribute("href");
      var pane = sel && document.querySelector(sel);
      var anchor = pane && pane.querySelector("span[id]:first-child, p > span[id]:only-child");
      if (anchor && anchor.id) {
        history.replaceState(null, "", "#" + anchor.id);
        syncLangSwitch();
      }
    });
  });
  openTabFor(window.location.hash);
  window.addEventListener("hashchange", function () { openTabFor(window.location.hash); });

  // ---------- External links in a new tab ----------
  // Quarto does this for page content (link-external-newwindow); this also
  // covers the navbar and footer. Same rule as link-external-filter in
  // _quarto.yml: other hosts, and the course sites under /curs-, are external.
  document.querySelectorAll('a[href^="http"]').forEach(function (a) {
    var url;
    try { url = new URL(a.href); } catch (e) { return; }
    var internal = url.host === location.host && !/^\/curs-/.test(url.pathname);
    if (!internal && !a.target) {
      a.target = "_blank";
      a.rel = (a.rel ? a.rel + " " : "") + "noopener";
    }
  });

  // ---------- 2. Scan lattice ----------
  var host = document.getElementById("scan-lattice");
  if (!host) return;

  var lang = (document.documentElement.lang || "ro").slice(0, 2);
  var text = {
    ro: {
      button: "Generează un nou câmp aleator",
      caption: function (s, m1, m2, rows, cols) {
        return "Statistica de scanare bidimensională: fereastra " + m1 + " × " + m2 +
          " cu cele mai multe evenimente dintr-un câmp aleator " + rows + " × " + cols +
          " are S = " + s + ". Apăsați pe grilă pentru un câmp nou.";
      }
    },
    en: {
      button: "Draw a new random field",
      caption: function (s, m1, m2, rows, cols) {
        return "Two-dimensional discrete scan statistic: in this " + rows + " × " + cols +
          " random field, the " + m1 + " × " + m2 + " window with the most events has S = " + s +
          ". Click the grid to draw a new field.";
      }
    }
  }[lang === "en" ? "en" : "ro"];

  var cols = 18, rows = 12, m1 = 4, m2 = 4;       // grid and window size
  var cell = 22, gap = 5, pad = 6, top = 28;       // drawing units
  var W = pad * 2 + cols * cell + (cols - 1) * gap;
  var H = top + pad + rows * cell + (rows - 1) * gap;
  var NS = "http://www.w3.org/2000/svg";

  var button = document.createElement("button");
  button.type = "button";
  button.className = "scan-button";
  button.setAttribute("aria-label", text.button);

  var svg = document.createElementNS(NS, "svg");
  svg.setAttribute("viewBox", "0 0 " + W + " " + H);
  svg.setAttribute("aria-hidden", "true");
  svg.setAttribute("focusable", "false");
  button.appendChild(svg);
  host.appendChild(button);

  var caption = host.parentNode.querySelector("figcaption");

  function xy(i, j) { return [pad + j * (cell + gap), top + i * (cell + gap)]; }

  // cells
  var rects = [];
  for (var i = 0; i < rows; i++) {
    rects.push([]);
    for (var j = 0; j < cols; j++) {
      var r = document.createElementNS(NS, "rect");
      var p = xy(i, j);
      r.setAttribute("x", p[0]); r.setAttribute("y", p[1]);
      r.setAttribute("width", cell); r.setAttribute("height", cell);
      r.setAttribute("rx", 3);
      r.setAttribute("class", "cell");
      svg.appendChild(r);
      rects[i].push(r);
    }
  }
  // window and its label
  var win = document.createElementNS(NS, "rect");
  win.setAttribute("class", "window");
  win.setAttribute("width", m2 * cell + (m2 - 1) * gap + gap);
  win.setAttribute("height", m1 * cell + (m1 - 1) * gap + gap);
  win.setAttribute("rx", 6);
  svg.appendChild(win);
  var tab = document.createElementNS(NS, "rect");
  tab.setAttribute("class", "window-tab");
  tab.setAttribute("height", 22);
  tab.setAttribute("rx", 4);
  svg.appendChild(tab);
  var label = document.createElementNS(NS, "text");
  label.setAttribute("class", "window-label");
  svg.appendChild(label);

  function draw() {
    // Bernoulli(p0) background with a planted region of higher intensity,
    // so that the scan window usually has something to find.
    var p0 = 0.16, p1 = 0.55;
    var ci = Math.floor(Math.random() * (rows - m1 + 1));
    var cj = Math.floor(Math.random() * (cols - m2 + 1));
    var X = [];
    for (var i = 0; i < rows; i++) {
      X.push([]);
      for (var j = 0; j < cols; j++) {
        var hot = i >= ci && i < ci + m1 && j >= cj && j < cj + m2;
        X[i].push(Math.random() < (hot ? p1 : p0) ? 1 : 0);
      }
    }
    // scan statistic: max over all m1 x m2 windows (2-D prefix sums)
    var P = [];
    for (i = 0; i <= rows; i++) { P.push(new Array(cols + 1).fill(0)); }
    for (i = 1; i <= rows; i++) for (j = 1; j <= cols; j++)
      P[i][j] = X[i - 1][j - 1] + P[i - 1][j] + P[i][j - 1] - P[i - 1][j - 1];
    var best = -1, bi = 0, bj = 0;
    for (i = 0; i + m1 <= rows; i++) for (j = 0; j + m2 <= cols; j++) {
      var s = P[i + m1][j + m2] - P[i][j + m2] - P[i + m1][j] + P[i][j];
      if (s > best) { best = s; bi = i; bj = j; }
    }
    for (i = 0; i < rows; i++) for (j = 0; j < cols; j++) {
      var inside = i >= bi && i < bi + m1 && j >= bj && j < bj + m2;
      rects[i][j].setAttribute("class", "cell" + (X[i][j] ? " on" : "") + (inside ? " inside" : ""));
    }
    var p = xy(bi, bj);
    win.setAttribute("x", p[0] - gap / 2);
    win.setAttribute("y", p[1] - gap / 2);
    // a small tab on top of the window carries the value of S
    var tx = p[0] - gap / 2, ty = p[1] - gap / 2 - 22;
    label.textContent = "S = " + best;
    tab.setAttribute("x", tx);
    tab.setAttribute("y", ty);
    tab.setAttribute("width", best >= 10 ? 62 : 54);
    label.setAttribute("x", tx + 8);
    label.setAttribute("y", ty + 16);
    if (caption) caption.textContent = text.caption(best, m1, m2, rows, cols);
  }

  draw();
  button.addEventListener("click", draw);
})();
