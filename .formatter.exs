locals_without_parens = [
  defstate: 1
]

[
  import_deps: [:stream_data, :finitomata],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens]
]
