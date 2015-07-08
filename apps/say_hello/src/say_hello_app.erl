-module(say_hello_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    io:format("just say hello\n"),
    say_hello_sup:start_link().

stop(_State) ->
    ok.
