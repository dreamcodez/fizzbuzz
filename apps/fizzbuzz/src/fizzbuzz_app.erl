-module(fizzbuzz_app).

-behaviour(application).

%% Application callbacks
-export([start/0, start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
    fizzbuzz_sup:start_link().

start(_StartType, _StartArgs) ->
    fizzbuzz_sup:start_link().

stop(_State) ->
    ok.
