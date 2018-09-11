-module(graphql_scalar_binary_coerce).

-export([input/2, output/2]).

input(_, X) -> {ok, X}.

%% According to the specification, Jun2018, we should
%% accept coercion as long as we are not "loosing information"
%% in the process
output(_,B) when is_binary(B) ->
    %% Standard case where the code provided a String value
    {ok, B};
output(_,X) when is_list(X) ->
    %% Literal string values in erlang are lists, so treat the data
    %% as iodata() and output it
    try iolist_to_binary(X) of
        Val -> {ok, Val}
    catch _:_ -> {error, not_coercible}
    end;
output(_, false) ->
    %% Boolean false, these do not provide information loss
    {ok, <<"false">>};
output(_, true)  ->
    %% Boolean true
    {ok, <<"true">>};
output(_, A) when is_atom(A) ->
    %% Atoms can be output stringently
    {ok, atom_to_binary(A, utf8)};
output(_, {enum, E}) ->
    %% Default internal enum representation can be output as well
    {ok, E};
output(_, I) when is_integer(I) ->
    %% Integers can be embedded in the string type
    {ok, integer_to_binary(I)};
output(_, F) when is_float(F) ->
    %% Likewise floating point values, although a small loss of precision might occur here
    {ok, float_to_binary(F)};
output(_, _) ->
    {error, not_coercible}.
