# Concise Reference Integrity Manifest

This is the working area for the individual Internet-Draft, "Concise Reference Integrity Manifest".

* [Editor's Copy](https://ietf-rats.github.io/draft-birkholz-rats-corim/#go.draft-birkholz-rats-corim.html)
* [Individual Draft](https://tools.ietf.org/html/draft-birkholz-rats-corim)
* [Compare Editor's Copy to Individual Draft](https://ietf-rats.github.io/draft-birkholz-rats-corim/#go.draft-birkholz-rats-corim.diff)

## Pulling the CDDL

The master copy of the CoRIM CDDL is stored in the [ietf-corim-cddl](https://github.com/ietf-rats/ietf-corim-cddl) repo.

When starting with a fresh clone you need to pull it in as a git submodule:

```
$ git submodule update --init --recursive
```

The CDDL files will materialise inside the `cddl/` folder.

Any change to the CDDL MUST be done in the master copy and pulled back in here.

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

* `cddl-lint`  - to check that the CDDL spec is in order;
* `cddl-clean` - to remove the auto-generated CDDL spec.

## Contributing

See the
[guidelines for contributions](https://github.com/ietf-rats/draft-birkholz-rats-corim/blob/master/CONTRIBUTING.md).
