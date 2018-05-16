---
title: "Exerciții de seminar 2"
subtitle: Regresie
output:
  html_document:
    code_folding: show
    css: labs_css/labs.css
    keep_md: yes
    number_sections: yes
    toc: yes
    toc_depth: 2
    toc_float:
      collapsed: no
      smooth_scroll: yes
    includes:
      in_header: lab_header/lab_header.html
      after_body: lab_header/lab_footer.html
  word_document:
    fig_caption: yes
    highlight: pygments
    keep_md: yes
    toc: no
  pdf_document:
    includes:
      before_body: tex/body.tex
      in_header: tex/preamble.tex
    keep_tex: yes
    number_sections: yes
    citation_package: natbib
bibliography: references/InstStatFin2018ref.bib
---

<script>
$(document).ready(function ()  {

    // move toc-ignore selectors from section div to header
    $('div.section.toc-ignore')
        .removeClass('toc-ignore')
        .children('h1,h2,h3,h4,h5').addClass('toc-ignore');

    // establish options
    var options = {
      selectors: "h1,h2,h3",
      theme: "bootstrap3",
      context: '.toc-content',
      hashGenerator: function (text) {
        return text.replace(/[.\\/?&!#<>]/g, '').replace(/\s/g, '_').toLowerCase();
      },
      ignoreSelector: ".toc-ignore",
      scrollTo: 60
    };
    options.showAndHide = false;
    options.smoothScroll = true;

    // tocify
    var toc = $("#TOC").tocify(options).data("toc-tocify");
});
</script>

Obiectivul acestui seminar este de a prezenta câteva exerciții de regresie liniară.



# Regresie liniară simplă

## Interpretări geometrice

În această secțiune încercăm să abordăm problema de regresie liniară simplă într-un context geometric. Din punct de vedere vectorial dispunem de doi vectori: vectorul $X = (x_1, x_2, \ldots, x_n)^\intercal$ a celor $n$ observații ale variabilei explicative și vectorul $Y = (y_1, y_2, \ldots, y_n)^\intercal$ compus din cele $n$ observații ale variabilei răspuns, pe care vrem să o explicăm. Cei doi vectori aparțin spațiului $\mathbb{R}^n$. 

Fie $\mathbf{1} = (1,1,\ldots,1)^\intercal\in\mathbb{R}^n$ și $\mathcal{M}(X)$ subspațiul liniar din $\mathbb{R}^n$ de dimensiune $2$ generat de vectorii $\{\mathbf{1}, X\}$ (acești vectori nu sunt coliniari deoarece $X$ conține cel puțin două elemente distincte). Notăm cu $\hat Y$ proiecția ortogonală a lui $Y$ pe subspațiul $\mathcal{M}(X)$ și cum $\{\mathbf{1}, X\}$ formează o bază în $\mathcal{M}(X)$ deducem că există $\hat\beta_0, \hat\beta_1\in \mathbb{R}$ astfel ca $\hat Y = \hat\beta_0\mathbf{1} + \hat\beta_1 X$. Cum, din definiția priecției ortogonale, $\hat Y$ este unicul vector din $\mathcal{M}(X)$ care minimizează distanța euclidiană (deci și pătratul ei)

$$
\left\lVert Y - \hat Y \right\rVert = \sum_{i = 1}^{n}[y_i - (\hat\beta_0 + \hat \beta_1 x_i)]^2
$$ 

deducem că $\hat\beta_0, \hat\beta_1$ coincid cu valorile obținute prin metoda celor mai mici pătrate. Astfel coeficienții $\hat\beta_0$ și $\hat\beta_1$ se reprezintă coordonatele proiecției ortogonale a lui $Y$ pe subspațiul generat de vectorii $\{\mathbf{1}, X\}$ (a se vedea figura de mai jos). 


<img src="images/lab5/RegresiaLiniaraGeom5.png" width="90%" style="display: block; margin: auto;" />

Observăm că, în general, vectorii $\{\mathbf{1}, X\}$ nu formează o bază ortogonală în $\mathcal{M}(X)$ (cu excepția cazului în care $\langle \mathbf{1}, X\rangle = n\bar x = 0$) prin urmare $\hat\beta_0\mathbf{1}$ nu este proiecția ortogonală a lui $Y$ pe $\mathbf{1}$ (aceasta este $\frac{\langle Y, \mathbf{1}\rangle}{\lVert \mathbf{1}\rVert^2}\mathbf{1} = \bar y\mathbf{1}$) iar $\hat\beta_1 X$ nu este proiecția ortogonală a lui $Y$ pe $X$ (aceasta fiind $\frac{\langle Y, X\rangle}{\lVert X\rVert^2}X$).

Fie $\hat\varepsilon = Y - \hat Y = (\hat\varepsilon_1, \hat\varepsilon_2, \ldots, \hat\varepsilon_n)^\intercal$ vectorul valorilor reziduale. Aplicând Teorema lui Pitagora (în triunghiul albastru) rezultă (descompunerea ANOVA pentru regresie) că 

\begin{align*}
  \left\lVert Y - \bar y \mathbf{1}\right\rVert^2 &= \left\lVert \hat Y - \bar y \mathbf{1}\right\rVert^2 + \left\lVert \underbrace{\hat\varepsilon}_{Y - \hat Y}\right\rVert^2\\
  \sum_{i = 1}^{n}(y_i - \bar y)^2 &= \sum_{i = 1}^{n}(\hat y_i - \bar y)^2 + \sum_{i = 1}^{n}(\underbrace{\hat\varepsilon_i}_{y_i - \hat y_i})^2\\
  SS_T &= SS_{reg} + RSS
\end{align*}

Din definiția coeficientului de determinare $R^2$ avem că 

$$
R^2 = \frac{SS_{reg}}{SS_T} = \frac{\left\lVert \hat Y - \bar y \mathbf{1}\right\rVert^2}{\left\lVert Y - \bar y \mathbf{1}\right\rVert^2} = 1 - \frac{\left\lVert \hat \varepsilon\right\rVert^2}{\left\lVert Y - \bar y \mathbf{1}\right\rVert^2}
$$

și conform figurii de mai sus $R^2 = \cos^2(\theta)$. Prin urmare dacă $R^2 = 1$, atunci $\theta = 0$ și $Y\in\mathcal{M}(X)$, deci $y_i = \beta_0 + \beta_1 x_i$, $i\in\{1,2,\ldots,n\}$ (punctele eșantionului sunt perfect aliniate) iar dacă $R^2 = 0$, deducem că $\sum_{i = 1}^{n}(\hat y_i - \bar y)^2 = 0$, deci $\hat y_i = \bar y$ (modelul liniar nu este adaptat în acest caz, nu putem explica mai bine decât media).

## Exercițiul 1

\BeginKnitrBlock{rmdexercise}<div class="rmdexercise">Arătați că estimatorii obținuți prin metoda celor mai mici pătrate, $\hat\beta_0$ și $\hat\beta_1$, sunt estimatori nedeplasați.

</div>\EndKnitrBlock{rmdexercise}

Coeficienții $\hat\beta_0$ și $\hat\beta_1$ obținuți prin metoda celor mai mici pătrate sunt dați de $\hat\beta_0 = \bar y - \hat\beta_1 \bar x$ și $\hat\beta_1 = \frac{\sum_{i = 1}^{n}(x_i - \bar x)(y_i - \bar y)}{\sum_{i = 1}^{n}(x_i - \bar x)^2}$ (aceștia sunt variabile aleatoare deoarece sunt funcții de $Y_i$ care sunt variabile aleatoare). Înlocuind în expresia lui $\hat\beta_1$ pe $y_i$ cu $\beta_0+\beta_1 x_i + \varepsilon_i$ avem 

\begin{align*}
\hat\beta_1 &= \frac{\sum_{i = 1}^{n}(x_i - \bar x)(y_i - \bar y)}{\sum_{i = 1}^{n}(x_i - \bar x)^2} = \frac{\sum_{i = 1}^{n}(x_i - \bar x)y_i}{\sum_{i = 1}^{n}(x_i - \bar x)^2} = \frac{\sum_{i = 1}^{n}(x_i - \bar x)(\beta_0+\beta_1 x_i + \varepsilon_i)}{\sum_{i = 1}^{n}(x_i - \bar x)^2}\\
  &= \frac{\beta_0\overbrace{\sum_{i = 1}^{n}(x_i - \bar x)}^{ = 0} + \beta_1 \sum_{i = 1}^{n}(x_i - \bar x)x_i + \sum_{i = 1}^{n}(x_i - \bar x)\varepsilon_i}{\sum_{i = 1}^{n}(x_i - \bar x)^2} = \frac{\beta_1 \sum_{i = 1}^{n}(x_i - \bar x)^2 + \sum_{i = 1}^{n}(x_i - \bar x)\varepsilon_i}{\sum_{i = 1}^{n}(x_i - \bar x)^2}\\
  &= \beta_1 + \frac{\sum_{i = 1}^{n}(x_i - \bar x)\varepsilon_i}{\sum_{i = 1}^{n}(x_i - \bar x)^2}.
\end{align*}

Conform ipotezei modelului de regresie liniară simplă, $\mathbb{E}[\varepsilon_i] = 0$, prin urmare $\mathbb{E}[\hat\beta_1] = \beta_1$ ceea ce arată că $\hat\beta_1$ este un estimator nedeplasat pentru $\beta_1$.

În mod similar, 

$$
\mathbb{E}[\hat\beta_0] = \mathbb{E}[\bar y] - \bar x\mathbb{E}[\hat\beta_1] = \beta_0 + \bar x\beta_1 - \bar x\beta_1 = \beta_0
$$
ceea ce arată că $\hat\beta_0$ este un estimator nedeplasat pentru $\beta_0$.


\BeginKnitrBlock{rmdexercise}<div class="rmdexercise">Calculați matricea de varianță-covarianță a estimatorilor $\hat\beta_0$ și $\hat\beta_1$.

</div>\EndKnitrBlock{rmdexercise}

Notăm cu $W = \begin{pmatrix}Var(\hat \beta_0) & Cov(\hat \beta_0, \hat \beta_1)\\ Cov(\hat \beta_0, \hat \beta_1) & Var(\hat \beta_1)\end{pmatrix}$ matricea de varianță-covarianță a estimatorilor $\hat\beta_0$ și $\hat\beta_1$.

Avem, folosind expresia lui $\hat\beta_1$ determinată la punctul anterior și homoscedasticitatea și necorelarea erorilor $Cov(\varepsilon_i, \varepsilon_j) = \delta_{ij}\sigma^2$, că 

\begin{align*}
  Var(\hat \beta_1) &= Var\left(\beta_1 + \frac{\sum_{i = 1}^{n}(x_i - \bar x)\varepsilon_i}{\sum_{i = 1}^{n}(x_i - \bar x)^2}\right) = Var\left(\frac{\sum_{i = 1}^{n}(x_i - \bar x)\varepsilon_i}{\sum_{i = 1}^{n}(x_i - \bar x)^2}\right)\\
  &= \frac{Var\left(\sum_{i = 1}^{n}(x_i - \bar x)\varepsilon_i\right)}{\left[\sum_{i = 1}^{n}(x_i - \bar x)^2\right]^2} = \frac{\sum_{i,j}(x_i - \bar x)(x_j - \bar x)Cov(\varepsilon_i, \varepsilon_j)}{\left[\sum_{i = 1}^{n}(x_i - \bar x)^2\right]^2}\\
  &= \frac{\sum_{i = 1}^{n}(x_i - \bar x)^2\sigma^2}{\left[\sum_{i = 1}^{n}(x_i - \bar x)^2\right]^2} = \frac{\sigma^2}{\sum_{i = 1}^{n}(x_i - \bar x)^2}.
\end{align*}

Din expresia $Var(\hat \beta_1)$ observăm că dacă $\sigma^2$ este mică (cu alte cuvinte $y_i$ sunt aproape de dreapta de regresie) atunci estimarea este mai precisă. De asemenea, se constată că pe măsură ce valorile $x_i$ sunt mai dispersate în jurul valorii medii $\bar x$ estimarea coeficientului $\hat \beta_1$ este mai precisă ($Var(\hat \beta_1)$ este mai mică). Acest fenomen se poate observa și în figura de mai jos în care am generat $100$ de valori aleatoare $X$ și $100$ de valori pentru $Y$ după modelul 

$$
  y = 1 + 2 x + \varepsilon
$$
cu $\varepsilon\sim \mathcal{N}(0, \sigma^2)$. Dreapta roșie descrie adevărata relație $f(x) = 1 + 2x$ în populație iar dreapta albastră reprezintă dreapta de regresie calculată cu ajutorul metodei celor mai mici pătrate (OLS). Dreptele albastru deschis au fost generate tot cu ajutorul metodei celor mai mici pătrate atunci când variem $\sigma^2$ (în figura din stânga) și respectiv pe $x_i$ în jurul lui $\bar x$ (în figura din dreapta).

<img src="Sem_2_files/figure-html/unnamed-chunk-5-1.png" width="80%" style="display: block; margin: auto;" />

Pentru a determina $Var(\hat \beta_0)$, vom folosi relația $\hat \beta_0 = \bar y - \hat \beta_1 \bar x$ ceea ce conduce la 

\begin{align*}
Var(\hat \beta_0) &= Var(\bar y - \hat \beta_1 \bar x) = Var(\bar y) - 2Cov(\bar y, \hat \beta_1 \bar x) + Var(\hat \beta_1 \bar x)\\
&= Var\left(\frac{1}{n}\sum_{i = 1}^{n}y_i\right) - 2\bar x Cov(\bar y, \hat \beta_1) + \bar x^2 Var(\hat \beta_1)\\
&= \frac{\sigma^2}{n} + \bar x^2 \frac{\sigma^2}{\sum_{i = 1}^{n}(x_i - \bar x)^2} - 2\bar x Cov(\bar y, \hat \beta_1).
\end{align*}

Pentru $Cov(\bar y, \hat \beta_1)$ avem (ținând cont de faptul că $\beta_0$, $\beta_1$ și $x_i$ sunt constante)

\begin{align*}
Cov(\bar y, \hat \beta_1) &= Cov\left(\frac{1}{n}\sum_{i = 1}^{n}y_i, \beta_1 + \frac{\sum_{j = 1}^{n}(x_j - \bar x)\varepsilon_j}{\sum_{j = 1}^{n}(x_j - \bar x)^2} \right) = \frac{1}{n}\sum_{i = 1}^{n}Cov\left(\beta_0 + \beta_1 x_i + \varepsilon_i, \beta_1 + \frac{\sum_{j = 1}^{n}(x_j - \bar x)\varepsilon_j}{\sum_{j = 1}^{n}(x_j - \bar x)^2}\right)\\
&= \frac{1}{n}\sum_{i = 1}^{n}Cov\left(\varepsilon_i, \frac{\sum_{j = 1}^{n}(x_j - \bar x)\varepsilon_j}{\sum_{j = 1}^{n}(x_j - \bar x)^2}\right) = \frac{1}{n}\sum_{i = 1}^{n}\frac{1}{\sum_{j = 1}^{n}(x_j - \bar x)^2}Cov\left(\varepsilon_i, \sum_{j = 1}^{n}(x_j - \bar x)\varepsilon_j\right)\\
&= \frac{1}{\sum_{j = 1}^{n}(x_j - \bar x)^2}\sum_{i = 1}^{n}\frac{1}{n}\sum_{j = 1}^{n}(x_j - \bar x)Cov(\varepsilon_i, \varepsilon_i=j) = \frac{1}{\sum_{j = 1}^{n}(x_j - \bar x)^2}\sum_{i = 1}^{n}\frac{1}{n}\sum_{j = 1}^{n}(x_j - \bar x)\delta_{ij}\sigma^2\\
&= \frac{\sigma^2}{\sum_{j = 1}^{n}(x_j - \bar x)^2}\frac{1}{n}\underbrace{\sum_{i = 1}^{n}(x_i - \bar x)}_{=0} = 0
\end{align*}

prin urmare 

$$
Var(\hat \beta_0) = \frac{\sigma^2}{n} + \bar x^2 \frac{\sigma^2}{\sum_{i = 1}^{n}(x_i - \bar x)^2} = \frac{\sigma^2\sum_{i = 1}^{n}x_i^2}{n\sum_{i = 1}^{n}(x_i - \bar x)^2}.
$$

Calculul covarianței dintre $\hat \beta_0$ și $\hat \beta_1$ rezultă aplicând relațiile de mai sus

$$
Cov(\hat \beta_0, \hat \beta_1) = Cov(\bar y - \hat \beta_1\bar x, \hat \beta_1) = Cov(\bar y, \hat \beta_1) - \bar x Var(\hat \beta_1) = -\frac{\sigma^2 \bar x}{\sum_{i = 1}^{n}(x_i - \bar x)^2}.
$$

Observăm că $Cov(\hat \beta_0, \hat \beta_1)\leq 0$ iar intuitiv, cum dreapta de regresie (bazată pe estimatorii obținuți prin metoda celor mai mici pătrate) $\bar y = \hat\beta_0 + \hat\beta_1 \bar x$ trece prin centrul de greutate al datelor $(\bar x, \bar y)$, dacă presupunem $\bar x > 0$ remarcăm că atunci când creștem panta (creștem $\hat\beta_1$) ordonata la origine scade (scade $\hat\beta_0$) și reciproc.  

Matricea de varianță-covarianță a estimatorilor $\hat\beta_0$ și $\hat\beta_1$ devine

$$
W = \begin{pmatrix}Var(\hat \beta_0) & Cov(\hat \beta_0, \hat \beta_1)\\ Cov(\hat \beta_0, \hat \beta_1) & Var(\hat \beta_1)\end{pmatrix} = \begin{pmatrix}\frac{\sigma^2\sum_{i = 1}^{n}x_i^2}{n\sum_{i = 1}^{n}(x_i - \bar x)^2} & -\frac{\sigma^2 \bar x}{\sum_{i = 1}^{n}(x_i - \bar x)^2}\\ -\frac{\sigma^2 \bar x}{\sum_{i = 1}^{n}(x_i - \bar x)^2} & \frac{\sigma^2}{\sum_{i = 1}^{n}(x_i - \bar x)^2}\end{pmatrix}.
$$

\BeginKnitrBlock{rmdexercise}<div class="rmdexercise">Arătați că în cadrul modelului de regresie liniară simplă, suma valorilor reziduale este nulă.

</div>\EndKnitrBlock{rmdexercise}

Observăm, folosind definiția $\hat\varepsilon_i = y_i - \hat y_i$, că 

\begin{align*}
  \sum_{i = 1}^{n}\hat\varepsilon_i &= \sum_{i = 1}^{n}(y_i - \hat y_i) = \sum_{i = 1}^{n}(y_i - \hat \beta_0 - x_i\hat\beta_1)\\
    &= \sum_{i = 1}^{n}\left[y_i - \underbrace{(\bar y - \bar x\hat\beta_1)}_{= \hat \beta_0} - x_i\hat\beta_1\right] = \sum_{i = 1}^{n}(y_i - \bar y) -\hat\beta_1 \sum_{i = 1}^{n}(x_i - \bar x) = 0
\end{align*}


\BeginKnitrBlock{rmdexercise}<div class="rmdexercise">Arătați că în modelul de regresie liniară simplă statistica $\hat\sigma^2 = \frac{1}{n-2}\sum_{i = 1}^{n}\hat\varepsilon_i^2$ este un estimator nedeplasat pentru $\sigma^2$.

</div>\EndKnitrBlock{rmdexercise}

Ținând cont de faptul că $\hat\beta_0 = \bar y - \hat\beta_1 \bar x$ și $\bar y = \beta_0 + \beta_1 \bar x + \bar \varepsilon$ (prin însumarea după $i$ a relațiilor $y_i = \beta_0 + \beta_1 x_i +\varepsilon_i$) găsim că 

\begin{align*}
\hat\varepsilon_i &= y_i - \hat y_i = (\beta_0 + \beta_1 x_i +\varepsilon_i) - (\hat\beta_0 + \hat\beta_1 x_i) \\
  &= (\underbrace{\bar y - \beta_1 \bar x - \bar \varepsilon}_{=\beta_0} + \beta_1 x_i +\varepsilon_i) - (\bar y - \hat\beta_1 \bar x + \hat\beta_1 x_i)\\
  &= (\beta_1 - \hat\beta_1)(x_i - \bar x) + (\varepsilon_i - \bar\varepsilon)
\end{align*}

și prin dezvoltarea binomului și utilizând relația $\hat\beta_1 = \beta_1 + \frac{\sum_{i = 1}^{n}(x_i - \bar x)\varepsilon_i}{\sum_{i = 1}^{n}(x_i - \bar x)^2}$ găsim

\begin{align*}
  \sum_{i = 1}^{n}\hat\varepsilon_i^2 &= (\beta_1 - \hat\beta_1)^2\sum_{i = 1}^{n}(x_i - \bar x) + \sum_{i = 1}^{n}(\varepsilon_i - \bar\varepsilon)^2 + 2(\beta_1 - \hat\beta_1)\sum_{i = 1}^{n}(x_i - \bar x)(\varepsilon_i - \bar\varepsilon)\\
    &= (\beta_1 - \hat\beta_1)^2\sum_{i = 1}^{n}(x_i - \bar x) + \sum_{i = 1}^{n}(\varepsilon_i - \bar\varepsilon)^2 + 2(\beta_1 - \hat\beta_1)\sum_{i = 1}^{n}(x_i - \bar x)\varepsilon_i - 2(\beta_1 - \hat\beta_1)\bar\varepsilon\sum_{i = 1}^{n}(x_i - \bar x)\\
    &= (\beta_1 - \hat\beta_1)^2\sum_{i = 1}^{n}(x_i - \bar x) + \sum_{i = 1}^{n}(\varepsilon_i - \bar\varepsilon)^2 - 2(\beta_1 - \hat\beta_1)^2\sum_{i = 1}^{n}(x_i - \bar x)^2\\
    &=\sum_{i = 1}^{n}(\varepsilon_i - \bar\varepsilon)^2 - (\beta_1 - \hat\beta_1)^2\sum_{i = 1}^{n}(x_i - \bar x)^2.
\end{align*}

Luând media găsim că

$$
\mathbb{E}\left(\sum_{i = 1}^{n}\hat\varepsilon_i^2\right) = \mathbb{E}\left(\sum_{i = 1}^{n}(\varepsilon_i - \bar\varepsilon)^2\right) - \sum_{i = 1}^{n}(x_i - \bar x)^2 Var(\hat\beta_1) = (n-1)\sigma^2 - \sigma^2 = (n-1)\sigma^2
$$

unde am folosit că $\mathbb{E}\left(\frac{1}{n-1}\sum_{i = 1}^{n}(\varepsilon_i - \bar\varepsilon)^2\right) = \sigma^2$ (deoarece $Var(\varepsilon_i) = \sigma^2$).

Concluzionăm că $\hat\sigma^2 = \frac{1}{n-2}\sum_{i = 1}^{n}\hat\varepsilon_i^2$ este un estimator nedeplasat pentru $\sigma^2$.

\BeginKnitrBlock{rmdexercise}<div class="rmdexercise">Fie $x_{n+1}$ o nouă valoare pentru variabila $X$ și ne propunem să prezicem valoarea $y_{n+1}$ conform modelului 

$$
  y_{n+1} = \beta_0 + \beta_1 x_{n+1} + \varepsilon_{n+1}
$$

cu $\mathbb{E}[\varepsilon_{n+1}] = 0$, $Var(\varepsilon_{n+1}) = \sigma^2$ și $Cov(\varepsilon_{n+1}, \varepsilon_i)=0$ pentru $i = 1,\ldots,n$. 

Arătați că varianța răspunsului mediu prezis este 

$$
  Var(\hat y_{n+1}) = \sigma^2\left[\frac{1}{n} + \frac{(x_{n+1} - \bar x)^2}{\sum_{i=1}^{n}(x_i - \bar x)^2}\right]
$$
  
iar varianța erorii de predicție $\hat\varepsilon_{n+1}$ satisface $\mathbb{E}[\hat\varepsilon_{n+1}] = 0$ și 

$$
  Var(\hat\varepsilon_{n+1}) = \sigma^2\left[1 + \frac{1}{n} + \frac{(x_{n+1} - \bar x)^2}{\sum_{i=1}^{n}(x_i - \bar x)^2}\right].
$$

</div>\EndKnitrBlock{rmdexercise}

Cum $\hat y_{n+1} = \hat\beta_0 + \hat\beta_1 x_{n+1}$ avem 

\begin{align*}
  Var(\hat y_{n+1}) &= Var(\hat\beta_0 + \hat\beta_1 x_{n+1}) = Var(\hat\beta_0) + 2Cov(\hat\beta_0, \hat\beta_1) + x_{n+1}^2Var(\hat\beta_1)\\
  &= \frac{\sigma^2\sum_{i = 1}^{n}x_i^2}{n\sum_{i = 1}^{n}(x_i - \bar x)^2} - 2\frac{\sigma^2 \bar x}{\sum_{i = 1}^{n}(x_i - \bar x)^2} + \frac{\sigma^2x_{n+1}^2}{\sum_{i = 1}^{n}(x_i - \bar x)^2}\\
  &= \frac{\sigma^2}{\sum_{i = 1}^{n}(x_i - \bar x)^2}\left[\frac{1}{n}\sum_{i = 1}^{n}x_i^2 - 2x_{n+1}\bar x + x_{n+1}^2\right]\\
  &= \frac{\sigma^2}{\sum_{i = 1}^{n}(x_i - \bar x)^2}\left[\frac{1}{n}\sum_{i = 1}^{n}(x_i -\bar x)^2 + \bar x^2 - 2x_{n+1}\bar x + x_{n+1}^2\right]\\
  &= \sigma^2\left[\frac{1}{n} + \frac{(x_{n+1} - \bar x)^2}{\sum_{i=1}^{n}(x_i - \bar x)^2}\right].
\end{align*}

Constatăm că atunci când $x_{n+1}$ este departe de valoarea medie $\bar x$ răspunsul mediu are o variabilitate mai mare. 

Pentru a obține varianța erorii de predicție $\hat\varepsilon_{n+1} = y_{n+1} - \hat y_{n+1}$ să observăm că $y_{n+1}$ depinde doar de $\varepsilon_{n+1}$ pe când $\hat y_{n+1}$ depinde de $\varepsilon_i$, $i\in\{1,2,\ldots,n\}$. Din necorelarea erorilor deducem că

$$
  Var(\hat\varepsilon_{n+1}) = Var(y_{n+1} - \hat y_{n+1}) = Var(y_{n+1}) + Var(\hat y_{n+1}) = \sigma^2\left[1 + \frac{1}{n} + \frac{(x_{n+1} - \bar x)^2}{\sum_{i=1}^{n}(x_i - \bar x)^2}\right].
$$

## Exercițiul 2: Coeficientul de determinare $R^2$ și coeficientul de corelație 

\BeginKnitrBlock{rmdexercise}<div class="rmdexercise">Arătați că

$$
  R^2 = r_{xy}^2 = r_{y\hat y}^2
$$
  
unde $r_{xy}$ este coeficientul de corelație empiric dintre $x$ și $y$.

</div>\EndKnitrBlock{rmdexercise}

Din definiția coeficientului de determinare și folosind coeficienții $\hat\beta_0 = \bar y - \hat\beta_1 \bar x$ și $\hat\beta_1 = \frac{\sum_{i = 1}^{n}(x_i - \bar x)(y_i - \bar y)}{\sum_{i = 1}^{n}(x_i - \bar x)^2}$ obținuți prin metoda celor mai mici pătrate avem 

\begin{align*}
R^2 &= \frac{\left\lVert \hat Y - \bar y \mathbf{1}\right\rVert^2}{\left\lVert Y - \bar y \mathbf{1}\right\rVert^2} = \frac{\sum_{i = 1}^{n}(\hat\beta_0 + \hat\beta_1 x_i - \bar y)^2}{\sum_{i = 1}^{n}(y_i - \bar y)^2} = \frac{\sum_{i = 1}^{n}(\bar y - \hat\beta_1 \bar x + \hat\beta_1\bar x - \bar y)^2}{\sum_{i = 1}^{n}(y_i - \bar y)^2}\\
  &= \frac{\hat\beta_1^2\sum_{i = 1}^{n}(x_i - \bar x)^2}{\sum_{i = 1}^{n}(y_i - \bar y)^2} = \left(\frac{\sum_{i = 1}^{n}(x_i - \bar x)(y_i - \bar y)}{\sum_{i = 1}^{n}(x_i - \bar x)^2}\right)^2\frac{\sum_{i = 1}^{n}(x_i - \bar x)^2}{\sum_{i = 1}^{n}(y_i - \bar y)^2}\\
  & = \frac{\left[\sum_{i = 1}^{n}(x_i - \bar x)(y_i - \bar y)\right]^2}{\sum_{i = 1}^{n}(x_i - \bar x)^2\sum_{i = 1}^{n}(y_i - \bar y)^2} = r_{xy}^2.
\end{align*}

Pentru a verifica a doua parte, $R^2 = r_{y\hat y}^2$, să observăm că 

$$
r_{y\hat y}^2 = \frac{\left[\sum_{i = 1}^{n}(\hat y_i - \bar{\hat y})(y_i - \bar y)\right]^2}{\sum_{i = 1}^{n}(\hat y_i - \bar{\hat y})^2\sum_{i = 1}^{n}(y_i - \bar y)^2}
$$

iar $\bar{\hat y} = \frac{\sum_{i = 1}^{n}\hat y_i}{n} = \hat \beta_0 + \hat\beta_1 \bar x = \bar y$, prin urmare 

$$
r_{y\hat y}^2 = \frac{\left[\sum_{i = 1}^{n}(\hat y_i - \bar{y})(y_i - \bar y)\right]^2}{\sum_{i = 1}^{n}(\hat y_i - \bar{y})^2\sum_{i = 1}^{n}(y_i - \bar y)^2}.
$$

De asemenea 

\begin{align*}
\sum_{i = 1}^{n}(\hat y_i - \bar{y})(y_i - \bar y) &= \sum_{i = 1}^{n}(\hat y_i - \bar{y})(y_i - \hat y_i + \hat y_i - \bar y) \\
 &= \sum_{i = 1}^{n}(\hat y_i - \bar{y})(y_i - \hat y_i) + \sum_{i = 1}^{n}(\hat y_i - \bar{y})^2
\end{align*}

și cum 

\begin{align*}
\sum_{i = 1}^{n}(\hat y_i - \bar{y})(y_i - \hat y_i) &= \sum_{i = 1}^{n}(\hat \beta_0 + \hat\beta_1 x_i - \bar{y})(y_i - \hat \beta_0 - \hat\beta_1 x_i) \\
  &= \sum_{i = 1}^{n}(\bar y - \hat\beta_1 \bar x + \hat\beta_1 x_i - \bar{y})[(y_i - \bar y ) - \hat\beta_1 (x_i - \bar x)]\\
  &= \hat\beta_1 \sum_{i = 1}^{n}(x_i - \bar x)(y_i - \bar y) - \hat\beta_1^2 \sum_{i = 1}^{n}(x_i - \bar x)^2 \\
  &= \underbrace{\frac{S_{xy}}{S_{xx}}}_{\hat\beta_1}S_{xy} - \frac{S_{xy}^2}{S_{xx}^2}S_{xx} = 0
\end{align*}

deducem că $r_{y\hat y}^2 = \frac{\sum_{i = 1}^{n}(\hat y_i - \bar{y})^2}{\sum_{i = 1}^{n}(y_i - \bar y)^2} = R^2$.



