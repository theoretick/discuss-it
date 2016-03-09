ExUnit.start

Mix.Task.run "ecto.create", ~w(-r DiscussIt.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r DiscussIt.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(DiscussIt.Repo)

