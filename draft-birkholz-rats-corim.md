---
v: 3

title: Concise Reference Integrity Manifest
abbrev: CoRIM
docname: draft-birkholz-rats-corim-latest
category: std
consensus: true
submissiontype: IETF

ipr: trust200902
area: Security
workgroup: RATS Working Group
keyword: RIM, RATS, attestation, verifier, supply chain

stand_alone: true
pi:
  toc: yes
  sortrefs: yes
  symrefs: yes
  tocdepth: 6

author:
- ins: H. Birkholz
  name: Henk Birkholz
  org: Fraunhofer SIT
  email: henk.birkholz@sit.fraunhofer.de
- ins: T. Fossati
  name: Thomas Fossati
  organization: arm
  email: Thomas.Fossati@arm.com
- ins: Y. Deshpande
  name: Yogesh Deshpande
  organization: arm
  email: yogesh.deshpande@arm.com
- ins: N. Smith
  name: Ned Smith
  org: Intel
  email: ned.smith@intel.com
- ins: W. Pan
  name: Wei Pan
  org: Huawei Technologies
  email: william.panwei@huawei.com

normative:
  RFC2119:
  RFC8152: cose
  RFC7252:
  RFC8126:
  RFC8174:
  RFC8610: cddl
  STD94:
    -: cbor
    =: RFC8949
  I-D.ietf-sacm-coswid: coswid
  I-D.ietf-rats-architecture: rats-arch
  IANA.language-subtag-registry: language-subtag

informative:
  RFC4949:

entity:
  SELF: "RFCthis"

--- abstract

Remote Attestation Procedures (RATS) enable Relying Parties to assess the
trustworthiness of a remote Attester and therefore to decide wheher to engage
in secure interactions with it. Evidence about trustworthiness can be rather
complex and it is deemed unrealistic that every Relying Party is capable of the
appraisal of Evidence. Therefore that burden is typically offloaded to a
Verifier.  In order to conduct Evidence appraisal, a Verifier requires not only
fresh Evidence from an Attester, but also trusted Endorsements and Reference
Values from Endorsers, such as manufacturers, distributors, or device owners.
This document specifies Concise Reference Integrity Manifests (CoRIM) that
represent Endorsements and Reference Values in CBOR format.  Composite devices
or systems are represented by a collection of Concise Module Identifiers
(CoMID) and Concise Software Identifiers (CoSWID) bundled in a CoRIM document.

--- middle

# Introduction

TODO

## Terminology and Requirements Language

This document uses terms and concepts defined by the RATS architecture.
For a complete glossary see {{Section 4 of -rats-arch}}.

The terminology from CBOR {{-cbor}}, CDDL {{-cddl}} and COSE {{-cose}} applies;
in particular, CBOR diagnostic notation is defined in {{Section 8 of -cbor}}
and {{Section G of -cddl}}.

{::boilerplate bcp14}

## CDDL Typographical Conventions

The CDDL definitions in this document follow the naming conventions illustrated
in {{tbl-typography}}.

