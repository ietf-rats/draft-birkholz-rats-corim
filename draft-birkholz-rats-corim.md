---
title: Concise Reference Integrity Manifest
abbrev: CoRIM
docname: draft-birkholz-rats-corim-latest
stand_alone: true
ipr: trust200902
area: Security
wg: RATS Working Group
kw: Internet-Draft
cat: std
pi:
  toc: yes
  sortrefs: yes
  symrefs: yes

author:
- ins: H. Birkholz
  name: Henk Birkholz
  org: Fraunhofer SIT
  abbrev: Fraunhofer SIT
  email: henk.birkholz@sit.fraunhofer.de
  street: Rheinstrasse 75
  code: '64295'
  city: Darmstadt
  country: Germany
- ins: T. Fossati
  name: Thomas Fossati
  organization: Arm Limited
  email: Thomas.Fossati@arm.com
  country: UK
- ins: Y. Deshpande
  name: Yogesh Deshpande
  organization: Arm Limited
  email: yogesh.deshpande@arm.com
  country: UK
- ins: N. Smith
  name: Ned Smith
  org: Intel Corporation
  abbrev: Intel
  email: ned.smith@intel.com
  street: ""
  code: ""
  city: ""
  country: USA
- ins: P. Uiterwijk
  name: Patrick Uiterwijk
  org: Red Hat
  email: puiterwijk@redhat.com
  street: 100 E Davie Street
  code: '27601'
  city: Raleigh
  country: Netherlands
- ins: W. Pan
  name: Wei Pan
  org: Huawei Technologies
  email: william.panwei@huawei.com

normative:
  RFC2119:
  RFC7231: COSE
  RFC8610:
  RFC8174:
  I-D.ietf-sacm-coswid: coswid
  I-D.ietf-rats-architecture: rats-arch
  IANA.language-subtag-registry: language-subtag 

informative:
  RFC4949:

--- abstract

Abstract

--- middle

# Introduction

The Remote Attestation Procedures (RATS) architecture {{-rats-arch}} describes appraisal procedures for attestation Evidence and Attestation Results. Appraisal procedures for Evidence are conducted by Verifiers and are intended to assess the trustworthiness of a remote peer. Appraisal procedures for Attestation Results are conducted by Relying Parties and are intended to operationalize the assessment about a remote peer and to act appropriately based on the assessment. In order to enable their intent, appraisal procedures consume Appraisal Policies, Reference Values, and Endorsements.

This documents specifies a binary encoding for Reference Values using the Concise Binary Object Representation (CBOR). The encoding is based on three parts that are defined using the Concise Data Definition Language (CDDL):

* Concise Reference Integrity Manifests (CoRIM),
* Concise Module Identifiers (CoMID), and
* Concise Software Identifier (CoSWID).

CoRIM and CoMID tags are defined in this document, CoSWID tags are defined in {{-coswid}}. CoRIM provide a wrapper structure, in which CoMID tags, CoSWID tags, as well as corresponding metadata can be bundled and signed as a whole. CoMID tags represent hardware components and provide a counterpart to CoSWID tags, which represent software components.

In accordance to {{RFC4949}}, software components that are stored in hardware modules are referred to as firmware. While firmware can be represented as a software component, it is also very hardware-specific and often resides directly on block devices instead of a file system. In this specification, firmware and their Reference Values are represented via CoMID tags. Reference Values for any other software components stored on a file system are represented via CoSWID tags.

In addition to CoRIM - and respective CoMID tags - this specification defines a Concise Manifest Revocation that represents a list of reference to CoRIM that are actively marked as invalid before their expiration time.

## Requirements Notation

{::boilerplate bcp14}

