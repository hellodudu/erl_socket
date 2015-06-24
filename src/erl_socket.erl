-module(erl_socket).
-behaviour(gen_server).
-behaviour(ranch_protocol).
-export([init/1]).
-export([init/4, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([
        start_link/4
    ]).

-define(TIMEOUT, 60000).
-record(state, {socket, transport}).

start_link(Ref, Socket, Transport, Opts) ->
    proc_lib:start_link(?MODULE, init, [Ref, Socket, Transport, Opts]).
         
init([]) -> {ok, undefined}.

init(Ref, Socket, Transport, _Opts = []) ->
    ok = proc_lib:init_ack({ok, self()}),
    ok = ranch:accept_ack(Ref),
    ok = Transport:setopts(Socket, [{active, once}]),
    gen_server:enter_loop(?MODULE, [], #state{ socket=Socket, transport=Transport}).

handle_info({tcp, Socket, Data}, State=#state{socket=Socket, transport=Transport}) ->
    Term = binary_to_list(Data),
    io:format("recv data:~p~n", [Term]),
	Transport:setopts(Socket, [{active, once}]),
	Transport:send(Socket, Data),
	{noreply, State, ?TIMEOUT};
handle_info({tcp_closed, _Socket}, State) ->
	{stop, normal, State};
handle_info({tcp_error, _, Reason}, State) ->
	{stop, Reason, State};
handle_info(timeout, State) ->
	{stop, normal, State};
handle_info(_Info, State) ->
	{stop, normal, State}.

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

