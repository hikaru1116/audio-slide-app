# フロントエンド仕様書

## 1. 概要

音声スライド学習 Web アプリのフロントエンド仕様書です。React（TypeScript）を使用し、画像・テキスト・音声によるマルチモーダル学習体験を提供します。

---

## 2. API 仕様

### 2.1 バックエンド API 通信

#### エンドポイント

```
GET /api/categories                                 // カテゴリ一覧取得
GET /api/quiz?category={category}&count={count}     // クイズ問題取得
GET /api/quiz/{id}                                  // 個別クイズ問題取得
```

#### カテゴリ一覧取得

**リクエスト**

```
GET /api/categories
```

**レスポンス形式**

```typescript
interface Category {
  id: string;
  name: string;
  description: string;
  thumbnail: string;
}

type CategoriesResponse = Category[];
```

#### クイズ問題取得

**リクエストパラメータ**

| パラメータ | 型     | 必須 | 説明                              |
| ---------- | ------ | ---- | --------------------------------- |
| category   | string | ✓    | カテゴリ（flags, animals, words） |
| count      | number | ✓    | 取得件数（1-50）                  |

**レスポンス形式**

```typescript
interface QuizQuestion {
  id: string;
  questionImageUrl: string;
  questionAudioUrl: string;
  correctAnswer: string;
  choices: string[];
  category: string;
  explanation: string;
}

type QuizResponse = QuizQuestion[];
```

**レスポンス例**

```json
[
  {
    "id": "quiz_flag_001",
    "questionImageUrl": "https://cdn.example.com/flags/italy.svg",
    "questionAudioUrl": "https://cdn.example.com/audio/italy.mp3",
    "correctAnswer": "イタリア",
    "choices": ["イタリア", "フランス", "ドイツ", "スペイン"],
    "category": "flags",
    "explanation": "イタリアの国旗は緑、白、赤の三色旗です。"
  }
]
```

#### エラーハンドリング

```typescript
interface ApiError {
  code: string;
  message: string;
}

// HTTPステータスコード
// 400: リクエストパラメータエラー
// 404: データが見つからない
// 500: サーバーエラー
```

---

## 3. 画面構成とコンポーネント設計

### 3.1 ページ構成

```
/                    - カテゴリ選択画面
/quiz/:category      - クイズ学習画面
```

### 3.2 コンポーネント階層

```
App
├── CategorySelectPage
│   ├── Header
│   ├── CategoryCard[]
│   └── Footer
└── QuizPage
    ├── Header
    ├── QuizContainer
    │   ├── QuizQuestion
    │   │   ├── ImageDisplay
    │   │   └── AudioPlayer
    │   ├── ChoiceList
    │   │   └── ChoiceButton[]
    │   └── AnswerResult
    │       ├── ResultDisplay
    │       └── ExplanationText
    ├── NavigationControls
    └── ProgressIndicator
```

### 3.3 主要コンポーネント仕様

#### CategorySelectPage

```typescript
interface CategorySelectPageProps {}

interface Category {
  id: string; // 'flags' | 'animals' | 'words'
  name: string; // 表示名
  thumbnail: string; // サムネイル画像URL
  description: string; // 説明文
}
```

**機能**

- 3 つのカテゴリカードを表示
- カード選択時にクイズ画面へ遷移
- サムネイル画像付きのカード UI

#### QuizPage

```typescript
interface QuizPageProps {
  category: string;
}

interface QuizPageState {
  questions: QuizQuestion[];
  currentIndex: number;
  isLoading: boolean;
  error: string | null;
  selectedAnswer: string | null;
  showResult: boolean;
  score: number;
}
```

**機能**

- API からクイズ問題を取得
- ランダム順序でクイズを表示
- 選択肢から答えを選択
- 正誤判定と解説表示
- 次の問題へ進む

#### QuizQuestion

```typescript
interface QuizQuestionProps {
  question: QuizQuestion;
  onAnswerSelect: (answer: string) => void;
  selectedAnswer: string | null;
  showResult: boolean;
}
```

**機能**

- 問題の画像・音声を表示
- 選択肢ボタンの表示
- 選択状態の管理

#### ChoiceList

```typescript
interface ChoiceListProps {
  choices: string[];
  selectedAnswer: string | null;
  correctAnswer: string;
  onSelect: (choice: string) => void;
  showResult: boolean;
}
```

**機能**

