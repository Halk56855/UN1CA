#!/usr/bin/env bash

# Safe FM radio files and libraries copy for Galaxy A04
fm_items=(
    "system/system/etc/permissions/privapp-permissions-com.sec.android.app.fm.xml|system"
    "system/system/etc/permissions/signature-permissions-com.sec.android.app.fm.xml|system"
    "system/system/etc/sysconfig/preinstalled-packages-com.sec.android.app.fm.xml|system"
    "system/system/lib64/libfmradio_jni.so|system"
    "system/system/lib64/vendor.qti.hardware.fm-V1-ndk.so|system"
    "system_ext/lib64/fm_helium.so|system_ext"
    "system_ext/lib64/libfm-hci.so|system_ext"
    "system_ext/lib64/vendor.qti.hardware.fm@1.0.so|system_ext"
    "system/system/lib64/android.hardware.bluetooth.audio-V3-ndk.so|system"
    "system/system/lib64/android.hardware.audio.common-V2-ndk.so|system"
    "system/system/lib64/android.media.audio.common.types-V2-ndk.so|system"
)

for item in "${fm_items[@]}"; do
    IFS="|" read -r file partition <<< "$item"
    if [ -f "out/fw/SM-A045F_XID/$file" ]; then
        if [ "$partition" = "system" ]; then
            rel_path="${file#system/}"
            ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "$rel_path" 0 0 755 "u:object_r:system_lib_file:s0"
        elif [ "$partition" = "system_ext" ]; then
            ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "$file" 0 0 755 "u:object_r:system_lib_file:s0"
        fi
    fi
done

# Download FM Radio app with some changes over GET_GALAXY_STORE_DOWNLOAD_URL
GET_GALAXY_STORE_DOWNLOAD_URL_RADIO()
{
    local PACKAGE="com.sec.android.app.fm"
    local DEVICES=("SM-A075F")
    local OS="36"
    local ONEUI="80000"
    local PROTOCOL

    PROTOCOL+="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>"
    PROTOCOL+="<SamsungProtocol networkType=\"0\" openApiVersion=\"$OS\" deviceModel=\"DEVICE\""
    PROTOCOL+=" mcc=\"262\" mnc=\"01\" csc=\"EUX\" version=\"7.7\""
    PROTOCOL+=" deviceFeature=\"locale=en_GB||abi32=armeabi-v7a:armeabi||abi64=arm64-v8a||oneUiVersion=$ONEUI\">"
    PROTOCOL+="<request id=\"2303\" numParam=\"2\">"
    PROTOCOL+="<param name=\"stduk\">0</param>"
    PROTOCOL+="<param name=\"productID\">PRODUCTID</param>"
    PROTOCOL+="</request>"
    PROTOCOL+="</SamsungProtocol>"

    local OUT
    local REQUEST
    for i in "${DEVICES[@]}"; do
        OUT="$(curl -L -s "https://vas.samsungapps.com/stub/stubUpdateCheck.as?appId=$PACKAGE&versionCode=0&deviceId=$i&mcc=262&mnc=01&csc=EUX&sdkVer=$OS&oneUiVersion=$ONEUI&systemId=0")"
        OUT="$(grep -o -P "(?<=<productId>)[^<]+" <<< "$OUT")"
        if [ ! "$OUT" ]; then
            continue
        fi

        REQUEST="$PROTOCOL"
        REQUEST="${REQUEST//DEVICE/$i}"
        REQUEST="${REQUEST//PRODUCTID/$OUT}"

        OUT="$(curl -L -s "https://uk-odc.samsungapps.com/ods.as" -H "Content-Type: text/plain" -d "$REQUEST")"
        OUT="$(grep -o -P "(?<=<value name=\"downLoadURI\">)[^<]+" <<< "$OUT")"
        if [ "$OUT" ]; then
            echo "${OUT//amp;/}"
            return 0
        fi
    done

    LOGE "No download URI found for app \"$PACKAGE\""
    return 1
}

LOG "- Downloading Samsung FM Radio app"
DOWNLOAD_FILE "$(GET_GALAXY_STORE_DOWNLOAD_URL_RADIO)" "$WORK_DIR/system/system/priv-app/HybridRadio/HybridRadio.apk"
SET_METADATA "system" "system/priv-app/HybridRadio" 0 0 755 "u:object_r:system_file:s0"
SET_METADATA "system" "system/priv-app/HybridRadio/HybridRadio.apk" 0 0 644 "u:object_r:system_file:s0"
unset -f GET_GALAXY_STORE_DOWNLOAD_URL_RADIO
