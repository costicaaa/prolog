/*
cod preluat din cartea(bibliografie[1]):
BALCAN Maria Florina, HRISTEA Florentina, 
Aspecte ale Cautarii si Reprezentarii Cunostintelor in Inteligenta Artificiala,
Editura Universitatii din Bucuresti, 2004, 
pg 216


:- use_module(library(file_systems),[]),file_systems:current_directory(_,'C:/stuff/fac/prolog/project/coco').


use_module(library(process)).
process_create('C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe', ['C:\\stuff\\fac\\prolog\\project\\coco\\aaa.html'] , []).

*/

close_all:-current_stream(_,_,S),close(S),fail;true.
curata_bc:-current_predicate(P), abolish(P,[force(true)]), fail;true.

:-use_module(library(lists)).
:-use_module(library(file_systems)).
:-use_module(library(system)).
:-use_module(library(process)).

:-dynamic fapt/3.
:-dynamic interogat/1.
:-dynamic scop/1.
:-dynamic interogabil/3.
:-dynamic regula/3.
:-dynamic solutie/4.

:-op(900,fy,not).
not(P) :- P, !, fail.
not(_).


% SCRIE IN CONSOLA O LISTA (propozitie)
% -------------------------------------
scrie_lista([]):-nl.

scrie_lista([H|T]) :- 
	write(H), space(1), 
	scrie_lista(T).
	
	space(0).
		
	space(N) :- 
		N > 0,write(' '),
		N1 is N-1, space(N1).


% CITESTE UN CUVANT (de la tastatura / din fisier)
% ------------------------------------------------
citeste_cuvant(-1,end_of_file,-1):-!.

