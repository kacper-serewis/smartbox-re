#ifndef SMARTBOX_DEVICE_PATHS_H
#define SMARTBOX_DEVICE_PATHS_H
#ifndef SMARTBOX_ROOT
#define SMARTBOX_ROOT ""
#endif
#define MODE_DIR SMARTBOX_ROOT "/mnt/UDISK/smartbox-mode"
#define MODE_FILE MODE_DIR "/connection-mode"
#define CONTROL_SOCKET SMARTBOX_ROOT "/tmp/smartbox-mirror.sock"
#define STATUS_FILE SMARTBOX_ROOT "/tmp/smartbox-mirror.json"
#define APP_ORIGINAL SMARTBOX_ROOT "/mnt/app/stock/CPAAProxyEx"
#define MODE_BINARY SMARTBOX_ROOT "/mnt/app/bin/smartbox-mode"
#define MODE_WEB SMARTBOX_ROOT "/mnt/app/mode-web"
#define MODE_DRIVER SMARTBOX_ROOT "/mnt/app/bin/smartbox-mode-driver"
#define RECOVERY_LATCH MODE_DIR "/recovery-disabled"
#define BOOT_PENDING MODE_DIR "/boot-pending"
#define MIRROR_LIBRARY SMARTBOX_ROOT "/mnt/app/lib/libsmartbox-mirror.so"
#endif
