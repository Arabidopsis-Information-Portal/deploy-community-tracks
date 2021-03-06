# Erik Ferlanti
# July 10, 2016

tool_version := $(shell cat VERSION)
agave_api_version := v2
agave_api_release := 2.1.9.0

SYSTEM_ID := 'data.iplantcollaborative.org'
SHARED_DIR := 'eriksf/share'
TRACK_URL_BASE := 'https://de.cyverse.org/anon-files/iplant/home'
ANONYMOUS_USER := 'anonymous'
ARAPORT_USER := 'araport'

CLI_GIT_REPO := 'https://bitbucket.org/agaveapi/cli'

TOOL := 'araport/deploy-community-tracks'
OBJ = agave-cli
SRC = src
TEST = test/sharness
BIN = bin
SOURCES = templatize
FILES_UPLOAD := $(shell command -v files-upload 2>/dev/null)

define AGAVE_CLI_ERROR_MSG
Can't find Agave CLI commands. Exiting.

Please make sure the Agave CLI is installed and is
available in your PATH. Also, make sure to have a current
access token from the iplantc.org tenant.
endef

include conf/config.sh

all: $(SOURCES)

print-%:
	@echo $*=$($*)

.SILENT: cli
cli: git-test
	echo "Fetching agaveapi/cli source..."
	if [ ! -d "$(OBJ)" ]; then \
		git clone -q https://bitbucket.org/agaveapi/cli.git ;\
		rm -rf cli/.git ;\
		cp -R cli $(OBJ); \
	fi

.SILENT: templatize
templatize:
	echo "Templatizing..."
	if [ ! -d "$(BIN)" ]; then \
		mkdir $(BIN) ;\
	fi
	sed -e 's|@@SYSTEM_ID@@|$(SYSTEM_ID)|g' \
		-e 's|@@SHARED_DIR@@|$(SHARED_DIR)|g' \
		-e 's|@@TRACK_URL_BASE@@|$(TRACK_URL_BASE)|g' \
		-e 's|@@ANONYMOUS_USER@@|$(ANONYMOUS_USER)|g' \
		-e 's|@@ARAPORT_USER@@|$(ARAPORT_USER)|g' \
		$(SRC)/process_genomic_data_format_files.sh > $(BIN)/process_genomic_data_format_files.sh
	sed -e 's|@@tool_version@@|$(tool_version)|g' \
		-e 's|@@IMAGENAME@@|$(TOOL)|g' \
		$(SRC)/deploy_community_tracks.sh > $(BIN)/deploy_community_tracks.sh
	cp $(SRC)/normalize_athaliana_chrom_ids.pl $(BIN)/.
	find $(BIN) -type f \( -name '*.sh' -o -name '*.pl' \) -exec chmod a+rx {} \;
	sed -e 's|@@APP_NAME@@|$(APP_NAME)|g' \
		-e 's|@@VERSION@@|$(tool_version)|g' \
		-e 's|@@DEPLOYMENT_PATH@@|$(DEPLOYMENT_PATH)|g' \
		app.jsonx > $(BIN)/app.json

.PHONY: clean
clean:
	rm -rf $(BIN) $(OBJ) cli $(TEST)/test-results

.SILENT: update
update: cli
	echo "Updating $(OBJ) tarball..."
	tar -czf "$(OBJ).tgz" $(OBJ)
	rm -rf $(OBJ)
	rm -rf cli

.SILENT: git-test
git-test:
	echo "Verifying that git is installed..."
	GIT_INFO=`git --version > /dev/null`
	if [ $$? -ne 0 ] ; then echo "Git not found or unable to be executed. Exiting." ; exit 1 ; fi
	git --version

# Docker image
docker: all
	build/docker.sh $(TOOL) $(tool_version) build

docker-release: docker
	build/docker.sh $(TOOL) $(tool_version) release

docker-clean:
	build/docker.sh $(TOOL) $(tool_version) clean

.SILENT: test
.PHONY: test
test:
	$(MAKE) -C test/sharness

.SILENT: release
release:
	git diff-index --quiet HEAD
	if [ $$? -ne 0 ]; then echo "You have unstaged changes. Please commit or discard then re-run make clean && make release."; exit 0; fi
	git tag -a "v$(tool_version)" -m "$(TOOL) $(tool_version). Requires Agave API $(agave_api_version)/$(agave_api_release)."
	git push origin "v$(tool_version)"

.SILENT: install
install: all
ifndef FILES_UPLOAD
	$(error $(AGAVE_CLI_ERROR_MSG))
endif
	echo "Installing agave app to $(DEPLOYMENT_PATH)..."
	files-upload -S $(SYSTEM_ID) -F ../$(APP_SRC) $(DEPLOYMENT_BASE)
	apps-addupdate -F $(BIN)/app.json
