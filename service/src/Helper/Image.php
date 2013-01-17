<?php

namespace Helper;

/**
 * Helper for image related processing
 */
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
                                                     $thumbWidth, $thumbHeight,
                                                     $mediumWidth, $mediumHeight,
                                                     $largeWidth, $largeHeight)
    {
        $img = imagecreatefromstring(base64_decode($base64Str));

        if (empty($img))
            return false;

        if ($img != false) {
            self::imageResize($thumbWidth, $thumbHeight, $img, $tPath);
            self::imageResize($mediumWidth, $mediumHeight, $img, $mPath);
            self::imageResize($largeWidth, $largeHeight, $img, $lPath, 1);
            return true;
        }
    }

    public function imageResize($maxWidth, $maxHeight, $image, $filePath, $original = null)
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

    public static function saveResizeAvatarFromBase64($base64Str, $fPath, $tPath)
    {
        $img = imagecreatefromstring(base64_decode($base64Str));

        if (empty($img))
            return false;

        if ($img != false) {
            self::imageResize(50, 50, $img, $tPath);
            self::imageResize(100, 100, $img, $fPath);
            return true;
        }
    }

    public static function makeThumbImageForAvatars()
    {

        $thumbImagePath = ROOTDIR . "images/avatar/thumb";
        $avatarFolderPath = ROOTDIR . 'images/avatar';

        // change current directory to avatar folder
        chdir($avatarFolderPath);

        // make a list of avatar images

        $fList = array();

        if ($handle = opendir($avatarFolderPath)) {
            while (false !== ($file = readdir($handle))) {
                if ($file != "." && substr($file, 0, 2) != "._" && $file != ".." && $file != "thumb") {
                    $fList[] = $file;
                }
            }
            closedir($handle);
        }

        // Ensure /avatar/thumb exists

        if (!file_exists($thumbImagePath))
            mkdir($thumbImagePath, 0777, true);

        // save resized avatar images in thumb folder
        self::saveThumbImages($fList, $thumbImagePath);
    }

    private static function saveThumbImages($fList, $thumbImagePath)
    {

        foreach ($fList as $filename) {

            $image_info = getimagesize($filename);
            $image_type = $image_info[2];

            if ($image_type == IMAGETYPE_JPEG) {
                $image = imagecreatefromjpeg($filename);
            } elseif ($image_type == IMAGETYPE_GIF) {
                $image = imagecreatefromgif($filename);
            } elseif ($image_type == IMAGETYPE_PNG) {
                $image = imagecreatefrompng($filename);
            }

            $target_file = $thumbImagePath . "/" . $filename;
            self::imageResize(50, 50, $image, $target_file, 1);
        }
    }

}