citeste_cuvant(Caracter,Cuvant,Caracter1) :-   
	caracter_cuvant(Caracter),!, 
	name(Cuvant, [Caracter]),get_code(Caracter1).
	
	caracter_cuvant(C):-member(C,[44,59,58,63,33,46,41,40,123,125,42,47,91,93,35,124]).
    % am specificat ASCII pentru   ,  ;  :  ?  !  .  )  (   {   }  *  /  [  ]  #   |


citeste_cuvant(Caracter, Numar, Caracter1) :-
	caracter_numar(Caracter),!,
	citeste_tot_numarul(Caracter, Numar, Caracter1).
	
	caracter_numar(C):-C<58,C>=48.
		
	citeste_tot_numarul(Caracter,Numar,Caracter1):-
		determina_lista(Lista1,Caracter1),
		append([Caracter],Lista1,Lista),
		transforma_lista_numar(Lista,Numar).

		determina_lista(Lista,Caracter1):-
			get_code(Caracter), 
			(caracter_numar(Caracter),
			determina_lista(Lista1,Caracter1),
			append([Caracter],Lista1,Lista); 
			\+(caracter_numar(Caracter)),
			Lista=[],Caracter1=Caracter).
		 
		transforma_lista_numar([],0).
			
		transforma_lista_numar([H|T],N):-
			transforma_lista_numar(T,NN), 
			lungime(T,L), Aux is exp(10,L),
			HH is H-48,N is HH*Aux+NN.

			lungime([],0).
				
			lungime([_|T],L):-
				lungime(T,L1),
				L is L1+1.


citeste_cuvant(Caracter,Cuvant,Caracter1) :-
	Caracter==39,!,  % 39 este codul ASCII pt '
	pana_la_urmatorul_apostrof(Lista_caractere),
	L=[Caracter|Lista_caractere],
	name(Cuvant, L),get_code(Caracter1).

	pana_la_urmatorul_apostrof(Lista_caractere):-
		get_code(Caracter),
		(Caracter == 39,Lista_caractere=[Caracter];
		Caracter\==39,
		pana_la_urmatorul_apostrof(Lista_caractere1),
		Lista_caractere=[Caracter|Lista_caractere1]).


citeste_cuvant(Caracter,Cuvant,Caracter1) :-          
	caractere_in_interiorul_unui_cuvant(Caracter),!,              
	((Caracter>64,Caracter<91),!,
	Caracter_modificat is Caracter+32;
	Caracter_modificat is Caracter),                              
	citeste_intreg_cuvantul(Caractere,Caracter1),
	name(Cuvant,[Caracter_modificat|Caractere]).
    
	% define ce sa fie considerat cuvant 
	caractere_in_interiorul_unui_cuvant(C):-
		C >= 48,C =< 57;  % [0,9]
		C >= 65,C =< 90;  % [A,Z]
		C >= 97,C =< 122; % [a,z]
		C == 45;		  % [-]
		C == 95.		  % [_]

	citeste_intreg_cuvantul(Lista_Caractere,Caracter1) :-
		get_code(Caracter),
		(caractere_in_interiorul_unui_cuvant(Caracter),
		((Caracter>64,Caracter<91),!, 
		Caracter_modificat is Caracter+32;
		Caracter_modificat is Caracter),
		citeste_intreg_cuvantul(Lista_Caractere1, Caracter1),
		Lista_Caractere=[Caracter_modificat|Lista_Caractere1]; \+(caractere_in_interiorul_unui_cuvant(Caracter)),
		Lista_Caractere=[], Caracter1=Caracter).


citeste_cuvant(_,Cuvant,Caracter1) :-                
	get_code(Caracter),       
	citeste_cuvant(Caracter,Cuvant,Caracter1).
%_________________________________________________________________________________________________________________________________________________
%_________________________________________________________________________________________________________________________________________________

%_________________S_T_A_R_T_______________________________________________________________________________________________________________________

pornire :-
	retractall(interogat(_)),
	retractall(fapt(_,_,_)),
	repeat,
	write('Introduceti una din urmatoarele optiuni: '),
	nl,nl,
	write(' (Incarca Consulta Reinitiaza  Afisare_fapte  Cum   Iesire ) '),
	nl,nl,write('|: '),citeste_linie([H|T]),/**/
	executa([H|T]), H == iesire.
	
	
	citeste_linie([Cuv|Lista_cuv]) :-
		get_code(Car),
		citeste_cuvant(Car, Cuv, Car1), 
		rest_cuvinte_linie(Car1, Lista_cuv).
 
		rest_cuvinte_linie(-1, []):-!. % -1 este codul ASCII pt EOF
			
		rest_cuvinte_linie(Car,[]) :-(Car==13;Car==10), !.
			
		rest_cuvinte_linie(Car,[Cuv1|Lista_cuv]) :-
			citeste_cuvant(Car,Cuv1,Car1),      
			rest_cuvinte_linie(Car1,Lista_cuv).


	executa([incarca]) :- 
		incarca(1),
		incarca(2),
		!,nl,
		write('Fisierul dorit a fost incarcat'),nl.
	
		incarca(1) :-
			%write('Introduceti numele fisierului care doriti sa fie incarcat: '),nl, write('|:'),read(F),
			F = 'all',
			file_exists(F),!,incarca(F, 1).

		incarca(2) :-
			%write('Introduceti numele fisierului care doriti sa fie incarcat: '),nl, write('|:'),read(F),
			F = 'desc',
			file_exists(F),!,incarca(F, 2).

		incarca:-write('Nume incorect de fisier! -- nu are cums a intre aici'),nl,fail.
			
		incarca(F, 1) :-
			retractall(interogat(_)),retractall(fapt(_,_,_)),
			retractall(scop(_)),retractall(interogabil(_,_,_)),
			retractall(regula(_,_,_)),
			see(F),incarca_reguli,seen,!.

		incarca(F, 2) :-
			retractall(solutie(_,_,_,_)),
			see(F),incarca_reguli,seen,!.

			incarca_reguli :-
				repeat,
				citeste_propozitie(L),
				proceseaza(L),
				L == [end_of_file],
				nl.

				citeste_propozitie([Cuv|Lista_cuv]) :-
						get_code(Car),
						citeste_cuvant(Car, Cuv, Car1), 
						rest_cuvinte_propozitie(Car1, Lista_cuv).
					
					rest_cuvinte_propozitie(-1, []):-!.
						
						%  punctu e 46
					rest_cuvinte_propozitie(Car,[]) :-Car==46, !.

						%  # e 35 
					rest_cuvinte_propozitie(Car,[]) :-Car==35, citeste_13_diez(13), !. 

					citeste_13_diez(0):- !.
					citeste_13_diez(N):- 
						get_code(_), 
						N1 is N - 1,
						citeste_13_diez(N1).

					%  niciodata nu apeleaza rest_cuvinte_propozitie ( # ) 
					% daca # este dupa spatiu sau new line, practic e ignorat
					rest_cuvinte_propozitie(Car,[Cuv1|Lista_cuv]) :-
						citeste_cuvant(Car,Cuv1,Car1),      
						rest_cuvinte_propozitie(Car1,Lista_cuv).
					
					
				proceseaza([end_of_file]):-!.
					


				proceseaza(L) :- 
					trad(R,L,[]),
					(R = interogabil(Atr,M,P) -> 
						append(M, [nu_stiu, nu_conteaza], NEWM),
						assertz(interogabil(Atr,NEWM,P))
					;
						assertz(R)
					),!.
					% trad(scop(X)) --> [scopul,este,X].

						%  parsare laptop
					trad(scop(X)) --> ['[',scop,']',X,'[','/',scop,']'].
						
						% parsare intrebare 
					trad(interogabil(Atr,M,P)) --> 
						['[',intrebare,']'],afiseaza(Atr,P),atribut(Atr),lista_optiuni(M), ['[','/',intrebare,']'].
						
						lista_optiuni(M) --> [optiuni,'#', '{'],lista_de_optiuni(M).

							lista_de_optiuni([Element]) -->  [Element,'}'].
								
							lista_de_optiuni([Element|T]) --> [Element,'*'],lista_de_optiuni(T).

						atribut(Atr) --> [atributul_intrebarii, '#', Atr].

						afiseaza(_,P) -->  [text, '#', P].
							
						afiseaza(P,P) -->  [].

					
						% parsare regula
					trad(regula(
								N,
								premise(Daca),
								concluzie(Atunci,F)
							)
						) --> 

							identificator(N),
							daca(Daca),
							atunci(Atunci,F).
						
						identificator(N) --> ['[',regula,']', nr, ':', N].
						daca(Daca) --> [premise_regula, ':'],lista_premise(Daca).

							lista_premise([Daca]) --> propoz(Daca),[implicatie_regula, ':'].
							lista_premise([Prima|Celalalte]) --> propoz(Prima),lista_premise(Celalalte).

						atunci(Atunci,FC) --> propoz(Atunci),['|', fc,'#', '(', FC, ')', '[','/',regula,']' ].
						atunci(Atunci,100) --> propoz(Atunci).

							propoz(not av(Atr,da)) --> [Atr, '#', not].
							propoz(av(Atr,Val)) --> [Atr,'#', '(', Val, ')'].
							propoz(av(Atr,da)) --> [Atr].

% trad de soolutie - > trebuie sa ii fac parsarea, salveaza 4

							% parsare solutie
					trad(solutie(
								Nume, 
								Descriere, 
								Imagine, 
								Prop
							)
						) -->
						numeSolutie(Nume),
						textDescriere(Descriere), 
						caleImagine(Imagine),
						toateProprietati(Prop), 
						['#'].

						numeSolutie(N) --> [solutie, '---', N].
						textDescriere(D) --> [descriere, '---', D].
						caleImagine(Imagine) --> [imagine, '---', '{', Imagine, '}'].
					
					
						toateProprietati(Prop) --> [proprietati, '---', '{'],lista_proprietati(Prop).

							lista_proprietati([Prop]) --> propoz(Prop), ['}'].
							lista_proprietati([Prima | Celalalte]) --> propoz(Prima), [','],lista_proprietati(Celalalte).

								% propoz(_) --> ['}'].
								propoz(av(Atr,Val)) --> [Atr, '#', Val].
								
					trad('Eroare la parsare'-L,L,_).


	executa([consulta]) :-
		sterge_folder('output_dem_sistem'),
		scopuri_princ,!.

		scopuri_princ :-
			scop(Atr),
			determina(Atr), 
			afiseaza_scop(Atr),
			fail.
		
			scopuri_princ.
		
			determina(Atr) :-
				realizare_scop(av(Atr,_),_,[scop(Atr)]),!.

			determina(_).
				
				realizare_scop(not Scop,Not_FC,Istorie) :-
					realizare_scop(Scop,FC,Istorie),
					Not_FC is - FC, !.


				realizare_scop(Scop,FC,_) :-
					fapt(Scop,FC,_), !.


				realizare_scop(Scop,FC,Istorie) :-
					pot_interoga(Scop,Istorie),
					!,realizare_scop(Scop,FC,Istorie).
					
					pot_interoga(av(Atr,_),Istorie) :-
						not interogat(av(Atr,_)),
						interogabil(Atr,Optiuni,Mesaj),
						interogheaza(Atr,Mesaj,Optiuni,Istorie),nl,
						asserta( interogat(av(Atr,_)) ).
						
						interogheaza(Atr,Mesaj,[da,nu,nu_stiu,nu_conteaza],Istorie):-
							!,write(Mesaj),nl,
							citeste_opt(X,[da,nu,nu_stiu,nu_conteaza],Istorie),
							% de_la_utiliz(X,Istorie,[da,nu]),
							(
								X = 'nu_conteaza' -> 
								asserta( fapt(av(Atr,da),100,[utiliz])),
								asserta( fapt(av(Atr,da),-100,[utiliz]))
								;	
								det_val_fc(X,Val,FC),
								asserta( fapt(av(Atr,Val),FC,[utiliz]) )
							).

						interogheaza(Atr,Mesaj,Optiuni,Istorie) :-
							write(Mesaj),nl,
							citeste_opt(VLista,Optiuni,Istorie),
							append(ActualOptiuni, [nu_stiu, nu_conteaza], Optiuni),
							assert_fapt(Atr,VLista,ActualOptiuni).
							
							citeste_opt(X,Optiuni,Istorie) :-
								append(['('],Optiuni,Opt1),
								append(Opt1,[')'],Opt),
								scrie_lista(Opt),
								de_la_utiliz(X,Istorie,Optiuni).

								de_la_utiliz(X,Istorie,Lista_opt) :-
									repeat,write(': '),citeste_linie(X),
									proceseaza_raspuns(X,Istorie,Lista_opt).

									proceseaza_raspuns([de_ce],Istorie,_) :- nl,afis_istorie(Istorie),!,fail.
									% CA EXEMPLU, NOI TREBUIE SA AVEM nu_stiu SI nu_conteaza
										afis_istorie([]) :- nl.
											
										afis_istorie([scop(X)|T]) :-
											scrie_lista([scop,X]),!, afis_istorie(T).

										afis_istorie([N|T]) :-
											afis_regula(N),!,afis_istorie(T).
										
										%  raspuns corect
									proceseaza_raspuns([X],_,Lista_opt):-
										member(X,Lista_opt).
										
										% cici fc 33 aici 
									proceseaza_raspuns([X,fc,FC],_,Lista_opt):-
										member(X,Lista_opt),float(FC).
								
							assert_fapt(Atr,[Val,fc,FC],ActualOptiuni) :-
								!,asserta( fapt(av(Atr,Val),FC,[utiliz]) ).

								% verifica daca e nu conteaza sau nu 
							assert_fapt(Atr,[Val],ActualOptiuni) :-
								(
									Val = 'nu_conteaza' -> 
									insert_all_optiuni(Atr, ActualOptiuni)
									;	
									asserta( fapt(av(Atr,Val),100,[utiliz]))
								).
							
							insert_all_optiuni(Atr, []).
							insert_all_optiuni(Atr, [H|T]):- 
									asserta(fapt(av(Atr,H), 100, [utiliz])),
									insert_all_optiuni(Atr, T).
									
							det_val_fc([nu],da,-100).
								
							det_val_fc([nu,FC],da,NFC) :- NFC is -FC.
								
							det_val_fc([nu,fc,FC],da,NFC) :- NFC is -FC.
								
							det_val_fc([Val,FC],Val,FC).
								
							det_val_fc([Val,fc,FC],Val,FC).
								
							det_val_fc([Val],Val,100).


						

					%  incearca sa demonstreze
				realizare_scop(Scop,FC_curent,Istorie) :-
					fg(Scop,FC_curent,Istorie).
					
					fg(Scop,FC_curent,Istorie) :-
						regula(N, premise(Lista), concluzie(Scop,FC)),
						demonstreaza(N,Lista,FC_premise,Istorie),
						ajusteaza(FC,FC_premise,FC_nou),
						actualizeaza(Scop,FC_nou,FC_curent,N),
						FC_curent == 100,!.

					fg(Scop,FC,_) :- fapt(Scop,FC,_).
						
						demonstreaza(N,ListaPremise,Val_finala,Istorie) :-
							dem(ListaPremise,100,Val_finala,[N|Istorie]),!.

							dem([],Val_finala,Val_finala,_).
								
							dem([H|T],Val_actuala,Val_finala,Istorie) :-
								realizare_scop(H,FC,Istorie),
								Val_interm is min(Val_actuala,FC),
								Val_interm >= 20,
								dem(T,Val_interm,Val_finala,Istorie).
				
						ajusteaza(FC1,FC2,FC) :-
							X is FC1 * FC2 / 100,
							FC is round(X).
				
						actualizeaza(Scop,FC_nou,FC,RegulaN) :-
							fapt(Scop,FC_vechi,_),
							combina(FC_nou,FC_vechi,FC),
							retract( fapt(Scop,FC_vechi,Reguli_vechi) ),
							asserta( fapt(Scop,FC,[RegulaN | Reguli_vechi]) ),!.

						actualizeaza(Scop,FC,FC,RegulaN) :-
							asserta( fapt(Scop,FC,[RegulaN]) ).

							combina(FC1,FC2,FC) :-
								FC1 >= 0,FC2 >= 0,
								X is FC2*(100 - FC1)/100 + FC1,
								FC is round(X).

							combina(FC1,FC2,FC) :-
								FC1 < 0,FC2 < 0,
								X is - ( -FC1 -FC2 * (100 + FC1)/100),
								FC is round(X).

							combina(FC1,FC2,FC) :-
								(FC1 < 0; FC2 < 0),
								(FC1 > 0; FC2 > 0),
								FCM1 is abs(FC1),FCM2 is abs(FC2),
								MFC is min(FCM1,FCM2),
								X is 100 * (FC1 + FC2) / (100 - MFC),
								FC is round(X).
								
								

		afiseaza_scop(Atr) :-
			nl,
			(	fapt(av(Atr,_),_,_)->
					ord_sol,
					fapt(av(Atr,Val),FC,_),
					FC >= 20,
					scrie_scop(av(Atr,Val),FC),
					scrie_in_fisier(av(Atr,Val)),
					nl,
					fail
					;
					write('Sistemul nu are solutii')
			).
		
			ord_sol :- setof(fapt(FC,Atr,Val,Ist),retract(fapt(av(Atr,Val),FC,Ist)),ListaOrd),insertOrd(ListaOrd).
			insertOrd([fapt(FC,Atr,Val,Ist)|T]):- asserta(fapt(av(Atr,Val),FC,Ist)),insertOrd(T).
			insertOrd([]).
				
			
			afiseaza_scop(_):-
				(
					scop(Atr),
					fapt(av(Atr,_),_,_) -> 
						executa([detalii])
						;
						nl
				),
				nl,
				nl,
				nl.

				scrie_scop(av(Atr,Val),FC) :-
					transformare(av(Atr,Val), X),
					scrie_lista(X),space(2),
					write(' '),
					write('factorul de certitudine este '),
					FC1 is integer(FC),write(FC1).
					
					transformare(av(A,da),[A]) :- !.
						
					transformare(not av(A,da), [not,A]) :- !.
						
					% transformare(av(A,nu),[not,A]) :- !.
						
					transformare(av(A,V),[A,este,V]).

				    transformare2(av(A,da),[A]) :- !.
						
					transformare2(not av(A,da), [A, '#', not]) :- !.
						
					transformare2(av(A,V),[A, '#', '(', V, ')']).

		
	executa([reinitiaza]) :- 
		retractall(interogat(_)),
		retractall(fapt(_,_,_)),!.


	executa([afisare_fapte]) :-
		afiseaza_fapte,!.

		afiseaza_fapte :-
			write('Fapte existente in baza de cunostinte:'),
			nl,nl, write(' (Atribut,valoare) '), nl,nl,
			listeaza_fapte,nl.

			listeaza_fapte:-  
				fapt(av(Atr,Val),FC,_), 
				write('('),write(Atr),write(','),
				write(Val), write(')'),
				write(','), write(' certitudine '),
				FC1 is integer(FC),write(FC1),
				nl,fail.

			listeaza_fapte.


	executa([detalii]) :-
		detalii,!.

		detalii :-
			nl,
			write('Detalii in browser? Da / Nu '),
			nl,
			write('|: '),
			citeste_linie([H|T]),
			(
				H == da -> 
				executa([detalii_da])
				;
					H == nu -> 
					executa([detalii_nu])
					;
					write('Comanda incorecta!'),
					nl
			).

	executa([detalii_da]):- 
		detalii_da, !.
		detalii_da :-
			write('vezi browser'),
			open('html_file8.html', write, Stream), 
			write(Stream, '<html><body>'),
			write(Stream, '<link rel="stylesheet" type="text/css" href="assets/global.css">'),
			write(Stream, '<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.js"></script>'),
			write(Stream, '<script src="assets/main.js"></script>'),
			write(Stream, '<h1>Solutii sistem expert</h1>'),
			scop(Atr),
			findall(Sol, FC^Istorie^(fapt(av(Atr, Sol), FC, Istorie), FC >= 20), ListaSol),


			scrieSolutie(Stream, ListaSol),
			write(Stream, '</body></html>'),
			nl(Stream), 
			close(Stream),
			
			(
				file_exists('C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe') ->
				process_create(
						'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe', 
						['html_file8.html'], 
						[]
					)
					;
					nl,
					write('Chrome exec not found'),
					! 
			),
			nl. 
			scrieSolutie(Stream, []):- !. 
			scrieSolutie(Stream, [Sol|T]) :- 
	% cauta in baza de cunostinte un laptop cu numele sol si returneaza in sol valorile lu bob ala gasit
				% fapt(av(Atr, Sol), _, _),
				
				solutie(Sol, Descriere, Imagine, Prop),
				write(Stream, '<h2>'),
				write(Stream, Sol),
				write(Stream, '</h2>'),

				clean_string_delimiters(Descriere, DescFaraGhilimeles),

				write(Stream, '<p>'),
				write(Stream, DescFaraGhilimeles),
				write(Stream, '</p>'),



				write(Stream, '<img src='),
				write(Stream, Imagine),
				write(Stream, '>'),

				write(Stream, '<br>'),

				write(Stream, '<button class="js--changeDisplay" data-display="1" data-sol="'),
				write(Stream, Sol),
				write(Stream, '">Schimba afisare!</button>'),

				write(Stream, '<div id="ul_'),
				write(Stream, Sol),
				write(Stream, '">'),
					write(Stream, '<ul>'),
					scrie_li(Prop,Stream),
					write(Stream, '</ul>'),
				write(Stream, '</div>'),

				write(Stream, '<br>'),

				write(Stream, '<div style="display:none" id="table_'),
				write(Stream, Sol),
				write(Stream, '">'),

					write(Stream, '<table>'),

						write(Stream, '<thead>'),
						write(Stream, '<tr>'),
						write(Stream, '<td>'),
						write(Stream, 'Atribut'),
						write(Stream, '</td>'),

						write(Stream, '<td>'),
						write(Stream, 'Valoare'),
						write(Stream, '</td>'),
						write(Stream, '</tr>'),
						write(Stream, '</thead>'),

						write(Stream, '<tbody>'),
						scrie_tr(Prop,Stream),
						write(Stream, '</tbody>'),

					write(Stream, '</table>'),
				write(Stream, '</div>'),

				nl(Stream),
				scrieSolutie(Stream,T).

			scrie_li([],Stream):- !.
			scrie_li([H|T],Stream):- 
				H = av(Atr, Val),
				write(Stream, '<li>'),
					write(Stream, Atr),	
					write(Stream, ':'),	
					write(Stream, Val),	
				write(Stream, '</li>'),
				scrie_li(T, Stream).


			scrie_tr([],Stream):- !.
			scrie_tr([H|T],Stream):- 
				H = av(Atr, Val),
				write(Stream, '<tr>'),
					write(Stream, '<td>'),
						write(Stream, Atr),	
					write(Stream, '</td>'),

					write(Stream, '<td>'),
						write(Stream, Val),	
					write(Stream, '</td>'),
				write(Stream, '</tr>'),
				scrie_tr(T, Stream).

	executa([detalii_nu]):- 
		detalii_nu, !.
		detalii_nu :-
			nl,nl
			.	


	executa([cum|L]) :- cum(L),!.
		
		cum([]) :- write('Scop? '),nl,
			write('|:'),citeste_linie(Linie),nl,
			transformare(Scop,Linie), cum(Scop).

		cum(L) :- 
			transformare(Scop,L),nl, cum(Scop).

		cum(not Scop) :- 
			fapt(Scop,FC,Reguli),
			lista_float_int(Reguli,Reguli1),
			FC < -20,
			transformare(not Scop,PG),
			append(PG,[a,fost,derivat,cu,ajutorul,'regulilor: '|Reguli1],LL),
			scrie_lista(LL),nl,
			afis_reguli(Reguli),fail.

		cum(Scop) :-
			fapt(Scop,FC,Reguli),
			lista_float_int(Reguli,Reguli1),
			FC > 20,
			transformare(Scop,PG),
			append( PG , [a,fost,derivat,cu,ajutorul,'regulilor: '|Reguli1] , LL),
			scrie_lista(LL),nl,
			afis_reguli(Reguli),fail.

			lista_float_int([],[]).
				
			lista_float_int([Regula|Reguli],[Regula1|Reguli1]):-
				(Regula \== utiliz,
				Regula1 is integer(Regula);
				Regula ==utiliz, Regula1=Regula),
				lista_float_int(Reguli,Reguli1).
			
			afis_reguli([]).
				
			afis_reguli([N|X]) :-
				afis_regula(N),
				premisele(N),
				afis_reguli(X).

				afis_regula(N) :-
					regula(N, premise(Lista_premise), concluzie(Scop,FC)),
					NN is integer(N),
					scrie_lista(['[regula]']),
					scrie_lista(['nr:', NN]),
					scrie_lista(['premise_regula:']),
					scrie_lista_premise(Lista_premise),
					scrie_lista(['implicatie_regula:']),
					transformare2(Scop,Scop_tr),
					append(['   '],Scop_tr,L1),
					FC1 is integer(FC),
					append(L1,['| fc # (', FC1, ')'], LL),
					
					scrie_lista(LL),
					scrie_lista(['[/regula]']),
					nl.

					scrie_lista_premise([]).
						
					scrie_lista_premise([H|T]) :-
						transformare2(H,H_tr),
						space(5),scrie_lista(H_tr),
						scrie_lista_premise(T).

				premisele(N) :-
					regula(N, premise(Lista_premise), _),
					!, cum_premise(Lista_premise).

					cum_premise([]).
						
					cum_premise([Scop|X]) :-
						cum(Scop),
						cum_premise(X).
			
		cum(_).
		
	executa([iesire]):-!.
		
	executa([_|_]) :-
		write('Comanda incorecta! '),nl.

	scrie_in_fisier(Scop):- 
		verifica_folder('output_dem_sistem'),
		gen_nume_fisier(Scop,NumeFisier),
		atom_concat( 'output_dem_sistem/', NumeFisier, Path),
		telling(Curent_input),
		tell(Path),
			transforma_scop(Scop,L),
			executa([cum|L]),
		told,
		tell(Curent_input),!.

		verifica_folder(Folder):- 
			(
				directory_exists(Folder) -> 
					true
					;
					make_directory(Folder)	
			).

		sterge_folder(Folder):- 
			(
				directory_exists(Folder) -> 
				delete_directory(Folder, [if_nonempty(delete)])
					;
					true
			).
		
		gen_nume_fisier(av(Atr,Solutie),NumeFisier):-
			fapt(av(Atr,Solutie),FC,_),
			creaza_nume_fisier(Solutie,FC,NumeFisier).

			creaza_nume_fisier(Solutie, FC, NumeFisier):-				
				nr_to_atom(FC, FCstring),

				atom_concat( 'demonstratie###', Solutie, N1),
				atom_concat( N1, '###', N2),
				atom_concat( N2, FCstring, N3),
				atom_concat( N3, '.txt', NumeFisier).
				
				nr_to_atom(Nr,Atom):-
					number_chars(Nr, Lchr),
					atom_chars(Atom, Lchr).
	

				transforma_scop(av(A,da),[A]) :- !.
				transforma_scop(av(A,nu), [nu,A]) :- !.
				transforma_scop(av(A,V),[A,este,V]).


				% cerinta 5 
			clean_string_delimiters(String, Result) :-
				atom_length(String, Str_length),
				Final_length is Str_length - 2,
				sub_atom(String, 1, Final_length, 1, Result).
