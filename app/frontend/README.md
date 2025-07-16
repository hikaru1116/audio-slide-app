# 音声スライド学習アプリ フロントエンド

このプロジェクトは、React + TypeScript + Viteを使用して構築された音声スライド学習アプリのフロントエンドです。

## 🚀 機能

- **カテゴリ選択**: 国旗、動物、言葉のカテゴリから学習内容を選択
- **クイズ機能**: 画像と音声を使った4択クイズ
- **音声再生**: MP3音声の自動再生・手動再生
- **進捗表示**: リアルタイムの学習進捗表示
- **結果表示**: 正誤判定と解説表示
- **スコア機能**: 正答率の計算と表示
- **レスポンシブデザイン**: モバイル・タブレット・デスクトップ対応

## 🛠️ 技術スタック

- **Frontend Framework**: React 18
- **Language**: TypeScript
- **Build Tool**: Vite 4
- **Styling**: Tailwind CSS 3
- **State Management**: React Context + useReducer
- **Routing**: React Router 6
- **HTTP Client**: Axios
- **Testing**: Vitest + React Testing Library

## 📁 プロジェクト構造

```
src/
├── components/          # 再利用可能なコンポーネント
│   ├── __tests__/      # コンポーネントテスト
│   ├── AudioPlayer.tsx # 音声プレイヤー
│   ├── CategoryCard.tsx # カテゴリカード
│   ├── ChoiceList.tsx  # 選択肢リスト
│   ├── Header.tsx      # ヘッダー
│   ├── ImageDisplay.tsx # 画像表示
│   ├── ProgressIndicator.tsx # 進捗表示
│   ├── QuizContainer.tsx # クイズコンテナ
│   ├── QuizQuestion.tsx # クイズ問題
│   ├── AnswerResult.tsx # 回答結果
│   └── ScoreDisplay.tsx # スコア表示
├── context/            # React Context
│   └── AppContext.tsx  # アプリケーション状態管理
├── hooks/              # カスタムフック
│   └── useAudioPlayer.ts # 音声プレイヤーフック
├── pages/              # ページコンポーネント
│   ├── CategorySelectPage.tsx # カテゴリ選択画面
│   └── QuizPage.tsx    # クイズ画面
├── types/              # TypeScript型定義
│   └── index.ts        # 型定義
├── api/                # API通信
│   └── index.ts        # API関数
└── utils/              # ユーティリティ関数
```

## 🏃‍♂️ 開発環境セットアップ

### 前提条件

- Node.js 18以上
- npm または yarn

### インストール

```bash
# 依存関係のインストール
npm install

# 開発サーバー起動
npm run dev

# ブラウザで http://localhost:3000 を開く
```

### 利用可能なコマンド

```bash
# 開発サーバー起動
npm run dev

# 本番ビルド
npm run build

# ビルド結果のプレビュー
npm run preview

# テスト実行
npm test

# ESLint実行
npm run lint
```

## 🧪 テスト

```bash
# 全テスト実行
npm test

# ウォッチモードでテスト実行
npm run test:watch
```

## 🎨 デザインシステム

### カラーパレット

```javascript
const colors = {
  primary: "#3B82F6",      // Blue-500
  secondary: "#10B981",    // Emerald-500
  accent: "#F59E0B",       // Amber-500
  text: "#1F2937",         // Gray-800
  textSecondary: "#6B7280", // Gray-500
  background: "#F9FAFB",   // Gray-50
  card: "#FFFFFF",         // White
  border: "#E5E7EB",       // Gray-200
  correct: "#10B981",      // Emerald-500 (正解)
  incorrect: "#EF4444",    // Red-500 (不正解)
  selected: "#3B82F6",     // Blue-500 (選択中)
  disabled: "#9CA3AF",     // Gray-400 (無効化)
};
```

### ブレークポイント

```css
sm: 640px   /* スマートフォン */
md: 768px   /* タブレット */
lg: 1024px  /* デスクトップ */
xl: 1280px  /* 大画面 */
```

## 🔧 設定ファイル

### 環境変数

```bash
# .env.development
VITE_API_BASE_URL=http://localhost:8080/api
VITE_AUDIO_PRELOAD=metadata

# .env.production
VITE_API_BASE_URL=https://api.example.com/api
VITE_AUDIO_PRELOAD=none
```

## 📱 レスポンシブデザイン

- **モバイルファースト**: 320px〜からサポート
- **タッチ対応**: タッチデバイスでの操作に最適化
- **アクセシビリティ**: WCAG 2.1 AA準拠

## 🔄 状態管理

React Context + useReducerパターンを使用して以下の状態を管理：

- **クイズ状態**: 問題データ、現在のインデックス、選択された回答
- **UI状態**: ローディング、エラー、結果表示
- **設定**: 音声自動再生、音量

## 🎵 音声機能

- **自動再生**: 問題表示時の自動音声再生
- **手動再生**: 再生/停止ボタンによる制御
- **進捗表示**: 音声の再生時間と進捗バー
- **音量調整**: 音量レベルの調整

## 🚀 本番環境デプロイ

```bash
# 本番ビルド
npm run build

# distフォルダの内容を静的ホスティングサービスにデプロイ
```

このフロントエンド仕様書は、音声スライド学習 Web アプリのクイズ機能を含む要件を満たし、拡張性とメンテナンス性を考慮した設計となっています。
