GO_EASY_ON_ME = 1

TARGET = iphone:clang:latest:7.0
ARCHS = armv7 armv7s arm64

THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222
THEOS_PACKAGE_DIR_NAME = deb

include theos/makefiles/common.mk

TWEAK_NAME = SmartBatteryPercentage
SmartBatteryPercentage_FILES = Tweak.xm
SmartBatteryPercentage_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += SBPSettings
include $(THEOS_MAKE_PATH)/aggregate.mk

before-stage::
	find . -name ".DS_Store" -delete
after-install::
	install.exec "killall -9 backboardd"
