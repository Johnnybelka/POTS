-module(proc_sieve).

-export([generate/1, sieve_run/2]).
-export([gen_print/1]).

-define(TIMEOUT, 100000).


generate(MaxN) ->
    Pid = sieve(),
    generate_help(Pid, 2, MaxN). 

generate_help(Pid, End, End) ->
    Pid ! {done, self()}, %% отправка id текущего процесса
    receive  %%начинает блок, ожидающий сообщения
            Res -> Res, 
            lists:foreach(
                fun(N) -> 
                    io:format("~w~n",  [N]) end, Res %% вывод простых чисел N
            )
    end;

generate_help(Pid, N, End) ->
    Pid ! N, %% отправка сообщения процессу с идентификатором Pid с информацией о текущем числе N
    generate_help(Pid, N + 1, End). %% отвечает за отправку сообщения с текущим числом на обработку процессу, а затем вызывает саму себя для обработки следующего числа

sieve() ->
    spawn(proc_sieve, sieve_run, [0, void]). 

sieve_run(0, InvalidPid) ->
    receive 
        P -> sieve_run(P, InvalidPid)
    after ?TIMEOUT ->
        io:format("Timeout in P=0~n")
    end;


sieve_run(P, NextPid) when is_pid(NextPid) -> %% корректный
    receive 
        {done, From} ->
            NextPid ! {done, self()},
            receive 
                ListOfRes -> 
                    From ! [P] ++ ListOfRes %% ожидаем получение списка результатов ListOfRes и затем отправляем это списком простых чисел, начиная с текущего числа P
            end;
        N when N rem P == 0 -> 
            sieve_run(P, NextPid);
        N when N rem P /= 0 -> 
            NextPid ! N,
            sieve_run(P, NextPid)
    after ?TIMEOUT ->
        io:format("Timeout in is_pid clause P=~p~n", [P])
    end;

sieve_run(P, Invalid) ->
    receive 
        {done, From} ->
            From ! [P];
        N when N rem P == 0 -> 
            sieve_run(P, Invalid);
        N when N rem P /= 0 ->  
            Pid = spawn(proc_sieve, sieve_run, [0, void]),
            Pid ! N,
            sieve_run(P, Pid)
    after ?TIMEOUT ->
        io:format("Timeout in no pid clause P=~p~n", [P])
    end. 

gen_print(MaxN) ->
    generate(MaxN).
