REBAR=$(shell which rebar || echo ./rebar)

all: $(REBAR)
	$(REBAR) get-deps compile

tests:  $(REBAR)
	$(REBAR) eunit skip_deps=true

sh: all
	erl -smp enable -pa ebin/ -pa deps/*/ebin/ -pa .eunit/ -eval 'shell_default:m(gcproc)'

test: tests

clean:
	$(REBAR) clean skip_deps=true

# Detect or download rebar

REBAR_URL=http://cloud.github.com/downloads/basho/rebar/rebar
./rebar:
	erl -noshell -s inets -s ssl \
		-eval 'httpc:request(get, {"$(REBAR_URL)", []}, [], [{stream, "./rebar"}])' \
		-s init stop
	chmod +x ./rebar

distclean:
	rm -f ./rebar