- 選択肢ボタンの表示
- 選択状態の視覚的表現
- 正解/不正解の色分け表示

#### AnswerResult

```typescript
interface AnswerResultProps {
  isCorrect: boolean;
  explanation: string;
  onNext: () => void;
}
```

**機能**

- 正解/不正解の表示
- 解説文の表示
- 次の問題へ進むボタン

#### QuizContainer

```typescript
interface QuizContainerProps {
  question: QuizQuestion;
  selectedAnswer: string | null;
  showResult: boolean;
  onAnswerSelect: (answer: string) => void;
  onNext: () => void;
}
```

**機能**

- クイズ問題・選択肢・結果を統合表示
- レスポンシブデザイン対応
- 回答状態の管理

#### AudioPlayer

```typescript
interface AudioPlayerProps {
  audioUrl: string;
  autoPlay: boolean;
  onPlayStateChange?: (isPlaying: boolean) => void;
}
```

**機能**

- MP3 音声の再生・停止
- 自動再生/手動再生の切り替え
- 再生状態の管理

#### NavigationControls

```typescript
interface NavigationControlsProps {
  onPrevious: () => void;
  onNext: () => void;
  canGoPrevious: boolean;
  canGoNext: boolean;
}
```

**機能**

- 前へ/次へボタン
- ボタンの有効/無効状態管理

#### ProgressIndicator

```typescript
interface ProgressIndicatorProps {
  current: number;
  total: number;
}
```

**機能**

- 現在の進捗を表示
- ドット形式またはバー形式

---

## 4. 状態管理設計

### 4.1 状態管理方式

React Context + useReducer を使用

### 4.2 グローバル状態

```typescript
interface AppState {
  // クイズ状態
  quiz: {
    category: string | null;
    questions: QuizQuestion[];
    currentIndex: number;
    isLoading: boolean;
    error: string | null;
    selectedAnswer: string | null;
    showResult: boolean;
    score: number;
    totalQuestions: number;
  };

  // 設定状態
  settings: {
    isAudioAutoPlay: boolean;
    volume: number;
  };
}

type AppAction =
  | { type: "SET_CATEGORY"; payload: string }
  | { type: "SET_QUIZ_QUESTIONS"; payload: QuizQuestion[] }
  | { type: "SET_CURRENT_INDEX"; payload: number }
  | { type: "SET_LOADING"; payload: boolean }
  | { type: "SET_ERROR"; payload: string | null }
  | { type: "SET_SELECTED_ANSWER"; payload: string | null }
  | { type: "SET_SHOW_RESULT"; payload: boolean }
  | { type: "INCREMENT_SCORE" }
  | { type: "NEXT_QUESTION" }
  | { type: "RESET_QUIZ" }
  | { type: "TOGGLE_AUTO_PLAY" }
  | { type: "SET_VOLUME"; payload: number };
```

### 4.3 データフロー

```
1. CategorySelectPage → カテゴリ選択
2. QuizPage → クイズAPI呼び出し
3. AppState → クイズ問題保存
4. QuizContainer → 現在の問題表示
5. ChoiceList → 選択肢選択
6. AppState → 回答状態更新
7. AnswerResult → 正誤判定・解説表示
8. NavigationControls → 次の問題へ
9. AppState → インデックス・スコア更新
```

---

## 5. 技術仕様

### 5.1 TypeScript 型定義

```typescript
// クイズ関連
interface QuizQuestion {
  id: string;
  questionImageUrl: string;
  questionAudioUrl: string;
  correctAnswer: string;
  choices: string[];
  category: string;
  explanation: string;
}

// カテゴリ関連
type CategoryType = "flags" | "animals" | "words";

interface Category {
  id: CategoryType;
  name: string;
  thumbnail: string;
  description: string;
}

// API関連
interface ApiResponse<T> {
  data: T;
  success: boolean;
  message?: string;
}

// エラー関連
interface ApiError {
  code: string;
  message: string;
}

// クイズ結果関連
interface QuizResult {
  isCorrect: boolean;
  selectedAnswer: string;
  correctAnswer: string;
  explanation: string;
}

// スコア関連
interface ScoreState {
  correct: number;
  total: number;
  percentage: number;
}
```

### 5.2 音声再生機能

#### 実装方針

