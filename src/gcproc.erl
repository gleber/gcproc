-module(gcproc).

-include_lib("eunit/include/eunit.hrl").

-export([spawn/1,

         send/2,

         link/1, unlink/1,
         monitor/1, demonitor/2,

         pid/1]).

-record(gcproc, {pid, res}).

spawn(Fun) ->
    Pid = erlang:spawn(Fun),
    Res = resource:notify_when_destroyed(whereis(gcproc_manager), {timeout, Pid}),
    #gcproc{pid = Pid, res = Res}.

send(Msg, #gcproc{pid = Pid}) ->
    Pid ! Msg.

pid(#gcproc{pid = Pid}) ->
    Pid.

link(#gcproc{pid = Pid}) ->
    erlang:link(Pid).

unlink(#gcproc{pid = Pid}) ->
    erlang:unlink(Pid).

monitor(#gcproc{pid = Pid}) ->
    erlang:monitor(process, Pid).

demonitor(Ref, #gcproc{pid = _Pid}) ->
    erlang:demonitor(Ref, [flush]).

simple_test() ->
    ok = application:start(gcproc),
    Self = self(),
    spawn_link(fun() ->
                       G = gcproc:spawn(fun() -> receive ok -> ok end end),
                       true = erlang:is_process_alive(G:pid()),
                       Self ! {pid, G:pid()}
               end),
    Pid = receive {pid, P} -> P end,
    timer:sleep(100),
    ?assertEqual(false, erlang:is_process_alive(Pid)).
