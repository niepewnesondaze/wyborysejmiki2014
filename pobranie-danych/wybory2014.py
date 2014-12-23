
from bs4 import BeautifulSoup
import re
import urllib
import urllib.request
import sys

baseUrl = "http://wybory2014.pkw.gov.pl"

outObwody = "obwody.csv"
outProt   = "protokoly.csv"
outWyniki = "wyniki.csv"

#http://www.crummy.com/software/BeautifulSoup/bs4/doc/#a-string
#przyklad - poziom gminy: http://wybory2014.pkw.gov.pl/pl/wyniki/gminy/view/303101

def parseWoj(wojfile):
	soupwoj = BeautifulSoup(wojfile)
	for powiatAnchor in soupwoj.find_all("a",href=re.compile("pl/wyniki/powiaty/view/")):
		print("Powiat "+powiatAnchor.text+"::"+powiatAnchor.get("href"))
		powiatfile = urllib.request.urlopen(baseUrl+powiatAnchor.get("href"))
		parsePowiat(powiatfile)

def parsePowiat(powiatfile):
	souppowiat = BeautifulSoup(powiatfile)
	# powiat albo miasto, jesli miasto to ma od razu obwody glosowania widoczne
	if souppowiat.find("a",href=re.compile("protokoly"),text=re.compile("RDW"))==None:
		print("jako powiat")
		# linki do protokolow z gmin
		for gminaAnchor in souppowiat.find_all("a",href=re.compile("pl/wyniki/gminy/view/")):
			print("Gmina "+gminaAnchor.text)
			gminafile = urllib.request.urlopen(baseUrl+gminaAnchor.get("href"))
			parseGmina(gminafile)
	else:
		print("Gmina miejska protokol")
		for rdwAnchor in souppowiat.find_all("a",href=re.compile("protokoly"),text=re.compile("RDW")):
			parseProtokolRDW(rdwAnchor)

def parseGmina(gminafile):
	soupgmina = BeautifulSoup(gminafile)
	# linki do protokolow do sejmikow - RDW
	for rdwAnchor in soupgmina.find_all("a",href=re.compile("protokoly"),text=re.compile("RDW")):
		parseProtokolRDW(rdwAnchor)

def parseProtokolRDW(rdwAnchor):
	# urle: <id obwodu>/<id protokolu, rdw=42xxx>
	obwodid = re.search("protokoly/(\d+)/",rdwAnchor.get("href")).group(1)
	print(obwodid)

	prot = urllib.request.urlopen(baseUrl+rdwAnchor.get("href"))
	protsoup = BeautifulSoup(prot)

	# tabela 0 - informacje o obwodzie
	obwodinfo = [quoteItem(item.text.strip()) for item in protsoup.find_all("table")[0].find_all("tr")[1].find_all("td")]
	obwodinfo.append(obwodid)

	# tabela 1 - frekwencja i karty
	freqinfo = [quoteItem(i.text.strip()) for i in protsoup.find_all("table")[1].find_all("td")]
	freqinfo = zip(freqinfo[0::3],freqinfo[2::3])

	# tabela 3 - uwagi
	uwagi = [quoteItem(i.text.strip()) for i in protsoup.find_all("table")[3].find_all("td")]
	# 0,2, 3,5,...
	uwagi = zip(uwagi[0::3],uwagi[2::3])

	# freq+uwagi=protokol dla obwodid

	# tabela 2 - wyniki glosowania na kandydatow
	wyniki = protsoup.find_all("table")[2].find_all("tr")

	# jesli jest 0 elmentow td, to wiersz pomijamy (naglowek listy po nazwie komitetu)
	# jesli sa 2 elementy td, to nazwa komitetu albo razem
	rezultat=[]
	komitet = ""
	for r in wyniki:
		n = r.find_all("td")
		# nowy komitet?
		if len(n)==2 and n[0].text!="Razem":
			komitet = n[0].text.strip()
		if len(n)==4:
			rezultat.append([komitet]+[kandydat.text.strip() for kandydat in n])

	outObwodyFile.write(";".join(quoteForCSV(obwodinfo))+"\n")
	# dopisac do protokolow
	for item in freqinfo:
		outProtFile.write(obwodid+";"+";".join(item)+"\n")
	for item in uwagi:
		outProtFile.write(obwodid+";"+";".join(item)+"\n")
	# dopisac do wynikow
	for item in rezultat:
		outWynikiFile.write(obwodid+";"+";".join(item)+"\n")

def quoteItem(text):
	return(text.replace("\r\n"," ").replace("\r"," ").replace("\n"," ").replace('"','\\"').replace(';','\;'))
		
def quoteForCSV(data):
	return([quoteItem(item) for item in data])

def main():
	global outObwodyFile
	global outProtFile
	global outWynikiFile

	outObwodyFile = open(outObwody,"wt",encoding="utf-8")
	outProtFile = open(outProt,"wt",encoding="utf-8")
	outWynikiFile = open(outWyniki,"wt",encoding="utf-8")

#	gmina = open("c:/tmp/303101.html","rt",encoding="UTF8").read()
#	parseGmina(gmina)
#	powiat = open("c:/tmp/3031.html","rt",encoding="UTF8").read()
#	parsePowiat(powiat)
#	woj = open("c:/tmp/30.html","rt",encoding="UTF8").read()
#	parseWoj(woj)

	wojewodztwa=['02','04','06','08','10','12','14','16','18','20','22','24','26','28','30','32']
	for woj in wojewodztwa:
		wojfile = urllib.request.urlopen(baseUrl+"/pl/wyniki/wojewodztwo/view/"+woj)
		parseWoj(wojfile)

	outObwodyFile.close()
	outProtFile.close()
	outWynikiFile.close()
	
if __name__ == '__main__':
    main()