-module(mobius).
-export([is_prime/1, prime_factors/1, is_square_multiple/1, find_square_multiples/2]).

% Проверка, является ли число N простым
is_prime(2) -> true;
is_prime(3) -> true;
is_prime(N) when N > 3 -> is_prime_h(N, 2).
is_prime_h(N,Div) when N rem Div == 0 -> false;
is_prime_h(N,Div) when Div * Div > N -> true;
is_prime_h(N,Div) -> is_prime_h(N,Div+1).

% Список простых сомножителей числа N
prime_factors(N) -> prime_fa(N,2,[]).
prime_fa(1,_,List) -> List; 
prime_fa(N, Div, List) -> 
    case N rem Div of
        0 -> prime_fa(N div Div, Div, [Div|List]);
        _ -> prime_fa(N, Div + 1, List) 
    end.

% Проверка, делится ли число N на квадрат простого числа
is_square_multiple(N) -> sq_help(N,2). 
sq_help(N, Div) when Div * Div > N -> false;
sq_help(N, Div) -> case is_prime(Div) of
    true -> case N rem (Div * Div) of
        0 -> true;
        _ -> sq_help(N, Div+1)
        end;
    false -> sq_help(N, Div+1)
    end.

% Поиск первого числа из последовательности чисел, делящихся на квадрат простого числа в заданном диапазоне
find_square_multiples(Count, MaxN) when Count > 0, MaxN >= 2 ->
    find_square_multiples_helper(Count, MaxN, 2, 0, 0).

find_square_multiples_helper(Count, MaxN, Num, Consecutive, LastChecked) when Num =< MaxN ->
    case is_square_multiple(Num) of
        true ->
            if
                Consecutive + 1 == Count -> Num - (Count - 1);
                true -> find_square_multiples_helper(Count, MaxN, Num + 1, Consecutive + 1, LastChecked)
            end;
        false -> find_square_multiples_helper(Count, MaxN, Num + 1, 0, Num)
    end;
find_square_multiples_helper(_, _, _, _, _) ->
    fail.