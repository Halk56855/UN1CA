#!/usr/bin/env bash

# Safe camera patch script for Galaxy A04 (skipping missing portrait_data)

# Check and copy portrait_data only if it exists in the source firmware
if [ -e "$TARGET_FIRMWARE/system/system/cameradata/portrait_data" ]; then
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/cameradata/portrait_data" 0 0 755 "u:object_r:system_file:s0"
fi

# Safe JDM camera libraries copy
libs=(
    libBST3DDNS.so libBstStick2D.so libBSTAiScene.so libbst_mosaic.so libBSTBeauty.so
    libglext.so libBSTDocShadowRemove.so libjniBst3ddns.so libBSTDualCamBokeh.so libjniBstAiDoc.so
    libBSTFaceDetction.so libjniBstAiScene.so libBSTFilter.so libjniBstBeauty.so libBSTFoodMode.so
    libjniBstDualBokeh.so libBSTHdrDynamicJni.so libjniBstFilter.so libBSTMultiExpoGainHDR.so libjniBstFoodMode.so
    libBSTSingleAIBokeh.so libjniBstHandDetect.so libjniBstSingleAIDoc.so libjniBstPanorama.so libBSTSpecialEffect.so
    libjniBstSingleBokeh.so libjniBstYuvNight.so libjniBstSticker.so libBstHD.so libjniBstYuvNight.so
)

for lib in "${libs[@]}"; do
    if [ -f "out/fw/SM-A045F_XID/system/system/lib64/$lib" ]; then
        ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/$lib" 0 0 755 "u:object_r:system_lib_file:s0"
    fi
done
