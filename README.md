# Nomadix

NixOS module for Nomad and convenient definition of Nomad jobs using Nix.

This ensures that your Nomad jobs are guaranteed to not only be deterministic,
but also have perfect caching of dependencies and minimum amount of deployment
overhead.

Right now this is in a very experimental discovery phase, so don't expect to
rely on anything to stay the way it is.

## Mini Example

To run the example under examples/mini you can try the following:

    nix build .#examples.mini.run
    nix copy -s --to ssh://skynet ./result
    nomad job run -output result

## Notes

This relies on Nix flakes to build the jobs, I'm hoping that by the time I'm
done, flakes will be stable enough for production use.

The reason for this is mostly way better user experience and speed.

Making a wrapper for stable Nix should be trivial though, I just haven't had
need for it yet.
