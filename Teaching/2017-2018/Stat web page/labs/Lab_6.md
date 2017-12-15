# Laborator 6

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

Obiectivul acestui laborator este de a ilustra noțiunea de consistență a unui estimator precum și de a compara mai mulți estimatori. 




# Exemplu de comparare a trei estimatori

\BeginKnitrBlock{rmdexercise}<div class="rmdexercise">Fie $X_1,X_2,\ldots,X_n$ un eșantion de talie $n$ dintr-o populație normală de medie $\mu$ și varianță $\sigma^2$. Atunci 

$$
  \hat{\mu}_1 = \frac{1}{n}\sum_{i=1}^{n}X_i, \quad \hat{\mu}_2 = M_n\,(\text{mediana}\,), \quad \hat{\mu}_3 = \frac{X_{(1)} + X_{(n)}}{2}
$$

sunt trei estimatori punctuali pentru $\mu$. Creați o funcție care să ilustreze cum sunt repartizați cei trei estimatori. Începeți cu $n = 10$, $\mu = 0$ și $\sigma^2 = 1$ și trasați histogramele pentru a-i compara. Ce se întâmplă dacă schimbați $n$, $\mu$ sau $\sigma^2$ ?

</div>\EndKnitrBlock{rmdexercise}

Vom crea o funcție numită `norm_estimators` care va construi repartițiile celor trei estimatori:


```r
norm_estimators = function(n, mu, sigma, S){
  # Initializam
  mu1 = numeric(S)
  mu2 = numeric(S)
  mu3 = numeric(S)
  
  # repetam experimentul de S ori
  for (i in 1:S){
    x = rnorm(n, mean = mu, sd = sigma)
    
    # calculam estimatorii
    mu1[i] = mean(x)
    mu2[i] = median(x)
    mu3[i] = (min(x)+max(x))/2
  }
  
  # afisam variantele estimatorilor 
  print(cbind(var_mu1 = var(mu1), var_mu2 = var(mu2), var_mu3 = var(mu3)))
  
 return(cbind(mu1 = mu1, mu2 = mu2, mu3 = mu3))
  
}
```

Pentru a ilustra grafic histogramele celor trei estimatori, considerăm $\mu = 0$ și $\sigma^2 = 1$ și avem:


```
          var_mu1     var_mu2    var_mu3
[1,] 0.0009731542 0.001545655 0.06017859
```

<img src="Lab_6_files/figure-html/unnamed-chunk-4-1.png" width="80%" style="display: block; margin: auto;" />

# Ilustrarea consistenței unui estimator

\BeginKnitrBlock{rmdexercise}<div class="rmdexercise">Fie $X_1,X_2,\ldots,X_n$ un eșantion de talie $n$ dintr-o populație $Pois(\theta)$. Ilustrați grafic consistența estimatorului $\hat{\theta}_n = S_n^2$ trasând histograma repartiției lui $\hat{\theta}_n$ pentru $n\in\{10,25,50,100\}$. Ce observați?

</div>\EndKnitrBlock{rmdexercise}

Considerăm funcția `pois_est` care pentru $\theta$ fixat simulează repartiția estimatorului $\hat{\theta}_n$: 


```r
pois_est1 = function(n, theta, S){
  # initializare
  sigma1 = numeric(S)
  
  for (i in 1:S){
    x = rpois(n, theta)
    sigma1[i] = var(x)
  }
  # afisam varianta estimatorului
  print(paste0("Pentru n = ", n," varianta estimatorului este ", var(sigma1)))
  return(sigma1)
}
```

Considerând $\theta = 3$ și $n\in\{10,25,50,100\}$ avem: 


```
[1] "Pentru n = 10 varianta estimatorului este 2.28247869052784"
[1] "Pentru n = 25 varianta estimatorului este 0.869379681294444"
[1] "Pentru n = 50 varianta estimatorului este 0.422022429491448"
[1] "Pentru n = 100 varianta estimatorului este 0.21263884734762"
```

<img src="Lab_6_files/figure-html/unnamed-chunk-7-1.png" width="80%" style="display: block; margin: auto;" />


Ce se întâmplă dacă în loc de $\hat{\theta}_n$ considerăm estimatorul $\tilde{\theta}_n = \bar{X}_n$ sau estimatorul $\dot{\theta}_n = \sqrt{\bar{X}_n S_n^2}$ ?

Pentru $\tilde{\theta}_n$ avem 


```
[1] "Pentru n = 10 varianta estimatorului este 0.30003410547811"
[1] "Pentru n = 25 varianta estimatorului este 0.120876808340007"
[1] "Pentru n = 50 varianta estimatorului este 0.0595150735269105"
[1] "Pentru n = 100 varianta estimatorului este 0.030285847051301"
```

<img src="Lab_6_files/figure-html/unnamed-chunk-8-1.png" width="80%" style="display: block; margin: auto;" />

iar pentru $\dot{\theta}_n$ avem 


```
[1] "Pentru n = 10 varianta estimatorului este 0.765811846058129"
[1] "Pentru n = 25 varianta estimatorului este 0.297314648418354"
[1] "Pentru n = 50 varianta estimatorului este 0.151431550188539"
[1] "Pentru n = 100 varianta estimatorului este 0.0760777653266234"
```

<img src="Lab_6_files/figure-html/unnamed-chunk-9-1.png" width="80%" style="display: block; margin: auto;" />


