+++
title = "Downloads"
date = 2018-07-28T08:01:21Z
description = "Downloads"
draft = false
toc = true
categories = ["downloads"]
tags = ["packages", "images"]
+++

{{< code >}}
      <table>
        <tr>
          <th class="col-icon"></th>
          <th class="col-name">
            {{if and (eq .Sort "name") (ne .Order "desc")}}
            <a href="?sort=name&order=desc">Name &#9650;</a>
            {{else if and (eq .Sort "name") (ne .Order "asc")}}
            <a href="?sort=name&order=asc">Name &#9660;</a>
            {{else}}
            <a href="?sort=name&order=asc">Name</a>
            {{end}}
          </th>
          <th class="col-size">
            {{if and (eq .Sort "size") (ne .Order "desc")}}
            <a href="?sort=size&order=desc">Size &#9650;</a>
            {{else if and (eq .Sort "size") (ne .Order "asc")}}
            <a href="?sort=size&order=asc">Size &#9660;</a>
            {{else}}
            <a href="?sort=size&order=asc">Size</a>
            {{end}}
          </th>
          <th class="col-time">
            {{if and (eq .Sort "time") (ne .Order "desc")}}
            <a href="?sort=time&order=desc">Modified &#9650;</a>
            {{else if and (eq .Sort "time") (ne .Order "asc")}}
            <a href="?sort=time&order=asc">Modified &#9660;</a>
            {{else}}
            <a href="?sort=time&order=asc">Modified</a>
            {{end}}
          </th>
        </tr>
      {{if .CanGoUp}}
        <tr>
          <td>
            <svg height="16" width="12" xmlns="http://www.w3.org/2000/svg"><path
 d="M6 2.5l-6 4.5 6 4.5v-3c1.73 0 5.14 0.95 6 4.38 0-4.55-3.06-7.05-6-7.38v-3z"
/></svg>
          </td>
          <td>
            <a href=".." class="up" title="Up one level">..</a>
          </td>
          <td></td>
          <td></td>
        </tr>
      {{end}}
        {{range .Items}}
        <tr class="file">
          <td>
            {{if .IsDir}}<svg height="16" width="14" xmlns="http://www.w3.org/20
00/svg"><path d="M13 4H7v-1c0-0.66-0.31-1-1-1H1c-0.55 0-1 0.45-1 1v10c0 0.55 0.4
5 1 1 1h12c0.55 0 1-0.45 1-1V5c0-0.55-0.45-1-1-1z m-7 0H1v-1h5v1z" /></svg>
            {{else}}<svg height="16" width="12" xmlns="http://www.w3.org/2000/sv
g"><path d="M6 5H2v-1h4v1zM2 8h7v-1H2v1z m0 2h7v-1H2v1z m0 2h7v-1H2v1z m10-7.5v9
.5c0 0.55-0.45 1-1 1H1c-0.55 0-1-0.45-1-1V2c0-0.55 0.45-1 1-1h7.5l3.5 3.5z m-1 0
.5L8 2H1v12h10V5z" /></svg>{{end}}
          </td>
          <td>
            <a href="{{.URL}}" class="name">{{.Name}}</a>
          </td>
          <td>{{if not .IsDir}}{{.HumanSize}}{{end}}</td>
          <td>{{.HumanModTime "02.01.2006 15:04:05"}}</td>
        </tr>
        {{end}}
      </table>
{{< /code >}}

