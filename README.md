# Simplistic URL router for Erlang projects

## The 3 Features

* Define HTTP verbs (GET, POST, PUT, etc.)
* Named parameters
* Return MFA

## Considerations/Alternatives

I'm a Ruby programmer new to Erlang, so that's why I thought I would
need a router in order to build an API for a webservice. After talking
to a experienced Erlang programmer, I've learned that there is another
and potentially easier way to do it. Here is an example:

    % handling /users/:user_id/projects/:project_id
    handle("GET", ["users", UserId, "projects", ProjectId], Params) ->
        io:format("handling the request"),
        {ok, <<"HELLO WORLD">>}.



## Usage

    Path = [<<"foo">>, <<"bar">>],
    HTTPMethod = "GET",
    Request = {HTTPMethod, Path},
    RouteDefinitions = [{{"GET",[<<"foo">>,<<"bar">>]}, {my_handler, my_method, []}}],
    case erl_route_url:match(Request, RouteDefinitions) of
        {error, notfound} -> 
            io:format("path not found");
        {ok, Params, {M,F,_}} ->
            apply(M,F,Params)
    end.


Here are the unit tests:


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

## Installation

Copy the file into your source code, no rebar project yet. Make sure you
add the path to the erl command.

