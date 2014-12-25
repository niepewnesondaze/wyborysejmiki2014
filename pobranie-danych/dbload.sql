drop database if exists wybory2014;
create database wybory2014;
use wybory2014;

create table obwody (
	woj text comment 'lookup',
	powiat text comment 'lookup',
	gmina text,
	teryt char(6),
	okreg text,
	siedziba text,
	id integer not null) engine=brighthouse default charset='UTF8';

create table protokolyraw (
	id integer not null,
	item varchar(3) not null comment 'lookup',
	val text ) engine=brighthouse default charset='UTF8';

create table protokolynum (
	id integer not null,
	item varchar(3) not null comment 'lookup',
	val integer ) engine=brighthouse default charset='UTF8';

create table wyniki (
	id integer not null,
	listatxt text comment 'lookup',
	lp integer,
	kandydat text,
	listaid integer,
	glosy integer) engine=brighthouse default charset='UTF8';

create table protokolyitem (
	item varchar(3) not null comment 'lookup',
	itemtxt text)  engine=brighthouse default charset='UTF8';

create table obwodymezowie (
	id integer not null,
	mazzaufania text comment 'lookup')  engine=brighthouse default charset='UTF8';

create table gminyteryt (
	teryt char(6),
	typgminy text comment 'lookup')  engine=brighthouse default charset='UTF8';

load data infile 'c:/temp/wybory-samorzadowe2014/obwody.csv' into table obwody fields terminated by ';' ESCAPED BY '\\' lines terminated by '\n';
load data infile 'c:/temp/wybory-samorzadowe2014/protokoly.csv' into table protokolyraw fields terminated by ';' ESCAPED BY '\\' lines terminated by '\n';
load data infile 'c:/temp/wybory-samorzadowe2014/wyniki.csv' into table wyniki fields terminated by ';' ESCAPED BY '\\' lines terminated by '\n';

select id,item,CAST(val AS UNSIGNED) AS val from (SELECT * from protokolyraw  where item not in ('14','15','16','17','18','19','20')
) as t into outfile 'c:/temp/wybory-samorzadowe2014/protokolynum.csv'
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"' 
ESCAPED BY '\\' 
LINES TERMINATED BY '\n'
;

load data infile 'c:/temp/wybory-samorzadowe2014/protokolynum.csv' into table protokolynum fields terminated by ';' ESCAPED BY '\\' lines terminated by '\n';

load data infile 'c:/temp/wybory-samorzadowe2014/protokolyitem.csv' into table protokolyitem fields terminated by ';' ESCAPED BY '\\' lines terminated by '\r\n';
load data infile 'c:/temp/wybory-samorzadowe2014/obwodymezowie.csv' into table obwodymezowie fields terminated by ';' ESCAPED BY '\\' lines terminated by '\r\n';
load data infile 'c:/temp/wybory-samorzadowe2014/gminyteryt.csv' into table gminyteryt fields terminated by ';' ESCAPED BY '\\' lines terminated by '\r\n';
