/* cities(L) holds when L is the list of cities on the road map */
cities(["Arad", "Zerind", "Oradea", "Sibiu", "Timisoara", "Fagaras", 
       "Rimnicu Vlicea", "Lugoj", "Mehadia",  "Drobeta", "Craiova", "Pitesti", 
       "Bucharest", "Giurgiu", "Urziceni", "Hirsova", "Eforie", "Vaslui", "Iasi",
        "Neamt"]).

/* from(C1,C2, D) holds true  when there is a direct link from city C1 to
 * city C2 and the distance between them is D.  Note that the predicate from 
 * is NOT symmetric. Thus, based on the map we have */

from("Arad", "Zerind", 75).
from("Arad", "Sibiu", 140).
from("Arad", "Timisoara", 118).
from("Zerind", "Oradea", 71).
from("Sibiu", "Oradea", 151).
from("Sibiu", "Fagaras", 99).
from("Sibiu", "Rimnicu Vlicea", 80).
from("Fagaras", "Bucharest", 211).
from("Rimnicu Vlicea", "Pitesti", 97).
from("Rimnicu Vlicea", "Craiova", 146).
from("Craiova", "Pitesti", 138).
from("Bucharest", "Pitesti", 101).
from("Craiova", "Drobeta", 120).
from("Mehadia", "Drobeta", 75).
from("Mehadia", "Lugoj", 70).
from("Lugoj", "Timisoara", 111).
from("Giurgiu", "Bucharest", 90).
from("Bucharest", "Urziceni", 85).
from("Urziceni", "Hirsova", 98).
from("Eforie", "Hirsova", 86).
from("Urziceni", "Vaslui", 142).
from("Vaslui", "Iasi", 92).
from("Iasi", "Neamt", 87).

% c(C1, C2, D): symmetric version of from. Thus
connected(X, Y, D):- from(X, Y, D).
connected(X, Y, D):- from(Y, X, D).

/* sld(C1, C2, D) is the estimate of the straight line distance 
 * between cities C1 and C2.  Note that if C1 and C2 are linked directly, 
 * then sld(C1, C2, D) is actually c(C1, C2, D).  Otherwise, we can use the
 *  ideas described in this assignment:*/

% From the table above, we have:
sld("Arad", "Bucharest",366).
sld("Bucharest", "Bucharest",0).
sld("Craiova", "Bucharest",160).
sld("Drobeta", "Bucharest",242).
sld("Eforie", "Bucharest",161).
sld("Fagaras", "Bucharest",176).
sld("Giurgiu", "Bucharest",77).
sld("Hirsova", "Bucharest",151).
sld("Iasi", "Bucharest",226).
sld("Lugoj", "Bucharest",244).
sld("Mehadia", "Bucharest",241).
sld("Neamt", "Bucharest",234).
sld("Oradea", "Bucharest",380).
sld("Pitesti", "Bucharest",100).
sld("Rimnicu Vlicea", "Bucharest",193).
sld("Sibiu", "Bucharest", 253).
sld("Timisoara", "Bucharest", 329).
sld("Urziceni", "Bucharest",80).
sld("Vaslui", "Bucharest", 199).
sld("Zerind", "Bucharest", 374).


%----------------------------------------------------------------------------
% Depth-first search code
% Edge based technique, uninformed search
% It uses the Stack data structure, performs two stages, first visited vertices 
% are pushed into stack and second if there is no vertices then visited vertices
% are popped. 

% Trivial: if X is the goal return X as the path from X to X.
dfs(X, [X],_):- goal(X), !.

% Stopping condition: Expand to all nodes, outputing all possible solution paths
% else expand X by Y and find path from Y
dfs(X, [X|Ypath], VISITED):-
 	connected(X, Y, _),
  	negmember(Y, VISITED),
  	dfs(Y, Ypath, [Y|VISITED]).

% Is in list
is_member(X,[X|_]).
is_member(X,[_|T]):- is_member(X,T).

% utility : negation of member
negmember(X, [X|_]):- !,fail.
negmember(X, [_|T]):- is_member(X, T), !, fail.
negmember(_, _).

