-module(worker).
-export([run/0]).

run() ->
  run("./worker.pl", 5000).

run (Cmd, Timeout) ->
  Port = erlang:open_port({spawn_executable, Cmd}, [exit_status]),
  loop(Port, "", Timeout).

loop(Port, OldStream, Timeout) ->
  receive
    {Port, {data, NewStream}} ->
      Stream = OldStream++NewStream,
      {Messages, AdjStream} = drain_stream(Stream),
      erlang:display({messages, Messages}),
      loop(Port, AdjStream, Timeout)
  after Timeout ->
    throw(timeout)
  end.

drain_stream(Stream) ->
  rdrain_stream([], Stream).

rdrain_stream(Messages, Stream) ->
  case get_msg(Stream) of
    undefined ->
      erlang:display(woo),
      {Messages, Stream};
    {NewMsg, NewStream} ->
      rdrain_stream(Messages ++ [NewMsg], NewStream)
  end.

get_msg(Stream) ->
  {ReadLen, RemainingStream} = get_len(Stream),
  case string:len(RemainingStream) =< ReadLen of
    true ->
      {string:substr(RemainingStream, 1, ReadLen), string:substr(RemainingStream, ReadLen + 1)};
    false ->
      undefined
  end.

get_len(Stream) ->
  rget_len("", Stream).

rget_len(MaybeLen, Stream) ->
  Part = string:substr(Stream, 1, 1),
  Rest = string:substr(Stream, 2),
  case Part of
    ":" ->
      {string:to_integer(MaybeLen), Rest};
    _ ->
    rget_len(MaybeLen ++ Part, Rest)
  end.

