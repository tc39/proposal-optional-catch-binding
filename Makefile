index.html: proposal.html node_modules
	ecmarkup "$<" "$@"

node_modules:
	npm install
