---
title: "Laborator 2"
subtitle: Intervale de încredere
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
  pdf_document:
    includes:
      before_body: tex/body.tex
      in_header: tex/preamble.tex
    keep_tex: yes
    number_sections: yes
  word_document:
    fig_caption: yes
    highlight: pygments
    keep_md: yes
    reference_docx: template/template.docx
    toc: no
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

Obiectivul acestui laborator este de a ilustra noțiunea de interval de încredere și a face o serie de exemple. 




# Ilustrarea intervalelor de încredere pentru o populație normală

Generarea intervalelor de încredere:


```r
# cate panouri sa avem 
p = 5

# nr de intervale de incredere per panou
n = 20

# talia esantionului
m = 50 

# coeficient de incredere
alpha = 0.05 

# media si sd populatia normala
mu = 3.5
sd = 1.5

lo3 <- hi3 <- lo2 <- hi2 <- lo <- hi <- vector("list", p)

for(i in 1:p) {
  dat = matrix(rnorm(n*m, mean = mu, sd = sd), ncol = m)
  
  # media si vaianta esantionului 
  me = apply(dat,1,mean)
  se = apply(dat,1,sd)
  
  # calcul intervale de incredere
  lo[[i]] = me - qnorm(1-alpha/2)*sd/sqrt(m)
  hi[[i]] = me + qnorm(1-alpha/2)*sd/sqrt(m)
  
  lo2[[i]] = me - qnorm(1-alpha/2)*se/sqrt(m)
  hi2[[i]] = me + qnorm(1-alpha/2)*se/sqrt(m)
  
  lo3[[i]] = me - qt(1-alpha/2, m-1)*se/sqrt(m)
  hi3[[i]] = me + qt(1-alpha/2, m-1)*se/sqrt(m)
}
```

Intervale de încredere atunci când $\sigma$ este cunoscut: 


```r
r = range(unlist(c(lo,hi,lo2,hi2,lo3,hi3)))

par(mfrow=c(1,5), las=1, mar=c(5.1,2.1,6.1,2.1))

for(i in 1:p) {
  plot(0, 0, type="n", 
       ylim = 0.5+c(0,n), 
       xlim = r, 
       ylab = "", 
       xlab = "", 
       yaxt = "n")
  
  abline(v = mu, lty=2, col="brown3", lwd=2)
  
  segments(lo[[i]], 1:n,
           hi[[i]], 1:n,
           lwd=2)
  
  o = (1:n)[lo[[i]] > 3.5 | hi[[i]] < 3.5]
  
  segments(lo[[i]][o], o,
           hi[[i]][o], o,
           lwd=2,col="orange")
}

par(mfrow=c(1,1))

mtext(expression(paste("100 intervale de încredere pentru ", mu)), 
      side=3, cex=1.5, xpd=TRUE, line=4)
mtext(expression(paste("(",sigma," cunoscut)")), side=3, cex=1.3, 
      xpd=TRUE,line=2.7)
```

<img src="Lab_2_files/figure-html/unnamed-chunk-3-1.png" width="90%" style="display: block; margin: auto;" />

Intervale de încredere **incorecte** atunci când $\sigma$ nu este cunoscut: 


```r
par(mfrow=c(1,5), las=1, mar=c(5.1,2.1,6.1,2.1))

for(i in 1:p) {
  plot(0, 0,
       type="n",
       ylim=0.5+c(0,n),
       xlim=r,
       ylab="",
       xlab="",
       yaxt="n")
  
  abline(v = mu,lty = 2, col="brown3", lwd=2)
  
  segments(lo2[[i]], 1:n,
           hi2[[i]], 1:n,
           lwd=2)
  
  o = (1:n)[lo2[[i]] > 3.5 | hi2[[i]] < 3.5]
  
  segments(lo2[[i]][o],o,
           hi2[[i]][o],o,
           lwd=2, col="orange")
}

par(mfrow=c(1,1))
mtext(expression(paste("100 intervale de încredere incorecte pentru ", mu)), 
      side=3, cex=1.5, xpd=TRUE, line=4)
mtext(expression(paste("(",sigma," necunoscut)")),
      side=3,cex=1.3,xpd=TRUE,line=2.7)
```

<img src="Lab_2_files/figure-html/unnamed-chunk-4-1.png" width="90%" style="display: block; margin: auto;" />

Intervale de încredere **corecte** atunci când $\sigma$ nu este cunoscut: 


```r
par(mfrow=c(1,5), las=1, mar=c(5.1,2.1,6.1,2.1))

for(i in 1:p) {
  plot(0,0,
       type="n",
       ylim=0.5+c(0,n),
       xlim=r,
       ylab="",
       xlab="",
       yaxt="n")
  
  abline(v = mu, lty=2, col="brown3", lwd=2)
  
  segments(lo3[[i]],1:n,
           hi3[[i]],1:n,
           lwd=2)
  
  o = (1:n)[lo3[[i]] > 3.5 | hi3[[i]] < 3.5]
  
  segments(lo3[[i]][o],o,
           hi3[[i]][o],o,
           lwd=2, col="orange")
}
par(mfrow=c(1,1))

mtext(expression(paste("100 intervale de încredere pentru ", mu)),
      side=3, cex=1.5, xpd=TRUE, line=4)

mtext(expression(paste("(",sigma," necunoscut)")),
      side=3, cex=1.3, xpd=TRUE, line=2.7)
```

