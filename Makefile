version-controlled:
	nix eval nixpkgs#hello.src.urls
	nix eval nixpkgs#hello.src.outputHash

verified-history:
	curl https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/applications/misc/hello/default.nix
	curl https://raw.githubusercontent.com/NixOS/nixpkgs/a0dbe47318bbab7559ffbfa7c4872a517833409f/pkgs/tools/misc/cowsay/default.nix

retained-indefinitely:
	curl https://github.com/NixOS/nixpkgs

two-person:
	echo 'https://nixos.org/manual/nixpkgs/stable/#reviewing-contributions--merging-pull-requests'

scripted-build:
	nix build nixpkgs#hello -L --rebuild
	nix show-derivation nixpkgs#hello | jq '.[]|(.builder,.args)'

build-service:
	echo 'https://hydra.nixos.org/build/159927087'

build-as-code:
	echo 'https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/misc/cowsay/default.nix'

ephermeral-environment:
	nix build .#hello-sandbox -L

isolated:
	nix build .#hello-sandbox -L

parameterless:
	nix build .#hello-sandbox -L

hermetic:
	nix build .#hello-sandbox -L

reproducible:
	nix build nixpkgs#hello -L --rebuild
	echo 'https://r13y.com'

available:
	curl https://cache.nixos.org/bycfqd9pi8ik14dflid8h71ib926icg7.narinfo | bat -l toml

authenticated:
	nix path-info nixpkgs#hello --json | jq
	nix show-derivation nixpkgs#hello | jq

service-generated:
	echo 'https://hydra.nixos.org'

non-falsifiable:
	nix path-info nixpkgs#hello --json | jq '.[].signatures'
	@echo This is a post-build-hook, sandbox has no access.

dependencies-complete:
	nix path-info -rsSh nixpkgs#hello
dependencies-complete-2:
	nix path-info -rsSh nixpkgs#hello --derivation

security:
	echo policy
access:
	echo policy
superusers:
	echo policy

cyclonedx:
	nix show-derivation .# --recursive | nix run github:sudo-bmitch/convert-nix-cyclonedx# | jq
	nix show-derivation nixpkgs#cowsay --recursive | nix run github:sudo-bmitch/convert-nix-cyclonedx# | jq

# TODO, fix docker demo to only use `nix build` instead of bundler
bundle:
	nix bundle nixpkgs#hello
	nix bundle --bundler github:tomberek/nix-generators#bundlers.toDockerImage nixpkgs#hello
	nix bundle --bundler github:tomberek/nix-utils#bundlers.deb nixpkgs#hello

fod:
	nix build .#exmple -L --rebuild

demo:
	nix bundle --bundler .# nixpkgs#hello -L
	docker load < hello
	docker inspect test:latest | jq '.[].Id'

	readlink hello > gc
	rm hello
	nix-store --delete $$(cat gc)

	nix bundle --bundler .# nixpkgs#hello -L
	docker load < hello
	docker inspect test:latest | jq '.[].Id'

	readlink hello > gc
	rm hello
	nix-store --delete $$(cat gc)
