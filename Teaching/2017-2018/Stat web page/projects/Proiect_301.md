# Proiect

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




**Notă:** Raportul poate fi scris în *Microsoft Word* sau \LaTeX (pentru ușurință recomand folosirea pachetului *rmarkdown* din *R* - mai multe informații găsiți pe site la secțiunea *Link-uri utile*). Toate simulările, figurile și codurile folosite trebuie incluse în raport. Se va folosi doar limbajul *R*.

# Problemă

Un segment de lungime $1$ este rupt în trei bucăți. Presupunând că punctele de ruptură sunt date de două variabile aleatoare $X$ și $Y$ repartizate pe $[0,1]$, Scopul acestui exercțiu este să determinăm, în funcție de procedura de alegere a punctelor de ruptură, care este probabilitatea de formare a unui triunghi cu lungimile celor trei segmente obținute. 

**Procedura $1$:** Presupunem că punctele de ruptură sunt date de două variabile aleatoare $X$ și $Y$, independente și repartizate uniform pe intervalul $[0,1]$.

  1. Fie $a$, $b$ și $c$ lungimile celor trei segmente obținute (luate de la stanga la dreapta). Arătați că lungimile celor trei segmente pot forma un triunghi dacă și numai dacă fiecare dintre cele trei lungimi este mai mică sau egală cu $\frac{1}{2}$. Traduceți această condiție in funcție de v.a. $X$ și $Y$.
  
  2. Într-o primă etapă dorim să aproximăm lungimile medii ale celor trei segmente obținute. Pentru aceasta, simulăm $N=5000$ de realizări independente ale cuplului $(X,Y)$. Care sunt valoriile lungimilor medii ? Ce teoremă limită justifică acest rezultat ?

  3. Dorim de asemenea să răspundem într-o manieră mai fină la intrebarea problemei: 
  
    a. Cuplul de puncte $(X,Y)$ de ruptură poate fi văzut ca un punct în pătratul unitate $[0,1]^2$. Plecând de la $5000$ de realizări independente ale cuplului $(X,Y)$, reprezentați grafic punctele $(X_i,Y_i)$ din interiorul pătratului $[0,1]^2$ care determină cele trei segmente cu ajutorul cărora putem forma un triunghi, cu albastru, și pe celelalte cu roșu. 
    
    b. Plecând de la $N=5000$ de realizări independente ale cuplului $(X,Y)$, estimați probabilitatea căutată. 
    
    c. Găsiți această probabilitate teoretic și comparați cu rezultatul găsit la punctul anterior. 
    
  4.^[Această întrebare este mai dificilă și nerezolvarea ei nu scade punctajul proiectului. Cu toate acestea, cine reușește să facă acest subpunct va primi 0.5 puncte suplimentare.] Presupunând că punctele de ruptură sunt date de procedura $1$, ce puteți spune despre probabilitatea de formare a unui triunghi obtuzunghic ? Justificați atât teoretic cât și prin simulare.

Ne întrebăm acum ce se întâmplă cu probabilitatea de formare a unui triunghi cu ajutorul celor trei segmente determinate de punctele de ruptură dacă adoptăm următoarele două proceduri. 
  
**Procedura 2:** Alegem pentru început un punct de ruptură $X$ repartizat uniform $\mathcal{U}([0,1])$ și dintre cele două segmente formate îl alegem pe cel mai lung pe care alegem un al doilea punct, $Y$, repartizat uniform pe acest segment. 

  5. Reconsiderați punctele b. și c. de la punctul 3.
  
  6. Pentru a ilustra grafic regiunea determinată de perechile care verifică problema (formează un triunghi) putem considera variabila aleatoare $Z$ repartizată uniform pe intervalul $[0,1]$ și care să fie independentă de $X$ și să exprimăm lungimile celor trei segmente în funcție de aceasta. Plecând de la $5000$ de realizări independente ale cuplului $(X,Z)$, reprezentați grafic, cu albastru, punctele $(X_i, Z_i)$ din interiorul pătratului $[0,1]$ care determină cele trei segmente cu ajutorul cărora putem forma un triunghi și pe celelalte cu roșu.  

**Procedura 3:** Alegem pentru început un punct de ruptură $X$ repartizat uniform $\mathcal{U}([0,1])$ care va împărții segmentul $[0,1]$ în două subsegmente. Aruncăm, de manieră independentă, o monedă echilibrată și alegem în funcție de rezultatul aruncării, cap sau pajură, segementul din stânga (cap) sau cel din dreapta (pajură). Pe segmentul selecționat alegem un al doilea punct de ruptură, $Y$, repartizat uniform pe acest segment.

  7. Reconsiderați punctele 5. și 6. de la *Procedura 2*.

