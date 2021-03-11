---
title: Concise Reference Integrity Manifest
abbrev: CoRIM
docname: draft-birkholz-rats-corim-latest0
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
  RFC8610:
  RFC8174:
  I-D.ietf-sacm-coswid: coswid
  I-D.ietf-rats-architecture: rats-arch

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

CoRIM and CoMID are defined in this document, CoSWID are defined in {{-coswid}}. CoRIM provide a wrapper structure, in which CoMID, CoSWID, as well as corresponding metadata can be bundled and signed as a whole. CoMID represent hardware components and provide a counterpart to CoSWID, which represent software components.

In accordance to {{RFC4949}}, software components that are stored in hardware modules are referred to as firmware. While firmware can be represented as a software component, it is also very hardware-specific and often resides directly on block devices instead of a file system. In this specification, firmware and their Reference Values are represented via CoMID. Reference Values for any other software components stored on a file system are represented via CoSWID.

In addition to CoRIM - and respective CoMID - this specification defines a Concise Manifest Revocation that represents a list of reference to CoRIM that are actively marked as invalid before their expiration time.

## Requirements Notation

{::boilerplate bcp14}

{: #mybody}
# Concise Reference Integrity Manifests

This section specifies the Concise RIM (CoRIM) format, the Concise MID format (CoMID), and the extension to the CoSWID specification that augments CoSWIDs to express specific relationships to CoMIDs.

While each specification defines its own start rule, only CoMID and CoSWID are stand-alone specifications. The CoRIM specification - as the bundling format - has a dependency on CoMID and CoSWID and is not a stand-alone specification.

While stand-alone CoSWIDs can be signed, CoMID are not intended to be signed themselves. In order to provide a proof of authenticity and to be temper-evident, CoMIDs MUST be wrapped in a CoRIM that is then signed.

## Extensibility

Both the CoRIM and the CoMID specification include extension points using CDDL sockets (see {{RFC8610}} Section 3.9). The use of CDDL sockets allow for well-formed extensions to be defined in supplementary CDDL descriptions that support additional uses of CoRIM and CoMID.

The following CDDL sockets (extension points) are defined in the CoRIM specification, which allow the addition of new information structures to their respective CDDL groups.

| Map Name | CDDL Socket | Defined in
|---
| concise-mid-tag | $$comid-extension | {{model-concise-mid-tag}}
{: #comid-extension-group-sockets title="CoMID CDDL Group Extension Points"}

# Concise RIM Data Definition

A CoRIM is a bundle of CoMIDs and CoSWIDs that can reference each other and that includes additional metadata about that bundle.

The root of the CDDL specification provided for CoRIM is the
rule `corim` (as defined in FIXME):

~~~ CDDL
start = corim
~~~

{: #model-concise-mid-tag}
## The concise-mid-tag Map

The CDDL specification for the root concise-mid-tag map is as follows. This rule and its constraints MUST be followed when creating or validating a CoMID tag:

~~~ CDDL
concise-mid-tag = {
  ? language => text,
  tag-metadata => tag-metadata-type,
  ? module-metadata => module-metadata-type,
  ? entity => entity-entry / [2* entity-entry], ; defined in coswid
  ? linked-tags => linked-tags-entry / [2* linked-tags-entry], ; dependent coswid and comid tags.
  ? claims => claims-entry, ; claims may be omitted for manifests that only capture dependencies to other manifests
  * $$comid-extension
}
~~~

The following describes each member of the concise-mid-tag root map.

- language:

- tag-metadata:

- module-metadata:

- entity:

- linked-tags:

- claims:

- $$comid-extension: This CDDL socket is used to add new information structures to the concise-mid-tag root map. See FIXME.

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
{::include cddl/corim.cddl}
<CODE ENDS>
~~~~

# Privacy Considerations

Privacy Considerations

# Security Considerations

Security Considerations

# IANA Considerations

See Body {{mybody}}.

--- back
