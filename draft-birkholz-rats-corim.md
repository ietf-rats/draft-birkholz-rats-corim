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
| triples-map | $$triples-map-extension | {{model-triples-map}}
| measurement-values-map | $$measurement-values-map-extension | {{model-measurement-values-map}}
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

$concise-tag-type-choice /= #6.TBD-SWID(bytes .cbor concise-swid-tag)
$concise-tag-type-choice /= #6.TBD-CoMID(bytes .cbor concise-mid-tag)
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

$$tag-identity-map-extension:

: This CDDL socket is used to add new information elements to the tag-identity-map container. See FIXME.

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

$$entity-map-extension:

: This CDDL socket is used to add new information elements to the entity-map container. See FIXME.

{: #model-linked-tag-map}
## The linked-tag-map Container

A list of tags that are linked to this CoMID tag.

~~~ CDDL
linked-tag-map = {
  comid.linked-tag-id => $tag-id-type-choice
  comid.tag-rel => $tag-rel-type-choice
}

$tag-rel-type-choice /= comid.supplements
$tag-rel-type-choice /= comid.replaces
~~~

The following describes each member of the linked-tag-map container.

comid.linked-tag-id:

: The tag-id of the linked tag. A linked tag MAY be a CoMID tag or a CoSWID tag.

comid.tag-rel:

: The relationship type with the linked tag. The relationship type MAY be `supplements` or `replaces`, as well as other types well-defined by additional specifications.

{: #model-triples-map}
## The triples-map Container

A set of directed properties that associate sets of data to provide reference values, endorsed values, verification key material or identifying key material for a specific hardware module that is a component of a composite device. The map provides the core element of CoMID tags that associate remote attestation relevant data with a distinct hardware component that runs an execution environment (a module that is either a Target Environment and/or an Attesting Environment). This rule and its constraints MUST be followed when generating or validating a CoMID tag.

~~~ CDDL
triples-map = non-empty<{
  ? comid.reference-triples => one-or-more<reference-triple-record>
  ? comid.endorsed-triples => one-or-more<endorsed-triple-record>
  ? comid.attest-key-triples => one-or-more<attest-key-triple-record>
  ? comid.identity-triples => one-or-more<identity-triple-record>
  * $$triples-map-extension
}>
~~~

The following describes each member of the triple-map container.

comid.reference-triples:

: A directed property that associates reference measurements with a module that is a Target Environment.

comid.endorsed-triples:

: A directed property that associates endorsed measurements with a module that is a Target Environment or Attesting Environment.

comid.attest-key-triples:

: A directed property that associates key material used to verify evidence generated from a module that is an attesting environment.

comid.identity-triples:

: A directed property that associates key material used to identify a module instance or a module class that is an identifying part of a device(-set).

$$triples-map-extension:

: This CDDL socket is used to add new information elements to the triples-map container. See FIXME.

{: #model-environment-map}
## The environment-map Container

This map represents the module(s) that a triple-map can point directed properties (relationships) from in order to associate them with external information for remote attestation, such as reference values, endorsement and endorsed values, verification key material for evidence, or identifying key material for module (re-)identification. This map can identify a single module instance via `comid.instance` or groups of modules via `comid.group`. Referencing classes of modules requires the use of the more complex `class-map` container. This rule and its constraints MUST be followed when generating or validating a CoMID tag.

~~~~ CDDL
environment-map = non-empty<{
  ? comid.class => class-map
  ? comid.instance => $instance-id-type-choice
  ? comid.group => $group-id-type-choice
}>

$instance-id-type-choice /= tagged-ueid-type
$instance-id-type-choice /= tagged-uuid-type

$group-id-type-choice /= tagged-uuid-type
~~~~

The following describes each member of the environment-map container.

comid-class:

: A composite identifier for classes of environments/modules.

comid.instance:

: An identifier for distinct instances of environments/modules that is either a UEID or a UUID.

comid.group:

: An identifier for a group of environments/modules that is a UUID.

## The class-map Container

This map enables a composite identifier intended to uniquely identify modules that are of a distinct class of devices. Effectively, all provided members in combination are a composite module class identifier.  This rule and its constraints MUST be followed when generating or validating a CoMID tag. This rule and its constraints MUST be followed when generating or validating a CoMID tag.

~~~~ CDDL
class-map = non-empty<{
  ? comid.class-id => $class-id-type-choice
  ? comid.vendor => tstr
  ? comid.model => tstr
  ? comid.layer => uint
  ? comid.index => uint
}>

$class-id-type-choice /= tagged-oid-type
$class-id-type-choice /= tagged-impl-id-type
$class-id-type-choice /= tagged-uuid-type
~~~~

The following describes each member of the class-map container.

{: #model-measurement-values-map}
## The measurement-map and measurement-values-map Containers

One of the targets (range) that a triple-map can point to in order to associate it with a module (domain) is the measurement-map. This map is used to provide reference measurements values that can be compared with Evidence Claim values or Endorsements and endorsed values from other sources than the corresponding CoRIM. `measurement-map` comes with a measurement key that identifies the measured element with via a OID reference or a UUID. `measurement-values-map` contains the actual measurements associated with the module(s). Byte strings with corresponding bit masks that highlights which bits in the byte string are used as reference measurements or endorsement are located in `raw-value-group`. The members of `measurement-values-map` provide well-defined and well-scoped semantics for reference measurement or endorsements with respect to a given module instance, class, or group. This rule and its constraints MUST be followed when generating or validating a CoMID tag.

~~~~ CDDL
measurement-map = {
  ? comid.mkey => $measured-element-type-choice
  comid.mval => measurement-values-map
}

$measured-element-type-choice /= tagged-oid-type
$measured-element-type-choice /= tagged-uuid-type

measurement-values-map = non-empty<{
  ? comid.ver => version-map
  ? comid.svn => svn-type-choice
  ? comid.digests => digests-type
  ? comid.flags => flags-type
  ? raw-value-group
  ? comid.mac-addr => mac-addr-type-choice
  ? comid.ip-addr =>  ip-addr-type-choice
  ? comid.serial-number => serial-number-type
  ? comid.ueid => ueid-type
  ? comid.uuid => uuid-type
  * $$measurement-values-map-extension
}>

flags-type = bytes .bits operational-flags

operational-flags = &(
  not-configured: 0
  not-secure: 1
  recovery: 2
  debug: 3
)

serial-number-type = text

digests-type = one-or-more<hash-entry>
~~~~

The following describes each member of the measurement-map and the measurement-values-map container.

comid.mkey:

: An identifier for the set of measurements expressed in measurement-values-map that is either an OID or a UUID.

comid.ver:

: A version number measurement.

comid.svn:

: A security related version number measurement.

comid.digests:

: A digest (typically a hash value) measurement.

comid.flags:

: Measurements that reflect operational modes that are made permanent at manufacturing time such that they are not expected to change during normal operation of the Attester.

raw-value-group:

: A measurement in the form of a byte string that can come with a corresponding bit mask defining the relevance of each bit in the byte string as a measurement.

comid.mac-addr:

: An EUI-48 or EUI-64 MAC address measurement.

comid.ip-addr:

: An Ipv4 or Ipv6 address measurement.
 
comid.serial-number:

: A measurement of a serial number in text.

comid.ueid:

: A measurement of a Unique Enough Identifier (UEID).

comid.uuid:

: A measurement of a Universally Unique Identifier (UUID).

$$measurement-values-map-extension:

: This CDDL socket is used to add new information elements to the measurement-values-map container. See FIXME.

### The version-map Container

This map expresses reference values about version information.

~~~~ CDDL
version-map = {
  comid.version => version-type
  ? comid.version-scheme => $version-scheme
}

version-type = text .default '0.0.0'
~~~~

The following describes each member of the version-map container.

comid.version:

: The version in the form of a text string.

comid-version-scheme:

: The version-scheme of the text string value as defined in {{-coswid}}

### The svn-type-choice Enumeration

This choice defines the CBOR tagged Security Version Numbers (SVN) that can be used as reference values for Evidence and Endorsements.

~~~~ CDDL
svn = int
min-svn = int
tagged-svn = #6.TBD-SVN(svn)
tagged-min-svn = #6.TBD-minSVN(min-svn)
svn-type-choice = tagged-svn / tagged-min-svn
~~~~

The following describes the types in the svn-type-choice enumeration.

tagged-svn:

: A specific SVN.

tagged-min-svn:

: A lower bound for allowed SVN.

### The raw-value-group Container

FIXME This group can express a single raw byte value and can come with an optional bit mask that defines which bits in the byte string is used as a reference value, by setting corresponding position in the bit mask to 1.

~~~~ CDDL
raw-value-group = (
  comid.raw-value => raw-value-type
  ? comid.raw-value-mask => raw-value-mask-type
)

raw-value-type = bytes
raw-value-mask-type = bytes
~~~~

The following describes the types in the raw-value-group Container.

comid.raw-value:

: FIXME Bit positions in raw-value-type that correspond to bit positions in raw-value-mask-type.

comid.raw-value-mask:

: A raw-value-mask-type bit corresponding to a bit in raw-value-type MUST be 1 to evaluate the corresponding raw-value-type bit.

### The ip-addr-type-choice Enumeration

This type choice expresses IP addresses as reference values.

~~~~ CDDL
ip-addr-type-choice = ip4-addr-type / ip6-addr-type
ip4-addr-type = bytes .size 4
ip6-addr-type = bytes .size 16
~~~~

### The mac-addr-type-choice Enumeration

This type choice expresses MAC addresses as reference values.

~~~~ CDDL
mac-addr-type-choice = eui48-addr-type / eui64-addr-type
eui48-addr-type = bytes .size 6
eui64-addr-type = bytes .size 8
~~~~

{: #model-verification-key-map}
## The verification-key-map Container

One of the targets (range) that a triple-map can point to in order to associate it with a module (domain). This map is used to provide the key material for evidence verification (effectively signature checking or a lightweight proof-of-possession of private signing key material) or for identity assertion/check (where a proof-of-possession implies a certain device identity). In support of informed trust decisions, an optional trust anchor in the form a PKIX certification path that is associated with the provided key material can be included. This rule and its constraints MUST be followed when generating or validating a CoMID tag.

~~~ CDDL
verification-key-map = {
  comid.key => pkix-base64-key-type
  ? comid.keychain => [ + pkix-base64-cert-type ]
}

pkix-base64-key-type = tstr
pkix-base64-cert-type = tstr
~~~

The following describes each member of the verification-key-map container.

comid.key:

: Verification key material in DER format base64-encoded.  Typically, but not necessarily, a public key.

comid.keychain:

: One or more base64 encoded PKIX certificates. The certificate containing the public key in comid.key MUST be the first certificate. Additional certificates MAY follow. Each subsequent certificate SHOULD certify the previous certificate.

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

# Security Considerations

Security Considerations

# IANA Considerations

See Body {{mybody}}.
