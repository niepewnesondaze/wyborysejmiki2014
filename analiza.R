# install the RODBC package
#install.packages("RODBC")

#### database fetch ####

# load the package
library(RODBC)

# connect to you new data source
db <- odbcConnect("infobright-wybory2014", uid="root", pwd="",DBMSencoding="UTF8",readOnlyOptimize=TRUE)

# list the names of the available tables
sqlTables(db)

qry <- "
SELECT
        w.id,w.listatxt,w.listaid,w.glosy,
        pu.val as uprawnieni,pk.val as kartywydane,pn.val as glosyniewazne,
        o.woj,o.powiat,o.gmina,t.typgminy,m.mazzaufania
FROM
        (SELECT id,listatxt,listaid,SUM(t.glosy) AS glosy FROM wyniki AS t WHERE listaid IN (1,2,3,4,5,6,7) GROUP BY id,listaid) AS w,
        obwody AS o,
        protokolynum AS pu,
        protokolynum AS pk,
        protokolynum AS pn,
        gminyteryt AS t,
        obwodymezowie AS m
WHERE
        w.listaid IN (1,2,3,4,5,6,7) AND
        w.id=o.id AND
        w.id=m.id AND
        o.teryt=t.teryt AND
        w.id=pu.id AND 
        w.id=pk.id AND 
        w.id=pn.id AND 
        pu.item=1 AND 
        pk.item=4 AND
        pn.item=11 
"

# load a_table into a data fram
dfgminy <- sqlQuery(db, qry, stringsAsFactors=TRUE)

dfgminy$shortlista<-factor(dfgminy$listatxt,levels = c(
        "Koalicyjny Komitet Wyborczy SLD Lewica Razem",
        "Komitet Wyborczy Demokracja Bezpośrednia",
        "Komitet Wyborczy Nowa Prawica — Janusza Korwin-Mikke",
        "Komitet Wyborczy Platforma Obywatelska RP",
        "Komitet Wyborczy Polskie Stronnictwo Ludowe",
        "Komitet Wyborczy Prawo i Sprawiedliwość",
        "Komitet Wyborczy Wyborców Ruch Narodowy"),
        labels=c("SLD","DB","KNP","PO","PSL","PiS","RN")
)


dfgminy$frekwencja <- dfgminy$kartywydane / dfgminy$uprawnieni
dfgminy$rezultat.lista <- dfgminy$glosy / dfgminy$kartywydane
dfgminy$rezultat.niewazne <- dfgminy$glosyniewazne / dfgminy$kartywydane
dfgminy$ve <- dfgminy$glosy/dfgminy$uprawnieni
dfgminy$frek2 <- (dfgminy$kartywydane-dfgminy$glosyniewazne)/dfgminy$uprawnieni

dfgminy$typgminy[dfgminy$typgminy=="Gmina miejska"]<-"Miasto"
dfgminy$typgminy<-droplevels(dfgminy$typgminy)
levels(dfgminy$typgminy)<-c("Wieś","Miasto")

listy<-c("PSL","PiS","PO","SLD","KNP")
kolory<-c("#11881140","#11118840","#ff881140","#88111140","#1111ff40")
koloryf<-c("#118811","#111188","#ff8811","#881111","#1111ff")

save(list=c("dfgminy","listy","kolory","koloryf"),file="data.Rda")

# close the connection
odbcClose(db)

rm(list=ls())

# jak w raporcie http://samarcandanalytics.com/?page_id=39 ####

rm(list=ls())
load("data.Rda")

library(lattice)

stopka<-function() {
        trellis.focus("toplevel")
        panel.text(0.85,0.02,"http://niepewnesondaze.blogspot.com",col="gray")
        trellis.unfocus()
}

png(filename=paste0("freqlista-razem.png"),width=809,height=655,type="windows",antialias="cleartype")
plot(dfgminy$frekwencja[dfgminy$listaid==1],dfgminy$rezultat.lista[dfgminy$listaid==1],pch = ".",type="n",
     xlab="Frekwencja",ylab="Poparcie dla listy",xlim=c(0,1),ylim=c(0,1),
     main="Wybory samorządowe 2014",
     sub="(każdy punkt to jeden obwód wyborczy)")

for (i in 1:length(listy)) {
        points(dfgminy$frekwencja[dfgminy$shortlista==listy[i]],
               dfgminy$rezultat.lista[dfgminy$shortlista==listy[i]],
               col=kolory[i],
               pch = ".")
}
legend(x=0,y=1,legend=listy,fill=koloryf,bty="n")
dev.off()

