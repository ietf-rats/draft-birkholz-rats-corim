# Concise Reference Integrity Manifest

This is the working area for the individual Internet-Draft, "Concise Reference Integrity Manifest".

* [Editor's Copy](https://ietf-rats.github.io/draft-birkholz-rats-corim/#go.draft-birkholz-rats-corim.html)
* [Individual Draft](https://tools.ietf.org/html/draft-birkholz-rats-corim)
* [Compare Editor's Copy to Individual Draft](https://ietf-rats.github.io/draft-birkholz-rats-corim/#go.draft-birkholz-rats-corim.diff)

## Building the Draft

Formatted text and HTML versions of the draft can be built using `make`.

```sh
$ make
```

This requires that you have the necessary software installed.  See
[the instructions](https://github.com/martinthomson/i-d-template/blob/master/doc/SETUP.md).

### CDDL

The `cddl/corim.cddl` file is assembled from the fragments in `cddl/`.  It is generated transparently by the build system and must not be added to git index.

The build system exposes two new targets:

* `cddl-check` - to check that the CDDL spec is in order;
* `cddl-clean` - to remove the auto-generated CDDL spec.

## Contributing

See the
[guidelines for contributions](https://github.com/ietf-rats/draft-birkholz-rats-corim/blob/master/CONTRIBUTING.md).
