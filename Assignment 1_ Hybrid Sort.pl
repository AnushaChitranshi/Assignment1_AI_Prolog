/*1. hybridSort takes SIX arguments: 
hybridSort(LIST,SMALL,BIG,THRESHOLD,SLIST, ORDER).
2. THRESHOLD is a positive integer
3. SMALL is one of the small sorts (Bubble sort, and insertion sort)
4. BIG is one of the big sorts (Merge sort, and Quick sort)
5. SLIST is the sorted version of LIST
6. ORDER is less or greater */

/* Comment describing decreasing and increasing */
decreasing(X, Y):- Y =< X. 
increasing(X, Y):- X =< Y.

/*swap the first two elements if they are not in order*/ 
swap([X, Y|T], [Y, X | T], increasing):- 
            decreasing(X, Y).
/*swap elements in the tail*/ 
swap([H|T], [H|T1], increasing):- 
              swap(T, T1, increasing). 
swap([X, Y|T], [Y, X | T], decreasing):- 
            increasing(X, Y).
swap([H|T], [H|T1], decreasing):- 
              swap(T, T1, decreasing).

/* Comment describing bubbleSort */
bubbleSort(L,SL, ORDER):- 
            swap(L, L1, ORDER), % at least one swap is needed 
             !, 
             bubbleSort(L1, SL, ORDER). 
bubbleSort(L, L, _ORDER). % here, the list is already sorted

/* Comment describing ordered */
ordered([],_).
ordered([_X], _).
ordered([H1, H2|T], increasing):-
    increasing(H1, H2), 
    ordered([H2|T], increasing).
ordered([H1, H2|T], decreasing):-
    decreasing(H1, H2), 
    ordered([H2|T], decreasing).

/*Comment describing insert(E, SL, SLE, ORDER) ...*/
insert(X, [],[X], _). 
insert(E, [H|T], [E,H|T], increasing):- 
                        ordered(T,increasing),
                        increasing(E, H), 
                        !. 
insert(E, [H|T], [H|T1], increasing):- 
            ordered(T,increasing),
            insert(E, T, T1, increasing). 
insert(E, [H|T], [E,H|T], decreasing):- 
                        ordered(T,decreasing),
                        decreasing(E, H), 
                        !. 
insert(E, [H|T], [H|T1], decreasing):- 
            ordered(T,decreasing),
            insert(E, T, T1, decreasing). 
  
/* Comment describing insertionSort */
insertionSort([], [], _). 
insertionSort([H|T], SORTED, increasing) :- 
          insertionSort(T, T1, increasing), 
          insert(H, T1, SORTED, increasing). 
insertionSort([H|T], SORTED, decreasing) :- 
          insertionSort(T, T1, decreasing), 
          insert(H, T1, SORTED, decreasing). 

/* Comment to describe meregeSort... */
mergeSort([], [], _).    %the empty list is sorted 
mergeSort([X], [X], _):-!.
mergeSort(L, SL, increasing):- 
             split_in_half(L, L1, L2), 
             mergeSort(L1, S1, increasing), 
             mergeSort(L2, S2, increasing),
             merge(S1, S2, SL, increasing). 
mergeSort(L, SL, decreasing):-  
    		 split_in_half(L, L1, L2), 
             mergeSort(L1, S1, decreasing), 
             mergeSort(L2, S2, decreasing),
             merge(S1, S2, SL, decreasing). 

/* Comment to describe split_in_half...*/
intDiv(N,N1, R):- R is div(N,N1).
split_in_half([], _, _):-!, fail.
split_in_half([X],[],[X]). 
split_in_half(L, L1, L2):- 
             length(L,N), 
             intDiv(N,2,N1),
             length(L1, N1), 
             append(L1, L2, L). 

/* Comment describing merge(S1, S2, S, ORDER) */
merge([], L, L, _).
merge(L, [],L, _).
merge([H1|T1],[H2|T2],[H1| T], increasing):-
						increasing(H1,H2),
						merge(T1,[H2|T2],T, increasing).
merge([H1|T1], [H2|T2], [H2|T], increasing):-
						decreasing(H1, H2),
						merge([H1|T1],T2, T , increasing).
   
merge([H1|T1],[H2|T2],[H1|T], decreasing):-
						decreasing(H1,H2),
						merge(T1,[H2|T2],T, decreasing).
merge([H1|T1], [H2|T2], [H2|T], decreasing):-
						increasing(H1, H2),
						merge([H1|T1], T2, T, decreasing).

/* Comment describing split for quickSort */
split(_, [],[],[]). 
split(X, [H|T], [H|SMALL], BIG):- 
								H =< X, 
    							split(X, T, SMALL, BIG).    
split(X, [H|T], SMALL, [H|BIG]):-
    							X =< H,
    							split(X, T, SMALL, BIG). 

/* Comment describing quickSort */
quickSort([], [], _).
quickSort([H|T], LS, increasing):-
        split(H, T, SMALL, BIG), 
        quickSort(SMALL, S, increasing), 
        quickSort(BIG, B, increasing), 
        append(S, [H|B], LS). 
quickSort([H|T], LS, decreasing):- 
        split(H, T, SMALL, BIG), 
        quickSort(SMALL, S, decreasing), 
        quickSort(BIG, B, decreasing),  
        append(B, [H], AUX),
        append(AUX, S, LS). 


/* Comment describing hybridSort */
hybridSort(LIST, bubbleSort, BIGALG, T, SLIST, ORDER):-
    		length(LIST, N), N=<T,      
    		bubbleSort(LIST, FILLINHERE, ORDER).

hybridSort(LIST, insertionSort, BIGALG, T, SLIST, ORDER):-
			length(LIST, N), N=<T,
     		insertionSort(LIST, SLIST, ORDER).

hybridSort(LIST, SMALL, mergeSort, T, SLIST, ORDER):-
			length(LIST, N), N>T,      
			split_in_half(LIST, L1, L2),
   			hybridSort(L1, SMALL, mergeSort, T, S1, ORDER),
    		hybridSort(L2, SMALL, mergeSort, T, S2, ORDER),
    		merge(S1,S2, SLIST, ORDER).

hybridSort([H|T], SMALL, quickSort, T, SLIST, increasing):-
			length(LIST, N), N>T,      
			split(H, T, L1, L2),
    		FILLINHERE several lines in the body of this clause
    		append(S1, [H|S2], SLIST).

hybridSort([H|T], SMALL, quickSort, T, SLIST, decreasing):-
			length(LIST, N), N>T,      
			split(H, T, L1, L2),
    		FILLINHERE several lines in the body of this clause
    		append(S1, [H|S2], SLIST).