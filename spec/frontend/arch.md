# フロントエンド アプリケーション構造

## ディレクトリ構成

```plaintext
frontend/
├── public/                    # 静的ファイル
│   ├── index.html
│   └── icons/
├── src/
│   ├── components/           # 再利用可能なコンポーネント
│   │   ├── ui/              # UI基盤コンポーネント
│   │   │   ├── Button/
│   │   │   ├── Card/
│   │   │   └── AudioPlayer/
│   │   ├── layout/          # レイアウトコンポーネント
│   │   │   ├── Header/
│   │   │   ├── Navigation/
│   │   │   └── Container/
│   │   └── common/          # 共通コンポーネント
│   │       ├── LoadingSpinner/
│   │       └── ErrorBoundary/
│   ├── pages/               # ページコンポーネント
│   │   ├── CategorySelection/
│   │   ├── LearningSlides/
│   │   └── NotFound/
│   ├── hooks/               # カスタムフック
│   │   ├── useAudio.ts
│   │   ├── useContentData.ts
│   │   └── useLocalStorage.ts
│   ├── services/            # API通信とビジネスロジック
│   │   ├── api/
│   │   │   ├── contentApi.ts
│   │   │   └── httpClient.ts
│   │   └── audio/
│   │       └── audioService.ts
│   ├── stores/              # 状態管理
│   │   ├── contentStore.ts
│   │   ├── audioStore.ts
│   │   └── uiStore.ts
│   ├── types/               # TypeScript型定義
│   │   ├── api.ts
│   │   ├── content.ts
│   │   └── ui.ts
│   ├── utils/               # ユーティリティ関数
│   │   ├── constants.ts
│   │   ├── helpers.ts
│   │   └── validation.ts
│   ├── styles/              # グローバルスタイル
│   │   ├── globals.css
│   │   └── variables.css
│   ├── App.tsx              # アプリケーションルート
│   ├── main.tsx             # エントリーポイント
│   └── vite-env.d.ts        # Vite型定義
├── tests/                   # テストファイル
│   ├── __mocks__/
│   ├── components/
│   ├── pages/
│   └── utils/
├── package.json
├── tsconfig.json
├── vite.config.ts
└── tailwind.config.js
```

## アーキテクチャ概要

このフロントエンドアプリケーションは、以下の原則に基づいて構成されています：

1. **コンポーネント指向**: 再利用可能なコンポーネントを中心とした設計
2. **関心の分離**: UI、ビジネスロジック、データ管理を明確に分離
3. **型安全性**: TypeScript による静的型チェック
4. **テスト容易性**: 単体テストが容易な設計

## レイヤー構成

### 1. UI Components Layer

- **ui/**: 基本的な UI コンポーネント（Button、Card、AudioPlayer など）
- **layout/**: レイアウト関連コンポーネント
- **common/**: 共通で使用されるコンポーネント

### 2. Pages Layer

- **pages/**: ページ単位のコンポーネント
- ルーティングと画面構成を担当

### 3. Business Logic Layer

- **hooks/**: カスタムフック（ビジネスロジックの再利用）
- **services/**: API 通信とビジネスロジック
- **stores/**: 状態管理

### 4. Data Layer

- **types/**: TypeScript 型定義
- **utils/**: ユーティリティ関数

## 技術スタック

### 主要フレームワーク・ライブラリ

- **React**: UI フレームワーク
- **TypeScript**: 型安全性
- **Vite**: ビルドツール
- **Tailwind CSS**: スタイリング

### 状態管理

- **Zustand**: シンプルな状態管理（推奨）
- または **Context API**: React 標準の状態管理

### HTTP 通信

- **Axios**: HTTP クライアント
- **React Query**: サーバー状態管理（オプション）

### 音声再生

- **HTML5 Audio API**: 音声再生機能
- **Web Audio API**: 高度な音声制御（必要に応じて）

## 主要機能の設計

### 1. カテゴリ選択機能

```typescript
// pages/CategorySelection/index.tsx
export const CategorySelection: React.FC = () => {
  const categories = useCategoryData();

  return (
    <div className="category-grid">
      {categories.map((category) => (
        <CategoryCard key={category.id} category={category} />
      ))}
    </div>
  );
};
```

### 2. 学習スライド機能

```typescript
// pages/LearningSlides/index.tsx
export const LearningSlides: React.FC = () => {
  const { contents, currentIndex, nextSlide, prevSlide } = useSlideNavigation();
  const { play, pause, isPlaying } = useAudio();

  return (
    <div className="slide-container">
      <SlideDisplay content={contents[currentIndex]} />
      <AudioPlayer onPlay={play} onPause={pause} isPlaying={isPlaying} />
      <SlideNavigation onNext={nextSlide} onPrev={prevSlide} />
    </div>
  );
};
```

### 3. 音声再生機能

```typescript
// hooks/useAudio.ts
export const useAudio = () => {
  const [isPlaying, setIsPlaying] = useState(false);
  const audioRef = useRef<HTMLAudioElement>(null);

  const play = useCallback((audioUrl: string) => {
    if (audioRef.current) {
      audioRef.current.src = audioUrl;
      audioRef.current.play();
      setIsPlaying(true);
    }
  }, []);

  return { play, pause, isPlaying };
};
```

## データフロー

```
User Interaction
    ↓
Page Components
    ↓
Custom Hooks (Business Logic)
    ↓
Services (API Communication)
    ↓
Store (State Management)
    ↓
UI Components (Re-render)
```

## パフォーマンス考慮事項

1. **コンポーネント最適化**

   - `React.memo` による不要な再レンダリング防止
   - `useMemo` / `useCallback` による計算結果キャッシュ

2. **リソース最適化**

   - 画像の遅延読み込み
   - 音声ファイルのプリロード
   - コード分割（React.lazy）

3. **状態管理最適化**
   - 適切な状態の粒度
   - 不要な状態の削減

## セキュリティ考慮事項

1. **XSS 対策**

   - ユーザー入力のサニタイズ
   - `dangerouslySetInnerHTML` の使用禁止

2. **API 通信**
   - HTTPS 通信の徹底
   - 適切なエラーハンドリング

## 開発環境設定

### 必要なファイル

- `package.json` - 依存関係とスクリプト定義
- `vite.config.ts` - Vite 設定
- `tsconfig.json` - TypeScript 設定
- `tailwind.config.js` - Tailwind CSS 設定
- `.env` - 環境変数定義

### 開発コマンド

```bash
# 開発サーバー起動
npm run dev

# ビルド
npm run build

# プレビュー
npm run preview

# 型チェック
npm run type-check

# リント
npm run lint

# テスト
npm run test
```

## デプロイ構成

### 本番環境

- **静的ファイル**: S3 + CloudFront
- **API 通信**: バックエンド API（Go/Gin）
- **環境変数**: 本番用設定

### ステージング環境

- **静的ファイル**: S3 + CloudFront
- **API 通信**: ステージング用 API
- **環境変数**: ステージング用設定
