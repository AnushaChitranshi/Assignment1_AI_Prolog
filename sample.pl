
/* cities(L) holds when L is the list of cities on the road map */
cities(["Arad", "Zerind", "Oradea", "Sibiu", "Timisoara", "Fagaras", "Rimnicu Vlicea", "Lugoj", "Mehadia",  "Drobeta", "Craiova", "Pitesti", "Bucharest", "Giurgiu", "Urziceni", "Hirsova", "Eforie", "Vaslui", "Iasi", "Neamt"]).

/* from(C1,C2, D) holds true  when there is a direct link from city C1 to city C2 and the distance between them is D.  Note that the predicate from is NOT symmetric. Thus, based on the map we have */
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
c(C1, C2, D):- from(C1, C2, D).
c(C1, C2, D):- from(C2, C1, D).

/* sld(C1, C2, D) is the estimate of the straight line distance between cities C1 and C2.  Note that if C1 and C2 are linked directly, then sld(C1, C2, D) is actually c(C1, C2, D).  Otherwise, we can use the ideas described in this assignment:
*/
sld(C1, C2, D):-c(C1, C2, D).  
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

sld("Mehandia", "Bucharest",241).
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
% Example of incomplete but otherwise working, depth-first search code

% From Start node to Goal node
% Start: determined upon call.
% Goal: determined in a clause.
% Utilizes the depth search mechanism of Prolog

% Trivial: if X is the goal return X as the path from X to X.
dfs(X, [X],_):-
	goal(X),
    !.

% Stopping condition: Expand to all nodes, outputing all possible solution paths
% else expand X by Y and find path from Y
dfs(X, [X|Ypath], VISITED):-
 	connected(X, Y),
  	negmember(Y, VISITED),
  	dfs(Y, Ypath, [Y|VISITED]).

% Is in list
is_member(X,[X|_]).
is_member(X,[_|T]):- is_member(X,T).

% utility : negation of member
negmember(X, [X|_]):-
    !,fail.
negmember(X, [_|T]):-
    is_member(X, T),
    !,
    fail.
negmember(_, _).

% Undirected graph:
connected(X, Y):- c(X, Y).
connected(X, Y):- c(Y, X).

%----------------------------------------------------------------------------
% Example of incomplete but otherwise working, breadth-first search code
/* The stopping rule for this condition is obtained when  the current path to be expanded starts with the goal node, that is:*/

is_not_member(_,[]).
is_not_member(X, [H|T]):-
    not(X = H),
    is_not_member(X, T).

bfs([[X |T]|_PATHS], [X|T]):-
               goal(X).

bfs([PATH|TPaths], SOL):-
          expand(PATH,  NPaths),
          append(TPaths, NPaths, NEWPATHS),
          bfs(NEWPATHS, SOL).
 
expand([HPath|TPath], NPaths):-
    findall([NEXT, HPath|TPath],
       (connected(HPath, NEXT),is_not_member(NEXT, [HPath|TPath])),
        NPaths).

%We next wrap this in a predicate solve_BF as follows:
solve_BFS(S, SOL):-
    bfs([[S]], Path),
    reverse(SOL,Path).
%----------------------------------------------------------------------------
%Greedy Search
% Trivial: if X is the goal return X as the path from X to X.
% Undirected graph:
connected_w_cost(X, Y, Cost):- c(X, Y, Cost).
connected_w_cost(X, Y, Cost):- c(Y, X, Cost).
connected_w_least_cost(X, Y):-
    findall([Node_connected_to_X, Cost], connected_w_cost(X, Node_connected_to_X, Cost), Fringe),
    find_least_cost(Fringe, Node_and_cost),
	get_node(Node_and_cost, Y).

find_least_cost([Min],Min).
find_least_cost([H,K|T],M) :-
    H =< K,                             
    find_least_cost([H|T],M).               
find_least_cost([H,K|T],M) :-
    H > K,                              
    find_least_cost([K|T],M).               

get_node([], []).
get_node([Node|_], Node).
    

greedy_search(X, [X],_):-
	goal(X),
    !.

% Stopping condition: Expand to all nodes, outputing all possible solution paths
% else expand X by Y and find path from Y
greedy_search(X, [X|Ypath], VISITED):-
 	connected_w_least_cost(X, Y),
  	negmember(Y, VISITED),
  	dfs(Y, Ypath, [Y|VISITED]).
%----------------------------------------------------------------------------
% Directed graph:
%Test set for dfs, bfs
% c(a, b).
% c(a, h).
% c(b, c).
% c(a, d).
% c(b, i).
% c(d, e).

%Test set 2


%Test set for greedy
c(a, b, 1).
c(a, h, 2).
c(b, c, 3).
c(a, d, 4).
c(b, i, 5).
c(d, e, 6).


% Specify the goal before querying the go predicate.
goal(e).

% query: ?-dfs(a, P, [a]).
% query: ?-solve_BFS(a, SOL).
% query: ?-greedy_search(a, P, [a]).


