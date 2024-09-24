+++
title = 'IoT'
description = "A"
type = 'docs'
+++


{{< cards >}}
  {{< card link="esp32-temp-over-lan" title="ESP32 Temperature over LAN" >}}
{{< /cards >}}



<br>


{{< cards >}}
  {{ range .Pages }}
    {{< card link="{{ .Permalink }}" title="{{ .Title }}" >}}
  {{ end }}
{{< /cards >}}
