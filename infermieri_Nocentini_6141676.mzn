%DATI
int: n; 
int: nGiorni=7;
int: D; %Numero minimo di infermieri per turno diurno
int: N; %Numero minimo di infermieri per turno notturno
int: k;
int: h;


%VARIABILI
set of int: INFERMIERI = 1..n;
set of int: GIORNI = 1..nGiorni;
int: mattina=3;
int: notte=1;
int: riposo=2;
int: pomeriggio=5;
int: sera=4;
int: nturni = if h>=8 then 2 else 3 endif;
set of int:TURNI = if h>=8 then 1..4 else 1..5 endif;
set of int:EFFETTIVI = if nturni=2 then 3..4 else 3..5 endif;
array[TURNI] of string: nome = if h>6 then ["_NOTTE_","RIPOSO_","MATTINA","__SERA_"] else ["___NOTTE__","__RIPOSO__","_MATTINA__","___SERA___","POMERIGGIO"] endif;
%array[TURNI] of string: nome = if h>6 then ["22-06 ","----- ","06-14 ","14-22 "] else ["22-06","-----","06-11","16-22","11-16"] endif;
array[INFERMIERI,GIORNI] of var TURNI: tabella;

constraint h*4+8>=k; % per garantire ore settimanali
constraint (16/nturni)*4+8>=k; % per garantire ore settimanali
constraint forall(k in INFERMIERI)(sum(i in GIORNI)(bool2int(tabella[k,i]==notte))=1); % in una settimana 1 turno notturno
constraint forall(k in INFERMIERI)(sum(i in GIORNI)(bool2int(tabella[k,i]==riposo))=2); % in una settimana 2 giorni di riposo
constraint forall(j in EFFETTIVI)(forall(k in INFERMIERI)(sum(i in GIORNI)(bool2int(tabella[k,i]==j))>=1)); %vincolo per le righe
constraint forall(i in GIORNI)(sum(k in INFERMIERI)(bool2int(tabella[k,i]==notte))>=N); % per ogni notte almeno N infermieri
constraint forall(i in GIORNI)(sum(k in INFERMIERI)(bool2int(tabella[k,i]==riposo))>=N*2); % vincolo derivante da almeno N notti
constraint forall(j in EFFETTIVI)(forall(i in GIORNI)(sum(k in INFERMIERI)(bool2int(tabella[k,i]==j))>=D)); %vincolo per le colonne
constraint forall(k in INFERMIERI)(forall(i in GIORNI diff nGiorni-1..nGiorni)(tabella[k,i]=notte->tabella[k,i+1]=riposo)); %dopo notte 1 giorno di riposo
constraint forall(k in INFERMIERI)(forall(i in GIORNI diff nGiorni-1..nGiorni)(tabella[k,i]=notte->tabella[k,i+2]=riposo)); %dopo notte 2 giorno di riposo
constraint forall(k in INFERMIERI)((tabella[k,7]=notte->tabella[k,1]=riposo)); 
constraint forall(k in INFERMIERI)((tabella[k,7]=notte->tabella[k,2]=riposo)); 
constraint forall(k in INFERMIERI)((tabella[k,6]=notte->tabella[k,7]=riposo)); 
constraint forall(k in INFERMIERI)((tabella[k,6]=notte->tabella[k,1]=riposo)); 


solve satisfy;

%OUTPUT

array[GIORNI] of int:b=[1,2,3,4,5,6,7];
array[GIORNI] of string: f=["LUNEDI'","MARTEDI'","MERCOLEDI'","GIOVEDI'","VENERDI'","SABATO","DOMENICA"];
output[f[fix(b[i])] ++ if i==nGiorni then "\n" else "    " endif | i in GIORNI];
output [ nome[fix(tabella[i,j])]  ++ if j==nGiorni then "\n" else "      " endif 
       | i in INFERMIERI, j in GIORNI ]; 
      