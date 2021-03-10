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

normative:
  RFC2119:
  RFC8174:
  I-D.ietf-sacm-coswid: coswid
  I-D.ietf-rats-architecture: rats-arch

informative:
  RFC4949:

--- abstract

Abstract

--- middle

# Introduction

The Remote Attestation Procedures (RATS) architecture {{-rats-arch}} describes appraisal procedures for attestation Evidence and Attestation Results. Appraisal procedures for Evidence are conducted by Verifiers and are intended to assess the trustworthiness of a remote peer. Appraisal procedures for Attestation Results are conducted by Relying Parties and are intended to operationalize the assessment about a remote peer and to act on it appropriately. In order to enable their intent, appraisal procedures consume Appraisal Policies, Reference Values, and Endorsements.

This documents specifies a binary encoding for Reference Values using the Concise Binary Object Representation (CBOR). The encoding is based on three parts that are defined using the Concise Data Definition Language (CDDL):

* Concise Reference Integrity Manifests (CoRIM),
* Concise Module Identifiers (CoMID), and
* Concise Software Identifier (CoSWID).

While CoRIM and CoMID are defined in this document, CoSWID are defined in {{-coswid}}. CoRIM provide a wrapper structure, in which CoMID, CoSWID, and corresponding metadata can be bundled and signed as a whole. CoMID represent hardware components and provide a counterpart to CoSWID, which represent software components.

While firmware can be represented as a software component, it is also very hardware-specific and often resides directly on block devices instead of a file system. In accordance to {{RFC4949}}, software components that are stored in hardware modules are referred to as firmware. In this specification, firmware and their Reference Values are represented via CoMID. Reference Values for any other software components stored on a file system are represented via CoSWID.

In addition to CoRIM - and respective CoMID - this specification defines a Concise Manifest Revocation that represents a list of reference to CoRIM that are actively marked as invalid before their expiration time.

## Requirements Notation

{::boilerplate bcp14}

{: #mybody}
# Concise Reference Integrity Manifests



Body

# CDDL

See {{-coswid}}.

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

New indexes for Software Tag Link Relationship Values needs to be registered as below:

### CoSWID to CoMID Link Relations
 | Index | Relationship Type Name | Description                                |
 --------|----------------------- |--------------------------------------------|
 | 12    | needs                  | links to a module this software needs      |
 | 13    | runs-on                | links to a module this software runs on    |
 | 14    | part-of                | links to a module this software is part of |
 | 15    | m-supplemental         | provides additional information of a module|
