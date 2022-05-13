$WorkPath = "."
$TargetExt = "jpg"
$DatafilmJson = "test.json"
#$DatafilmJson = "PEN-Fテスト.json"
#$DatafilmJson = "続き.json"
$exiftool = "C:\exiftoolgui\exiftool.exe"

$targetFiles = Get-ChildItem -Path ( Join-Path $WorkPath ( "*." + $TargetExt ) ) | Sort-Object -Property Name
#$targetFiles | Format-Table

# Olympusのハーフカメラで計算
$focalScale = [ Math ]::Sqrt( [ Math ]::Pow( 36, 2 ) + [ Math ]::Pow( 24, 2 ) ) / [ Math ]::Sqrt( [ Math ]::Pow( 24, 2 ) + [ Math ]::Pow( 18, 2 ) )

$jsonData = ( Get-Content ( Join-Path $WorkPath $DatafilmJson ) -Encoding UTF8 | ConvertFrom-Json )

$exifMake = $jsonData.camera.manufacturer
$exifModel = $jsonData.camera.model
$exifSerial = $jsonData.camera.serial
$exifIso = $jsonData.isoRating

$i = 1
do {
    $contFlag = $false
    foreach ( $frame in $jsonData.frames ) {
        if ( $frame.count -eq $i ) {
            $contFlag = $true

            $existingExif = Invoke-Command -ScriptBlock {
                & $exiftool `
                    "-printFormat", "`"Make: `${Make}, Model: `${Model}, Lens Model: `${LensModel}, Software: `${Software}`"" `
                    "-ignoreMinorErrors", `
                    ( "`"" + $targetFiles[ $i - 1 ].FullName + "`"" )
            }

            $exifLensModel = $frame.lens
            $exifExposureTime = $frame.shutterSpeed.Substring( 0, $frame.shutterSpeed.Length - 1 )
            $exifFNumber = [ Math ]::Round( $frame.aperture, 1, [ MidpointRounding ]::AwayFromZero )
            $exifFocalLength = $frame.focal
            $exifFocalLengthIn35mmFormat = [ Math ]::Round( $frame.focal * $focalScale, [ MidpointRounding ]::AwayFromZero )
            if( $frame.flash -eq "true" ) {
                $exifFlash = "0x1"
            } else {
                $exifFlash = "0x0"
            }
            $exifDateTimeOriginal = $frame.dateCreated.Substring( 0, 19 ).Replace( "-", ":" ).Replace( "T", " " )
            $exifTimeZoneOffset = $frame.dateCreated.Substring( 23, 3 )
            if( 0 -lt $frame.latitude ) {
                $exifGPSLatitude = $frame.latitude
                $exifGPSLatitudeRef = "N"
            } else {
                $exifGPSLatitude = [ Math ]::Abs( $frame.latitude )
                $exifGPSLatitudeRef = "S"
            }
            if( 0 -lt $frame.longitude ) {
                $exifGPSLongitude = $frame.longitude
                $exifGPSLongitudeRef = "E"
            } else {
                $exifGPSLongitude = [ Math ]::Abs( $frame.longitude )
                $exifGPSLongitudeRef = "W"
            }

            Start-Process -FilePath $exiftool -NoNewWindow -Wait -ArgumentList `
                ( "-exif:Make=`"" + $exifMake + "`"" ) `
                , ( "-exif:Model=`"" + $exifModel + "`"" ) `
                , ( "-xmp-Microsoft:CameraSerialNumber=`"" + $exifSerial + "`"" ) `
                , ( "-exif:LensModel=`"" + $exifLensModel + "`"" ) `
                , ( "-xmp-Microsoft:LensModel=`"" + $exifLensModel + "`"" ) `
                , ( "-exif:ExposureTime=" + $exifExposureTime ) `
                , ( "-exif:FNumber=" + $exifFNumber ) `
                , ( "-exif:ISO=" + $exifIso ) `
                , ( "-exif:FocalLength=`"" + $exifFocalLength + "`"" ) `
                , ( "-exif:FocalLengthIn35mmFormat=`"" + $exifFocalLengthIn35mmFormat + " mm`"" ) `
                , "-exif:FileSource=1" `
                , ( "-exif:Flash#=" + $exifFlash ) `
                , ( "-exif:DateTimeOriginal=`"" + $exifDateTimeOriginal + "`"" ) `
                , ( "-exif:TimeZoneOffset=" + $exifTimeZoneOffset ) `
                , ( "-exif:GPSLatitude=" + $exifGPSLatitude ) `
                , ( "-exif:GPSLatitudeRef=" + $exifGPSLatitudeRef ) `
                , ( "-exif:GPSLongitude=" + $exifGPSLongitude ) `
                , ( "-exif:GPSLongitudeRef=" + $exifGPSLongitudeRef ) `
                , ( "-comment=`"[Digitize] " + $existingExif + "`"" ) `
                , ( "`"" + $targetFiles[ $i - 1 ].FullName + "`"" )
        }
    }
    $i++
} while( $contFlag )

Write-Host "end"

