
Analiza wyników wyborów do sejmików wojewódzkich 2014
============================================================


#Pobranie danych
Skrypt pobranie-danych/wybory2014.py jest napisany w Pythonie i œci¹ga raporty RDW z [wizualizacji udostêpnionej przez PKW](http://wybory2014.pkw.gov.pl).

Skrypt dzia³a w sposób rekurencyjny:
- dla ka¿dego województwa z listy w funkcji main() wchodzi na odpowiedni¹ stronê: np. http://wybory2014.pkw.gov.pl/pl/wyniki/wojewodztwo/view/02
	- dla ka¿dego powiatu wymienionego na tej stronie wchodzi na odpowiedni¹ stronê z list¹ gmin
		- dla ka¿dej gminy przegl¹da listê obwodów 
			- dla ka¿dego obwodu znajduje raport RDW
		- wyj¹tkiem s¹ powiaty grodzkie (roboczo nazwane w kodzie gminami miejskimi), gdzie lista obwodów znajduje siê poziom wy¿ej - nie ma dostêpnej listy gmin

Z raportu [(przyk³ad)](http://wybory2014.pkw.gov.pl/pl/wyniki/protokoly/27055/42111) wyci¹gane s¹ wszystkie udostêpnione informacje:
- informacje o obwodzie
- rozliczenie kart do g³osowania
- adnotacje i uwagi
- liczba g³osów na poszczególnych kandydatów

Dziêki temu, w jaki sposób Python obs³uguje dane wejœciowe program mo¿na uruchomiæ i testowaæ podaj¹c albo url albo
otwarty plik ze œci¹gniêtym HTML do jednej z funkcji dzia³aj¹cych na odpowiednim poziomie:
```
	parseWoj(plik)
	parsePowiat(plik)
	parseGmina(plik)
	parseProtokolRDW(plik)
```

#Pliki wynikowe
Skrypt zapisuje wyniki do nastêpuj¹cych plików:
- obwody.csv - informacje o obwodach
- protokoly.csv - rozliczenie kart, uwagi i adnotacje dla ka¿dego obwodu
- wyniki.csv - kandydaci, listy i liczba g³osów w ka¿dym pojedynczym obwodzie

#Pliki pomocnicze
- protokolyitem.csv - klucz do kolejnych pozycji w protokoly.csv

#Struktura danych
- dbload.sql to kod SQL, który tworzy bazê danych i odpowiednie tabele oraz ³aduje wy¿ej wymienione pliki

Wewn¹trz tego pliku znajduj¹ siê polecenia CREATE TABLE z nazwami i typami kolejnych kolumn w powy¿szych plikach csv.

Do analizy u¿ywam bazy danych [Infobright](http://www.infobright.org/) - MySQL z dodatkowym silnikiem brighthouse, 

który fantastycznie szybko dokonuje wyszukiwania, ³¹czenia i agregacji danych.
Po niewielkich zmianach za pomoc¹ dbload.sql mo¿na za³adowaæ te dane do standardowego MySQL

#Przyk³ad u¿ycia
W pliku analiza.R jest kod, którego u¿y³em do [napisania tego wpisu](http://niepewnesondaze.blogspot.com/2014/12/czy-wybory-samorzadowe-mogy-zostac.html). 

Przyk³adowe dane zagregowane na poziomie obwodów i list (bez pojedynczych kandydatów) s¹ w za³¹czonym data.Rda.