{: #mybody}
# Concise Reference Integrity Manifests

This section specifies the Concise RIM (CoRIM) format, the Concise MID format (CoMID), and the extension to the CoSWID specification that augments CoSWID tags to express specific relationships to CoMID tags.

While each specification defines its own start rule, only CoMID and CoSWID are stand-alone specifications. The CoRIM specification - as the bundling format - has a dependency on CoMID and CoSWID and is not a stand-alone specification.

While stand-alone CoSWID tags may be signed {{-coswid}}, CoMID tags are not intended to be stand-alone and are always part of a CoRIM that must be signed. {{-coswid}} specifies the use of COSE {{-COSE}} for signing. This specification defines how to generate singed CoRIM tags with COSE to enable proof of authenticity and temper-evidence.

This document uses the Concise Data Definition Language (CDDL {{RFC8610}}) to define the data structure of CoRIM and CoMID tags, as well as the extensions to CoSWID. The CDDL definitions provided define nested containers. Typically, the CDDL types used for nested containers are maps. Every key used in the maps is a named type that is associated with an corresponding uint via a block of rules appended at the end of the CDDL definition.

Every set of uint keys that is used in the context of the "collision domain" of map is intended to be collision-free (each key is intended to be unique in the scope of a map, not a multimap). To accomplish that, for each map there is an IANA registry for the map members of maps. <!-- FIXME: ref to IANA sections --> 

## Typographical Conventions

Type names in the following CDDL definitions follow the naming convention illustrated in table {{tbl-typography}}.

| type trait | example | typo convention |
|---
| extensible type choice | `int / text / ...` | `$`NAME`-type-choice` |
| closed type choice | `int / text` | NAME`-type-choice` |
| group choice | `( 1 => int // 2 => text )` | `$$`NAME`-group-choice` |
| group | `( 1 => int, 2 => text )` | NAME`-group` |
| type | `int` | NAME`-type`|
| tagged type | `#6.123(int)` | `tagged-`NAME`-type`|
| map | `{ 1 => int, 2 => text }` | NAME-`map` |
| flags | `&( a: 1, b: 2 )` | NAME-`flags` |
{: #tbl-typography title="Type Traits & Typographical Convention"}

## Prefixes and Namespaces

The semantics of the information elements (attributes) defined for CoRIM, CoMID tags, and CoSWID tags are sometimes very similar, but often do not share the same scope or are actually quite different. In order to not overload the already existing semantics of the software-centric IANA registries of CoSWID tags with, for example, hardware-centric semantics of CoMID tags, new type names are introduced. For example: both CoSWID tags and CoMID tags define a tag-id. As CoSWID already specifies `tag-id`, the tag-id in CoMID tags is prefixed with `comid.` to disambiguate the context, resulting in `comid.tag-id`. This prefixing provides a well-defined scope for the use of the types defined in this document and guarantees interoperability (no type name collisions) with the CoSWID CDDL definition. Effectively, the prefixes used in this specification enable simple hierarchical namespaces. The prefixing introduced is also based on the anticipated namespace features for CDDL. <!-- FIXME: ref to upcoming CDDL Namespaces I-D -->

## Extensibility

Both the CoRIM and the CoMID tag specification include extension points using CDDL sockets (see {{RFC8610}} Section 3.9). The use of CDDL sockets allows for well-formed extensions to be defined in supplementary CDDL definitions that support additional uses of CoRIM and CoMID tags.

There are two types of extensibility supported via the extension points defined in this document. Both types allow for the addition of keys in the scope of a map.

Custom Keys:

: The CDDL definition allows for the use of negative integers as keys. These keys cannot take on a well-defined global semantic. They can take on custom-defined semantics in a limited or local scope, e.g. vendor-defined scope.

Registered Keys:

: Additional keys can be registered at IANA via separate specifications.

Both types of extensibility also allow for the definition of new nested maps that again can include additional defined keys.

## Concise RIM Extension Points

The following CDDL sockets (extension points) are defined in the CoRIM specification, which allow the addition of new information structures to their respective CDDL groups.

| Map Name | CDDL Socket | Defined in
|---
| corim-entity-map | $$corim-entity-map-extension | {{model-corim-entity-map}}
| unsigned-corim-map | $$unsigned-corim-map-extension | {{model-unsigned-corim-map}}
| concise-mid-tag | $$comid-extension | {{model-concise-mid-tag}}
| tag-identity-map | $$tag-identity-map-extension | {{model-tag-identity-map}}
| entity-map | $$entity-map-extension | {{model-entity-map}}
| linked-tag-map | $$linked-tag-map-extension | {{model-linked-tag-map}}
| triples-map | $$triples-map-extension | {{model-triples-map}}
;| identity-claim-map | $$identity-claim-map-extension | {{model-identity-claim-map}}
| instance-claim-map | $$instance-claim-map-extension | {{model-instance-claim-map}}
| element-name-map | $$element-name-map-extension | {{model-element-name-map}}
| element-value-map | $$element-value-map-extension | {{model-element-value-map}}
| endorsed-claim-map | $$endorsed-claim-map-extension | {{model-endorsed-claim-map}}
| reference-claim-map | $$reference-claim-map-extension | {{model-reference-claim-map}}
{: #comid-extension-group-sockets title="CoMID CDDL Group Extension Points"}

## CDDL Generic Types

The CDDL definitions for CoRIM and CoMID tags use the two following generic types.

### Non-Empty

The non-empty generic type is used to express that a map with only optional members MUST at least include one of the optional members.

~~~~ CDDL
non-empty<M> = (M) .within ({ + any => any })
~~~~

### One-Or-More

The one-or-more generic type allows to omit an encapsulating array, if only one member would be present.

~~~~ CDDL
one-or-more<T> = T / [ 2* T ] ; 2*
~~~~

# Concise RIM Data Definition

A CoRIM is a bundle of CoMID tags and/or CoSWID tags that can reference each other and that includes additional metadata about that bundle.

The root of the CDDL specification provided for CoRIM is the
rule `corim` <!-- (as defined in FIXME) -->:

~~~ CDDL
start = corim
~~~

{: #model-signed-corim}
## The signed-corim Container

A CoRIM is signed using {{-COSE}}. The additional CoRIM-specific COSE header member label corim-meta is defined as well as the corresponding type corim-meta-map as its value. This rule and its constraints MUST be followed when generating or validating a signed CoMID tag.


~~~ CDDL
signed-corim = #6.18(COSE-Sign1-corim)

protected-signed-corim-header-map = {
  corim.alg-id => int
  corim.content-type => "application/rim+cbor"
  corim.issuer-key-id => bstr
  corim.meta => corim-meta-map
  * cose-label => cose-values 
}

unprotected-signed-corim-header-map = {
  * cose-label => cose-values
}

COSE-Sign1-corim = [
  protected: bstr .cbor protected-signed-corim-header-map
  unprotected: unprotected-signed-corim-header-map
  payload: bstr .cbor unsigned-corim-map
  signature: bstr
]
~~~~

### The corim-meta-map Container

This map contains the two additionally defined attributes `corim-entity-map` and `validity-map` that are used to annotate a CoRIM with metadata.

~~~~ CDDL
corim-meta-map = {
  corim.signer => one-or-more<corim-entity-map>
  ? corim.validity => validity-map
}
~~~~

corim.signer:

: One or more entities that created and/or signed the issued CoRIM.

corim.validity:

: A time period defining the validity span of a CoRIM.

{: #model-corim-entity-map}
### The corim-entity-map Container

This map is used to identify the signer of a CoRIM via a dedicated entity name, a corresponding role and an optional identifying URI.

~~~~ CDDL
corim-entity-map = {
  corim.entity-name => $entity-name-type-choice
  ? corim.reg-id => uri
  corim.role => $corim-role-type-choice
  * $$corim-entity-map-extension
}

$corim-role-type-choice /= corim.manifest-creator
$corim-role-type-choice /= corim.manifest-signer
~~~~

corim.entity-name:

: The name of the organization that takes on the role expressed in `corim.role`

corim.reg-id:

: The registration identifier of the organization that has authority over the namespace for `corim.entity-name`.

corim.role:

: The role type that is associated with the entity, e.g. the creator of the CoRIM or the signer of the CoRIM.

$$corim-entity-map-extension:

: This CDDL socket is used to add new information elements to the corim-entity-map container. See FIXME.

### The validity-map Container

The members of this map indicate the life-span or period of validity of a CoRIM that is baked into the protected header at the time of signing.

~~~~ CDDL
validity-map = {
  ? corim.not-before => time
  corim.not-after => time
}
~~~~

corim.not-before:

: The timestamp indicating the CoRIM's begin of its validity period.

corim.not-after:

: The timestamp indicating the CoRIM's end of its validity period.

{: #model-unsigned-corim-map}
## The unsigned-corim-map Container

This map contains the payload of the COSE envelope that is used to sign the CoRIM. This rule and its constraints MUST be followed when generating or validating an unsigned Concise RIM.

~~~~ CDDL
unsigned-corim-map = {
  corim.id => $corim-id-type-choice
  corim.tags => one-or-more<$concise-tag-type-choice>
  ? corim.dependent-rims => one-or-more<corim-locator-map>
  * $$unsigned-corim-map-extension
}

$corim-id-type-choice /= tstr
$corim-id-type-choice /= uuid-type

$concise-tag-type-choice /= #6.XXXX(bytes .cbor concise-swid-tag)
$concise-tag-type-choice /= #6.XXXX(bytes .cbor concise-mid-tag)
~~~~

corim.id:

: Typically a UUID or a text string that MUST uniquely identify a CoRIM in a given scope.

corim.tags:

: A collection of one or more CoMID tags and/or CoSWID tags.

corim.dependent-rims:

: One or more services available via the Internet that can supply additional, possibly dependent manifests (or other associated resources).

$$unsigned-corim-map-extension:

: This CDDL socket is used to add new information elements to the unsigned-corim-map container. See FIXME.

### The corim-locator-map Container

This map is used to locate and verify the integrity of resources provided by external services, e.g. the CoRIM provider.

~~~~ CDDL
corim-locator-map = {
  corim.href => uri
  ? corim.thumbprint => hash-entry
}
~~~~

corim.href:

: A pointer to a services that supplies dependent files or records.

corim.thumbprint:

: A digest of the reference resource.

{: #model-concise-mid-tag}
## The concise-mid-tag Container

The CDDL specification for the root concise-mid-tag map is as follows. This rule and its constraints MUST be followed when generating or validating a CoMID tag.

~~~ CDDL
concise-mid-tag = {
  ? comid.language => language-type
  comid.tag-identity => tag-identity-map
  ? comid.entity => one-or-more<entity-map>
  ? comid.linked-tags => one-or-more<linked-tag-map>
  comid.triples => triples-map
  * $$concise-mid-tag-extension
}
~~~

The following describes each member of the concise-mid-tag root map.

comid.language:

: A textual language tag that conforms with the IANA Language Subtag Registry {{-language-subtag}}.

comid.tag-identity:

: A composite identifier containing identifying attributes that enable global unique identification of a CoMID tag across versions.

comid.entity:

: A list of entities that contributed to the CoMID tag.

comid.linked-tags:

: A lost of tags that are linked to this CoMID tag.

comid.triples:

: A set of relationships in the form of triples, representing a graph-like and semantic reference structure between tags.

$$comid-mid-tag-extension:

: This CDDL socket is used to add new information elements to the concise-mid-tag root container. See FIXME.

{: #model-tag-identity-map}
## The tag-identity-map Container

The CDDL specification for the tag-identity-map includes all identifying attributes that enable a consumer of information to anticipate required capabilities to process the corresponding tag that map is included in. This rule and its constraints MUST be followed when generating or validating a CoMID tag.

~~~ CDDL
tag-identity-map = {
  comid.tag-id => $tag-id-type-choice
  comid.tag-version => tag-version-type
  * $$tag-identity-map-extension
}

$tag-id-type-choice /= tstr
$tag-id-type-choice /= uuid-type

tag-version-type = uint .default 0

~~~

The following describes each member of the tag-identity-map container.

comid.tag-id:

: An identifier for a CoMID that MUST be globally unique.

comid.tag-version:

: An unsigned integer used as a version identifier.

$$tag-metadata-map-extension:

: This CDDL socket is used to add new information elements to the concise-mid-tag root container. See FIXME.

{: #model-entity-map}
## The entity-map Container

This Container provides qualifying attributes that provide more context information describing the module as well its origin and purpose. This rule and its constraints MUST be followed when generating or validating a CoMID tag.

~~~ CDDL
entity-map = {
  comid.entity-name => $entity-name-type-choice
  ? comid.reg-id => uri
  comid.role => one-or-more<$comid-role-type-choice>
  * $$entity-map-extension
}

$comid-role-type-choice /= comid.tag-creator
$comid-role-type-choice /= comid.creator
$comid-role-type-choice /= comid.maintainer
~~~

The following describes each member of the tag-identity-map container.

comid.entity-name:

: The name of an organization that performs the roles as indicated by comid.role.

comid.reg-id:

: The registration identifier of the organization that has authority over the namespace for `comid.entity-name`.

comid.role:

: The list of roles a CoMID entity is associated with. The entity that generates the concise-mid-tag SHOULD include a $comid-role-type-choice value of comid.tag-creator.

$$module-entity-map-extension:

: This CDDL socket is used to add new information elements to the module-entity-map container. See FIXME.

{: #model-linked-tag-map}
## The linked-tag-map Container

A list of tags that are linked to this CoMID tag.

~~~ CDDL
linked-tag-map = {
  comid.linked-tag-id => $tag-id-type-choice
  comid.tag-rel => $tag-rel-type-choice
}

$tag-rel-type-choice /= comid.includes
$tag-rel-type-choice /= comid.or-includes
$tag-rel-type-choice /= comid.supplements
$tag-rel-type-choice /= comid.updates
$tag-rel-type-choice /= comid.replaces
$tag-rel-type-choice /= comid.patches
~~~

The following describes each member of the linked-tag-map container.

comid.linked-tag-id:

: The tag-id of the linked tag. A linked tag MAY be a CoMID tag or a CoSWID tag.

comid.tag-rel:

: The relationship type with the linked tag. The relationship type MAY be `include`, `or-includes`, `supplements`, `updates`, `replaces`, or `patches`, as well as other types well-defined by additional specifications. 

{: #model-triples-map}
## The triples-map Container

A set of directed properties that associate sets of data to provide reference values, endorsed values, verification key material or identifying key material for a specific hardware module that is a component of a composite device. This rule and its constraints MUST be followed when generating or validating a CoMID tag.

~~~ CDDL
triples-map = non-empty<{
  ? comid.reference-triples => one-or-more<reference-triple-record>
  ? comid.endorsed-triples => one-or-more<endorsed-triple-record>
  ? comid.attest-key-triples => one-or-more<attest-key-triple-record>
  ? comid.identity-triples => one-or-more<identity-triple-record>
  * $$triples-map-extension
}>
~~~

The following describes each member of the claims-map container.

comid.reference-triples:

: A directed property that associates reference measurements with a module that is an attesting environment.

comid.endorsed-triples:

: A directed property that associates endorsed measurements with a module that is a target environment.

comid.attest-key-triples:

: A directed property that associates key material used to verify evidence generated from a module that is an attesting environment.

comid.identity-triples:

: A directed property that associates key material used to identify a module that is an identifying part of a device.

$$triples-map-extension:

: This CDDL socket is used to add new information elements to the triples-map container. See FIXME.

{: #model-identity-claim-map}
## The identity-claim-map Container

FIXME: description

~~~ CDDL
identity-claim-map = {
  ? comid.device-id => $device-id-type-choice
  comid.key-material => COSE_KeySet
}
~~~

The following describes each member of the identity-claim-map container.

comid.device-id:

: FIXME

comid.key-material:

: FIXME

{: #model-instance-claim-map}
## The instance-claim-map Container

FIXME: description

~~~ CDDL
instance-claim-map = {
  ? comid.element-name => element-name-map
  $$instance-value-group-choice
}
~~~

The following describes each member of the instance-claim-map container.

comid.element-name:

: FIXME

$$instance-value-group-choice:

: This CDDL socket is used to add new information elements to the instance-claim-map container. See FIXME.

## The instance-value-group-choice Enumeration

This group choice allows for exactly one type of named instance claim per instance-claim map. If more than one instance-claim type has to be represented, an array of instance-claim-map entries for comid.instance-claims has to be created (enabled via the one-or-more\<instance-claim-map\> generic type).

~~~ CDDL
$$instance-value-group-choice //= (
  comid.mac-addr => mac-addr-type-choice //
  comid.ip-addr => ip-addr-type-choice //
  comid.serial-number => serial-number-type //
  comid.ueid => ueid-type //
  comid.uuid => uuid-type
)
~~~

The following describes each member of the instance-value-group-choice enumeration.

comid.mac-addr:

: FIXME

comid.ip-addr:

: FIXME

comid.serial-number:

: FIXME

comid.ueid:

: FIXME

comid.uuid:

: FIXME

{: #model-element-name-map}
## The element-name-map Container

FIXME: description

~~~ CDDL
element-name-map = non-empty<{
  ? comid.label => label-type
  ? comid.vendor => vendor-type
  ? comid.class-id => $class-id-type-choice
  ? comid.model => model-type
  ? comid.layer => layer-type
  ? comid.index => index-type
}>
~~~

The following describes each member of the element-name-map container.

comid.label:

: FIXME

comid.vendor:

: FIXME

comid.class-id:

: FIXME

comid.model:

: FIXME

comid.layer:

: FIXME

comid.index:

: FIXME

{: #model-element-value-map}
## The element-value-map Container

FIXME: description

~~~ CDDL
element-value-map = non-empty<{
  ? comid.version => module-version-map
  ? comid.svn => svn-type
  ? comid.digests => digests-type
  ? comid.flags => flags-type
  ? raw-value-group
}>
~~~

The following describes each member of the element-value-map container.

comid.version:

: FIXME

comid.svn:

: FIXME

comid.digests:

: FIXME

comid.flags:

: FIXME

raw-value-group:

: FIXME

<!-- module-version-map = {
  comid.version => version-type
  ? comid.version-scheme => $version-scheme
}

raw-value-group = (
  comid.raw-value => raw-value-type
  ? comid.raw-value-mask => raw-value-mask-type
)

svn-type = int
flags-type = bytes .bits operational-flags

operational-flags = &(
  not-configured: 0
  not-secure: 1
  recovery: 2
  debug: 3
) -->

{: #model-endorsed-claim-map}
## The endorsed-claim-map Container

FIXME: description (note: highlight a/symmetry with reference-claim-map)

~~~ CDDL
endorsed-claim-map = non-empty<{
  ? comid.element-name => element-name-map
  ? comid.element-value => element-value-map
  * $$endorsed-claim-map-extension
}>
~~~

The following describes each member of the endorsed-claim-map container.

comid.element-name:

: FIXME (note: also used in reference-claim-map)

comid.element-value:

: FIXME (note: also used in reference-claim-map)

$$endorsed-claim-map-extension:

: This CDDL socket is used to add new information elements to the endorsed-claim-map container. See FIXME.

{: #model-reference-claim-map}
## The reference-claim-map Container

FIXME: description (note: highlight a/symmetry with endorsed-claim-map)

~~~ CDDL
reference-claim-map = {
  ? comid.element-name => element-name-map
  comid.element-value => element-value-map
  * $$reference-claim-map-extension
}
~~~

The following describes each member of the reference-claim-map container.

comid.element-name:

: FIXME (note: also used in endorsed-claim-map)

comid.element-value:

: FIXME (note: also used in endorsed-claim-map)

$$reference-claim-map-extension:

: This CDDL socket is used to add new information elements to the reference-claim-map container. See FIXME.

# Full CDDL Definition

This section aggregates the CDDL definitions specified in this document in a full CDDL definitions including:

* the COSE envelope for CoRIM: signed-corim
* the CoRIM document: unsigned-corim
* the CoMID document: concise-mid-tag

Not included in the full CDDL definition are CDDL dependencies to CoSWID. The following CDDL definitions can be found in {{-coswid}}:

* the COSE envelope for CoRIM: signed-coswid
* the CoSWID document: concise-swid-tag

~~~~ CDDL
<CODE BEGINS>
{::include corim-cddl/corim-autogen.cddl}
<CODE ENDS>
~~~~

# Privacy Considerations

Privacy Considerations

# Concise SWID Data Extension

## New CoSWID to CoMID Relations

The CoSWID link-entry map is extended to describe relationships between CoSWID
and CoMID.  The new Link Rel values are defined in {{sec-link-rel-values}}.

When using one of these new relations, the following optional elements MUST NOT
be present in the Link Entry:

* artifact
* ownership
* use

### Link Rel Values {#sec-link-rel-values}

This document adds the following code-points to the Link Rel values defined in
Table 6 of {{!I-D.ietf-sacm-coswid}}.  These new indexes define relationships
between a CoSWID and a CoMID with the semantics specified in
{{tbl-link-rel-values}}.

 | Index | Relationship Type Name | Definition |
 --------|----------------------- |--------------------------------------------|
 | 12    | requires-module        | The link references a prerequisite module that needs to be loaded or present for installing this software |
 | 13    | runs-on-module         | The link references a module tag that this software runs on |
{: #tbl-link-rel-values title="New CoSWID to CoMID Link Relations"}

The rel values listed in {{tbl-link-rel-values}} MUST be used only for link
relations involving a base CoSWID and a target CoMID.

# Security Considerations

Security Considerations

# IANA Considerations

See Body {{mybody}}.


### CoSWID to CoMID Link Relations

IANA is requested to add the indexes in {{tbl-iana-link-rel-values}} to the
Software Tag Link Relationship Values Registry.

 | Index | Relationship Type Name | Specification               |
 --------|----------------------- |-----------------------------|
 | 12    | requires-module        | See {{sec-link-rel-values}} |
 | 13    | runs-on-module         | See {{sec-link-rel-values}} |
{: #tbl-iana-link-rel-values title="New CoSWID Link Relationship Values"}
