# ==================================================
# DynamoDB設定 - Audio Slide App
# ==================================================
# アプリケーションのデータを保存するNoSQLデータベース
# - クイズデータ（カテゴリ、アイテム情報）を保存
# - 高速アクセスとスケーラビリティを提供

# ==================================================
# メインテーブル: Quiz
# ==================================================
# アプリケーションの全データを保存するメインテーブル
# シングルテーブルデザインで複数のエンティティを管理

resource "aws_dynamodb_table" "quiz" {
  name           = var.dynamodb_table_name  # 変数で定義されたテーブル名
  billing_mode   = "PAY_PER_REQUEST"       # オンデマンドモード（使用量に応じた課金）
  hash_key       = "PK"                    # パーティションキー（プライマリキーの一部）
  range_key      = "SK"                    # ソートキー（プライマリキーの一部）

  # ==================================================
  # テーブル属性定義
  # ==================================================
  # DynamoDBでは、キーとインデックスで使用する属性のみ事前定義が必要

  attribute {
    name = "PK"  # Partition Key: データの分散に使用するキー
    type = "S"   # String型
  }

  attribute {
    name = "SK"  # Sort Key: 同一パーティション内でのソート用キー
    type = "S"   # String型
  }

  attribute {
    name = "category"  # カテゴリ名（flags, animals, words等）
    type = "S"         # String型
  }

  attribute {
    name = "id"  # アイテムID（カテゴリ内での一意識別子）
    type = "S"   # String型
  }

  # ==================================================
  # グローバルセカンダリインデックス（GSI）
  # ==================================================
  # カテゴリ別のクエリ性能を向上させるためのインデックス
  # category + id で組み合わせた高速検索を可能にする
  # オンデマンドモードのため、read_capacity/write_capacityは不要

  global_secondary_index {
    name            = "category-id-index"  # GSI名
    hash_key        = "category"          # GSIのパーティションキー
    range_key       = "id"               # GSIのソートキー
    projection_type = "ALL"              # 全属性をインデックスに投影（パフォーマンス優先）
  }

  tags = {
    Name = "${var.project_name}-quiz-table"
  }
}

# # ==================================================
# # Terraform状態ロック用テーブル
# # ==================================================
# # Terraformの同時実行を防ぐためのロック機構
# # 複数のユーザーが同時にterraform applyすることを防止

# resource "aws_dynamodb_table" "terraform_locks" {
#   name           = "audio-slide-app-terraform-locks"  # 固定のテーブル名
#   billing_mode   = "PAY_PER_REQUEST"                  # 使用量ベースの課金（コスト最適化）
#   hash_key       = "LockID"                          # TerraformロックID用キー

#   # TerraformロックID属性定義
#   attribute {
#     name = "LockID"  # Terraformが使用するロック識別子
#     type = "S"       # String型
#   }

#   tags = {
#     Name = "${var.project_name}-terraform-locks"
#   }
# }