for (i in 1:length(listy)) {
        png(filename=paste0("freqlista-",listy[i],".png"),width=809,height=655,type="windows",antialias="cleartype")        
        plot(dfgminy$frekwencja[dfgminy$shortlista==listy[i]],dfgminy$rezultat.lista[dfgminy$shortlista==listy[i]],col=kolory[i],pch = ".",
                xlab="Frekwencja",ylab=paste0("Poparcie dla listy"),xlim=c(0,1),ylim=c(0,1),
                main=paste0("Wybory samorządowe 2014 - ",listy[i]),
                sub="(każdy punkt to jeden obwód wyborczy)")
        dev.off()
}


png(filename=paste0("freqlista-listy.png"),width=809,height=655,type="windows",antialias="cleartype")
xyplot(rezultat.lista~frekwencja|shortlista,data=dfgminy[dfgminy$shortlista %in% listy,],col="#ffaa1140",pch=".",
       xlab="Frekwencja",ylab="Poparcie dla listy",xlim=c(0,1),ylim=c(0,1),
       main="Wyniki list w obwodach")
stopka()
dev.off()

### głosowanie w regionach ####

for (i in 1:length(listy)) {
png(filename=paste0("freqlistawoj-",listy[i],".png"),width=809,height=655,type="windows",antialias="cleartype")        
print(xyplot(rezultat.lista~frekwencja|woj,data=dfgminy[dfgminy$shortlista==listy[i],],pch=".",col=kolory[i],
       xlab="Frekwencja",ylab="Poparcie dla listy",xlim=c(0,1),ylim=c(0,1),
       main=paste0("Wyniki ",listy[i]," w województwach"),
       sub="każdy punkt to jeden obwód wyborczy"
        ))
stopka()
dev.off()
}


### frekwencja ####

png(filename=paste0("frekwencja.png"),width=809,height=655,type="windows",antialias="cleartype")        
hist(dfgminy$frekwencja[dfgminy$listaid==1],breaks = 50,ylab="Liczba obwodów",xlab="Frekwencja",main="Frekwencja w obwodach",col="gold")
dev.off()

png(filename=paste0("frekwencja-woj.png"),width=809,height=655,type="windows",antialias="cleartype")        
histogram(~frekwencja|woj,data=dfgminy[dfgminy$listaid==1,],type="count",breaks=25,xlab="Frekwencja",ylab="Liczba obwodów",main="Frekwencja w województwach",col="gold")
stopka()
dev.off()

### poparcie dla partii / histogram ####

png(filename=paste0("histogram-lista.png"),width=809,height=655,type="windows",antialias="cleartype")        
histogram(~rezultat.lista|shortlista,data=dfgminy[dfgminy$shortlista %in% listy,],
          type="count",breaks=25,
          xlab="Wynik listy",
          ylab="Liczba obwodów",
          layout=c(5,1),
          main="Wynik listy a liczba obwodów",
          col="gold")
dev.off()

# mężowie zaufania: rezultaty list ####

png(filename=paste0("maz-frek-listy.png"),width=809,height=655,type="windows",antialias="cleartype")        
xyplot(rezultat.lista~frekwencja|mazzaufania+shortlista,data=dfgminy[dfgminy$shortlista %in% listy,],col=kolory[3],pch=".",
       xlab="Frekwencja",ylab="Poparcie dla listy",xlim=c(0,1),ylim=c(0,1),auto.key=TRUE,
       main="Wyniki list w obwodach")
stopka()
dev.off()

# mężowie zaufania: frekwencja ####

f1<-hist(dfgminy$frekwencja[dfgminy$listaid==1 & dfgminy$mazzaufania=="brak mężów"],breaks = 50,plot=FALSE)
f2<-hist(dfgminy$frekwencja[dfgminy$listaid==1 & dfgminy$mazzaufania=="brak uwag"],breaks = 50,plot=FALSE)
f3<-hist(dfgminy$frekwencja[dfgminy$listaid==1 & dfgminy$mazzaufania=="uwagi"],breaks = 50,plot=FALSE)

png(filename=paste0("maz-frek-1.png"),width=809,height=655,type="windows",antialias="cleartype")        
plot(f1$breaks[-1],f1$counts/max(f1$counts),type="s",col="#0000eec0",lwd=2,main="Frekwencja a mężowie zaufania",ylab="Liczba obwodów (przeskalowane do 100%)",xlab="Frekwencja")
lines(f2$breaks[-1],f2$counts/max(f2$counts),type="s",col="#00ee00c0",lwd=2)
lines(f3$breaks[-1],f3$counts/max(f3$counts),type="s",col="#ee0000c0",lwd=2)
legend(x=0,y=1,fill=c("blue","green","red"),legend = c("brak mężów","brak uwag","uwagi"),bty="n",cex=0.8)
dev.off()