```typescript
// カスタムフック
const useAudioPlayer = (audioUrl: string, autoPlay: boolean = false) => {
  const [isPlaying, setIsPlaying] = useState(false);
  const [duration, setDuration] = useState(0);
  const [currentTime, setCurrentTime] = useState(0);
  const audioRef = useRef<HTMLAudioElement>(null);

  const play = () => {
    audioRef.current?.play();
  };

  const pause = () => {
    audioRef.current?.pause();
  };

  const stop = () => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current.currentTime = 0;
    }
  };

  return {
    isPlaying,
    duration,
    currentTime,
    play,
    pause,
    stop,
    audioRef,
  };
};
```

#### 音声プレイヤー UI

- 再生/停止ボタン
- 音量調整スライダー
- 再生時間表示
- 自動再生切り替えトグル

### 5.3 UI/UX ガイドライン

#### デザインシステム

```typescript
// カラーパレット
const colors = {
  primary: "#3B82F6", // Blue-500
  secondary: "#10B981", // Emerald-500
  accent: "#F59E0B", // Amber-500
  text: "#1F2937", // Gray-800
  textSecondary: "#6B7280", // Gray-500
  background: "#F9FAFB", // Gray-50
  card: "#FFFFFF", // White
  border: "#E5E7EB", // Gray-200
  // クイズ専用カラー
  correct: "#10B981", // Emerald-500 (正解)
  incorrect: "#EF4444", // Red-500 (不正解)
  selected: "#3B82F6", // Blue-500 (選択中)
  disabled: "#9CA3AF", // Gray-400 (無効化)
};

// スペーシング
const spacing = {
  xs: "0.25rem", // 4px
  sm: "0.5rem", // 8px
  md: "1rem", // 16px
  lg: "1.5rem", // 24px
  xl: "2rem", // 32px
  xxl: "3rem", // 48px
};

// タイポグラフィ
const typography = {
  h1: "text-3xl font-bold",
  h2: "text-2xl font-semibold",
  h3: "text-xl font-medium",
  body: "text-base",
  caption: "text-sm text-gray-500",
};
```

#### レスポンシブデザイン

```css
/* ブレークポイント */
sm: 640px   /* スマートフォン */
md: 768px   /* タブレット */
lg: 1024px  /* デスクトップ */
xl: 1280px  /* 大画面 */
```

#### アニメーション

```typescript
// スライド遷移
const slideTransition = {
  initial: { opacity: 0, x: 100 },
  animate: { opacity: 1, x: 0 },
  exit: { opacity: 0, x: -100 },
  transition: { duration: 0.3 },
};

// カードホバーエフェクト
const cardHover = {
  scale: 1.05,
  transition: { duration: 0.2 },
};

// クイズ結果アニメーション
const resultAnimation = {
  correct: {
    scale: [1, 1.1, 1],
    backgroundColor: ["#ffffff", "#dcfce7", "#ffffff"],
    transition: { duration: 0.6 },
  },
  incorrect: {
    scale: [1, 1.05, 1],
    backgroundColor: ["#ffffff", "#fef2f2", "#ffffff"],
    transition: { duration: 0.6 },
  },
};
```

### 5.4 アクセシビリティ

#### 対応項目

1. **キーボードナビゲーション**

   - Tab/Shift+Tab でフォーカス移動
   - Enter/Space でボタン操作
   - 矢印キーでスライドナビゲーション

2. **スクリーンリーダー対応**

   - 適切な aria-label 設定
   - 画像に alt 属性追加
   - 音声再生状態の読み上げ

3. **色覚サポート**
   - 色だけに依存しない情報伝達
   - 十分なコントラスト比の確保

```typescript
// アクセシビリティ対応例
<button
  aria-label={isPlaying ? "音声を停止" : "音声を再生"}
  onClick={togglePlay}
  onKeyDown={(e) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      togglePlay();
    }
  }}
>
  {isPlaying ? "⏸️" : "▶️"}
</button>
```

### 5.5 パフォーマンス最適化

#### 実装方針

1. **画像の最適化**

   - 遅延読み込み（Lazy Loading）
   - 適切なサイズでの配信
   - WebP 形式の活用

2. **音声の最適化**

   - preload の適切な設定
   - 音声キャッシュの活用

3. **バンドルサイズ最適化**
   - Code Splitting
   - Tree Shaking
   - 動的 import

