data "aws_iam_policy_document" "utility" {
  statement {
    sid = "1"

    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]

    resources = [
      "arn:aws-us-gov:s3:::${var.pkg_s3_bucket}",
      "arn:aws-us-gov:s3:::${var.pkg_s3_bucket}/*"
    ]
  }


}

resource "aws_iam_role_policy" "utility" {
  name = local.name
  role = aws_iam_role.utility.id
  policy = data.aws_iam_policy_document.utility.json
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "utility" {
  name               = local.name
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  tags = merge({
          "Name"  = local.name
        }, local.tags)
}

resource "aws_iam_instance_profile" "utility" {
  name = local.name
  role = aws_iam_role.utility.name
}