data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# EC2DescribeAutoScalingRole [ec2_describe_asg]
# DescribeEC2AndASGPolicy  

# (1) describe_asg
data "aws_iam_policy_document" "describe_asg" {
  statement {
    sid     = "AllowDescribesBroadly"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "AllowDescribeBasics"
    actions = [
      "ec2:DescribeSecurityGroups"
    ]
    resources = ["*"]
  }
}

# (2) passrole
data "aws_iam_policy_document" "passrole" {
  statement {
    sid       = "AllowPassRole"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.ec2_athena_query.arn]
  }

  statement {
    sid       = "AllowGetInstanceProfile"
    actions   = ["iam:GetInstanceProfile"]
    resources = ["*"]
  }
}

# (3) conditional_run_instance
data "aws_iam_policy_document" "conditional_run_instance" {
  statement {
    sid = "AllowRunInstancesOnlyWithSpecificLT"
    actions = ["ec2:RunInstances"]
    resources = ["*"] # 여기서는 *을 쓰되, Condition으로 제한

    condition {
      test     = "ArnEquals"
      variable = "ec2:LaunchTemplate"
      values   = [aws_launch_template.startEc2.arn]
    }
  }
}


# (4) read_iam_role
data "aws_iam_policy_document" "read_iam_role"{
  statement{
    sid= "AllowReadOnlyOnSpecificRole"
    actions = ["iam:ListAttachedRolePolicies",
              "iam:ListRolePolicies"
    ]
    resources = [
      aws_iam_role.ec2_describe_asg.arn
    ]
  }
  statement{
    sid = "AllowOnlySpecificPolicy"
    actions = ["iam:GetPolicy",
    "iam:GetPolicyVersion"]

    resources = [aws_iam_policy.describe_asg_policy.arn,
    aws_iam_policy.conditional_run_instance_policy.arn
    ]
  }
}


# 역할 (policy랑 attach)
resource "aws_iam_role" "ec2_describe_asg" {
  name               = "cg-ec2-describe-asg-role-${var.cgid}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_policy" "describe_asg_policy" {
  name   = "cg-describe-asg-${var.cgid}"
  policy = data.aws_iam_policy_document.describe_asg.json
}

resource "aws_iam_policy" "passrole_policy" {
  name   = "cg-passrole-${var.cgid}"
  policy = data.aws_iam_policy_document.passrole.json
}

resource "aws_iam_policy" "conditional_run_instance_policy" {
  name   = "cg-conditional-run-instance-${var.cgid}"
  policy = data.aws_iam_policy_document.conditional_run_instance.json
}

resource "aws_iam_policy" "read_iam_role_policy" {
  name  = "cg-read-iam-role-${var.cgid}"
  policy = data.aws_iam_policy_document.read_iam_role.json
}

resource "aws_iam_role_policy_attachment" "describe_asg_attach" {
  role       = aws_iam_role.ec2_describe_asg.name
  policy_arn = aws_iam_policy.describe_asg_policy.arn
}

resource "aws_iam_role_policy_attachment" "passrole_attach" {
  role       = aws_iam_role.ec2_describe_asg.name
  policy_arn = aws_iam_policy.passrole_policy.arn
}
resource "aws_iam_role_policy_attachment" "conditional_run_instance_policy"{
  role = aws_iam_role.ec2_describe_asg.name
  policy_arn = aws_iam_policy.conditional_run_instance_policy.arn
}

resource "aws_iam_role_policy_attachment" "read_iam_role_policy"{
  role = aws_iam_role.ec2_describe_asg.name
  policy_arn = aws_iam_policy.read_iam_role_policy.arn
}


# EC2DescribeAutoScalingRole 
# -> ConditionalRunInstancesPolicy
# -> -> ec2 새로 설치(새로운 .. launchtemplate 지정, ssh 등은 안되게끔)
# -> DescribeEC2AndASGPolicy
# -> -> ec2 describe (subnet, security group), autoscaling, launchtemplate 
# -> EC2PassRolePolicy
# -> -> passrole(딱히 지정하지 말기), getinstanceprofile  
# -> ReadIAMRoleAndPolicyPolicy
# -> -> 정책 확인 가능한 권한들만 넣어둠

#위 역할의 instance profile을 만든다
resource "aws_iam_instance_profile" "ec2_describe_asg_profile" {
  name = "ec2_describe_asg_profile-${var.cgid}"
  role = aws_iam_role.ec2_describe_asg.name
} 


# EC2AthenaQueryRole
#(1) athenas3
data "aws_iam_policy_document" "athena_s3" {
  statement {
    sid = "AthenaQueryAccess"
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetWorkGroup",
      "athena:ListWorkGroups",
      "glue:GetDatabases",
      "glue:GetTables",
      "glue:GetDatabase",
      "glue:GetTable"
    ]
    resources = ["*"]
  }
  
  statement{
    
        sid      = "LakeFormationAccess"
        actions   = [
          "lakeformation:GetDataAccess",
          "lakeformation:ListPermissions"
        ]
        resources = ["*"]
      
  }

                          statement{
    sid = "AthenaWriteResults"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:PutObject"
    ]
      resources = [
    "arn:aws:s3:::cg-${var.cgid}-athena-bucketresult",
    "arn:aws:s3:::cg-${var.cgid}-athena-bucketresult/*"]
  }  

  
}
#(2) RoleRead
data "aws_iam_policy_document" "role_read" {
  statement {
    sid = "AllowReadAccessToRole"
    actions = [
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies"
    ]
    resources = [aws_iam_role.ec2_athena_query.arn]

  }

  statement {
    sid = "AllowReadAccessToPolices"
    actions = [
      
      "iam:GetRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion"
    ]
    resources = [aws_iam_policy.athena_s3_policy.arn
    ]
  }
}


