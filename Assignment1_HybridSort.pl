/*1. hybridSort takes SIX arguments: 
hybridSort(LIST,SMALL,BIG,THRESHOLD,SLIST, ORDER).
2. THRESHOLD is a positive integer
3. SMALL is one of the small sorts (Bubble sort, and insertion sort)
4. BIG is one of the big sorts (Merge sort, and Quick sort)
5. SLIST is the sorted version of LIST
6. ORDER is less or greater */

/* Checks if which one of two numbers is larger and decides increasing and decreasing */
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

/* predicate implementing bubble sort-continuously compares two adjacent elements several times untill the entire list is sorted */
bubbleSort(L,SL, ORDER):- 
            swap(L, L1, ORDER), % at least one swap is needed 
             !, 
             bubbleSort(L1, SL, ORDER). 
bubbleSort(L, L, _ORDER). % here, the list is already sorted

/* Facts desribing whether the list is in increasing or decreasing order. checks first two elements and then uses recursive calls to split and check the rest of the list */
ordered([],_).
ordered([_X], _).
ordered([H1, H2|T], increasing):-
    increasing(H1, H2), 
    ordered([H2|T], increasing).
ordered([H1, H2|T], decreasing):-
    decreasing(H1, H2), 
    ordered([H2|T], decreasing).

/*predicate describing the insertion of an element E into a list after ensuring the list is ordered accordingly*/
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
  
/* uses insertion sort-utilizing the split operator to continuously divide he list into sorted and unsorted parts to sort the list */
insertionSort([], [], _). 
insertionSort([H|T], SORTED, increasing) :- 
          insertionSort(T, T1, increasing), 
          insert(H, T1, SORTED, increasing). 
insertionSort([H|T], SORTED, decreasing) :- 
          insertionSort(T, T1, decreasing), 
          insert(H, T1, SORTED, decreasing). 

/* Utilizes recursion to apply mergesort-divide the list into two halves and recursively call itself and then merge the lists together.*/
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

/* split_in_half splits our list into half*/
intDiv(N,N1, R):- R is div(N,N1).
split_in_half([], _, _):-!, fail.
split_in_half([X],[],[X]). 
split_in_half(L, L1, L2):- 
             length(L,N), 
             intDiv(N,2,N1),
             length(L1, N1), 
             append(L1, L2, L). 

/* merge sort algorithm recursively splits the list into sublists until sublist size 
is 1, then merges those sublists to produce a sorted list. */
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

/* quickSort works by selecting a 'pivot' element from the array and partitioning the 
other elements into two sub-arrays, according to whether they are less than or greater than the pivot. */
split(_, [],[],[]). 
split(X, [H|T], [H|SMALL], BIG):- 
				H =< X, 
    				split(X, T, SMALL, BIG).    
split(X, [H|T], SMALL, [H|BIG]):-
    				X =< H,
    				split(X, T, SMALL, BIG). 

/* applies quicksort algorithm using a pivot and then partitioning array around given pivot. */
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


/* hybridSort selects a sorting method based on the list size with respect to the entered threshold (T)
when the length of LIST is less than THRESHOLD, then hybridSort calls SMALL
when the length of list LIST is greater than or equal to THRESHOLD, then hybridSort behaves like one of the BIG sorts */

hybridSort(LIST, bubbleSort, BIGALG, T, SLIST, ORDER):-
    			length(LIST, N), N=<T,      
    			bubbleSort(LIST, SLIST, ORDER).

hybridSort(LIST, insertionSort, BIGALG, T, SLIST, ORDER):-
			    length(LIST, N), N=<T,
     			insertionSort(LIST, SLIST, ORDER).

hybridSort(LIST, SMALL, mergeSort, T, SLIST, ORDER):-
			length(LIST, N), N>T,      
			split_in_half(LIST, L1, L2),
   			hybridSort(L1, SMALL, mergeSort, T, S1, ORDER),
    			hybridSort(L2, SMALL, mergeSort, T, S2, ORDER),
    			merge(S1,S2, SLIST, ORDER).

hybridSort([H|T], SMALL, quickSort, Threshold, SLIST, increasing):-
			length([H|T], N), N>Threshold,      
			split(H, T, L1, L2),
    		hybridSort(L1, SMALL, quickSort, Threshold, S1, increasing),
    		hybridSort(L2, SMALL, quickSort, Threshold, S2, increasing),
    		append(S1, [H|S2], SLIST).

hybridSort([H|T], SMALL, quickSort, Threshold, SLIST, decreasing):-
			length([H|T], N), N>Threshold,      
			split(H, T, L1, L2),
    		hybridSort(L1, SMALL, quickSort, Threshold, S1, decreasing),
    		hybridSort(L2, SMALL, quickSort, Threshold, S2, decreasing),
    		append(S1, [H|S2], SLIST).

myList([1,4,5]).

