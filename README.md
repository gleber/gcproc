# GCproc #

This library implements garbage-collected processes by (ab)using
garbage collection of NIF resources.

Big thanks to Tony Rogvall who did all the hard parts in http://github.com/tonyrog/resource project.

Please note that node will be garbage collected along with the
resource, hence it may take some short time before it's terminated due
to way BEAM GC works.

Notes:

1. work only with SMP enabled!
2. garbage collection works well only locally, since NIF resource reference counting is per-node

## Usage ##

Example:
```erlang
1> results(0). %% make sure shell doesn't cache results
20
2> ok = application:start(gcproc).
ok
3> G = gcproc:spawn(fun() -> receive ok -> ok end end).
{gcproc,<0.40.0>,{resource,143010032,<<>>}}
4> is_process_alive(pid(0,40,0)).
true %% process is still running
5> f(). %% forget all shell bindings
ok
6> is_process_alive(pid(0,40,0)).
false %% process is not running anymore!

```

Sending message
```erlang
9> G = gcproc:spawn(fun() -> receive done -> io:format("Receive works!") end, receive ok -> ok end end).
{gcproc,<0.49.0>,{resource,143008592,<<>>}}
10> G:send(done). %% equivalent to "G:pid() ! done"
Receive works!
done
11> is_process_alive(pid(0,49,0)).
true
12> f().
ok
13> is_process_alive(pid(0,49,0)).
false

```
