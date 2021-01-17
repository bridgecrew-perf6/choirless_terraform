resource "aws_elastictranscoder_preset" "rawPreset" {
  container   = "mp4"
  description = "transcoderPreset"
  name        = "choirlessTranscoderPreset"

  audio {
    audio_packing_mode = "SingleTrack"
    bit_rate           = 128
    channels           = 2
    codec              = "AAC"
    sample_rate        = 44100
  }

  audio_codec_options {
    profile = "AAC-LC"
  }

  video {
    bit_rate             = "900"
    codec                = "H.264"
    display_aspect_ratio = "4:3"
    fixed_gop            = "false"
    frame_rate           = "auto"
    max_frame_rate       = "25"
    keyframes_max_dist   = 90
    max_height           = "480"
    max_width            = "640"
    padding_policy       = "NoPad"
    sizing_policy        = "ShrinkToFit"
  }

  video_codec_options = {
    Profile                  = "baseline"
    Level                    = "3"
    MaxReferenceFrames       = 3
    InterlacedMode           = "Progressive"
    ColorSpaceConversionMode = "None"
  }

  thumbnails {
    format         = "png"
    interval       = 120
    max_width      = "640"
    max_height     = "480"
    padding_policy = "NoPad"
    sizing_policy  = "ShrinkToFit"
  }

}

resource "aws_elastictranscoder_pipeline" "rawPipeline" {
  input_bucket = aws_s3_bucket.choirlessRaw.bucket
  name         = "choirlessRawPipeline"
  role         = aws_iam_role.choirlessTranscoderRole.arn

  content_config {
    bucket        = aws_s3_bucket.choirlessConverted.bucket
    storage_class = "Standard"
  }

  thumbnail_config {
    bucket        = aws_s3_bucket.choirlessSnapshot.bucket
    storage_class = "Standard"
  }

}