:- initialization main.
:- initialization writeln('1. bubble sort output').
:- initialization forall(bubbleSort([48, 46, 40, 11, 31, 8, 17, 58, 53, 37, 1, 5, 15, 25, 88, 71, 18, 39, 41, 65, 44, 84, 47, 79, 99, 34, 4, 67, 14, 69, 86, 2, 91, 93, 55, 81, 42, 32, 85, 77, 49, 61, 35, 64, 13, 27, 36, 23, 7, 95, 52], Output, increasing), writeln(Output)).
:- initialization writeln('2. insertion sort output').
:- initialization forall(insertionSort([48, 46, 40, 11, 31, 8, 17, 58, 53, 37, 1, 5, 15, 25, 88, 71, 18, 39, 41, 65, 44, 84, 47, 79, 99, 34, 4, 67, 14, 69, 86, 2, 91, 93, 55, 81, 42, 32, 85, 77, 49, 61, 35, 64, 13, 27, 36, 23, 7, 95, 52], Output, increasing), writeln(Output)).
:- initialization writeln('3. merge sort output').
:- initialization forall(mergeSort([48, 46, 40, 11, 31, 8, 17, 58, 53, 37, 1, 5, 15, 25, 88, 71, 18, 39, 41, 65, 44, 84, 47, 79, 99, 34, 4, 67, 14, 69, 86, 2, 91, 93, 55, 81, 42, 32, 85, 77, 49, 61, 35, 64, 13, 27, 36, 23, 7, 95, 52], Output, increasing), writeln(Output)).
:- initialization writeln('4. quick sort output').
:- initialization forall(quickSort([48, 46, 40, 11, 31, 8, 17, 58, 53, 37, 1, 5, 15, 25, 88, 71, 18, 39, 41, 65, 44, 84, 47, 79, 99, 34, 4, 67, 14, 69, 86, 2, 91, 93, 55, 81, 42, 32, 85, 77, 49, 61, 35, 64, 13, 27, 36, 23, 7, 95, 52], Output, increasing), writeln(Output)).

:- initialization writeln('5. hybrid sort output: bubble and merge').
:- initialization forall(hybridSort([48, 46, 40, 11, 31, 8, 17, 58, 53, 37, 1, 5, 15, 25, 88, 71, 18, 39, 41, 65, 44, 84, 47, 79, 99, 34, 4, 67, 14, 69, 86, 2, 91, 93, 55, 81, 42, 32, 85, 77, 49, 61, 35, 64, 13, 27, 36, 23, 7, 95, 52], bubbleSort, mergeSort, 5, Output, increasing), writeln(Output)).

:- initialization writeln('6. hybrid sort output: bubble and quick').
:- initialization forall(hybridSort([48, 46, 40, 11, 31, 8, 17, 58, 53, 37, 1, 5, 15, 25, 88, 71, 18, 39, 41, 65, 44, 84, 47, 79, 99, 34, 4, 67, 14, 69, 86, 2, 91, 93, 55, 81, 42, 32, 85, 77, 49, 61, 35, 64, 13, 27, 36, 23, 7, 95, 52], bubbleSort, quickSort, 5, Output, increasing), writeln(Output)).

:- initialization writeln('7. hybrid sort output: insert and merge').
:- initialization forall(hybridSort([48, 46, 40, 11, 31, 8, 17, 58, 53, 37, 1, 5, 15, 25, 88, 71, 18, 39, 41, 65, 44, 84, 47, 79, 99, 34, 4, 67, 14, 69, 86, 2, 91, 93, 55, 81, 42, 32, 85, 77, 49, 61, 35, 64, 13, 27, 36, 23, 7, 95, 52], insertionSort, mergeSort, 5, Output, increasing), writeln(Output)).

:- initialization writeln('8. hybrid sort output: insert and quick').
:- initialization forall(hybridSort([48, 46, 40, 11, 31, 8, 17, 58, 53, 37, 1, 5, 15, 25, 88, 71, 18, 39, 41, 65, 44, 84, 47, 79, 99, 34, 4, 67, 14, 69, 86, 2, 91, 93, 55, 81, 42, 32, 85, 77, 49, 61, 35, 64, 13, 27, 36, 23, 7, 95, 52], insertionSort, quickSort, 5, Output, increasing), writeln(Output)).


main :-
    % sample_list = [33,  5, 36, 21, 38, 47, 12, 46, 20, 31, 37, 45,  2,  6, 41,  9, 24, 3,  7, 44, 35, 27, 16, 26, 10, 14, 43, 42,  4, 15, 48, 22, 18, 11, 17, 28, 39,  1, 32, 34, 25, 23,  0, 19,  8, 49, 40, 13, 30, 29];
    % bubbleSort(sample_list, BubbleSort_output, increasing);
    % write(BubbleSort_output);
    write('Hello World\n').
