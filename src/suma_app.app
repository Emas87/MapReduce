{application, suma_app,
  [{description, "Sumador"},
    {vsn, "1"},
    {modules, [suma_app, master_supervisor, worker_supervisor, handler_server, task_worker]},
    {registered, []},
    {applications, [kernel, stdlib]},
    {mod, {suma_app,[]}}
  ]}.