<img src="Lab_2_files/figure-html/unnamed-chunk-5-1.png" width="90%" style="display: block; margin: auto;" />

# Ilustrarea probabilității de acoperire

## Intervale de încredere de tip Wald

\BeginKnitrBlock{rmdexercise}<div class="rmdexercise">Fie $X_1,X_2,\ldots,X_n$ un eșantion de talie $n$ dintr-o populație Bernoulli de medie $\theta$. Determinați un interval de încredere asimptotic pentru $\theta$ cu un coeficient de încredere $1-\alpha$. 

Ilustrați grafic *probabilitatea de acoperire* $\mathbb{P}_{\theta}\left(IC^{1-\alpha}(\theta)\ni \theta\right)$ ca funcție de $\theta$ pentru diferite valori ale lui $n\in \{50, 100\}$ și $\alpha = 0.05$. Ce observați?
</div>\EndKnitrBlock{rmdexercise}

Știm că $\hat{\theta}_n = \bar{X}_n$ este estimatorul de verosimilitate maximă pentru $\theta$ și folosind proprietatea asimptotică a estimatorilor de verosimilitate maximă găsim că un interval de încredere asimptotic pentru $\theta$ este (folosid o înlocuire de tip Wald)

$$
  IC^{1-\alpha}(\theta) = \bar{X}_n \pm z_{1-\frac{\alpha}{2}}\sqrt{\frac{\bar{X}_n(1-\bar{X}_n)}{n}}.
$$

Probabilitatea de acoperire este:


```r
binom.wald.cvg = function(theta, n, alpha) {
  z = qnorm(1 - alpha / 2)
  
  f = function(p) {
    t = 0:n

    s = sqrt(t * (n - t) / n)
    o = (t - z * s <= n * p & t + z * s >= n * p)
  
    return(sum(o * dbinom(t, size = n, prob = p)))
  }
  
  out = sapply(theta, f)
  return(out)
}
```


```r
# date intrare
par(mfrow = c(1,2))

n = 50
alpha = 0.05

theta = seq(0.01, 0.99, len=200)

plot(theta, binom.wald.cvg(theta, n, alpha), 
     ylim=c(0.5, 1), type="l", lwd=1,
     bty = "n",
     col = "forestgreen", 
     main = paste0("n = ", n),
     xlab = expression(theta), 
     ylab = "Probabilitatea de acoperire")

abline(h = 1-alpha, lty=3, lwd=2,
       col = "brown3")

# al doilea grafic
n = 100

plot(theta, binom.wald.cvg(theta, n, alpha), 
     ylim=c(0.5, 1), type="l", lwd=1,
     bty = "n",
     col = "forestgreen", 
     main = paste0("n = ", n),
     xlab = expression(theta), 
     ylab = "Probabilitatea de acoperire")

abline(h = 1-alpha, lty=3, lwd=2,
       col = "brown3")
```

<img src="Lab_2_files/figure-html/unnamed-chunk-8-1.png" width="90%" style="display: block; margin: auto;" />

Observăm că probabilitatea de acoperire tinde să fie mai scăzută decât pragul $1-\alpha = 0.95$ ales pentru majoritatea valorilor lui $\theta$.


\BeginKnitrBlock{rmdexercise}<div class="rmdexercise">Fie $X_1,X_2,\ldots,X_n$ un eșantion de talie $n$ dintr-o populație Exponențială de parametru $\theta$. Determinați un interval de încredere asimptotic pentru $\theta$ cu un coeficient de încredere $1-\alpha$. 

Ilustrați grafic *probabilitatea de acoperire* $\mathbb{P}_{\theta}\left(IC^{1-\alpha}(\theta)\ni \theta\right)$ ca funcție de $n$ pentru diferite valori ale lui $\theta\in \{1, 3\}$ și $\alpha = 0.05$. Ce observați?
</div>\EndKnitrBlock{rmdexercise}

Știm că $\hat{\theta}_n = \bar{X}_n$ este estimatorul de verosimilitate maximă pentru $\theta$ și folosind proprietatea asimptotică a estimatorilor de verosimilitate maximă găsim că un interval de încredere asimptotic pentru $\theta$ este (folosid o înlocuire de tip Wald)

$$
  IC^{1-\alpha}(\theta) = \bar{X}_n \pm z_{1-\frac{\alpha}{2}}\frac{\bar{X}_n}{\sqrt{n}}.
$$

