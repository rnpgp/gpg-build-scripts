#!/bin/bash

readonly __progname=$(basename "$0")

errx() {
	echo -e "$__progname: $*" >&2
	exit 1
}

main() {

	docker run -it \
		-v "$(pwd)":/usr/local/gpg-build-scripts \
		--workdir "/usr/local/gpg-build-scripts" \
		centos:7 bash

}

main "$@"

exit 0
