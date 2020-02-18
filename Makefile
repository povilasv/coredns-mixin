JSONNET_ARGS := -n 2 --max-blank-lines 2 --string-style s --comment-style s
ifneq (,$(shell which jsonnetfmt))
	JSONNET_FMT_CMD := jsonnetfmt
else
	JSONNET_FMT_CMD := jsonnet
	JSONNET_FMT_ARGS := fmt $(JSONNET_ARGS)
endif
JSONNET_FMT := $(JSONNET_FMT_CMD) $(JSONNET_FMT_ARGS)

all: fmt prometheus_alerts.yaml lint test

fmt:
	find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | \
		xargs -n 1 -- $(JSONNET_FMT) -i

prometheus_alerts.yaml: mixin.libsonnet lib/alerts.jsonnet alerts/*.libsonnet
	jsonnet -J vendor -S lib/alerts.jsonnet > $@

lint: prometheus_alerts.yaml
	find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | \
		while read f; do \
			$(JSONNET_FMT) "$$f" | diff -u "$$f" -; \
		done

	promtool check rules prometheus_alerts.yaml

clean:
	rm -rf prometheus_alerts.yaml

test: prometheus_alerts.yaml
	promtool test rules tests.yaml
