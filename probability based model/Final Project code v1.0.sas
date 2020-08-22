libname mis "C:\Users\virendsi\Desktop\ABI project"; run;

proc import datafile="C:\Users\viren\books.txt" out=mis.booksnew dbms=dlm replace;
   delimiter='09'x;
   getnames=yes;
run;

/*barnesandnoble.com truncated to barnesandn */
/*but that works since we have two values only*/

data mis.booksnew;
set mis.booksnew(drop= var15);run;


proc contents data=mis.booksnew;run;

/*question 1*/
/*sorting by User ID*/
proc sort data=mis.booksnew;
by userid;run;

/* find missing values in data*/

proc means data = mis.booksnew n nmiss;
  var _numeric_;
run;

proc freq data = mis.booksnew;
  tables  region domain ;
run;



data miss;
set mis.booksnew;
if region = '*' then region= .;
if qty= . then delete;
run;

/* missing value in amazon so no need to impute*/

proc sort data =miss; by userid;run;

data books_1(drop = domain date product qty price);
set miss;
by userid;
if first.userid then t_qty=0;   /*total quantity assigned to zero for the first record of the group*/
if domain = "barnesandn" then t_qty + qty; /*total quantity summed up successively for "barnesandn"*/
if last.userid;
run;


ods rtf file = "C:\Users\virendsi\Desktop\ABI project\ans1.doc";
proc print data=books_1(obs=10);run;
ods rtf close;


proc contents data=books_1;run;
/*question 2*/
proc sort data=books_1; by t_qty;run;


data books_2(drop = userid education region hhsz age income child race country);
set books_1;
by t_qty;
if first.t_qty then peoplecount=0;
peoplecount + 1;
if last.t_qty;
run;

proc print data=books_2;run;


/* keeping only T_QTY <20 as data is not sequential after that*/

data mis.books_2;
set books_2;
if t_qty <=20;


run;



proc print data= mis.books_2;run;





PROC NLMIXED DATA=mis.books_2;
	retain factor 0;
	parms shapeR=0.5 alpha=0.5; /*lambda is gamma distrbuted with parameters shape r and scale alpha;*/
	IF t_qty = 0 THEN 
		DO;
			factor=((alpha/(alpha + 1)) ** shapeR);
			ll=peoplecount*log(factor);
			
		END;
	ELSE 
		DO; 
			ll = peoplecount * log(factor * ((shapeR + t_qty - 1)/(t_qty*(alpha + 1))));	
			factor = (factor * ((shapeR + t_qty - 1)/(t_qty*(alpha + 1))));	
		END;
MODEL t_qty ~ general(ll); 


RUN;


/*

proc sgplot data= books_2 ;
  TITLE "PLOT of t_qty";
  HISTOGRAM t_qty/ transparency=0.75 fillattrs=(color=blue);
  density t_qty / type=normal lineattrs=(color=red) legendlabel='t_qty';
RUN ;

*/



/*Question 4*/
/*dummy variable creation*/
data books_3;
set books_1;
if region =. then delete;
/* creating dummy variable for region*/

if region = 2 then reg2 =1;else reg2 =0;
if region = 3 then reg3 =1;else reg3 =0;
if region = 4 then reg4 =1;else reg4 =0;


/*Created dummy variables for education categorical variable*/
if education = 0 then e0 = 1; else e0 = 0;
if education = 1 then e1 = 1; else e1 = 0;
if education = 2 then e2 = 1; else e2 = 0;
if education = 3 then e3 = 1; else e3 = 0;
if education = 4 then e4 = 1; else e4 = 0;
if education = 5 then e5 = 1; else e5 = 0;
/*Created dummy variables for income categorical variable*/
/*if income = 1 then i1 = 1;
else i1 = 0;*/
if income = 2 then i2 = 1; else i2 = 0;
if income = 3 then i3 = 1; else i3 = 0;
if income = 4 then i4 = 1; else i4 = 0;
if income = 5 then i5 = 1; else i5 = 0;
if income = 6 then i6 = 1; else i6 = 0;
/*Created dummy variables for age categorical variable*/
/*if age = 1 then a1 = 1;
else a1 = 0;*/
if age = 2 then a2 = 1; else a2 = 0;
if age = 3 then a3 = 1; else a3 = 0;
if age = 4 then a4 = 1; else a4 = 0;
if age = 5 then a5 = 1; else a5 = 0;
if age = 6 then a6 = 1; else a6 = 0;
if age = 7 then a7 = 1; else a7 = 0;
if age = 8 then a8 = 1; else a8 = 0;
if age = 9 then a9 = 1; else a9 = 0;
if age = 10 then a10 = 1; else a10 = 0;
if age = 11 then a11 = 1; else a11 = 0;
/*if race = 11 then r1 = 1;
else r = 0;*/
if race = 2 then r2 = 1; else r2 = 0;
if race = 3 then r3 = 1; else r3 = 0;
if race = 4 then r4 = 1; else r4 = 0;

