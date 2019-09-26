-module(undefined_user_type).

-include_lib("eunit/include/eunit.hrl").

undefined_user_type_test_() ->
    {setup,
     fun () ->
         {ok, Apps} = application:ensure_all_started(gradualizer),
         gradualizer_db:import_erl_files(
             ["priv/test/undefined_user_type_helper.erl"]),
         Apps
     end,
     fun (Apps) ->
         [ok = application:stop(App) || App <- Apps],
         ok
     end,
     ?_test(begin
        File = "test/misc/undefined_user_type.erl",
        Errors = gradualizer:type_check_file(File, [return_errors]),
        %% Test that error formatting doesn't crash
        Opts = [{fmt_location, brief},
                {fmt_expr_fun, fun erl_prettypr:format/1}],
        lists:foreach(fun({_, Error}) -> typechecker:handle_type_error(Error, Opts) end, Errors),
        {ok, Forms} = gradualizer_file_utils:get_forms_from_erl(File, []),
        ExpectedErrors = typechecker:number_of_exported_functions(Forms),
        ?assertEqual(ExpectedErrors, length(Errors))
    end)}.