```r
expo.wald.cvg = function(N, theta, alpha) {
    z = qnorm(1 - alpha / 2)
    
  f = function(n) {
    f1 = 1 - pgamma(n * theta / (1 - z / sqrt(n)), 
                    shape=n, rate=1/theta)
    f2 = pgamma(n * theta / (1 + z / sqrt(n)), 
                shape=n, rate=1/theta)
    return(1 - f1 - f2)
  }
  
  out = sapply(N, f)
  return(out)
}
```



```r
alpha = 0.05
n = seq(100, 1500, by=50)

par(mfrow = c(1,2))

plot(n, expo.wald.cvg(n, 1, alpha), 
     ylim=c(0.945, 0.95), type="l", lwd=2,
     bty = "n", col = "forestgreen",
     main = TeX("$\\theta = 1$"),
     xlab="n", ylab="Probabilitatea de acoperire")

abline(h=1-alpha, lty=3, lwd=2,
       col = "brown3")

plot(n, expo.wald.cvg(n, 3, alpha), 
     ylim=c(0.945, 0.95), type="l", lwd=2,
     bty = "n", col = "forestgreen",
     main = TeX("$\\theta = 3$"),
     xlab="n", ylab="Probabilitatea de acoperire")

abline(h=1-alpha, lty=3, lwd=2,
       col = "brown3")
```

<img src="Lab_2_files/figure-html/unnamed-chunk-11-1.png" width="90%" style="display: block; margin: auto;" />

## Intervale de încredere folosid transformări stabilizatoare de varianță 

\BeginKnitrBlock{rmdinsight}<div class="rmdinsight">Spune că o funcție $g$ este stabilizatoare de varianță dacă verifică ecuația diferențială:
  
$$
  \left[g'(\theta)\right]^{2} = c^2 I_1(\theta), \quad c>0
$$

unde $I_1(\theta)$ este informația lui Fisher.</div>\EndKnitrBlock{rmdinsight}

\BeginKnitrBlock{rmdexercise}<div class="rmdexercise">Fie $X_1,X_2,\ldots,X_n$ un eșantion de talie $n$ dintr-o populație Bernoulli de medie $\theta$. Determinați o funcție stabilizatoare de varianță și găsiâi un interval de încredere asimptotic pentru $\theta$ cu un coeficient de încredere $1-\alpha$. 

Ilustrați grafic *probabilitatea de acoperire* $\mathbb{P}_{\theta}\left(IC^{1-\alpha}(\theta)\ni \theta\right)$ ca funcție de $\theta$ pentru diferite valori ale lui $n\in \{50, 100\}$ și $\alpha = 0.05$. Ce observați acum?
</div>\EndKnitrBlock{rmdexercise}

Observăm că pentru $g(\theta) = \arcsin{\sqrt{\theta}}$ avem 

$$
  g'(\theta) = \frac{1}{2}\frac{1}{\sqrt{\theta(1-\theta)}}
$$
deci 

$$
\left[g'(\theta)\right]^{2} = \frac{1}{4} I_1(\theta)
$$

și găsim un interval de încredere de tipul 

$$
  IC^{1-\alpha}(\theta) = \sin^2\left(\arcsin{\sqrt{\bar{X}_n}} \pm z_{1-\frac{\alpha}{2}}\frac{1}{16n^2}\right)
$$


```r
binom.vst.cvg = function(theta, n, alpha) {
  z = qnorm(1 - alpha / 2)
  
  f = function(p) {
    t = 0:n
    a = asin(sqrt(t / n))
    s = z / 2 / sqrt(n)
    
    o = (a - s <= asin(sqrt(p)) & a + s >= asin(sqrt(p)))
    
    return(sum(o * dbinom(t, size=n, prob=p)))
  }
  
  out = sapply(theta, f)
  return(out)
}
```


```r
# date intrare
par(mfrow = c(1,2))

n = 50
alpha = 0.05

theta = seq(0.01, 0.99, len=200)

plot(theta, binom.vst.cvg(theta, n, alpha), 
     ylim=c(0.5, 1), type="l", lwd=1,
     bty = "n",
     col = "forestgreen", 
     main = paste0("n = ", n),
     xlab = expression(theta), 
     ylab = "Probabilitatea de acoperire")

abline(h = 1-alpha, lty=3, lwd=2,
       col = "brown3")

# al doilea grafic
n = 100

plot(theta, binom.vst.cvg(theta, n, alpha), 
     ylim=c(0.5, 1), type="l", lwd=1,
     bty = "n",
     col = "forestgreen", 
     main = paste0("n = ", n),
     xlab = expression(theta), 
     ylab = "Probabilitatea de acoperire")

abline(h = 1-alpha, lty=3, lwd=2,
       col = "brown3")
```

<img src="Lab_2_files/figure-html/unnamed-chunk-15-1.png" width="90%" style="display: block; margin: auto;" />

Observăm că probabilitatea de acoperire în acest caz este mai aproape de ținta de $1-\alpha = 0.95$ comparativ cu exemplul anterior.
