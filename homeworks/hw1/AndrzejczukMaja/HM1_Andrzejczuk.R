library(PogromcyDanych)
library(dplyr)
library(stringr)
library(tidyr)


## 1. Z kt�rego rocznika jest najwi�cej aut i ile ich jest?
auta2012 %>%
  group_by(Rok.produkcji) %>%
  summarize(count = n()) %>%
  arrange(desc(count)) %>%
  head(1)

## Odp: Najwiecej samochod�w jest z rocznika 2011, jest ich 17418


## 2. Kt�ra marka samochodu wyst�puje najcz�ciej w�r�d aut wyprodukowanych w 2011 roku?
auta2012 %>%
  filter(Rok.produkcji == 2011) %>%
  group_by(Marka) %>%
  summarize(count = n()) %>%
  arrange(desc(count)) %>%
  head(1)

## Odp: Skoda


## 3. Ile jest aut z silnikiem diesla wyprodukowanych w latach 2005-2011?

auta2012 %>%
  filter(2005 <= Rok.produkcji,
         2011 >= Rok.produkcji,
         Rodzaj.paliwa == 'olej napedowy (diesel)') %>%
  summarise(n = n())


## Odp: Jest 59534 takich aut.


## 4. Spo�r�d aut z silnikiem diesla wyprodukowanych w 2011 roku, kt�ra marka jest �rednio najdro�sza?


auta2012 %>%
  filter(Rodzaj.paliwa == 'olej napedowy (diesel)', Rok.produkcji == 2011) %>%
  select(Marka, Cena.w.PLN) %>%
  group_by(Marka) %>%
  summarise(mean = mean(Cena.w.PLN, na.rm = TRUE)) %>%
  arrange(desc(mean)) %>%
  head(1)

## Odp. Porsche


## 5. Spo�r�d aut marki Skoda wyprodukowanych w 2011 roku, kt�ry model jest �rednio najta�szy?

auta2012 %>%
  filter(Marka == 'Skoda', Rok.produkcji == 2011) %>%
  group_by(Model) %>%
  summarise(mean = mean(Cena.w.PLN, na.rm = TRUE)) %>%
  arrange(-desc(mean))



## Odp: Fabia


## 6. Kt�ra skrzynia bieg�w wyst�puje najcz�ciej w�r�d 2/3-drzwiowych aut,
##    kt�rych stosunek ceny w PLN do KM wynosi ponad 600?

auta2012 %>%
  filter(Liczba.drzwi == '2/3') %>%
  mutate(stosunek = Cena.w.PLN / KM) %>%
  filter(stosunek > 600) %>%
  group_by(Skrzynia.biegow) %>%
  count() %>%
  arrange(desc(n)) %>%
  head(1)


## Odp: Automatyczna


## 7. Spo�r�d aut marki Skoda, kt�ry model ma najmniejsz� r�nic� �rednich cen
##    mi�dzy samochodami z silnikiem benzynowym, a diesel?


auta2012 %>%
  filter((
    Rodzaj.paliwa == 'olej napedowy (diesel)' |
      Rodzaj.paliwa == 'benzyna'
  ),
  Marka == 'Skoda'
  ) %>%
  group_by(Model, Rodzaj.paliwa) %>%
  summarise(mean = mean(Cena.w.PLN, na.rm = TRUE)) %>%
  summarise(diff = abs(mean[Rodzaj.paliwa == 'benzyna'] - mean[Rodzaj.paliwa == 'olej napedowy (diesel)'])) %>%
  arrange(-desc(diff)) %>%
  head(1)


## Odp: Felicia


## 8. Znajd� najrzadziej i najcz�ciej wyst�puj�ce wyposa�enie/a dodatkowe
##    samochod�w marki Lamborghini





auta2012 %>%
  filter(Marka == 'Lamborghini') %>%
  select(Marka, Wyposazenie.dodatkowe) %>%
  separate_rows(Wyposazenie.dodatkowe, sep = ', ') %>%
  select(Wyposazenie.dodatkowe) %>%
  group_by(Wyposazenie.dodatkowe) %>%
  summarise(n = n()) %>%
  arrange(desc(n))

auta2012 %>%
  filter(Marka == 'Lamborghini') %>%
  select(Marka, Wyposazenie.dodatkowe) %>%
  separate_rows(Wyposazenie.dodatkowe, sep = ', ') %>%
  select(Wyposazenie.dodatkowe) %>%
  group_by(Wyposazenie.dodatkowe) %>%
  summarise(n = n()) %>%
  arrange(-desc(n))



## Odp: Najwiecej jest ABS, alufelgi, wspomaganie kierownicy,
##      a najmniej blokada skrzyni biegow, klatka


## 9. Por�wnaj �redni� i median� mocy KM mi�dzy grupami modeli A, S i RS
##    samochod�w marki Audi

auta2 <- auta2012 %>%
  filter(Marka == 'Audi') %>% select (Marka, KM, Model) %>%
  mutate(Grupy = case_when(
    grepl("^A", Model) ~ "A",
    grepl("^S", Model) ~ "S",
    grepl("^RS", Model) ~ "RS"
  )) %>% group_by(Grupy) %>%
  summarise(mean = mean(KM, na.rm = TRUE),
            median = median(KM, na.rm = TRUE))


## Odp:
# Grupy  mean median
# <chr> <dbl>  <dbl>
# 1 A      160.    140
# 2 RS     500.    450
# 3 S      344.    344

## 10. Znajd� marki, kt�rych auta wyst�puj� w danych ponad 10000 razy.
##     Podaj najpopularniejszy kolor najpopularniejszego modelu dla ka�dej z tych marek.

Marka <- auta2012 %>% group_by(Marka) %>%
  summarise(n = n()) %>%
  filter(n > 10000)  %>% select(Marka)

Pomoc <- auta2012 %>% group_by(Model, Marka) %>%
  summarise(n = n())


Model <- inner_join(auta2012, Marka) %>% group_by(Marka, Model) %>%
  summarise(n = n()) %>% group_by(Marka) %>% summarise(max = max(n))


Model2 <-
  inner_join(Model, Pomoc) %>% filter(n == max) %>% select(Model, Marka, max)

Pomoc2 <- auta2012 %>% group_by(Model, Marka, Kolor) %>%
  summarise(n = n())



ColorPomoc <- inner_join(Pomoc2, Model2) %>% group_by(Marka, Kolor)%>% 
  summarise(n2 = (n))

Color <- inner_join(Pomoc2, Model2) %>% group_by(Marka, Kolor)%>% 
  summarise(n2 = (n)) %>% group_by(Marka) %>% summarise(Najpopularniejszy = max(n2))

Color2 = inner_join(Color, ColorPomoc) %>% filter(n2==Najpopularniejszy)

Color3 = inner_join(Color2, Model2)
Color3 = Color3 %>% select(Marka, Model, Kolor)


Color3

# Odp: 
# Marka         Model  Kolor           
# <fct>         <fct>  <fct>           
# Audi          A4     czarny-metallic 
# BMW           320    srebrny-metallic
# Ford          Focus  srebrny-metallic
# Mercedes-Benz C 220  srebrny-metallic
# Opel          Astra  srebrny-metallic
# Renault       Megane srebrny-metallic
# Volkswagen    Passat srebrny-metallic
