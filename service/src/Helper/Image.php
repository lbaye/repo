<?php

namespace Helper;

class Image
{
    public static function saveImageFromBase64($base64Str, $filePath)
    {
        $path = ROOTDIR . '/images/' . $filePath;
        $img = imagecreatefromstring(base64_decode($base64Str));

        if ($img != false) {
            imagejpeg($img, $path, 100);
            imagedestroy($img);
        }
    }
}