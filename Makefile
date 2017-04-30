# ADDITIONAL_OBJCFLAGS = -fobjc-arc

MODULES = jailed
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = pokemongo
DISPLAY_NAME = mitm
BUNDLE_ID = com.niico.pokemongo

pokemongo_FILES = Tweak.xm Location/WCLocation.m
pokemongo_IPA = pokemongo.v0.61.0.ipa
# pokemongo_IPA = PokeGo2.0r-22.ipa

pokemongo_FRAMEWORKS=QuartzCore Security
pokemongo_USE_FISHHOOK=1

# pokemongo_INJECT_DYLIBS=FridaGadget.dylib

include $(THEOS_MAKE_PATH)/tweak.mk
