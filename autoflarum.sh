#!/bin/bash

set -e

# İş öncesi temizlik.
if [[ -d "${1}" ]] ; then
	rm -rf "${1}"
fi

mkdir "${1}"

# Flarum'u getir.
composer create-project flarum/flarum "${1}"

# Public'in altındakileri ana dizine kopyala.
if [[ -d "${1}/public" ]] ; then
	mv -v "${1}/public/"* "${1}"
	rm -rvf "${1}/public"
else
	echo "public dizini bulunamadı, hatalı kurmuş olabilirsiniz."
	exit 1
fi

cat - > "${1}/site.php" <<SITE
<?php

/*
 * This file is part of Flarum.
 *
 * For detailed copyright and license information, please view the
 * LICENSE file that was distributed with this source code.
 */

/*
|-------------------------------------------------------------------------------
| Load the autoloader
|-------------------------------------------------------------------------------
|
| First, let's include the autoloader, which is generated automatically by
| Composer (PHP's package manager) after installing our dependencies.
| From now on, all classes in our dependencies will be usable without
| explicitly loading any files.
|
*/

require __DIR__.'/vendor/autoload.php';

/*
|-------------------------------------------------------------------------------
| Configure the site
|-------------------------------------------------------------------------------
|
| A Flarum site represents your local installation of Flarum. It can be
| configured with a bunch of paths:
|
| - The *base path* is Flarum's root directory and contains important files
|   such as config.php and extend.php.
| - The *public path* is the directory that serves as document root for the
|   web server. Files in this place are accessible to the public internet.
|   This is where assets such as JavaScript files or CSS stylesheets need to
|   be stored in a default install.
| - The *storage path* is a place for Flarum to store files it generates during
|   runtime. This could be caches, session data or other temporary files.
|
| The fully configured site instance is returned to the including script, which
| then uses it to boot up the Flarum application and e.g. accept web requests.
|
*/

return Flarum\Foundation\Site::fromPaths([
    'base' => __DIR__,
    'public' => __DIR__,
    'storage' => __DIR__.'/storage',
]);
SITE

cat - > "${1}/index.php" <<INDEX
<?php

/*
 * This file is part of Flarum.
 *
 * For detailed copyright and license information, please view the
 * LICENSE file that was distributed with this source code.
 */

\$site = require './site.php';

/*
|-------------------------------------------------------------------------------
| Accept incoming HTTP requests
|-------------------------------------------------------------------------------
|
| Every HTTP request pointed to the web server that cannot be served by simply
| responding with one of the files in the "public" directory will be sent to
| this file. Now is the time to boot up Flarum's internal HTTP server, which
| will try its best to interpret the request and return the appropriate
| response, which could be a JSON document (for API responses) or a lot of HTML.
|
*/

\$server = new Flarum\Http\Server(\$site);
\$server->listen();
INDEX