run;


proc print data = books_3(obs =20);run;

/*
proc freq data=books_1;
tables education;run;
*/


proc print data=books_3(obs=10);run;
proc nlmixed data=books_3;
parms lambda0=1 b0=0 b1=0 b2=0 b3=0 b4=0 b5=0 b6=0 b7=0 b8=0 b9=0 b10=0 b11=0 b12=0 b13=0 b14=0 
b15=0 b16=0 b17=0 b18=0 b19=0 b20=0 b21=0 b22=0.5 b23=0 b24=0 b25=0 b26 = 0 b27 =0 b28 = 0 b29 =0 b30 =0 ;
lambda=lambda0*exp(b0+b1*hhsz + b2*child + b3*country + b4*e0 + b5*e1 + b6*e2 + b7*e3 + b8*e4 + 
b9*e5 + b10*a2 + b11*a3 + b12*a4 + b13*a5 + b14*a6 +  b15*a7 + b16*a8 + b17*a9 + b18*a10 + b19*a11
+ b20*r2 + b21*r3 + b22*r4+b23*reg2+b24*reg3+b25*reg4 +b26*i2+b27*i3+b28*i4+b29*i5+b30*i6); 
logprob = - lambda + t_qty*log(lambda) - log(fact(t_qty));
ll = logprob;
model t_qty ~ general(ll);
run;



/* predicting results for poisson regression*/

%let lambda0= 0.6466;%let b0 = -0.3711;%let b1 =	-0.00285;
%let b2=0.09791;
%let b3 =	-0.06178;
%let b4 =	-0.3866;
%let b5 =	0.2631;
%let b6 =	0.3373;
%let b7 =	-0.1609;
%let b8 =	-0.2972;
%let b9 =	-0.2079;
%let b10 =	0.04004;
%let b11 =	0.4944;
%let b12 =	0.4455;
%let b13	= 0.3743;
%let b14	 = 0.7606;
%let b15 =	0.3432;
%let b16 =	0.5098;
%let b17 =	0.6989;
%let b18 =	0.2592;
%let b19 =	0.6492;
%let b20 =	-0.5857;
%let b21 =	-0.2706;
%let b22 =	0.5;
%let b23 =	-0.1814;
%let b24 =	-0.3236;
%let b25 =	-0.344;
%let b26 =	-0.07363;
%let b27 =	-0.226;
%let b28	=0.02839;
%let b29	 =0.1496;
%let b30	= 0.1496;
 

data BNProb;
  set books_3;
  lambda=&lambda0*exp(&b0+&b1*hhsz + &b2*child + &b3*country + &b4*e0 + &b5*e1 + &b6*e2 + &b7*e3 + &b8*e4 + 
&b9*e5 + &b10*a2 + &b11*a3 + &b12*a4 + &b13*a5 + &b14*a6 +  &b15*a7 + &b16*a8 + &b17*a9 + &b18*a10 + &b19*a11
+ &b20*r2 + &b21*r3 + &b22*r4+&b23*reg2+&b24*reg3+&b25*reg4 +&b26*i2+&b27*i3+&b28*i4+&b29*i5+&b30*i6); 

  array prob (11) prob0 - prob10;  /* prob(y+1)=proby */ 
  prob0=poisson(lambda,0);
  prob10=1-prob0; /* prob of visited 10+ times. */
  do y=1 to 9;
    prob(y+1)=poisson(lambda,y)-poisson(lambda,y-1);
    prob10=prob10-prob(y+1);
  end;
run;

proc print data =BNProb(obs=10);run;

/*average the probabilities over the whole population*/
proc means data=BNProb;
var prob0-prob10;
output out=mean_var mean=;
run;


PROC TRANSPOSE DATA=mean_var OUT=transpose NAME=Prob;
 ID _FREQ_;
 VAR prob0-prob10;
RUN;
PROC PRINT data=transpose;run;
/*Removing the variables created in proc means and multiplying the probablities by the populayion*/
data transpose(drop=_8134); 
set transpose;
_8134 = _8134*8134;
rename _8134 = value;
run;
proc print data=transpose;run;


proc sgplot data=transpose;
	TITLE "Bar chart of Counts"; 
   vbar prob / response=value;
run;	

proc freq data=books_3;
	TITLE "Frequency chart of t_qty";
tables t_qty / plots=freqplot;run;










/* question 6*/

