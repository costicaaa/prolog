:- dynamic(fapt/3).

fapt(av(laptop,alienware),50,[77]).
fapt(av(laptop,asus),60,[20]).
fapt(av(laptop,dell),80,[23,24]).

ord :- setof((FC, X, Y), 
    retract(fapt(av(laptop,X), FC, Y)),ListaFinala),
    parc(ListaFinala).

parc([]).
parc([(FC, X, Y)|T]) :-
    asserta(fapt(av(laptop,X), FC, Y)),
    parc(T).