```typescript
// 遅延読み込み例
const LazyImage = ({ src, alt, ...props }) => {
  const [isLoaded, setIsLoaded] = useState(false);
  const [isInView, setIsInView] = useState(false);
  const imgRef = useRef<HTMLImageElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsInView(true);
          observer.disconnect();
        }
      },
      { threshold: 0.1 }
    );

    if (imgRef.current) {
      observer.observe(imgRef.current);
    }

    return () => observer.disconnect();
  }, []);

  return (
    <img
      ref={imgRef}
      src={isInView ? src : undefined}
      alt={alt}
      onLoad={() => setIsLoaded(true)}
      className={`transition-opacity duration-300 ${
        isLoaded ? "opacity-100" : "opacity-0"
      }`}
      {...props}
    />
  );
};
```

---

## 6. 開発環境設定

### 6.1 必要なパッケージ

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.8.0",
    "axios": "^1.3.0",
    "tailwindcss": "^3.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "typescript": "^4.9.0",
    "vite": "^4.0.0",
    "@vitejs/plugin-react": "^3.0.0"
  }
}
```

### 6.2 環境変数

```bash
# .env.development
REACT_APP_API_BASE_URL=http://localhost:8080/api
VITE_AUDIO_PRELOAD=metadata

# .env.production
REACT_APP_API_BASE_URL=https://api.example.com/api
VITE_AUDIO_PRELOAD=none
```

---

## 7. テスト仕様

### 7.1 テスト方針

- **Unit Test**: 各コンポーネントの単体テスト
- **Integration Test**: API 通信を含む統合テスト
- **E2E Test**: ユーザーフローのエンドツーエンドテスト

### 7.2 テストツール

```json
{
  "devDependencies": {
    "@testing-library/react": "^13.4.0",
    "@testing-library/jest-dom": "^5.16.0",
    "@testing-library/user-event": "^14.4.0",
    "vitest": "^0.28.0",
    "jsdom": "^21.0.0"
  }
}
```

### 7.3 テストケース例

```typescript
// QuizPage.test.tsx
describe("QuizPage", () => {
  it("should display quiz questions and choices", async () => {
    const mockQuestions = [
      {
        id: "quiz_1",
        questionImageUrl: "image1.jpg",
        questionAudioUrl: "audio1.mp3",
        correctAnswer: "正解",
        choices: ["正解", "不正解1", "不正解2", "不正解3"],
        category: "flags",
        explanation: "説明文",
      },
    ];

    render(<QuizPage category="flags" />);

    await waitFor(() => {
      expect(screen.getByText("正解")).toBeInTheDocument();
      expect(screen.getByText("不正解1")).toBeInTheDocument();
    });
  });

  it("should show result when answer is selected", async () => {
    // テストケース実装
  });
});

// ChoiceList.test.tsx
describe("ChoiceList", () => {
  it("should handle choice selection", async () => {
    const mockOnSelect = jest.fn();
    const choices = ["選択肢1", "選択肢2", "選択肢3"];

    render(
      <ChoiceList
        choices={choices}
        selectedAnswer={null}
        correctAnswer="選択肢1"
        onSelect={mockOnSelect}
        showResult={false}
      />
    );

    await userEvent.click(screen.getByText("選択肢1"));
    expect(mockOnSelect).toHaveBeenCalledWith("選択肢1");
  });
});
```

---

## 8. 今後の拡張性

### 8.1 追加予定機能

1. **学習進捗管理**

   - クイズ結果の保存
   - 正答率の可視化
   - 学習履歴の管理

2. **ユーザー設定**

   - 音声速度調整
   - UI 言語切り替え
   - 難易度設定

3. **クイズ機能強化**

   - タイムアタック機能
   - 復習モード
   - 成績ランキング

4. **オフライン対応**
   - Service Worker 活用
   - キャッシュ戦略

### 8.2 拡張可能な設計

```typescript
// プラグイン形式での機能追加
interface PluginConfig {
  name: string;
  version: string;
  initialize: (app: App) => void;
}

// 新しいカテゴリの追加
interface CategoryPlugin extends PluginConfig {
  category: Category;
  quizLoader: (count: number) => Promise<QuizQuestion[]>;
}

// クイズ機能の拡張
interface QuizPlugin extends PluginConfig {
  quizType: string;
  questionGenerator: (category: string) => Promise<QuizQuestion[]>;
  resultHandler: (result: QuizResult) => void;
}
```

このフロントエンド仕様書は、音声スライド学習 Web アプリのクイズ機能を含む要件を満たし、拡張性とメンテナンス性を考慮した設計となっています。クイズ機能により、ユーザーは画像と音声を使った選択式問題で効果的に学習できます。