proc nlmixed data=books_3;
parms nbdr=1 alpha=1 b0=0 b1=0 b2=0 b3=0 b4=0 b5=0 b6=0 b7=0 b8=0 b9=0 b10=0 b11=0 b12=0 b13=0 
b14=0 b15=0 b16=0 b17=0 b18=0 b19=0 b20=0 b21=0 b22=0.5 b23=0 b24=0 b25=0 b26 = 0 b27 =0 b28 = 0 b29 =0 b30 =0;
expo =exp(b0+b1*hhsz + b2*child + b3*country + b4*e0 + b5*e1 + b6*e2 + b7*e3 + b8*e4 + b9*e5+ b10*a2 + 
b11*a3 + b12*a4 + b13*a5 + b14*a6 +  b15*a7 + b16*a8 + b17*a9 + b18*a10 + b19*a11 + b20*r2 + b21*r3 
+ b22*r4+b23*reg2+b24*reg3+b25*reg4+b26*i2+b27*i3+b28*i4+b29*i5+b30*i6); 

 logprob = log(gamma(nbdr+t_qty))-log(gamma(nbdr))-log(fact(t_qty))+nbdr*log(alpha/(alpha+expo))+t_qty*log(expo/(alpha+expo));
ll =logprob;
model t_qty ~ general(ll);

  run;






  %let shapeR	=0.09484 ;
%let alpha	=0.3686  ;
%let b0	    =0.7185  ;
%let b1		=0.003782;
%let b2		=0.09451 ;
%let b3		=-0.02508;
%let b4		=-0.2191 ;
%let b5		=0.1799  ;
%let b6		=0.2858  ;
%let b7		=-0.5376 ;
%let b8		=-0.3686;
%let b9		=-0.1937;
%let b10	=-0.1435;
%let b11	=0.3535 ;
%let b12	=0.3267 ;
%let b13	=0.204  ;
%let b14	=0.5837 ;
%let b15	=0.2349 ;
%let b16	=0.3604 ;
%let b17	=0.6027 ;
%let b18	=0.1134  ;
%let b19	=0.5262  ;
%let b20	=-0.6416 ;
%let b21	=-0.4138 ;
%let b22	=0.5     ;
%let b23	=-0.254  ;
%let b24	=-0.3979 ;
%let b25	=-0.3527 ;
%let b26	=-0.0452 ;
%let b27	=-0.1954 ;
%let b28	=0.0501  ;
%let b29	=0.1395  ;
%let b30	=0.158   ;



data NBIIProb;
  set books_3;
  eBx =exp(&b0+&b1*hhsz + &b2*child + &b3*country + &b4*e0 + &b5*e1 + &b6*e2 + &b7*e3 + &b8*e4 + &b9*e5+ &b10*a2 + 
&b11*a3 + &b12*a4 + &b13*a5 + &b14*a6 +  &b15*a7 + &b16*a8 + &b17*a9 + &b18*a10 + &b19*a11 + &b20*r2 + &b21*r3 
+ &b22*r4+&b23*reg2+&b24*reg3+&b25*reg4+&b26*i2+&b27*i3+&b28*i4+&b29*i5+&b30*i6);


  array prob(11) prob0 - prob10;  /* prob(y+1)=proby */ 
  prob0=((&alpha/(&alpha+eBx))** &shapeR);
  prob10=1-prob0; /* prob of visited 10+ times. */
  do y=1 to 9;
    prob(y+1)= (gamma(&shapeR+y)/(gamma(&shapeR)*fact(y))) * ((&alpha/(&alpha+eBx))** &shapeR) * ((eBx/(&alpha+eBx)) ** y);
    prob10=prob10-prob(y+1);
  end;
run;

proc print data =NBIIProb(obs =10);run; 

data comparenbd(keep =t_qty prob0);
set NBIIProb;
run;

proc print data =comparenbd(obs =10);run;
/*-------------------------*/



/*average the probabilities over the whole population*/
proc means data=NBIIprob;
var prob0-prob10;
output out=mean_nb mean=;
run;


PROC TRANSPOSE DATA=mean_nb OUT=transpose_nb NAME=Prob;
 ID _FREQ_;
 VAR prob0-prob10;
RUN;
PROC PRINT data=transpose_nb;run;
/*Removing the variables created in proc means and multiplying the probablities by the populayion*/
data transpose_nb(drop=_8134); 
set transpose_nb;
_8134 = _8134*8134;
rename _8134 = value;
run;
proc print data=transpose_nb;run;


proc sgplot data=transpose_nb;
	TITLE "Bar chart of Counts"; 
   vbar prob / response=value;
run;	

proc freq data=books_3;
	TITLE "Frequency chart of t_qty";
tables t_qty / plots=freqplot;run;

