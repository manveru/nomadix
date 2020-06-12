require "clim"

# TODO: actually implement this sometime :)

class Clim
  class Command
    private macro run(class_name, method_name)
      run { |opts, args| {{class_name}}.{{method_name}}(opts, args) }
    end

    private macro run_help
      run { |opts, args| puts opts.help_string }
    end
  end
end


module Nomadix
  VERSION = "0.1.0"

  class CLI < Clim
    main do
      desc "Noamdix - Nomad <3 Nix"
      usage "nomadix command [arguments]"
      version "Nomadix #{VERSION}"

      run_help

      sub "run" do
        desc "run the given nomadix task files"
        usage "nomad run task1.nix task2.nix ..."
        option "--jobs=PATH", type: String, desc: "Path to the jobs JSON file"
        option "--substitute-on-destination", type: Bool, desc: "whether to try substitutes on the destination store"
        run Nomad, run
      end
    end
  end

  class Nomad
    def self.run(opts, args)
      args.each do |arg|
        Process.run("nomad", ["job", "run", arg], output: STDOUT, error: STDERR)
      end
    end
  end
end

Nomadix::CLI.start(ARGV)
