# agenix rules: `cd secrets && agenix -e <file>.age`
# Recipients come from lib/keys.nix (hosts.<h> decrypts, admins edit), e.g.
#   let keys = import ../lib/keys.nix; in
#   { "example.age".publicKeys = [ keys.hosts.cc1 ] ++ keys.admins; }
{ }
