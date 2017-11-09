clean:
	rm -rf .requirements-env
	rm -f requirements.txt
	rm -f requirements-dev.txt

requirements.txt requirements-dev.txt: %.txt : %.txt.in
	[ ! -e .requirements-env ] || exit 1
	echo "# You should not edit this file directly.  Instead, you should edit $<." > $@
	virtualenv .requirements-env
	source .requirements-env/bin/activate && \
	pip install -r $< && \
	pip freeze >> $@
	rm -rf .requirements-env
	scripts/find_missing_wheels.py requirements.txt

dependencies-dev:
	pip install -r requirements-dev.txt

