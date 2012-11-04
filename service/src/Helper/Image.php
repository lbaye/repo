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

    public static function saveResizeImageFromBase64($base64Str, $tPath, $mPath, $lPath,
                                                     $thumbWidth,$thumbHeight,
                                                     $mediumWidth,$mediumHeight,
                                                     $largeWidth,$largeHeight)
    {
        $img = imagecreatefromstring(base64_decode($base64Str));

        if ($img != false) {
            self::imageResize($thumbWidth, $thumbHeight, $img,$tPath);
            self::imageResize($mediumWidth, $mediumHeight, $img,$mPath);
            self::imageResize($largeWidth, $largeHeight, $img,$lPath,1);
        }
    }

    public function imageResize($maxWidth, $maxHeight, $image,$filePath,$original=null)
    {
        // Get current dimensions
        $oldWidth = imagesx($image);
        $oldHeight = imagesy($image);

        // Calculate the scaling we need to do to fit the image inside our frame
        $scale = min($maxWidth / $oldWidth, $maxHeight / $oldHeight);

        // Get the new dimensions
        $newWidth = ceil($scale * $oldWidth);
        $newHeight = ceil($scale * $oldHeight);

        // Create new empty image
        $new = imagecreatetruecolor($newWidth, $newHeight);

        // Resize old image into new
        imagecopyresampled($new, $image,
            0, 0, 0, 0,
            $newWidth, $newHeight, $oldWidth, $oldHeight);

        // Catch the imagedata
        imagejpeg($new, $filePath, 100);

        // Destroy resources
        if ($original == 1)
            imagedestroy($image);
        imagedestroy($new);
    }
}