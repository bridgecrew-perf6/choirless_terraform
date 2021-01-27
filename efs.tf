resource "aws_efs_file_system" "choirlessEFS" {
}

resource "aws_efs_mount_target" "choirlessEFSMount1" {
  file_system_id = aws_efs_file_system.choirlessEFS.id
  subnet_id = aws_subnet.choirlessEFSSubnet1.id
}

resource "aws_efs_mount_target" "choirlessEFSMount2" {
  file_system_id = aws_efs_file_system.choirlessEFS.id
  subnet_id = aws_subnet.choirlessEFSSubnet2.id
}

resource "aws_efs_access_point" "choirlessEFSAP" {
  file_system_id = aws_efs_file_system.choirlessEFS.id
  posix_user {
    gid = 1001
    uid = 1001
  }
  root_directory {
    path = "/lambdatmp"
    creation_info {
      owner_gid = 1001
      owner_uid = 1001
      permissions = 750
    }
  }
}


