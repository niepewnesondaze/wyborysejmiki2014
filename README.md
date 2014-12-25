
Analiza wyników wyborów do sejmików wojewódzkich 2014
============================================================


#Pobranie danych
Skrypt pobranie-danych/wybory2014.py jest napisany w Pythonie i ściąga raporty RDW z [wizualizacji udostępnionej przez PKW](http://wybory2014.pkw.gov.pl).

Skrypt działa w sposób rekurencyjny:
- dla każdego województwa z listy w funkcji main() wchodzi na odpowiednią stronę: np. http://wybory2014.pkw.gov.pl/pl/wyniki/wojewodztwo/view/02
	- dla każdego powiatu wymienionego na tej stronie wchodzi na odpowiednią stronę z listą gmin
		- dla każdej gminy przegląda listę obwodów 
			- dla każdego obwodu znajduje raport RDW
		- wyjątkiem są powiaty grodzkie (roboczo nazwane w kodzie gminami miejskimi), gdzie lista obwodów znajduje się poziom wyżej - nie ma dostępnej listy gmin

Z raportu [(przykład)](http://wybory2014.pkw.gov.pl/pl/wyniki/protokoly/27055/42111) wyciągane są wszystkie udostępnione informacje:
- informacje o obwodzie
- rozliczenie kart do głosowania
- adnotacje i uwagi
- liczba głosów na poszczególnych kandydatów

Dzięki temu, w jaki sposób Python obsługuje dane wejściowe program można uruchomić i testować podając albo url albo
otwarty plik ze ściągniętym HTML do jednej z funkcji działających na odpowiednim poziomie:
```
	parseWoj(plik)
	parsePowiat(plik)
	parseGmina(plik)
	parseProtokolRDW(plik)
```

#Pliki wynikowe
Skrypt zapisuje wyniki do następujących plików:
- obwody.csv - informacje o obwodach
- protokoly.csv - rozliczenie kart, uwagi i adnotacje dla każdego obwodu
- wyniki.csv - kandydaci, listy i liczba głosów w każdym pojedynczym obwodzie

#Pliki pomocnicze
- protokolyitem.csv - klucz do kolejnych pozycji w protokoly.csv
- gminyteryt.csv - rodzaje gmin (wiejska, miejska, miasto) wg kodów teryt z [listy obwodów PKW](http://wybory2014.pkw.gov.pl/pl/pliki)
- obwodymezowie.csv - odfiltrowana lista uwag mężów zaufania (brak mężów, brak uwag, uwagi)

#Struktura danych
- dbload.sql to kod SQL, który tworzy bazę danych i odpowiednie tabele oraz ładuje wyżej wymienione pliki

Wewnątrz tego pliku znajdują się polecenia CREATE TABLE z nazwami i typami kolejnych kolumn w powyższych plikach csv.

Do analizy używam bazy danych [Infobright](http://www.infobright.org/) - MySQL z dodatkowym silnikiem brighthouse, 

który fantastycznie szybko dokonuje wyszukiwania, łączenia i agregacji danych.
Po niewielkich zmianach za pomocą dbload.sql można załadować te dane do standardowego MySQL

#Przykład użycia
W pliku analiza.R jest kod, którego użyłem do [napisania tego wpisu](http://niepewnesondaze.blogspot.com/2014/12/czy-wybory-samorzadowe-mogy-zostac.html). 

Przykładowe dane zagregowane na poziomie obwodów i list (bez pojedynczych kandydatów) są w załączonym data.Rda.

