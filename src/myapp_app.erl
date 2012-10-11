-module(myapp_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    io:put_chars("whee\n"), io:put_chars("wonk\n"),
    myapp_sup:start_link().

stop(_State) ->
    ok.

