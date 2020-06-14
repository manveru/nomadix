Dir.glob("expected/*.hcl") do |file|
  basename = File.basename(file, ".hcl")
  expected = IO::Memory.new
  Process.run("nomad", ["job", "run", "-output", file], output: expected, error: STDERR)
  Process.run("nomad", ["job", "run", "-output", file], output: expected, error: STDERR)
end