| Type trait | Example | Typographical convention |
|---
| extensible type choice | `int / text / ...` | `$`NAME`-type-choice` |
| closed type choice | `int / text` | NAME`-type-choice` |
| group choice | `( 1 => int // 2 => text )` | `$$`NAME`-group-choice` |
| group | `( 1 => int, 2 => text )` | NAME`-group` |
| type | `int` | NAME`-type`|
| tagged type | `#6.123(int)` | `tagged-`NAME`-type`|
| map | `{ 1 => int, 2 => text }` | NAME-`map` |
| flags | `&( a: 1, b: 2 )` | NAME-`flags` |
{: #tbl-typography title="Type Traits & Typographical Conventions"}

## CDDL Generic Types

The CDDL definitions for CoRIM and CoMID tags make use the following generic
type.

### Non-Empty

The `non-empty` generic type is used to express that a map with only optional
members MUST at least include one of the optional members.

~~~~ cddl
non-empty<M> = (M) .within ({ + any => any })
~~~~

## CDDL Custom Types

### UUID Types

~~~ cddl
tagged-uuid-type = #6.37(uuid-type)
~~~

### UEID Types

~~~ cddl
ueid-type = bytes .size 33
tagged-ueid-type = #6.550(ueid-type)
~~~

### OID Types

~~~ cddl
oid-type = bytes
tagged-oid-type = #6.111(oid-type)
~~~

### Tagged Integer Type

~~~ cddl
tagged-int-type = #6.551(int)
~~~

# CoRIM
Concise Reference Integrity Manifest (CoRIM) contain tags that describe the composition and measurements of a platform, device, component, or software.

## Purpose
CoRIM describes an envelope to carry information exchanged between an Endorser and Verifier Roles [Ref RATS]. Endorsements are information produced by Endorsers and consumed by Verifiers. CoRIM contains Endorsment Claims. Inside CoRIM, Claims about hardware or firmware are described using CoMID tags. Software Claims are described using CoSWID tags. 
CoRIM can be integrity protected and authenticated using cryptography. The CoRIM signer is the entity that asserts Endorsement Claims.
In a complex supply chain, it is likely multiple Endorsers will produce CoRIMs, pertaining to individual components they produce, at different times. Hence a CoRIM can provide a link to other CoRIMs such that a combination of CoRIMs describe a device class.

## Top Level Schema

Top level CoRIM schema provides optionality to the Endorser to include either a tagged Signed CoRIM or an Unsigned CoRIM containing just the CoRIM Map.

~~~ cddl
corim = #6.500(concise-reference-integrity-manifest-type-choice)

tagged-corim-map = #6.501(corim-map)
$concise-reference-integrity-manifest-type-choice  /= tagged-corim-map
$concise-reference-integrity-manifest-type-choice /= #6.502(signed-corim)
~~~

The section {{CoRIM Map}} explains the details of `corim-map`, while section {{Signed CoRIM Schema}} explain the details of `signed-corim`.

## Signed CoRIM Schema
A signed CoRIM is a COSE Sign1 Envelope. The COSE envelope contains a protected CoRIM Header which carries the security information of the Envelope and additional information about CoRIM.

~~~ cddl
COSE-Sign1-corim = [
  protected: bstr .cbor protected-corim-header-map
  unprotected: unprotected-corim-header-map
  payload: bstr .cbor tagged-corim-map
  signature: bstr
]
~~~
The following describes each child element of this type.

- protected: A CBOR Encoded protected header which is protected by the COSE signature. Contains information as given by Protected Header Map below.

- unprotected A COSE header that is not protected by COSE signature.

- payload A CBOR encoded tagged CoRIM.

- signature A COSE signature block which is the signature over the protected and payload components of the signed CoRIM.

### Protected Header Map

~~~ cddl
protected-corim-header-map = {
  corim.alg-id => int
  corim.content-type => "application/corim-unsigned+cbor"
  corim.issuer-key-id => bstr
  corim.meta => bstr .cbor corim-meta-map
  * cose-label => cose-values 
}
~~~

The following describes each child item of this map.

- corim.alg-id: An integer that identifies a signature algorithm.

- corim.content-type: A string that represents the "MIME Content type" carried in the CoRIM payload.

- corim.issuer-key-id: A bit string which is a key identity pertaining to the CoRIM Issuer.

- corim.meta: A map that contains meta data associated with a signed CoRIM as described in Meta Map below.

- cose-label: Additional data that can be included in the COSE header map.

### Meta Map

The CoRIM meta map identifies the entity or entities that create and sign the CoRIM. This ensures the consumer of the corim is able to identify credentials used to authenticate its creator/signer.

~~~ cddl
corim-meta-map = {
  corim.signer => corim-signer-map
  ? corim.signature-validity => validity-map
}
~~~

The following describes each child item of this group.

- corim.signer: Signer Map carries information about the entity that performs the CoRIM Signer Role

- corim.signature-validity: Validity Map carries the validity period of signed CoRIM.

#### Signer Map

~~~ cddl
corim-signer-map = {
  corim.signer-name => $entity-name-type-choice
  ? corim.signer-uri => uri
  * $$corim-signer-map-extension
}
~~~
- corim.signer-name A string for the name of the organization that performs the signer role.

- corim.signer-uri The registration identifier for the organization that manages the namespace corim.signer-name.

- corim-signer-map-extension The extension point to the signer map.

#### Validity Map

Validity Map contains the validity period ranges.

~~~ cddl
validity-map = {
  ? corim.not-before => time
  corim.not-after => time
}
~~~
- corim.not-before An optional parameter in time units to represent start time of the CoRIM signature. 

- corim.not-after Time to represent the expiry for CoRIM signature

## CoRIM Map

The CDDL specification for the corim-map is as follows and this rule and its constraints must be followed when creating or validating a CoRIM map.

~~~ cddl
corim-map = {
  &(id: 0) => $corim-id-type-choice
  &(tags: 1) => [ + $concise-tag-type-choice ]
  ? &(dependent-rims: 2) => [ + corim-locator-map ]
  ? &(profile: 3) => [ + profile-type-choice ]
  ? &(rim-validity: 4) => validity-map
  ? &(entities: 5) => [ + corim-entity-map ]
  * $$corim-map-extension
}
~~~
The following describes each child item of this map. 

- id A globally unique identifier to identify a CoRIM instance as per CDDL syntax {{Identity}} 

- tags An array of one or more CoMID or CoSWID tag as per CDDL syntax {{Tags}} 

- dependent-rims: An array containing a list of additional supplied rim information or dependent files as per CDDL syntax {{Dependent RIMs}}

- profile: A uri or a tagged oid that identify the profile that this CoRIM specifies. A profile specifies which of the optional parts of a CoRIM are required, which are prohibited and which extension points are exercised and how, as per the CDDL syntax {{Profiles}}

- rim-validity : Specifies the validity period of RIM Contents as per the CDDL syntax {{RIM Validity}

- entities: A list of entities involved in a CoRIM lifecycle. The CDDL syntax is as per {{Entities}}

- $$corim-map-extension: This CDDL socket is used to add new information structures to the corim-map.

### Identity
A CoRIM Identity can be either a text string or a UUID type that uniquely identifies a CoRIM identity.

~~~ cddl
$corim-id-type-choice /= tstr
$corim-id-type-choice /= uuid-type
~~~

### Tags
A concise-tag-type-choice selection can either be a tagged CBOR payload that carries either a {{CoMID}} or a {{CoSWID}}.

~~~ cddl
$concise-tag-type-choice /= #6.505(bytes .cbor concise-swid-tag)
$concise-tag-type-choice /= #6.506(bytes .cbor concise-mid-tag)
~~~


### Dependent RIMs

~~~ cddl
corim-locator-map = {
  &(href: 0) => uri
  ? &(thumbprint: 1) => hash-entry
}
~~~

### Profiles

~~~ cddl
profile-type-choice = uri / tagged-oid-type
~~~

### RIM Validity

~~~ cddl
validity-map = {
  ? &(not-before: 0) => time
  &(not-after: 1) => time
}
~~~

### Entities

~~~ cddl
corim-entity-map = {
  &(entity-name: 0) => $entity-name-type-choice
  ? &(reg-id: 1) => uri
  &(role: 2) => $corim-role-type-choice
  * $$corim-entity-map-extension
}
~~~

The following are the elements within a corim-entity-map

- entity-name: The name of entity which is responsible for the CoRIM action as defined by the role. `$entity-name-type-choice` can only be text string in this version of specification.
- reg-id: uri that is the registration identifier for the organization that manages the namespace for corim.entity-name
- role: The role that the Manifest entity is involved with this Manifest. For this version of specification  `corim-role-type-choice` can only be `manifest-creator` of an entity.

# CoMID

## Purpose

## Structure

~~~ cddl
concise-mid-tag = {
  ? &(language: 0) => language-type
  &(tag-identity: 1) => tag-identity-map
  ? &(entities: 2) => [ + entity-map ]
  ? &(linked-tags: 3) => [ + linked-tag-map ]
  &(triples: 4) => triples-map
  * $$concise-mid-tag-extension
}
~~~

### Language

~~~ cddl
language-type = text
~~~

### Tag Identity

~~~ cddl
tag-identity-map = {
  &(tag-id: 0) => $tag-id-type-choice
  ? &(tag-version: 1) => tag-version-type
}
~~~

#### Tag ID {#sec-tag-id}

~~~ cddl
$tag-id-type-choice /= tstr
$tag-id-type-choice /= uuid-type
~~~

#### Tag Version

~~~ cddl
tag-version-type = uint .default 0
~~~

### Entities

~~~ cddl
entity-map = {
  &(entity-name: 0) => $entity-name-type-choice
  ? &(reg-id: 1) => uri
  &(role: 2) => [ + $comid-role-type-choice ]
  * $$entity-map-extension
}
~~~

#### Name

~~~ cddl
$entity-name-type-choice /= text
~~~

#### Registered ID

#### Role

~~~ cddl
$comid-role-type-choice /= &(tag-creator: 0)
$comid-role-type-choice /= &(creator: 1)
$comid-role-type-choice /= &(maintainer: 2)
~~~

### Linked Tags

~~~ cddl
linked-tag-map = {
  &(linked-tag-id: 0) => $tag-id-type-choice
  &(tag-rel: 1) => $tag-rel-type-choice
}
~~~

#### Linked Tag Identification

For the definition see {{sec-tag-id}}.

#### Tag Relations

~~~ cddl
$tag-rel-type-choice /= &(supplements: 0)
$tag-rel-type-choice /= &(replaces: 1)
~~~

### Triples

~~~ cddl
triples-map = non-empty<{
  ? &(reference-triples: 0) => [ + reference-triple-record ]
  ? &(endorsed-triples: 1)  => [ + endorsed-triple-record ]
  ? &(identity-triples: 2) => [ + identity-triple-record ]
  ? &(attest-key-triples: 3) => [ + attest-key-triple-record ]
  // TODO(tho) 4 and 5
  ? &(coswid-triples: 6) => [ + coswid-triple-record ]
  * $$triples-map-extension
}>
~~~

#### Common Data Items

##### Environment

~~~ cddl
environment-map = non-empty<{
  ? &(class: 0) => class-map
  ? &(instance: 1) => $instance-id-type-choice
  ? &(group: 2) => $group-id-type-choice
}>
~~~

##### Class

~~~ cddl
class-map = non-empty<{
  ? &(class-id: 0) => $class-id-type-choice
  ? &(vendor: 1) => tstr
  ? &(model: 2) => tstr
  ? &(layer: 3) => uint
  ? &(index: 4) => uint
}>
~~~

##### Class Id

~~~ cddl
$class-id-type-choice /= tagged-oid-type
$class-id-type-choice /= tagged-uuid-type
$class-id-type-choice /= tagged-int-type
~~~

##### Instance

~~~ cddl
$instance-id-type-choice /= tagged-ueid-type
$instance-id-type-choice /= tagged-uuid-type
~~~

##### Group

~~~ cddl
$group-id-type-choice /= tagged-uuid-type
~~~

##### Measurements

~~~ cddl
measurement-map = {
  ? &(mkey: 0) => $measured-element-type-choice
  &(mval: 1) => measurement-values-map
}
~~~

###### Measurement Keys

~~~ cddl
$measured-element-type-choice /= tagged-oid-type
$measured-element-type-choice /= tagged-uuid-type
$measured-element-type-choice /= uint
~~~

###### Measurement Values

~~~ cddl
measurement-values-map = non-empty<{
  ? &(ver: 0) => version-map
  ? &(svn: 1) => svn-type-choice
  ? &(digests: 2) => digests-type
  ? &(flags: 3) => flags-map
  ? (
      &(raw-value: 4) => $raw-value-type-choice,
      ? &(raw-value-mask: 5) => raw-value-mask-type
    )
  ? &(mac-addr: 6) => mac-addr-type-choice
  ? &(ip-addr: 7) =>  ip-addr-type-choice
  ? &(serial-number: 8) => serial-number-type
  ? &(ueid: 9) => ueid-type
  ? &(uuid: 10) => uuid-type
  ? &(name: 11) => tstr
  * $$measurement-values-map-extension
}>
~~~

##### Crypto Keys

~~~ cddl
$crypto-key-type-choice /= tagged-pkix-base64-key-type
$crypto-key-type-choice /= tagged-pkix-base64-cert-type
$crypto-key-type-choice /= tagged-pkix-base64-cert-path-type

tagged-pkix-base64-key-type = #6.554(tstr)
tagged-pkix-base64-cert-type = #6.555(tstr)
tagged-pkix-base64-cert-path-type = #6.556(tstr)
~~~

#### Reference Values

~~~ cddl
reference-triple-record = [
  environment-map
  [ + measurement-map ]
]
~~~

#### Endorsed Values

~~~ cddl
endorsed-triple-record = [
  environment-map
  [ + measurement-map ]
]
~~~

#### Attestation Verification Keys

~~~ cddl
attest-key-triple-record = [
  environment-map
  [ + $crypto-key-type-choice ]
]
~~~

#### Identity Keys

~~~ cddl
identity-triple-record = [
  environment-map
  [ + $crypto-key-type-choice ]
]
~~~

#### CoMID-CoSWID Linkage

~~~ cddl
coswid-triple-record = [
  environment-map
  [ + concise-swid-tag-id ]
]

concise-swid-tag-id = text / bstr .size 16
~~~

## Extensibility

# Signed CoRIM

~~~ cddl
COSE-Sign1-corim = [
  protected: bstr .cbor protected-corim-header-map
  unprotected: unprotected-corim-header-map
  payload: bstr .cbor tagged-corim-map
  signature: bstr
]
~~~

## Protected Header CoRIM Metadata

~~~ cddl
protected-corim-header-map = {
  &(alg-id: 1) => int
  &(content-type: 3) => "application/corim-unsigned+cbor"
  &(issuer-key-id: 4) => bstr
  &(meta: 8) => bstr .cbor corim-meta-map
  * cose-label => cose-values
}

cose-label = int / tstr
cose-values = any
~~~

## Unprotected Header CoRIM Map

~~~ cddl
unprotected-corim-header-map = {
  * cose-label => cose-values
}
~~~

### CoRIM Meta Map

~~~ cddl
corim-meta-map = {
  &(signer: 0) => corim-signer-map
  ? &(signature-validity: 1) => validity-map
}
~~~

# Implementation Status

See [Section 2 of RFC7942](https://datatracker.ietf.org/doc/html/rfc7942#section-2)

# Security and Privacy Considerations {#sec-sec}

# IANA Considerations

## New CBOR Tags

TODO: populate table from the contents of cbor-tags.txt

| Tag | Data Item | Semantics | Reference |
|---
| TODO | TODO | TODO | {{&SELF}} |


## New CoRIM Registries

## New CoMID Registries

## New Media Types

IANA is requested to add the following media types to the "Media Types"
registry {{!IANA.media-types}}.

| Name | Template | Reference |
| corim-signed+cbor | application/corim-signed+cbor | {{&SELF}}, {{sec-mt-corim-signed}} |
| corim-unsigned+cbor | application/corim-unsigned+cbor | {{&SELF}}, {{sec-mt-corim-unsigned}} |
{: #tbl-media-type align="left" title="New Media Types"}

### corim-signed+cbor {#sec-mt-corim-signed}

{:compact}
Type name:
: `application`

Subtype name:
: `corim-signed+cbor`

Required parameters:
: n/a

Optional parameters:
: "profile" (CoRIM profile in string format.  OIDs MUST use the dotted-decimal notation.)

Encoding considerations:
: binary

Security considerations:
: {{sec-sec}} of {{&SELF}}

Interoperability considerations:
: n/a

Published specification:
: {{&SELF}}

Applications that use this media type:
: Attestation Verifiers, Endorsers and Reference-Value providers that need to transfer COSE Sign1 wrapped CoRIM payloads over HTTP(S), CoAP(S), and other transports.

Fragment identifier considerations:
: n/a

Magic number(s):
: `D9 01 F6 D2`, `D9 01 F4 D9 01 F6 D2`

File extension(s):
: n/a

Macintosh file type code(s):
: n/a

Person & email address to contact for further information:
: RATS WG mailing list (rats@ietf.org)

Intended usage:
: COMMON

Restrictions on usage:
: none

Author/Change controller:
: IETF

Provisional registration?
: Maybe

### corim-unsigned+cbor {#sec-mt-corim-unsigned}

{:compact}
Type name:
: `application`

Subtype name:
: `corim-unsigned+cbor`

Required parameters:
: n/a

Optional parameters:
: "profile" (CoRIM profile in string format.  OIDs MUST use the dotted-decimal notation.)

Encoding considerations:
: binary

Security considerations:
: {{sec-sec}} of {{&SELF}}

Interoperability considerations:
: n/a

Published specification:
: {{&SELF}}

Applications that use this media type:
: Attestation Verifiers, Endorsers and Reference-Value providers that need to transfer unprotected CoRIM payloads over HTTP(S), CoAP(S), and other transports.

Fragment identifier considerations:
: n/a

Magic number(s):
: `D9 01 F5`, `D9 01 F4 D9 01 F5`

File extension(s):
: n/a

Macintosh file type code(s):
: n/a

Person & email address to contact for further information:
: RATS WG mailing list (rats@ietf.org)

Intended usage:
: COMMON

Restrictions on usage:
: none

Author/Change controller:
: IETF

Provisional registration?
: Maybe

## CoAP Content-Formats Registration

IANA is requested to register the two following Content-Format numbers in the
"CoAP Content-Formats" sub-registry, within the "Constrained RESTful
Environments (CoRE) Parameters" Registry {{!IANA.core-parameters}}:

| Content-Type | Content Coding | ID | Reference |
|---
| application/corim-signed+cbor | - | TBD1 | {{&SELF}} |
| application/corim-unsigned+cbor | - | TBD2 | {{&SELF}} |
{: align="left" title="New Content-Formats"}

--- back

# Full CoRIM CDDL

~~~ cddl
corim = [ "TODO" ]
~~~

# Full CoMID CDDL

~~~ cddl
comid = [ "TODO" ]
~~~

