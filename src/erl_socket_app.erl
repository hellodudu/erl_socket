-module(erl_socket_app).
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    {ok, _} = ranch:start_listener(erl_socket, 10,
		ranch_tcp, [{port, 2345}], erl_socket, []),
    erl_socket_sup:start_link().

stop(_State) ->
    ok.