# wygładzone
png(filename=paste0("maz-frek-2.png"),width=809,height=655,type="windows",antialias="cleartype")
plot(density(dfgminy$frekwencja[dfgminy$listaid==1 & dfgminy$mazzaufania=="uwagi"]),col="#ee0000c0",main="Frekwencja a mężowie zaufania",ylab="Gęstość rozkładu",xlab="Frekwencja")
lines(density(dfgminy$frekwencja[dfgminy$listaid==1 & dfgminy$mazzaufania=="brak uwag"]),col="#00ee00c0")
lines(density(dfgminy$frekwencja[dfgminy$listaid==1 & dfgminy$mazzaufania=="brak mężów"]),col="#0000eec0")
legend(x=0.05,y=4,fill=c("blue","green","red"),legend = c("brak mężów","brak uwag","uwagi"),bty="n",cex=0.8)
dev.off()

# bezpośrednio
png(filename=paste0("maz-frek-3.png"),width=809,height=655,type="windows",antialias="cleartype")        
histogram(~frekwencja|mazzaufania,data=dfgminy[dfgminy$listaid==1,],
          type="percent",breaks=50,
          xlab="Frekwencja",
          ylab="Odsetek obwodów",
          main="Frekwencja a mężowie zaufania",
          layout=c(1,3),
          col="gold")
stopka()
dev.off()

# typ obwodu: wyniki list ####

png(filename=paste0("typ-listy.png"),width=809,height=655,type="windows",antialias="cleartype")
xyplot(rezultat.lista~frekwencja|typgminy+shortlista,data=dfgminy[dfgminy$shortlista %in% listy,],col=kolory[3],pch=".",
       xlab="Frekwencja",ylab="Poparcie dla listy",xlim=c(0,1),ylim=c(0,1),auto.key=TRUE,
       main="Wyniki list w obwodach")
stopka()
dev.off()

# typ obwodu: frekwencja ####

f1<-hist(dfgminy$frekwencja[dfgminy$listaid==1 & dfgminy$typgminy=="Miasto"],breaks = 100,plot=FALSE)
f2<-hist(dfgminy$frekwencja[dfgminy$listaid==1 & dfgminy$typgminy=="Wieś"],breaks = 100,plot=FALSE)

png(filename=paste0("typ-frek-1.png"),width=809,height=655,type="windows",antialias="cleartype")
plot(f1$breaks[-1],f1$counts,type="s",col="blue",lwd=2,main="Frekwencja wg typu obwodów",ylab="Liczba obwodów",xlab="Frekwencja")
lines(f2$breaks[-1],f2$counts,type="s",col="red",lwd=2)
legend(x=0,y=800,fill=c("blue","red"),legend = c("Miasto","Wieś"),bty="n",cex=0.8)
dev.off()

# tu ładnie widać
png(filename=paste0("typ-frek-2.png"),width=809,height=655,type="windows",antialias="cleartype")
histogram(~frekwencja|typgminy,data=dfgminy[dfgminy$listaid==1,],
          type="percent",breaks=50,
          xlab="Frekwencja",
          ylab="Odsetek obwodów",
          main="Frekwencja a typ obwodu",
          layout=c(1,2),
          col="gold")
stopka()
dev.off()

png(filename=paste0("typ-listy-2.png"),width=809,height=655,type="windows",antialias="cleartype")
histogram(~rezultat.lista|shortlista+typgminy,data=dfgminy[dfgminy$shortlista %in% listy,],
          type="percent",breaks=25,
          xlab="Wynik listy",
          ylab="Odsetek obwodów",
          main="Wyniki list a typ obwodu",
          col="gold")
stopka()
dev.off()

## ciekawostki ####

rm(list=ls())
load("data.Rda")

dfgminy<-dfgminy[(dfgminy$kartywydane-dfgminy$glosyniewazne)>100,]

# gdzie jest najwieksze poparcie? (co najmniej 100 kart waznych) ####

listymax=list()
for (i in listy) {
        df <- dfgminy[dfgminy$shortlista==i,]
        dfid<-df$id[df$rezultat.lista==max(df$rezultat.lista,na.rm=TRUE)]
        listymax$id[i] <- dfid[!is.na(dfid)][1]
}

# load the package
library(RODBC)
# connect to you new data source
db <- odbcConnect("infobright-wybory2014", uid="root", pwd="",DBMSencoding="UTF8",readOnlyOptimize=TRUE)
qry <- paste0("SELECT * FROM obwody WHERE obwody.id IN (",paste(unlist(listymax),collapse = ","),")")
dfmax <- sqlQuery(db, qry, stringsAsFactors=TRUE)
odbcClose(db)

obwodymax<-data.frame()
for (l in listy) {
        obwodymax<-rbind(obwodymax,cbind(
                dfmax[dfmax$id==listymax$id[l],c("woj","powiat","gmina","siedziba")],
                dfgminy[dfgminy$id==listymax$id[l] & dfgminy$shortlista==l,c("shortlista","uprawnieni","kartywydane","glosyniewazne","glosy","rezultat.lista")]
        ))
}
write.table(obwodymax,"obwodymax.csv",col.names = TRUE,row.names = FALSE,sep=";",dec=",",fileEncoding="UTF8")
