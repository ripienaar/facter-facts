What?
=====

A simple little framework to get facts from external sources.

You can create files in /etc/facts.d which can be text, yaml,
json or executables.  In the case of executables it supports
caching so you only need to run your expensive scripts every
now and then.

JSON
----

Create a file for with extension _json_, example _/etc/facts.d/facts.json_:

<pre>
{
  "some_fact":"some_value",
  "another_fact":"some_value"
}
</pre>

YAML
----

Create a file with extension _yaml_, for example _/etc/facts.d/facts.yaml_:

<pre>
---
some_fact: some_value
another_fact: some_value
</pre>

TXT
---

Create a file with extension _txt, for example _/etc/facts.d/facts.txt:

<pre>
some_fact=some_value
another_fact=some_value
</pre>

Executable
----------

Create files with +x set, they should print to STDOUT _key=val_ pairs:

<pre>
#!/bin/sh

echo "some_fact=some_value"
echo "another_fact=some_value"
</pre>

In the case of executables we can build a mode 0600 cache in
_/tmp/facts_cache.yml_, to allow the output from _foo.sh_ to be cached
make a file called _foo.sh.ttl_ with just a number in seconds on the
first line

