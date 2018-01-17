# Laborator Suplimentar

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

Obiectivul acestui laborator suplimentar este de a prezenta în limbajul R soluția unei probleme de predicție a locației într-un sistem de poziționare interior^[Acest laborator este inspirat din lucrarea lui Thomas King, Stephan Kopf, Thomas Haenselmann, Christian Lubberger și Wolfgang Effelsberg *COMPASS: A probabilistic indoor positioning system based on 802.11 and digital compasses*, In Proceedings of the 1st international workshop on Wireless network testbeds, experimental evaluation characterization (September 2006), pp. 34-40 și reproduce parte din capitolul *Predicting location via Indoor Positioning Systems* din cartea lui Deborah Nolan și Duncan T. Lang *Data Science in R*, CRC Press, 2015].





# Contextul problemei

Scopul acestui exemplu este de a construi un sistem de localizare a poziției unei persoane în interiorul unei clădiri (IPS - Indoor Positioning System) pe baza intensității semnalelor WiFi detectate de la diferite puncte de acces la rețea fixe (access points). Pentru a construi un astfel de sistem avem nevoie de un set de date de referință care să conțină informații despre intensitatea semnalului, măsurat în diferite locații predefinite din interiorul clădirii, dintre un device mobil (de exemplu un telefon mobil sau un laptop) și diferite puncte de acces fixe (de exemplu routere). Având aceste date încercăm să construim un model de localizare a device-ului mobil ca funcție de intensitatea semnalului dintre acesta și fiecare punct de acces care să permită apoi prezicerea locației unui nou semnal.

