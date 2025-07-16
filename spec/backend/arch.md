# コンテンツサービス アプリケーション構造

## ディレクトリ構成

```plaintext
contents-service
├── application  # アプリケーション層
│   └── usecase  # サービスのユースケースを実装
├── cmd  # アプリのエントリーポイントを格納
│   └── api  # API サーバを起動するエントリーポイント
├── common  # 共通ユーティリティ
├── config  # 設定の読み込みロジックを格納
├── domain  # ドメイン層
│   ├── dto  # 取得したデータを定義するモデルを格納
│   ├── model  # ドメインモデル: 主にリポジトリで使用
│   ├── repository  # データを永続化するためのインターフェースを定義
│   └── service  # リポジトリを扱うためのサービスを定義
├── infrastructure  # DB や API などの外部リソースとの通信を行う層 (リポジトリの実装)
│   ├── api  # API との通信を定義
│   └── postgresql  # PostgreSQL との通信を定義
├── interface  # インターフェース層
│   ├── handler  # API のエンドポイントとユースケースを結びつける
│   └── job      # cli のコマンドとユースケースを結びつける
├── mocks # 単体テスト用モック
│   ├── repository
│   ├── service
│   └── usecase
└── spec # 仕様やアーキテクチャに関するドキュメント
```

## アーキテクチャ概要

このアプリケーションはクリーンアーキテクチャの原則に従って構成されています。各レイヤーの責務は以下の通りです：

1. **domain** - ビジネスロジックの中心。ドメインモデルとリポジトリインターフェースを定義
2. **application** - ユースケースを実装し、ドメイン層のロジックを組み合わせて機能を提供
3. **interface** - API ハンドラや CLI コマンドなど、外部とのインターフェースを担当
4. **infrastructure** - DB や API 通信など外部リソースとの連携を実装

## その他

- `app/backend/go.mod` - Go モジュール定義
- `app/backend/Makefile` - ビルド・テスト用タスク
- `app/backend/Dockerfile` - コンテナ定義

## 開発コマンド (実装後)

### バックエンド

```bash
# 開発環境起動
make dev

# ビルド
make build

# テスト実行
make test

# カバレッジ計測
make coverage

# モック生成
make mocks
```