base64 -d - > "${1}/.htaccess" <<HTACCESS
PElmTW9kdWxlIG1vZF9yZXdyaXRlLmM+CiAgUmV3cml0ZUVuZ2luZSBvbgoKICAjIEVuc3VyZSB0
aGUgQXV0aG9yaXphdGlvbiBIVFRQIGhlYWRlciBpcyBhdmFpbGFibGUgdG8gUEhQCiAgUmV3cml0
ZVJ1bGUgLiogLSBbRT1IVFRQX0FVVEhPUklaQVRJT046JXtIVFRQOkF1dGhvcml6YXRpb259XQoK
ICAjIFVuY29tbWVudCB0aGUgZm9sbG93aW5nIGxpbmVzIGlmIHlvdSBhcmUgbm90IHVzaW5nIGEg
YHB1YmxpY2AgZGlyZWN0b3J5CiAgIyB0byBwcmV2ZW50IHNlbnNpdGl2ZSByZXNvdXJjZXMgZnJv
bSBiZWluZyBleHBvc2VkLgogICMgPCEtLSBCRUdJTiBFWFBPU0VEIFJFU09VUkNFUyBQUk9URUNU
SU9OIC0tPgogICMgUmV3cml0ZVJ1bGUgL1wuZ2l0IC8gW0YsTF0KICAjIFJld3JpdGVSdWxlIF5h
dXRoXC5qc29uJCAvIFtGLExdCiAgIyBSZXdyaXRlUnVsZSBeY29tcG9zZXJcLihsb2NrfGpzb24p
JCAvIFtGLExdCiAgIyBSZXdyaXRlUnVsZSBeY29uZmlnLnBocCQgLyBbRixMXQogICMgUmV3cml0
ZVJ1bGUgXmZsYXJ1bSQgLyBbRixMXQogICMgUmV3cml0ZVJ1bGUgXnN0b3JhZ2UvKC4qKT8kIC8g
W0YsTF0KICAjIFJld3JpdGVSdWxlIF52ZW5kb3IvKC4qKT8kIC8gW0YsTF0KICAjIDwhLS0gRU5E
IEVYUE9TRUQgUkVTT1VSQ0VTIFBST1RFQ1RJT04gLS0+CgogICMgUGFzcyByZXF1ZXN0cyB0aGF0
IGRvbid0IHJlZmVyIGRpcmVjdGx5IHRvIGZpbGVzIGluIHRoZSBmaWxlc3lzdGVtIHRvIGluZGV4
LnBocAogIFJld3JpdGVDb25kICV7UkVRVUVTVF9GSUxFTkFNRX0gIS1mCiAgUmV3cml0ZUNvbmQg
JXtSRVFVRVNUX0ZJTEVOQU1FfSAhLWQKICBSZXdyaXRlUnVsZSBeIGluZGV4LnBocCBbUVNBLExd
CjwvSWZNb2R1bGU+CgojIERpc2FibGUgZGlyZWN0b3J5IGxpc3RpbmdzCk9wdGlvbnMgLUluZGV4
ZXMKCiMgTXVsdGlWaWV3cyBjYW4gbWVzcyB1cCBvdXIgcmV3cml0aW5nIHNjaGVtZQpPcHRpb25z
IC1NdWx0aVZpZXdzCgojIFRoZSBmb2xsb3dpbmcgZGlyZWN0aXZlcyBhcmUgYmFzZWQgb24gYmVz
dCBwcmFjdGljZXMgZnJvbSBINUJQIEFwYWNoZSBTZXJ2ZXIgQ29uZmlncwojIGh0dHBzOi8vZ2l0
aHViLmNvbS9oNWJwL3NlcnZlci1jb25maWdzLWFwYWNoZQoKIyBFeHBpcmUgcnVsZXMgZm9yIHN0
YXRpYyBjb250ZW50CjxJZk1vZHVsZSBtb2RfZXhwaXJlcy5jPgogIEV4cGlyZXNBY3RpdmUgb24K
ICBFeHBpcmVzRGVmYXVsdCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImFj
Y2VzcyBwbHVzIDEgbW9udGgiCiAgRXhwaXJlc0J5VHlwZSB0ZXh0L2NzcyAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICJhY2Nlc3MgcGx1cyAxIHllYXIiCiAgRXhwaXJlc0J5VHlwZSBhcHBs
aWNhdGlvbi9hdG9tK3htbCAgICAgICAgICAgICAgICAgICJhY2Nlc3MgcGx1cyAxIGhvdXIiCiAg
RXhwaXJlc0J5VHlwZSBhcHBsaWNhdGlvbi9yZGYreG1sICAgICAgICAgICAgICAgICAgICJhY2Nl
c3MgcGx1cyAxIGhvdXIiCiAgRXhwaXJlc0J5VHlwZSBhcHBsaWNhdGlvbi9yc3MreG1sICAgICAg
ICAgICAgICAgICAgICJhY2Nlc3MgcGx1cyAxIGhvdXIiCiAgRXhwaXJlc0J5VHlwZSBhcHBsaWNh
dGlvbi9qc29uICAgICAgICAgICAgICAgICAgICAgICJhY2Nlc3MgcGx1cyAwIHNlY29uZHMiCiAg
RXhwaXJlc0J5VHlwZSBhcHBsaWNhdGlvbi9sZCtqc29uICAgICAgICAgICAgICAgICAgICJhY2Nl
c3MgcGx1cyAwIHNlY29uZHMiCiAgRXhwaXJlc0J5VHlwZSBhcHBsaWNhdGlvbi9zY2hlbWEranNv
biAgICAgICAgICAgICAgICJhY2Nlc3MgcGx1cyAwIHNlY29uZHMiCiAgRXhwaXJlc0J5VHlwZSBh
cHBsaWNhdGlvbi92bmQuZ2VvK2pzb24gICAgICAgICAgICAgICJhY2Nlc3MgcGx1cyAwIHNlY29u
ZHMiCiAgRXhwaXJlc0J5VHlwZSBhcHBsaWNhdGlvbi92bmQuYXBpK2pzb24gICAgICAgICAgICAg
ICJhY2Nlc3MgcGx1cyAwIHNlY29uZHMiCiAgRXhwaXJlc0J5VHlwZSBhcHBsaWNhdGlvbi94bWwg
ICAgICAgICAgICAgICAgICAgICAgICJhY2Nlc3MgcGx1cyAwIHNlY29uZHMiCiAgRXhwaXJlc0J5
VHlwZSB0ZXh0L2NhbGVuZGFyICAgICAgICAgICAgICAgICAgICAgICAgICJhY2Nlc3MgcGx1cyAw
IHNlY29uZHMiCiAgRXhwaXJlc0J5VHlwZSB0ZXh0L3htbCAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICJhY2Nlc3MgcGx1cyAwIHNlY29uZHMiCiAgRXhwaXJlc0J5VHlwZSBpbWFnZS92bmQu
bWljcm9zb2Z0Lmljb24gICAgICAgICAgICAgICJhY2Nlc3MgcGx1cyAxIHdlZWsiCiAgRXhwaXJl
c0J5VHlwZSBpbWFnZS94LWljb24gICAgICAgICAgICAgICAgICAgICAgICAgICJhY2Nlc3MgcGx1
cyAxIHdlZWsiCiAgRXhwaXJlc0J5VHlwZSB0ZXh0L2h0bWwgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICJhY2Nlc3MgcGx1cyAwIHNlY29uZHMiCiAgRXhwaXJlc0J5VHlwZSBhcHBsaWNhdGlv
bi9qYXZhc2NyaXB0ICAgICAgICAgICAgICAgICJhY2Nlc3MgcGx1cyAxIHllYXIiCiAgRXhwaXJl
c0J5VHlwZSBhcHBsaWNhdGlvbi94LWphdmFzY3JpcHQgICAgICAgICAgICAgICJhY2Nlc3MgcGx1
cyAxIHllYXIiCiAgRXhwaXJlc0J5VHlwZSB0ZXh0L2phdmFzY3JpcHQgICAgICAgICAgICAgICAg
ICAgICAgICJhY2Nlc3MgcGx1cyAxIHllYXIiCiAgRXhwaXJlc0J5VHlwZSBhcHBsaWNhdGlvbi9t
YW5pZmVzdCtqc29uICAgICAgICAgICAgICJhY2Nlc3MgcGx1cyAxIHdlZWsiCiAgRXhwaXJlc0J5
VHlwZSBhcHBsaWNhdGlvbi94LXdlYi1hcHAtbWFuaWZlc3QranNvbiAgICJhY2Nlc3MgcGx1cyAw
IHNlY29uZHMiCiAgRXhwaXJlc0J5VHlwZSB0ZXh0L2NhY2hlLW1hbmlmZXN0ICAgICAgICAgICAg
ICAgICAgICJhY2Nlc3MgcGx1cyAwIHNlY29uZHMiCiAgRXhwaXJlc0J5VHlwZSB0ZXh0L21hcmtk
b3duICAgICAgICAgICAgICAgICAgICAgICAgICJhY2Nlc3MgcGx1cyAwIHNlY29uZHMiCiAgRXhw
aXJlc0J5VHlwZSBhdWRpby9vZ2cgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJhY2Nlc3Mg
cGx1cyAxIG1vbnRoIgogIEV4cGlyZXNCeVR5cGUgaW1hZ2UvYm1wICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAiYWNjZXNzIHBsdXMgMSBtb250aCIKICBFeHBpcmVzQnlUeXBlIGltYWdlL2dp
ZiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImFjY2VzcyBwbHVzIDEgbW9udGgiCiAgRXhw
aXJlc0J5VHlwZSBpbWFnZS9qcGVnICAgICAgICAgICAgICAgICAgICAgICAgICAgICJhY2Nlc3Mg
cGx1cyAxIG1vbnRoIgogIEV4cGlyZXNCeVR5cGUgaW1hZ2UvcG5nICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAiYWNjZXNzIHBsdXMgMSBtb250aCIKICBFeHBpcmVzQnlUeXBlIGltYWdlL3N2
Zyt4bWwgICAgICAgICAgICAgICAgICAgICAgICAgImFjY2VzcyBwbHVzIDEgbW9udGgiCiAgRXhw
aXJlc0J5VHlwZSBpbWFnZS93ZWJwICAgICAgICAgICAgICAgICAgICAgICAgICAgICJhY2Nlc3Mg
cGx1cyAxIG1vbnRoIgogIEV4cGlyZXNCeVR5cGUgdmlkZW8vbXA0ICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAiYWNjZXNzIHBsdXMgMSBtb250aCIKICBFeHBpcmVzQnlUeXBlIHZpZGVvL29n
ZyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImFjY2VzcyBwbHVzIDEgbW9udGgiCiAgRXhw
aXJlc0J5VHlwZSB2aWRlby93ZWJtICAgICAgICAgICAgICAgICAgICAgICAgICAgICJhY2Nlc3Mg
cGx1cyAxIG1vbnRoIgogIEV4cGlyZXNCeVR5cGUgYXBwbGljYXRpb24vd2FzbSAgICAgICAgICAg
ICAgICAgICAgICAiYWNjZXNzIHBsdXMgMSB5ZWFyIgogIEV4cGlyZXNCeVR5cGUgZm9udC9jb2xs
ZWN0aW9uICAgICAgICAgICAgICAgICAgICAgICAiYWNjZXNzIHBsdXMgMSBtb250aCIKICBFeHBp
cmVzQnlUeXBlIGFwcGxpY2F0aW9uL3ZuZC5tcy1mb250b2JqZWN0ICAgICAgICAgImFjY2VzcyBw
bHVzIDEgbW9udGgiCiAgRXhwaXJlc0J5VHlwZSBmb250L2VvdCAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICJhY2Nlc3MgcGx1cyAxIG1vbnRoIgogIEV4cGlyZXNCeVR5cGUgZm9udC9vcGVu
dHlwZSAgICAgICAgICAgICAgICAgICAgICAgICAiYWNjZXNzIHBsdXMgMSBtb250aCIKICBFeHBp
cmVzQnlUeXBlIGZvbnQvb3RmICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImFjY2VzcyBw
bHVzIDEgbW9udGgiCiAgRXhwaXJlc0J5VHlwZSBhcHBsaWNhdGlvbi94LWZvbnQtdHRmICAgICAg
ICAgICAgICAgICJhY2Nlc3MgcGx1cyAxIG1vbnRoIgogIEV4cGlyZXNCeVR5cGUgZm9udC90dGYg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiYWNjZXNzIHBsdXMgMSBtb250aCIKICBFeHBp
cmVzQnlUeXBlIGFwcGxpY2F0aW9uL2ZvbnQtd29mZiAgICAgICAgICAgICAgICAgImFjY2VzcyBw
bHVzIDEgbW9udGgiCiAgRXhwaXJlc0J5VHlwZSBhcHBsaWNhdGlvbi94LWZvbnQtd29mZiAgICAg
ICAgICAgICAgICJhY2Nlc3MgcGx1cyAxIG1vbnRoIgogIEV4cGlyZXNCeVR5cGUgZm9udC93b2Zm
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiYWNjZXNzIHBsdXMgMSBtb250aCIKICBFeHBp
cmVzQnlUeXBlIGFwcGxpY2F0aW9uL2ZvbnQtd29mZjIgICAgICAgICAgICAgICAgImFjY2VzcyBw
bHVzIDEgbW9udGgiCiAgRXhwaXJlc0J5VHlwZSBmb250L3dvZmYyICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICJhY2Nlc3MgcGx1cyAxIG1vbnRoIgogIEV4cGlyZXNCeVR5cGUgdGV4dC94LWNy
b3NzLWRvbWFpbi1wb2xpY3kgICAgICAgICAgICAiYWNjZXNzIHBsdXMgMSB3ZWVrIgo8L0lmTW9k
dWxlPgoKIyBHemlwIGNvbXByZXNzaW9uCjxJZk1vZHVsZSBtb2RfZGVmbGF0ZS5jPgogIDxJZk1v
ZHVsZSBtb2RfZmlsdGVyLmM+CiAgICBBZGRPdXRwdXRGaWx0ZXJCeVR5cGUgREVGTEFURSAiYXBw
bGljYXRpb24vYXRvbSt4bWwiIFwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJh
cHBsaWNhdGlvbi9qYXZhc2NyaXB0IiBcCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAiYXBwbGljYXRpb24vanNvbiIgXAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ImFwcGxpY2F0aW9uL2xkK2pzb24iIFwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICJhcHBsaWNhdGlvbi9tYW5pZmVzdCtqc29uIiBcCiAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAiYXBwbGljYXRpb24vcmRmK3htbCIgXAogICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgImFwcGxpY2F0aW9uL3Jzcyt4bWwiIFwKICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICJhcHBsaWNhdGlvbi9zY2hlbWEranNvbiIgXAogICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgImFwcGxpY2F0aW9uL3ZuZC5nZW8ranNvbiIgXAogICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgImFwcGxpY2F0aW9uL3ZuZC5tcy1mb250b2JqZWN0IiBcCiAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiYXBwbGljYXRpb24vd2FzbSIgXAogICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImFwcGxpY2F0aW9uL3gtZm9udC10dGYiIFwK
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJhcHBsaWNhdGlvbi94LWphdmFzY3Jp
cHQiIFwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJhcHBsaWNhdGlvbi94LXdl
Yi1hcHAtbWFuaWZlc3QranNvbiIgXAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ImFwcGxpY2F0aW9uL3hodG1sK3htbCIgXAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgImFwcGxpY2F0aW9uL3htbCIgXAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ImZvbnQvY29sbGVjdGlvbiIgXAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImZv
bnQvZW90IiBcCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiZm9udC9vcGVudHlw
ZSIgXAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImZvbnQvb3RmIiBcCiAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiZm9udC90dGYiIFwKICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICJpbWFnZS9ibXAiIFwKICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICJpbWFnZS9zdmcreG1sIiBcCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAiaW1hZ2Uvdm5kLm1pY3Jvc29mdC5pY29uIiBcCiAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAiaW1hZ2UveC1pY29uIiBcCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAidGV4dC9jYWNoZS1tYW5pZmVzdCIgXAogICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgInRleHQvY2FsZW5kYXIiIFwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICJ0ZXh0L2NzcyIgXAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInRleHQvaHRt
bCIgXAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInRleHQvamF2YXNjcmlwdCIg
XAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInRleHQvcGxhaW4iIFwKICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ0ZXh0L21hcmtkb3duIiBcCiAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAidGV4dC92Y2FyZCIgXAogICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgInRleHQvdm5kLnJpbS5sb2NhdGlvbi54bG9jIiBcCiAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAidGV4dC92dHQiIFwKICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICJ0ZXh0L3gtY29tcG9uZW50IiBcCiAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAidGV4dC94LWNyb3NzLWRvbWFpbi1wb2xpY3kiIFwKICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICJ0ZXh0L3htbCIKICAgIDwvSWZNb2R1bGU+CjwvSWZNb2R1bGU+
CgojIEZpeCBmb3IgaHR0cHM6Ly9odHRwb3h5Lm9yZyB2dWxuZXJhYmlsaXR5CjxJZk1vZHVsZSBt
b2RfaGVhZGVycy5jPgogIFJlcXVlc3RIZWFkZXIgdW5zZXQgUHJveHkKPC9JZk1vZHVsZT4K
HTACCESS
