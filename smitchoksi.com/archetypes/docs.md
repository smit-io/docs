---
linkTitle: '{{ replace .File.ContentBaseName "-" " " | title }}'
title: '{{ replace .File.ContentBaseName "-" " " | title }}'
cascade:
    type: docs
date: {{ .Date }}
weight: 1
prev: /
next: /
draft: {{ .Site.Params.draft | default true }}
---