# kodi_downloader

I use KODI to manage all my music.

One of the challenges is if I want to use for my phone or usb, or transfer certain songs based on crtain criteria to other devices.

This script helps me do just that.

You enter your KODI DB Location (Must be MYSQL DB) and the credentials, as well as the SQL Query you want to use, and the script will
extract songs based on that criteria to a specified folder. 
Additionally, since most devices only support mp3, if the song is not mp3, it will use FFMPEG (Not included here - just dl and stick in directory)
to convert the song into mp3 and then delete the copy that is not mp3.
