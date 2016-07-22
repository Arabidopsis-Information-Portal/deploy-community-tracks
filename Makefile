# Erik Ferlanti
# July 10, 2016

tool_version := $(shell cat VERSION)

CLI_GIT_REPO := 'https://bitbucket.org/agaveapi/cli'

TOOL = deploy-community-tracks
OBJ = cyverse-cli
SOURCES = cli

all: $(SOURCES)

.SILENT: cli
cli: git-test
	echo "Fetching agaveapi/cli source..."
	if [ ! -d "$(OBJ)" ]; then \
		git clone -q https://bitbucket.org/agaveapi/cli.git ;\
		rm -rf cli/.git ;\
		cp -R cli $(OBJ); \
	fi

.PHONY: clean
clean:
	rm -rf $(OBJ) cli

.SILENT: update
update: clean git-test
	git pull
	if [ $$? -eq 0 ] ; then echo "Now, run make."; exit 0; fi

.SILENT: git-test
git-test:
	echo "Verifying that git is installed..."
	GIT_INFO=`git --version > /dev/null`
	if [ $$? -ne 0 ] ; then echo "Git not found or unable to be executed. Exiting." ; exit 1 ; fi
	git --version

# Docker image
docker:
	build/docker.sh $(TOOL) $(tool_version) build

docker-release: docker
	build/docker.sh $(TOOL) $(tool_version) release

docker-clean:
	build/docker.sh $(TOOL) $(tool_version) clean

# Github release
.SILENT: dist
dist: all
	tar -czf "$(OBJ).tgz" $(OBJ)
	rm -rf $(OBJ)
	rm -rf cli
	echo "Ready for release. "
