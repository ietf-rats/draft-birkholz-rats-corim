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

normative:
  RFC2119:
  RFC8174:
  I-D.ietf-sacm-coswid: coswid

informative:

--- abstract

Abstract

--- middle

# Introduction

Introduction

## Requirements Notation

{::boilerplate bcp14}

{: #mybody}
# Body

Body

# CDDL

See {{-coswid}}.

~~~~ CDDL
<CODE BEGINS>
{::include corim.cddl}
<CODE ENDS>
~~~~

# Privacy Considerations

Privacy Considerations

# Security Considerations

Security Considerations

# IANA Considerations

See Body {{mybody}}.

--- back