data "aws_iam_policy_document" "read_s3" {
  statement{
    sid = "AthenaReadStorage"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
  "arn:aws:s3:::cg-${var.cgid}-athena-bucketstorage",
  "arn:aws:s3:::cg-${var.cgid}-athena-bucketstorage/*"]
  }
  
 
}

# 역할 policy 랑 attach

resource "aws_iam_role" "ec2_athena_query" {
  name               = "cg-ec2-athena-query-role-${var.cgid}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_policy" "athena_s3_policy" {
  name   = "cg-athena-s3-policy-${var.cgid}"
  policy = data.aws_iam_policy_document.athena_s3.json
}

resource "aws_iam_policy" "role_read_policy" {
  name   = "cg-athena-role-read-policy-${var.cgid}"
  policy = data.aws_iam_policy_document.role_read.json
}

resource "aws_iam_policy" "read_s3_policy" {
  name   = "cg-athena-read-s3-policy-${var.cgid}"
  policy = data.aws_iam_policy_document.read_s3.json
}

resource "aws_iam_role_policy_attachment" "athena_s3_attach" {
  role       = aws_iam_role.ec2_athena_query.name
  policy_arn = aws_iam_policy.athena_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "role_read_attach" {
  role       = aws_iam_role.ec2_athena_query.name
  policy_arn = aws_iam_policy.role_read_policy.arn
}

resource "aws_iam_role_policy_attachment" "read_s3_attach" {
  role       = aws_iam_role.ec2_athena_query.name
  policy_arn = aws_iam_policy.read_s3_policy.arn
}




# EC2AthenaQueryRole
# -> athenas3policy
# -> -> athena, glue, s3
# -> EC2AthenaQueryRoleReadPolicy
# -> -> rolepolicy, policy

# role 완성했고 ,, lakefm(0) athena(권한만 주면될듯) glue(0) s3(0) ec2(asg에서 자동으로 만들어짐) asg(0) launchtemplate(0) iam(0) vpc(0) subnet(0) 

#위 역할의 instance profile을 만든다
resource "aws_iam_instance_profile" "ec2_athena_query_profile" {
  name = "ec2_athena_query_profile-${var.cgid}"
  role = aws_iam_role.ec2_athena_query.name
} 

# 결론적으로 말하면 pem 키를 주어준다 그러면 이를 이용해 특정 ec2에 ssh로 접근하여 들어온다. 
# key.pem 을 이용함.
# 처음에 output에 key를 노출시킴 그것으로 공격자가 ec2에 들어가 임시 자격증명을 통해 해당 role을 확인한다
# 그리고 ec2를 새로 만들어서 할 때는 glue가 해당 s3를 잘 이용하도록 해야함 

# 계속 참조되는 거 잘 확인하기 