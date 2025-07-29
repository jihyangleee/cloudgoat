# ✅ Lake Formation + Glue + Athena 연결 Terraform 예시
# 이 코드는 다음을 구성합니다:
# - Glue Data Catalog DB(0)
# - Lake Formation에 DB 등록
# - IAM Role (Athena 실행용) (0)
# - Lake Formation 권한 부여
# - Athena Workgroup 생성

# # 1. Glue Catalog Database 생성
resource "aws_glue_catalog_database" "flag_db" {
  name = "cg_flag_db"
  description = "LakeFormation protected database"
}

resource "aws_glue_catalog_database" "logs_db" {
  name = "cg_logs_db"
  description = "LakeFormation protected database"
}

resource "aws_glue_catalog_database" "users_db" {
  name = "cg_users_db"
  description = "LakeFormation protected database"
}



#2. 위에 db를 기준으로 table 생성하기

resource "aws_glue_catalog_table" "flag_table" {
  name          = "flag_table"
  database_name = aws_glue_catalog_database.flag_db.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://cg-athena-bucketstorage/flag/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet-serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "x1"
      type = "string"
    }
  }
}

resource "aws_glue_catalog_table" "logs_table" {
  name          = "logs_table"
  database_name = aws_glue_catalog_database.logs_db.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://cg-athena-bucketstorage/logs/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet-serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "id"
      type = "int"
    }

    columns {
      name = "value"
      type = "string"
    }
  }
}

resource "aws_glue_catalog_table" "users_table" {
  name          = "users_table"
  database_name = aws_glue_catalog_database.users_db.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://cg-athena-bucketstorage/users/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet-serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "id"
      type = "int"
    }

    columns {
      name = "value"
      type = "string"
    }
  }
}

# 3. Athena Workgroup 생성
resource "aws_athena_workgroup" "cg_workgroup" {
  name = "cg-athena-lf-wg"
  configuration {
    result_configuration {
      output_location = "s3://cg-athena-bucketresult/" 
    }
    enforce_workgroup_configuration = true
  }
  tags = {
    Name = "CG Athena LF Workgroup"
  }
}

# 4. Lake Formation 등록 및 권한 부여
resource "aws_lakeformation_resource" "flag_db" {
  arn                      = aws_glue_catalog_database.flag_db.arn
  role_arn                 = aws_iam_role.athena_exec_role.arn
  use_service_linked_role = false
}

resource "aws_lakeformation_resource" "logs_db" {
  arn                      = aws_glue_catalog_database.logs_db.arn
  role_arn                 = aws_iam_role.athena_exec_role.arn
  use_service_linked_role = false
}

resource "aws_lakeformation_resource" "users_db" {
  arn                      = aws_glue_catalog_database.users_db.arn
  role_arn                 = aws_iam_role.athena_exec_role.arn
  use_service_linked_role = false
}
# 이거 전체 db 움직여 지는 게 맞는지 확인하고 테이블과 그 파일들 (s3)와 잘 연결하기
# flag db를 제외하고 나머지 db를 이용한다. 

resource "aws_lakeformation_permissions" "athena_access_flag" {
  principal   = aws_iam_role.ec2_athena_query.arn
  permissions = ["DESCRIBE"]

  database {
    name = aws_glue_catalog_database.flag_db.name
  }
}

resource "aws_lakeformation_permissions" "athena_access_logs" {
  principal   = aws_iam_role.ec2_athena_query.arn
  permissions = ["SELECT"]

  database {
    name = aws_glue_catalog_database.logs_db.name
  }
}

resource "aws_lakeformation_permissions" "athena_access_users" {
  principal   = aws_iam_role.ec2_athena_query.arn
  permissions = ["SELECT"]

  database {
    name = aws_glue_catalog_database.users_db.name
  }
}


# (선택) 테이블 등록 및 권한 부여는 별도 테이블 생성 후 추가
resource "aws_lakeformation_permissions" "athena_access_logs_table" {
  principal   = aws_iam_role.ec2_athena_query.arn
  permissions = ["SELECT"]

  table {
    database_name = aws_glue_catalog_database.logs_db.name
    name          = aws_glue_catalog_table.logs_table.name
  }
}

resource "aws_lakeformation_permissions" "athena_access_users_table" {
  principal   = aws_iam_role.ec2_athena_query.arn
  permissions = ["SELECT"]

  table {
    database_name = aws_glue_catalog_database.users_db.name
    name          = aws_glue_catalog_table.users_table.name
  }
}