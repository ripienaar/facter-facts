What?
=====

A simple little framework to get facts from external sources.

You can create files in /etc/facts.d which can be text, yaml,
json or executables.

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

