
Analiza wynik�w wybor�w do sejmik�w wojew�dzkich 2014
============================================================


#Pobranie danych
Skrypt pobranie-danych/wybory2014.py jest napisany w Pythonie i �ci�ga raporty RDW z [wizualizacji udost�pnionej przez PKW](http://wybory2014.pkw.gov.pl).

Skrypt dzia�a w spos�b rekurencyjny:
- dla ka�dego wojew�dztwa z listy w funkcji main() wchodzi na odpowiedni� stron�: np. http://wybory2014.pkw.gov.pl/pl/wyniki/wojewodztwo/view/02
	- dla ka�dego powiatu wymienionego na tej stronie wchodzi na odpowiedni� stron� z list� gmin
		- dla ka�dej gminy przegl�da list� obwod�w 
			- dla ka�dego obwodu znajduje raport RDW
		- wyj�tkiem s� powiaty grodzkie (roboczo nazwane w kodzie gminami miejskimi), gdzie lista obwod�w znajduje si� poziom wy�ej - nie ma dost�pnej listy gmin

Z raportu [(przyk�ad)](http://wybory2014.pkw.gov.pl/pl/wyniki/protokoly/27055/42111) wyci�gane s� wszystkie udost�pnione informacje:
- informacje o obwodzie
- rozliczenie kart do g�osowania
- adnotacje i uwagi
- liczba g�os�w na poszczeg�lnych kandydat�w

Dzi�ki temu, w jaki spos�b Python obs�uguje dane wej�ciowe program mo�na uruchomi� i testowa� podaj�c albo url albo
otwarty plik ze �ci�gni�tym HTML do jednej z funkcji dzia�aj�cych na odpowiednim poziomie:
```
	parseWoj(plik)
	parsePowiat(plik)
	parseGmina(plik)
	parseProtokolRDW(plik)
```

#Pliki wynikowe
Skrypt zapisuje wyniki do nast�puj�cych plik�w:
- obwody.csv - informacje o obwodach
- protokoly.csv - rozliczenie kart, uwagi i adnotacje dla ka�dego obwodu
- wyniki.csv - kandydaci, listy i liczba g�os�w w ka�dym pojedynczym obwodzie

#Pliki pomocnicze
- protokolyitem.csv - klucz do kolejnych pozycji w protokoly.csv

#Struktura danych
- dbload.sql to kod SQL, kt�ry tworzy baz� danych i odpowiednie tabele oraz �aduje wy�ej wymienione pliki

Wewn�trz tego pliku znajduj� si� polecenia CREATE TABLE z nazwami i typami kolejnych kolumn w powy�szych plikach csv.

Do analizy u�ywam bazy danych [Infobright](http://www.infobright.org/) - MySQL z dodatkowym silnikiem brighthouse, 

kt�ry fantastycznie szybko dokonuje wyszukiwania, ��czenia i agregacji danych.
Po niewielkich zmianach za pomoc� dbload.sql mo�na za�adowa� te dane do standardowego MySQL

#Przyk�ad u�ycia
W pliku analiza.R jest kod, kt�rego u�y�em do [napisania tego wpisu](http://niepewnesondaze.blogspot.com/2014/12/czy-wybory-samorzadowe-mogy-zostac.html). 

Przyk�adowe dane zagregowane na poziomie obwod�w i list (bez pojedynczych kandydat�w) s� w za��czonym data.Rda.

