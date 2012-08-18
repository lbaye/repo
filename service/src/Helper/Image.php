<?php

namespace Helper;

class Image
{
    public static function saveImageFromBase64($base64Str, $filePath)
    {
        $img = imagecreatefromstring(base64_decode($base64Str));

        if ($img != false) {
            imagejpeg($img, $filePath, 100);
            imagedestroy($img);
        }
    }
}