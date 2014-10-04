ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = SBPSettings
SBPSettings_FILES = SBPSettings.mm
SBPSettings_INSTALL_PATH = /Library/PreferenceBundles
SBPSettings_FRAMEWORKS = UIKit
SBPSettings_PRIVATE_FRAMEWORKS = Preferences
SBPSettings_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SBPSettings.plist$(ECHO_END)
