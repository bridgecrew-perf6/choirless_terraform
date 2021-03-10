variable "COUCH_URL" {
  description = "URL to access couchdb"
  type        = string
  sensitive  = true
}

variable "tags" {
  description = "Tags for the project"
  type        = map(string)
}

variable "api_methods" {
  default = ["postUserLogin","getUser","postRender", "getChoirSongParts","getUserChoirs"]
#,"deleteChoirSong","deleteChoirSongPart","deleteChoirSongPartName","deleteInvitation","getChoir","getChoirMembers","getChoirSong","getChoirSongPart","getChoirSongParts","getChoirSongs","getInvitation","getInvitationList","getRenderDone","getRender","getUserByEmail","getUserChoirs","getUser","postChoirJoin","postChoir","postChoirSong","postChoirSongPartDownload","postChoirSongPart","postChoirSongPartName","postChoirSongPartUpload","postInvitation","postRender","postUserLogin", "postUser"]
}

variable "bucket_names" {
  default = ["choirless-raw","choirless-snapshot"]
}

variable "mount_path"  {
   description = "Mount path for the EFS system"
   default = "/mnt/tmp"
}