Datele provin din două fișiere .txt, numite [*offline*](lab_IPS_data/offline.final.trace.txt) și [*online*](lab_IPS_data/online.final.trace.txt), care se găsesc pe site-ul [CRAWDAD](https://crawdad.org/mannheim/compass/20080411/) (A Community Resource for Archiving Wireless Data At Dartmouth). Setul de date *offline* conține măsurători ale intensității semnalului folosind un laptop IBM Thinkpad R51 pe un grid de 166 de puncte distanțate la un metru fiecare și distribuite pe o suprafață de aproximativ 312 $m^2$ aparținând holului unui birou construit în campusul Universității din Mannheim (suprafața totală $15\times 32$ - vezi planul de mai jos în care cerculețele gri reprezintă locațiile măsurătorilor offline și pătratele negre sunt locațiile punctelor de acces - 6). 

<img src="lab_IPS_data/building.jpg" width="90%" style="display: block; margin: auto;" />

În plus față de coordonatele $(x,y)$ ale device-ului mobil ne sunt furnizate și orientările acestuia. Intensitatea semnalelor a fost înregistrată pentru 8 orientări diferite (0, 45, 90, 135, 180, 225, 270, 315), înregistrându-se un total de 110 măsurători pentru fiecare punct de acces și fiecare combinație de locație-orientare. 

Al doilea set de date, numit *online*, conține 110 înregistrări ale intensității semnalului măsurate pentru fiecare punct de acces și pentru 60 de locații și orientări alese aleator. Acest set de date va fi folosit pentru prezicerea poziției unui device mobil.  

În ambele seturi de date, *offline* și *online*, o parte din cele 110 intensități de semnale nu au fost înregistrate și în plus pot apărea și măsurători de la alte device-uri din vecinătatea unității experimentale (e.g. de la alte laptop-uri sau telefoane). 

# Descrierea și curățarea datelor 

În această etapă vom preprocesa datele din formatul raw (neprelucrat) și le vom explora în vederea analizei ulterioare. Dacă deschidem fișierul *offline.final.trace.txt* cu ajutorul unui editor de text (de exemplu [Notepad++](https://notepad-plus-plus.org/)) putem vedea forma generală a înregistrărilor pentru a ne face o imagine preliminară asupra acestora. O primă intrare este de forma:


```
 [1] "# timestamp=2006-02-11 08:31:58"   
 [2] "# usec=250"                        
 [3] "# minReadings=110"                 
 [4] "t=1139643118358"                   
 [5] "id=00:02:2D:21:0F:33"              
 [6] "pos=0.0,0.0,0.0"                   
 [7] "degree=0.0"                        
 [8] "00:14:bf:b1:97:8a=-38,2437000000,3"
 [9] "00:14:bf:b1:97:90=-56,2427000000,3"
[10] "00:0f:a3:39:e1:c0=-53,2462000000,3"
[11] "00:14:bf:b1:97:8d=-65,2442000000,3"
[12] "00:14:bf:b1:97:81=-65,2422000000,3"
[13] "00:14:bf:3b:c7:c6=-66,2432000000,3"
[14] "00:0f:a3:39:dd:cd=-75,2412000000,3"
[15] "00:0f:a3:39:e0:4b=-78,2462000000,3"
[16] "00:0f:a3:39:e2:10=-87,2437000000,3"
[17] "02:64:fb:68:52:e6=-88,2447000000,1"
[18] "02:00:42:55:31:00=-84,2457000000,1"
```

Tabelul de mai jos prezintă descrierea variabilelor care apar în seturile de date *offline* și *online*:

| Variabila | Scurtă descriere |
|:------|:----------------------------------------------|
| t | timestamp-ul calculată în milisecunde de la miezul nopții zilei de 1 Ianuarie 1970 |
| id | adresa MAC a device-ului cu care s-a scanat |
| pos | poziția fizică a device-ului cu care s-a scanat |
| degree | unghiul de orientare a device-ului cu care s-a scanat |
| MAC | adresa MAC a unui device respondent cu valoarea intensității semnalului în dBm, frecvența canalului și tipul acestuia (punct de acces = 3 și device adhoc = 1) |

Deoarece datele nu vin într-un format bine definit le vom citi fișierul *offline.final.trace.txt* cu ajutorul funcției `readLines()` și apoi ne vom uita la numărul de linii care încep cu $\#$:


```r
doc = readLines("lab_IPS_data/offline.final.trace.txt")
sum(substr(doc,1,1) == "#") # nr de linii care incep cu "#"
[1] 5312
length(doc) # cate linii are documentul
[1] 151392

# cate linii avem de fapt 
# coincide cu nr pe care ne asteptam sa-l avem 
length(doc) - sum(substr(doc,1,1) == "#") 
[1] 146080
# ne asteptam la 
166*8*110 
[1] 146080
```

## Preprocesarea datelor 

În această secțiune vrem să scriem o funcție care să permită transformarea datelor din formatul brut într-un format tabelar (un data.frame) care să aibă drept coloane variabile precum timpul (time), id-ul adresei MAC a device-ului cu care am scanat (mac-id), locația device-ului (coordonatele $x,y,z$), orientarea device-ului, adresa MAC a emitentului semnalului, intensitatea semnalului, frecvența canalului de transmitere precum și tipul de emitent (punct de acces sau device adhoc). 

Dacă ne uităm la prima intrare din setul de date *offline* care nu este un comentariu (nu începe cu $\#$) atunci observăm că numele variabilei este separat de valoarea acesteia prin semnul $=$ iar în situații precum poziția valorile sunt separate prin $,$:


```r
strsplit(doc[4], ";")[[1]]
 [1] "t=1139643118358"                   
 [2] "id=00:02:2D:21:0F:33"              
 [3] "pos=0.0,0.0,0.0"                   
 [4] "degree=0.0"                        
 [5] "00:14:bf:b1:97:8a=-38,2437000000,3"
 [6] "00:14:bf:b1:97:90=-56,2427000000,3"
 [7] "00:0f:a3:39:e1:c0=-53,2462000000,3"
 [8] "00:14:bf:b1:97:8d=-65,2442000000,3"
 [9] "00:14:bf:b1:97:81=-65,2422000000,3"
[10] "00:14:bf:3b:c7:c6=-66,2432000000,3"
[11] "00:0f:a3:39:dd:cd=-75,2412000000,3"
[12] "00:0f:a3:39:e0:4b=-78,2462000000,3"
[13] "00:0f:a3:39:e2:10=-87,2437000000,3"
[14] "02:64:fb:68:52:e6=-88,2447000000,1"
[15] "02:00:42:55:31:00=-84,2457000000,1"
```

Pentru a separa șirul de caractere `doc[4]` în funcție de $;$, $=$ sau $,$ folosim expresia regulată `[;=,]` ca argument a funcției `strsplit()`:


```r
tokens = strsplit(doc[4], "[;=,]")[[1]]
tokens[c(2,4,6:8, 10)] # doar valorile primelor 6 variabile
[1] "1139643118358"     "00:02:2D:21:0F:33" "0.0"              
[4] "0.0"               "0.0"               "0.0"              

# pt celelalte 4 variabile: MAC, signal, channel, device type
tokens[-(1:10)]
 [1] "00:14:bf:b1:97:8a" "-38"               "2437000000"       
 [4] "3"                 "00:14:bf:b1:97:90" "-56"              
 [7] "2427000000"        "3"                 "00:0f:a3:39:e1:c0"
[10] "-53"               "2462000000"        "3"                
[13] "00:14:bf:b1:97:8d" "-65"               "2442000000"       
[16] "3"                 "00:14:bf:b1:97:81" "-65"              
[19] "2422000000"        "3"                 "00:14:bf:3b:c7:c6"
[22] "-66"               "2432000000"        "3"                
[25] "00:0f:a3:39:dd:cd" "-75"               "2412000000"       
[28] "3"                 "00:0f:a3:39:e0:4b" "-78"              
[31] "2462000000"        "3"                 "00:0f:a3:39:e2:10"
[34] "-87"               "2437000000"        "3"                
[37] "02:64:fb:68:52:e6" "-88"               "2447000000"       
[40] "1"                 "02:00:42:55:31:00" "-84"              
[43] "2457000000"        "1"                
```

Valorile din `tokens[-(1:10)]` pot fi văzute ca o matrice cu 4 coloane și câte un rând pentru fiecare adresă de MAC emitentă. Următoarea funcție înglobează aceste operații în vederea aplicârii ei pe întreg setul de date (mai exact pentru fiecare rând din setul de date *offline*). Ea conține de asemenea și cazul în care sunt intrări în setul de date care nu au niciun semnal:


```r
processLine = function(x){
  # x este linia documentului 
  # luam in considerare liniile mai scurte - cele care au mai 
  # putin de 10 variabile (nu avem observatii de semnal)
  tokens = strsplit(x, "[;=,]")[[1]]
  # pt obs care au 10 obs
  if (length(tokens) == 10){
    return(NULL)
  }
  
  tmp = matrix(tokens[-(1:10)], ncol = 4, byrow = TRUE)
  cbind(matrix(tokens[c(2,4,6:8, 10)], 
               nrow = nrow(tmp), ncol = 6, byrow = TRUE),tmp)
}
```

Apelăm această funcție pe întreg setul de date:


```r
# stergem liniile cu # din setul de date
lines = doc[substr(doc, 1, 1) != "#"]

tmp = lapply(lines, processLine) # procesam fiecare linie din doc

# combina data intr-un data.frame 
# uneste toate matricele din lista obtinuta folosind do.call()
offline = as.data.frame(do.call("rbind", tmp), 
                        stringsAsFactors = FALSE)

str(offline)
'data.frame':	1181628 obs. of  10 variables:
 $ V1 : chr  "1139643118358" "1139643118358" "1139643118358" "1139643118358" ...
 $ V2 : chr  "00:02:2D:21:0F:33" "00:02:2D:21:0F:33" "00:02:2D:21:0F:33" "00:02:2D:21:0F:33" ...
 $ V3 : chr  "0.0" "0.0" "0.0" "0.0" ...
 $ V4 : chr  "0.0" "0.0" "0.0" "0.0" ...
 $ V5 : chr  "0.0" "0.0" "0.0" "0.0" ...
 $ V6 : chr  "0.0" "0.0" "0.0" "0.0" ...
 $ V7 : chr  "00:14:bf:b1:97:8a" "00:14:bf:b1:97:90" "00:0f:a3:39:e1:c0" "00:14:bf:b1:97:8d" ...
 $ V8 : chr  "-38" "-56" "-53" "-65" ...
 $ V9 : chr  "2437000000" "2427000000" "2462000000" "2442000000" ...
 $ V10: chr  "3" "3" "3" "3" ...
```

Cum data.frame-ul obținut conține numai variabile de tip `character` următorul pas constă în transformarea acestora după tipul corespunzător, e.g. intensitatea semnalului să devină `numeric`. 


```r
# dam nume variabilelor
names(offline) = c("time","scanMac", "posX", "posY", "posZ", 
                   "orientation", "mac", "signal", "channel", "type")

# convertim variabilele numerice
numVars = c("time", "posX", "posY", "posZ", "orientation",  "signal")
offline[numVars] = lapply(offline[numVars], as.numeric)
```

Cum suntem interasați doar de semnale care provin de la punctele de acces putem să eliminăm înregistrările care conțin adrese de la device-uri adhoc (`type = 3`). 


```r
offline = offline[offline$type == "3", ]

# stergem variabila type
offline = offline[ , names(offline) != "type"] 
dim(offline)
[1] 978443      9
```

Dacă ne uităm la variabila `time` și ținem cont de descrierea din tabelul de mai sus putem să o transformăm în formatul `POSIXt` pentru a putea ulterior să efectuăm operații cu ea în R (să remarcăm totuși că timpul în setul de date este măsurat în milisecunde față de data de referință 01.01.1970 iar în formatul amintit timpul este măsurat față de aceeași dată de referință numai că în secunde, deci se impune o transformare):


```r
offline$rawTime = offline$time
# transformam timpul din millisecunde in secunde
offline$time = offline$time/1000  
class(offline$time) = c("POSIXt", "POSIXct")
```

Vrem să verificăm cum arată fiecare variabilă din setul de date aplicând funcția `summary` (pentru variabile de tip caracter trebuie să le transformăm în prealabil în date de tip `factor` pentru a putea aplica funcția `summary` și în acest caz obținem câte observații avem din fiecare valoarea unică a variabilelor calitative avem): 


```r
# variabilele numerice
summary(offline[, numVars])
      time                          posX            posY       
 Min.   :2006-02-11 09:31:58   Min.   : 0.00   Min.   : 0.000  
 1st Qu.:2006-02-11 15:21:27   1st Qu.: 2.00   1st Qu.: 3.000  
 Median :2006-02-11 21:57:58   Median :12.00   Median : 6.000  
 Mean   :2006-02-16 16:57:37   Mean   :13.52   Mean   : 5.897  
 3rd Qu.:2006-02-19 16:52:40   3rd Qu.:23.00   3rd Qu.: 8.000  
 Max.   :2006-03-09 22:41:10   Max.   :33.00   Max.   :13.000  
      posZ    orientation        signal     
 Min.   :0   Min.   :  0.0   Min.   :-99.0  
 1st Qu.:0   1st Qu.: 90.0   1st Qu.:-69.0  
 Median :0   Median :180.0   Median :-60.0  
 Mean   :0   Mean   :167.2   Mean   :-61.7  
 3rd Qu.:0   3rd Qu.:270.0   3rd Qu.:-53.0  
 Max.   :0   Max.   :359.9   Max.   :-25.0  

# variabilele calitative - trebuie transformate in factor
summary(sapply(offline[, c("mac", "channel", "scanMac")], 
               as.factor))
                mac               channel                    scanMac      
 00:0f:a3:39:e1:c0:145862   2462000000:189774   00:02:2D:21:0F:33:978443  
 00:0f:a3:39:dd:cd:145619   2437000000:152124                             
 00:14:bf:b1:97:8a:132962   2412000000:145619                             
 00:14:bf:3b:c7:c6:126529   2432000000:126529                             
 00:14:bf:b1:97:90:122315   2427000000:122315                             
 00:14:bf:b1:97:8d:121325   2442000000:121325                             
 (Other)          :183831   (Other)   :120757                             
```

Uitându-ne la rezultatele obținute mai sus remarcăm că variabila `scanMac` are o singură valoarea ceea ce ne spune că datele au fost culese cu un singur aparat și prin urmare putem să renunțăm la această variabilă. De asemenea variabila `posZ` este constantă $0$ ceea ce înseamnă că toate măsurătorile au fost luate de la același nivel și putem renunța și la această variabilă. 


```r
offline = offline[, !names(offline) %in% c("scanMac", "posZ")]
```

## Să explorăm orientările

În această secțiune ne oprim să studiem un pic orientările device-ului mobil care a înregistrat datele. Conform documentației, ne așteptăm ca setul de date să conțină 8 orientări (0, 45, 90, 135, 180, 225, 270, 315) numai că găsim 


```r
length(unique(offline$orientation))
[1] 203
```

iar funția de repartiție empirică a acestora este 

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-16-1.png" width="90%" style="display: block; margin: auto;" />

ceea ce arată că observațiile sunt aglomerate în jurul celor 8 valori de orientare. Următoarea funcție permite transformarea unghiurilor din setul de date în unghiurile corespunzătoare orientăriilor celor mai apropiate (e.g. $47.5$ se duce în $45$ și $358.2$ se duce în $0$)


```r
roundOrientation = function(angles){
  refs = seq(0,360, by = 45)
  q = sapply(angles, function(x){
        which.min(abs(x-refs))
      })# indicii minimului 
  a = c(refs[1:8], 0)# schimba 360 in 0 
  return(a[q])
}
```

Schimbând orientările obținem rezultatul așteptat


```r
offline$angle = roundOrientation(offline$orientation)
```

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-19-1.png" width="90%" style="display: block; margin: auto;" />

## Să explorăm adresele MAC emitente

Dacă ne uităm la datele sumarizate ale adreselor MAC emitente (ale punctelor de acces) și ale frecvenței canalelor de emisie am putea concluziona că există o bijecție între acestea: 


```
                mac               channel      
 00:0f:a3:39:e1:c0:145862   2462000000:189774  
 00:0f:a3:39:dd:cd:145619   2437000000:152124  
 00:14:bf:b1:97:8a:132962   2412000000:145619  
 00:14:bf:3b:c7:c6:126529   2432000000:126529  
 00:14:bf:b1:97:90:122315   2427000000:122315  
 00:14:bf:b1:97:8d:121325   2442000000:121325  
 (Other)          :183831   (Other)   :120757  
```

Dacă ne uităm la câte observații din fiecare adresă MAC avem, obținem că sunt trei adrese cu un număr foarte mic de observații în comparație cu celelalte ceea ce implică că aceste device-uri nu au fost aria de test (poate au provenit de la un alt etaj) sau nu au fost active pe toată durata testului. 


```r
table(offline$mac)

00:04:0e:5c:23:fc 00:0f:a3:39:dd:cd 00:0f:a3:39:e0:4b 00:0f:a3:39:e1:c0 
              418            145619             43508            145862 
00:0f:a3:39:e2:10 00:14:bf:3b:c7:c6 00:14:bf:b1:97:81 00:14:bf:b1:97:8a 
            19162            126529            120339            132962 
00:14:bf:b1:97:8d 00:14:bf:b1:97:90 00:30:bd:f8:7f:c5 00:e0:63:82:8b:a9 
           121325            122315               301               103 
```

Conform documentației setului de date știm că punctele de acces consistă din 5 routere Linksys/Cisco și un router Lancom L-54g. Accesând pagina [http://coffer.com/mac_find/](http://coffer.com/mac_find/) găsim că adresele care încep cu `00:14:bf` aparțin producătorului Linksys/Cisco dar nu găsim o corespondență cu routerul Lancom L-54g și prin urmare vom păstra primele 7 adrese după numărul de observații. 


```r
subMacs = names(sort(table(offline$mac), decreasing = TRUE))[1:7]

# stergem observatiile canu nu se MAC-ul corespunzator
offline = offline[offline$mac %in% subMacs, ]

# verificam daca avem corespondenta bijectiva
table(offline[c("mac", "channel")])
                   channel
mac                 2412000000 2422000000 2427000000 2432000000 2437000000
  00:0f:a3:39:dd:cd     145619          0          0          0          0
  00:0f:a3:39:e1:c0          0          0          0          0          0
  00:14:bf:3b:c7:c6          0          0          0     126529          0
  00:14:bf:b1:97:81          0     120339          0          0          0
  00:14:bf:b1:97:8a          0          0          0          0     132962
  00:14:bf:b1:97:8d          0          0          0          0          0
  00:14:bf:b1:97:90          0          0     122315          0          0
                   channel
mac                 2442000000 2462000000
  00:0f:a3:39:dd:cd          0          0
  00:0f:a3:39:e1:c0          0     145862
  00:14:bf:3b:c7:c6          0          0
  00:14:bf:b1:97:81          0          0
  00:14:bf:b1:97:8a          0          0
  00:14:bf:b1:97:8d     121325          0
  00:14:bf:b1:97:90          0          0
```

Cum avem o corespondență bijectivă între adresele MAC emitente și frecvența canalelor de emisie putem elimina variabila `channel` din setul de date:


```r
# stergem variabila channel
offline = offline[, names(offline)!="channel"]
```

## Să explorăm poziția device-ului mobil

Investigăm care sunt locațiile diferite în care s-au înregistrat datele și pentru aceasta apelăm funcția `by()`. 


```r
# functia by() verifica toate pereichile posibile
# aplica o functie la un data.frame impartiti dupa diverse categorii
locDF = with(offline, by(offline, list(posX, posY), 
                         function(x) x))
length(locDF) # marimea listei
[1] 476
```

Conform documentației ne așteptăm să avem $166$ de locații dar găsim că avem 476, diferența reiese din faptul că multe din pozițiile rezultate aplicând funcția `by()` sunt nule, mai exact avem 


```r
sum(sapply(locDF, is.null))
[1] 310

# eliminam elementele nule
locDF = locDF[!sapply(locDF, is.null)]
```

Pentru a determina câte observații avem pentru fiecare locație în parte și a reprezenta grafic aceste date avem:


```r
# pastram si pozitia
locCounts = sapply(locDF, function(df){
  # fiecare element din locDF este un data.frame cu 8 coloane 
  c(df[1, c("posX","posY")], count = nrow(df))
})

locCounts[, 1:8]
      [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8]
posX  0    1    2    0    1    2    0    1   
posY  0    0    0    1    1    1    2    2   
count 5505 5505 5506 5524 5543 5558 5503 5564

# pentru grafic 
locCounts = t(locCounts) # transpunem 
```


```
Graficul cu coordonatele locatiilor
```

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-27-1.png" width="90%" style="display: block; margin: auto;" />


```
Graficul cu numarul de observatii din fiecare locatie
```

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-28-1.png" width="90%" style="display: block; margin: auto;" />

Pentru reproductibilitate, sumarizăm toate operațiile efectuate până acum într-o singură funcție `readData()`:


```r
# Corpul functiei readData()
#----------------------------

readData = 
  function(filename = 'lab_IPS_data/offline.final.trace.txt', 
                   subMacs = c("00:0f:a3:39:e1:c0", 
                               "00:0f:a3:39:dd:cd", 
                               "00:14:bf:b1:97:8a",
                               "00:14:bf:3b:c7:c6", 
                               "00:14:bf:b1:97:90", 
                               "00:14:bf:b1:97:8d",
                               "00:14:bf:b1:97:81"))
  {
    # functia care citeste si curata datele  
    
    doc = readLines(filename)# citeste data 
    doc = doc[substr(doc,1,1)!="#"]# sterge comment-urile 
    
    tmp = lapply(doc, processLine) # proceseaza documentul
    offline = as.data.frame(do.call("rbind", tmp), 
                            stringsAsFactors = FALSE)# in data.frame
    
    # numele variabilelor  
    names(offline) = c("time","scanMac", "posX", "posY", 
                       "posZ", "orientation", "mac", 
                       "signal", "channel", "type")
    
    # pastram semnale de la punctele de acces
    offline = offline[ offline$type == "3", ]
    
    # eliminam var scanMac, posZ, channel, si type - 
    #contin informatie redundanta
    dropVars = c("scanMac", "posZ", "channel", "type")
    offline = offline[ , !( names(offline) %in% dropVars ) ]
    
    # eliminam punctele de acces care nu prezinta interes
    offline = offline[ offline$mac %in% subMacs, ]
    
    # transform variabilele in numeric 
    numVars = c("time", "posX", "posY", "orientation", "signal")
    offline[numVars] = lapply(offline[numVars], as.numeric)
    
    # pastram timpul raw
    offline$rawTime = offline$time
    offline$time = offline$time/1000 # ms in s
    class(offline$time) = c("POSIXt", "POSIXct")
    
    # rotunjim orientarile la 45 
    offline$angle = roundOrientation(offline$orientation)
    
    return(offline)
    
    # fct de procesare 
    processLine = function(x){
      # x este linia documentului 
      # luam in considerare liniile mai scurte - cele care au mai 
      # putin de 10 variabile (nu avem observatii de semnal)
      tokens = strsplit(x, "[;=,]")[[1]]
      # pt obs care au 10 obs
     
      if (length(tokens) == 10){
        return(NULL)
      }
      
      tmp = matrix(tokens[-(1:10)], ncol = 4, byrow = TRUE)
      cbind(matrix(tokens[c(2,4,6:8, 10)], nrow = nrow(tmp), 
                   ncol = 6, byrow = TRUE),tmp)
    }
    
    # Functia de rotunjire a orientarilor 
    roundOrientation = function(angles){
      refs = seq(0,360, by = 45)
      q = sapply(angles, function(x){
        which.min(abs(x-refs))
      })
      a = c(refs[1:8], 0)# 360 -> 0 
      return(a[q])
    }
  }
```

Apelăm funcția 


```r
offline = readData()
```


# Analiza intensității semnalului 

În această secțiune ne propunem să investigăm care este comportamentul variabilei intensitatea semnalului și să investigăm cum locația, orientarea și punctul de acces poate influența repartiția intensității semnalului. 

## Repartiția intensității semnalului 

Ne propunem să comparăm cum este repartizată intensitatea semnalului în funcție de diferite unghiuri de orientare și diferite puncte de acces. Fixând o locație (e.g. $(x,y)=(22,4)$) ne uităm cum variază intensitatea semnalului odată cu schimbarea orientării:

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-31-1.png" width="90%" style="display: block; margin: auto;" />

Să ne reamintim că intensitatea semnalului se măsoară în valori negative cu valori mici de tipul $-98$ însemnând semnale slabe și valori mar de tipul $-25$ însemnând intensitate puternică. Repartiția intensității semnalului pentru locația centrală $(x,y)=(12,5)$ în funcție de fiecare orientare și adresă MAC este 


<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-32-1.png" width="100%" style="display: block; margin: auto;" />

Dacă am vrea să investigăm repartiția semnalului după toate cele 166 de poziții, 8 orientări și 6 puncte de acces ar trebui să facem mii de grafice și cum acest lucru este practic imposibil putem să sumarizăm datele așa încât pentru fiecare pereche locație-orientare-punct de acces să avem o valoare medie, mediană, o abatere standard și un interval între cuartile IQR. 

Începem prin a crea o nouă variabilă care conține toate perechile de puncte $(x,y)$ și apoi creăm o listă de data.frame-uri pentru fiecare combinație $(x,y)$, unghi și punct de acces:


```r
offline$posXY = paste(offline$posX, offline$posY, sep = "-")

byLocAngleAP = with(offline, 
                    by(offline, list(posXY, angle, mac), 
                       function(x) x))
length(byLocAngleAP) # cate data.frame-uri avem 166*8*7
[1] 9296
```

și continuăm prin calculul statisticilor de sumarizare 


```r
signalSummary = lapply(byLocAngleAP, function(oneLoc){
  # creaza o data.frame care are aceleasi campuri ca cea originala
  ans = oneLoc[1, ] 
  ans$medSignal = median(oneLoc$signal)
  ans$avgSignal = mean(oneLoc$signal)
  ans$num = length(oneLoc$signal)
  ans$sdSignal = sd(oneLoc$signal)
  ans$irqSignal = IQR(oneLoc$signal)
  return(ans)
})

# cream un data.frame din variabilele sumarizate
offlineSummary = do.call("rbind", signalSummary) 
```

Ne uităm dacă abaterile standard variază în funcție de intensitatea medie a semnalului recepționat și constatăm că semnalele slabe au o abatere standard mai mică și aceasta crește odată cu creșterea intensității semnalului.

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-35-1.png" width="90%" style="display: block; margin: auto;" />

## Cum influențează distanța semnalul ?

Pentru a vedea cum este influențat semnalul în funcție de distanță vom trasa o hartă topografică (un heat map) folosind pachetul `fields` care o folosește o metodă de tip spline pentru a potrivi (fit) o suprafață în locațiile date după valorile intensității semnalului recepționat. Funcția `Tps()` (Thin plate spline regression) necesită pentru fiecare pereche de puncte $(x,y)$ o unică valoare $z$ și prin urmare vom folosi setul de date *offlineSummary*:


```r
# functia care traseaza pentru o adresa MAC si un unghi 
# heat map-ul necesar
surfaceSS = function(data, mac, angle = 45, ...){
  require(fields) # avem nevoie de acest pachet
  
  # subsectionam data
  oneAPAngle = data[data$mac == mac & data$angle == angle, ] 
  
  # construim suprafata prin regresie spline
  smoothSS = Tps(oneAPAngle[, c("posX","posY")], oneAPAngle$avgSignal)
  
  # transforma functia fitata intr-o suprafata plotabila
  vizSmooth = predictSurface(smoothSS)
  plot.surface(vizSmooth, type = "C", 
               xlab = "", ylab = "", xaxt = "n", yaxt = "n", 
               bty = "n", ...)
  
  points(oneAPAngle$posX, oneAPAngle$posY, pch=19, cex = 0.5)
}
```


```
Graficul pentru adresa MAC  00:0f:a3:39:e1:c0 
```

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-37-1.png" width="90%" style="display: block; margin: auto;" />

```
Graficul pentru adresa MAC  00:0f:a3:39:dd:cd 
```

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-37-2.png" width="90%" style="display: block; margin: auto;" />

```
Graficul pentru adresa MAC  00:14:bf:b1:97:8a 
```

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-37-3.png" width="90%" style="display: block; margin: auto;" />

```
Graficul pentru adresa MAC  00:14:bf:3b:c7:c6 
```

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-37-4.png" width="90%" style="display: block; margin: auto;" />

```
Graficul pentru adresa MAC  00:14:bf:b1:97:90 
```

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-37-5.png" width="90%" style="display: block; margin: auto;" />

```
Graficul pentru adresa MAC  00:14:bf:b1:97:8d 
```

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-37-6.png" width="90%" style="display: block; margin: auto;" />

```
Graficul pentru adresa MAC  00:14:bf:b1:97:81 
```

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-37-7.png" width="90%" style="display: block; margin: auto;" />

Graficele de mai sus ne spun și unde se află locațiile punctelor de acces pe plan. Putem să creăm o matrice cu pozițiile și numele celor 6 puncte de acces:


```r
AP = matrix(c(7.5, 6.3, 2.5, -.8, 12.8, -2.8, 
              1, 14, 33.5, 9.3, 33.5, 2.8), 
            ncol = 2, byrow = TRUE, 
            dimnames = list(subMacs[-2], c("x", "y")))
AP
                     x    y
00:0f:a3:39:e1:c0  7.5  6.3
00:14:bf:b1:97:8a  2.5 -0.8
00:14:bf:3b:c7:c6 12.8 -2.8
00:14:bf:b1:97:90  1.0 14.0
00:14:bf:b1:97:8d 33.5  9.3
00:14:bf:b1:97:81 33.5  2.8
```

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-39-1.png" width="90%" style="display: block; margin: auto;" />

Pentru a vedea ce relație există între intensitatea semnalului și distanța de la punctul de acces putem să calculăm distanțele de la locația device-ului până la punctele de acces (distanța Euclidiană)


```r
offlineSummary = subset(offlineSummary, mac != subMacs[2])

# calculam diferenta de pozitie x si y dintre 
# locatie si punctul de acces
diffs = offlineSummary[, c("posX", "posY")] - 
  AP[offlineSummary$mac, ]

# dist Euclidiana
offlineSummary$dist = sqrt(diffs[ ,1]^2 + diffs[, 2]^2)
```

<img src="Lab_Suplimentar_IPS_files/figure-html/unnamed-chunk-41-1.png" width="100%" style="display: block; margin: auto;" />


# Metodă de prezicere a locației


