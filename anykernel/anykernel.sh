### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
properties() { '
kernel.string=Fyreflies are such magical creatures, aren\x27t?
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=alioth
device.name2=aliothin
device.name3=
device.name4=
'; }

boot_attributes() {
  set_perm_recursive 0 0 750 750 "$RAMDISK"/*;
}

### Boot image configuration
BLOCK=/dev/block/bootdevice/by-name/boot;
IS_SLOT_DEVICE=1;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# Import AnyKernel3 functions and variables.
. tools/ak3-core.sh;

choose_battery_variant() {
  local key variant;
  variant=original;

  ui_print " ";
  ui_print "Select battery profile:";
  ui_print "Volume Up: Original battery (4520mAh)";
  ui_print "Volume Down: Apollo battery (5000mAh)";
  ui_print "Waiting 10 seconds...";

  if [ -x "$BIN/busybox" ]; then
    key=$("$BIN/busybox" timeout 10 getevent -ql 2>/dev/null | grep -m1 -E 'KEY_VOLUMEUP|KEY_VOLUMEDOWN' || true);
  else
    key=$(timeout 10 getevent -ql 2>/dev/null | grep -m1 -E 'KEY_VOLUMEUP|KEY_VOLUMEDOWN' || true);
  fi;

  case "$key" in
    *KEY_VOLUMEDOWN*) variant=5k ;;
    *KEY_VOLUMEUP*) variant=original ;;
    *)
      case "${ZIPFILE:-}" in
        *j3s*|*J3S*) variant=5k ;;
        *) variant=original ;;
      esac
      ;;
  esac;

  if [ "$variant" = "5k" ]; then
    [ -f 5k/dtb ] || abort "Missing 5k/dtb";
    [ -f 5k/dtbo.img ] || abort "Missing 5k/dtbo.img";
    cp -f 5k/dtb dtb || abort "Unable to select 5k DTB";
    cp -f 5k/dtbo.img dtbo.img || abort "Unable to select 5k DTBO";
    ui_print "Selected Apollo 5000mAh profile.";
  else
    ui_print "Selected Original 4520mAh profile.";
  fi;
}

### Install
choose_battery_variant;

set_perm_recursive 0 0 750 750 "$RAMDISK"/*;

dump_boot;

# Remove stale overlay directory before repacking the boot ramdisk.
[ ! -d "$RAMDISK/overlay" ] || rm -rf "$RAMDISK/overlay";

write_boot;

### vendor_boot
if [ "$IS_SLOT_DEVICE" = "1" ]; then
  BLOCK=/dev/block/bootdevice/by-name/vendor_boot;
  RAMDISK_COMPRESSION=auto;
  PATCH_VBMETA_FLAG=auto;

  reset_ak;
  dump_boot;
  write_boot;
fi;
