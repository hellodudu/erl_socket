-module(erl_socket_app).
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([start/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================
start() ->
    lager:error("lager error erl_socket_app start/0!"),
    io:format("erl_socket_app start/0!\n"),
    start(0, []).

start(_StartType, _StartArgs) ->
    lager:error( "lager error erl_socket_app start!"),
    io:format("erl_socket_app start!\n"),
    {ok, _} = ranch:start_listener(erl_socket, 10,
		ranch_tcp, [{port, 2345}, {active, once}, {packet,4}], erl_socket, []),
    erl_socket_sup:start_link().

stop(_State) ->
    ok.
