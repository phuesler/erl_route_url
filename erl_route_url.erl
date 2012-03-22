-module (erl_route_url).

-export ([match/2]).

match(_, []) ->
    {error, notfound};

match({HTTPMethod, PathTokens}, [RouteDefinition | Tail]) ->
    {ResourceDefinition, RouteHandler} = RouteDefinition,
    case resource_match({HTTPMethod, PathTokens}, ResourceDefinition, []) of
		false ->
            match({HTTPMethod, PathTokens}, Tail);
		{true, Bindings} ->
			{ok, Bindings, RouteHandler}
	end.

% ======================   INTERNAL API ==========================

resource_match({Verb, [Element | PathTokens]}, {Verb, [Element | Map]}, Bindings) ->
    resource_match({Verb, PathTokens}, {Verb, Map}, Bindings);

resource_match({Verb, [Element | PathTokens]}, {Verb, [NamedParam | Map]}, Bindings) when
is_atom(NamedParam) ->
    resource_match({Verb, PathTokens}, {Verb, Map}, [{NamedParam, Element} | Bindings]);

resource_match({Verb, []},{Verb, []}, Bindings) ->
    {true, Bindings};

resource_match(_Segments, _Map, _Bindings) ->
    false.




-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

match_success_test() ->
    Input = {"GET", [<<"foo">>,<<"bar">>]},
    RouteDefinitions = [{{"GET",[<<"foo">>,<<"bar">>]}, {my_handler, my_method, []}}],
    {ok, Params, HandlerMFA} = match(Input, RouteDefinitions),
    ?assertEqual({my_handler, my_method, []}, HandlerMFA),
    ?assertEqual(Params, []).

match_notfound_test() ->
    Input = {"GET", [<<"INVALID">>]},
    RouteDefinitions = [{{"GET",[<<"foo">>,<<"bar">>]}, {my_handler, my_method, []}}],
    ?assertEqual({error, notfound}, match(Input, RouteDefinitions)).


resource_match_true_test() ->
    Input = {"GET", [<<"foo">>,<<"bar">>]},
    List = {"GET", [<<"foo">>, <<"bar">>]},
    Bindings = [],
    Result = resource_match(Input, List, Bindings),
    ?assertEqual({true, []}, Result).

resource_match_false_test() ->
    Input = {"GET", [<<"foo">>,<<"bar">>]},
    List = {"GET", [<<"foo">>, <<"koo">>]},
    Bindings = [],
    Result = resource_match(Input, List, Bindings),
    ?assertEqual(false, Result).

resource_match_wild_card_test() ->
    Input = {"GET", [<<"foo">>, <<"bar">>]},
    List = {"GET", [foo, <<"bar">>]},
    Bindings = [],
    Result = resource_match(Input, List, Bindings),
    ?assertEqual({true, [{foo, <<"foo">>}]}, Result).

-endif.

