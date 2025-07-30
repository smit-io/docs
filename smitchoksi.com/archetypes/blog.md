---
title: '{{ replace .File.ContentBaseName "-" " " | title }}'
date: {{ .Date }}
authors:
  - name: "{{ with index .Site.Params.author "name" }}{{ . }}{{ else }}Author Name{{ end }}"
    link: "{{ with index .Site.Params.author "link" }}{{ . }}{{ else }}https://example.com{{ end }}"
    image: "{{ with index .Site.Params.author "image" }}{{ . }}{{ else }}/images/default-author.jpg{{ end }}"
tags: []
excludeSearch: {{ .Site.Params.excludeSearch | default false }}
draft: {{ .Site.Params.draft | default true }}
---