# resource "aws_s3_bucket_policy" "media_bucket_policy" {
#   bucket = "highly.available.wordpress.media"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": "*",
#             "Action": [
#                 "s3:GetObject",
#                 "s3:GetObjectAcl"
#             ],
#             "Resource": "arn:aws:s3:::highly.available.wordpress.media/*",
#             "Condition": {
#                 "StringLike": {
#                     "aws:Referer": [
#                         "https://*.cloudfront.net/*",
#                         "https://*.cloudfront.com/*"
#                     ]
#                 }
#             }
#         }
#     ]
# }
# EOF
# }
