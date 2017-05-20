# iOS mitm.tweak

Dump all requests to server into a `dump` folder you can access through iTunes.  

To view those dump, you can use https://github.com/pogosandbox/node-pogo-mitm.  
To do so, put all dump into a `ios.dump` folder (each session in a folder named like `mitm.123456789123` (copied from your phone) and run `./import/ios.dump.js`, then use the embed ui to view requests.

To build and install, you'll need https://github.com/kabiroberai/theos-jailed.

To get Frida gadget, use `curl -O https://build.frida.re/frida/ios/lib/FridaGadget.dylib`
