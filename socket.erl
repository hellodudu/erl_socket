-module(socket).
-behaviour(gen_server).
-export([start/0, stop/0, get_down/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include_lib("eunit/include/eunit.hrl").

%% 默认服务名
-define(SERVER, ?MODULE).

%% 默认连接数
-define(DEF_Accept_Num, 1000).

%% 默认tcp监听端口
-define(DEF_Port, 2345).

%% 测试
start_test() -> {ok, start()}.

%% 外部接口
start() -> gen_server:start_link({ local, ?SERVER }, ?MODULE, [], []).
stop() -> gen_server:call(?MODULE, stop).
get_down() -> gen_server:call(?MODULE, get_down).

%% gen_server回调函数
init([]) ->
    case gen_tcp:listen(?DEF_Port, [binary, {packet, 4}, {reuseaddr, true}, {active, false}]) of
        {ok, Listen} ->
            start_servers(Listen, ?DEF_Accept_Num),
            {ok, 1};
        _Other ->
            {error, 0}
    end.

handle_call(get_down, _From, Tab) ->
    {stop, somehappened, get_down, Tab};
handle_call(stop, _From, Tab) ->
    {stop, normal, { stop, handle_call_stopped }, Tab}.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(Reason, _State) ->
    io:format("socket server terminate, reason:~p~n", [Reason]).
code_change(_OldVsn, State, _Extra) -> {ok, State}.


%% 开启tcp服务
start_servers(_Listen, 0) ->
    io:format("spawn link complete!~n");
start_servers(Listen, Accept_Num) ->
    spawn(fun() -> start_server(Listen) end),
    start_servers(Listen, Accept_Num - 1).

start_server(Listen) -> 
    case gen_tcp:accept(Listen) of
        {ok, Socket} ->
            loop(Socket);
        _Other ->
            return
    end.

loop(Socket) ->
    inet:setopts(Socket, [{active, once}]),
    receive
        {tcp, Socket, Data} ->
            Str = binary_to_term(Data),
            io:format("Server Receive Data = ~p from socket = ~p~n", [Str, Socket]),
            loop(Socket);
        {tcp_closed, Socket} ->
            io:format("Server Socket<~p> closed~n", [Socket]);
        Any ->
            io:format("Receive Any = ~p~n", [Any])
    end.

