*import source file into program#;
proc import file="/shared/home/ayesha.noor@ieseg.fr/MusicDNA/SpotifyAudioFeaturesApril2019.csv"
    out=rawdata
    dbms=csv;
run;
 
*print few imported data;
proc print data=rawdata (obs=6) noobs;
run;

*Verify data for special characters to understand the significance before removing;
proc print data=rawdata;
where artist_name like '%$%';
run;

*As it can be seen Letter S is appearing as $ in artist name and trackname hence replace $ by S;
data translate_dollar_to_S;
	set rawdata;
artist_name_new = translate(artist_name, 'S', '$');
track_name_new = translate(track_name, 'S', '$');
run;

*Cross verify the data;
proc print data=translate_dollar_to_S;
where artist_name_new like '%$%';
run;*No observations returned;

*remove all special characters from string columns;
data remove_special_char;
	set translate_dollar_to_S;
Artist_Name_New2=compress(artist_name_new, '','kad');
track_Name_New2=compress(track_name_new, '','kad');
run;

* verify data again based on artist name and check results in artist_name_new2 variable;
proc print data=remove_special_char;
where artist_name like '%[%';
run;

*delete rows from artist_name ariable which has just numbers
 in artist name;
data remove_numeric_values;
  	set remove_special_char;
  	if not (anyalpha(artist_Name_New2)) then delete; 
run;

*Cross erify previous operation;
proc print data=remove_numeric_values; 
where artist_name_new2 like '%888%';
run; *no observations returned;

* using the cmiss function to find the rows that include complete cases, 
i.e. none of the variables contain missing data;

DATA Remove_nulls_from_allvar;
    SET remove_numeric_values;
    IF cmiss(of _ALL_) ~= 0 THEN DELETE;
RUN;

*Delete all old vvariables and rename new created ariables to old names;
data remove_unrequired_var;
	set Remove_nulls_from_allvar(drop = artist_name track_name artist_name_new  track_name_new);
	rename artist_Name_New2 = artist_name track_Name_New2 = track_name;
run;

*Verify your result;
proc print data=remove_unrequired_var (obs=6) noobs;
run; *correct observations are returned;

*Verify  results for numeric valuues;
proc print data=remove_unrequired_var (obs=6) noobs;
where artist_name like '%888%';
run; *0 observations returned;

*Verify your results for letter being displayed as $;
proc print data=remove_unrequired_var (obs=6) noobs;
where artist_name like '%$%';
run; *0 observations returned;

*Verify your results for special characters;
proc print data=remove_unrequired_var (obs=6) noobs;
where artist_name like '%[%';
run; *0 observations returned;

*As Data is cleaned let's extract it to a sas dataset for model development;
data "/shared/home/ayesha.noor@ieseg.fr/casuser/Cleaned_Music_Source_data";
set remove_unrequired_var;
run;