%----------------------------------------------------------------------------
% Breadth-first search code
% Vertex based technique, uninformed search
% In BFS, one vertex is selected at a time when it is visited and marked then
% its adjacent are visited and stored in the queue.

/* The stopping rule for this condition is obtained when  the current path to 
 * be expanded starts with the goal node, that is:*/
is_not_member(_,[]).
is_not_member(X, [H|T]):-
    not(X = H),
    is_not_member(X, T).

bfs([[X |T]|_PATHS], [X|T]):- goal(X).

bfs([PATH|TPaths], SOL):-
          expand(PATH,  NPaths),
          append(TPaths, NPaths, NEWPATHS),
          bfs(NEWPATHS, SOL).
 
expand([HPath|TPath], NPaths):-
    findall([NEXT, HPath|TPath],
       (connected(HPath, NEXT, _),is_not_member(NEXT, [HPath|TPath])),
        NPaths).

%We next wrap this in a predicate solve_BF as follows:
solve_BFS(S, SOL):-
    bfs([[S]], S1),
    reverse(S1,SOL).

%----------------------------------------------------------------------------
% Greedy Search
% Greedy is an algorithmic paradigm that builds up a solution piece by piece, 
% always choosing the next piece that offers the most obvious and immediate benefit.
% it is not the most optimal for this problem because locally optimal solutions do
% not lead to a globally optimal solution here. 
% Informed search

greedy(X, [X], _) :- goal(X), !.
greedy(X, [X|Ypath], VISITED):-
 	connected(X, Y, _), connected(X, Z, _),
    sld(Y,"Bucharest",D1), sld(Z,"Bucharest",D2), %f(n) = h(n) which is estimate of cost from n to goal
    D1 =< D2, Y \== Z,
  	negmember(Y, VISITED),
  	greedy(Y, Ypath, [Y|VISITED]), !.

%----------------------------------------------------------------------------
% A* algorithm
% Informed Search
% Most optimal solution

%Bubble sort
bubble(Unsorted, Sorted) :-
    append(Left, [[A,X], [B,Y] | Right], Unsorted),
    B < A,
    append(Left, [[B,Y], [A,X] | Right], MoreSorted),
    bubble(MoreSorted, Sorted), !.
bubble(Sorted, Sorted).

% Function to return the first element of the list
first_element([[_, X]|_], [_,X]).  
    
astar(X, [X], _) :- goal(X), !.
astar(X, [X|Ypath], VISITED):-
    findall([SumCost,Y], sum(X,Y,SumCost), SumsList),
    bubble(SumsList, SortedSumsList), %sorting the costs from least to max
 	first_element(SortedSumsList, [_,Yn]), %selecting the node with least cost
  	astar(Yn, Ypath, [Yn|VISITED]).

% In A* algorithm, f(n) = h(n) + c(n) is used to compare
sum(X, Y, SumCost) :- sld(Y,"Bucharest",C1), from(X, Y, C2), SumCost is C1+C2.
sum(X, Y, SumCost) :- sld(Y,"Bucharest",C1), from(Y, X, C2), SumCost is C1+C2.

%----------------------------------------------------------------------------
% Directed graph:
%Test set for dfs, bfs
:- discontiguous from/3.
from(a, b, 1).
from(a, h, 4).
from(b, c, 3).
from(a, d, 2).
from(b, i, 5).
from(d, e, 6).
from(d, f, 3).
from(f, e, 2).

%Test set 2
:- discontiguous from/3.
%from(a, b, 1).
%from(a, h, 2).
%from(b, c, 3).
%from(b, i, 4).
%from(c, d, 5).
%from(d, e, 6).
%from(d, i, 7).
%from(e, f, 8).
%from(f, g, 9).
%from(f, h, 10).
%from(f, i, 11).
%from(g, h, 12).
%from(h, i, 13).

% Specify the goal before querying the go predicate.
goal(e).
goal("Bucharest").

% query: ?-dfs(a, P, [a]).
% query: ?-solve_BFS(a, SOL).
% query: ?-greedy_search(a, P, [a]).

% solve_BFS("Oradea", SOL).
% dfs("Oradea", P, ["Oradea"]).