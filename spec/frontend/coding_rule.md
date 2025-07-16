# フロントエンド コーディング規約

## 基本方針

音声スライド学習アプリのフロントエンドでは、以下の方針に基づいてコードを記述します：

1. **型安全性の確保**: TypeScript を活用し、実行時エラーを防ぐ
2. **コンポーネントの再利用性**: 再利用可能なコンポーネント設計
3. **パフォーマンス最適化**: 不要な再レンダリングを防ぐ
4. **アクセシビリティ**: 誰でも使いやすい UI の実装
5. **一貫性**: 命名規則とコードスタイルの統一

## ディレクトリ構成とファイル配置

アプリケーションのディレクトリ構成は、[arch.md](./arch.md)を参照してください。

## 命名規則

### ファイル・ディレクトリ

- **コンポーネント**: PascalCase + フォルダ構成
  - 例: `components/ui/Button/index.tsx`
- **フック**: camelCase + `use` プレフィックス
  - 例: `hooks/useAudio.ts`
- **ユーティリティ**: camelCase
  - 例: `utils/formatTime.ts`
- **型定義**: camelCase
  - 例: `types/content.ts`

### コンポーネント

- **React コンポーネント**: PascalCase
  - 例: `CategoryCard`, `AudioPlayer`, `SlideNavigation`
- **props インターフェース**: コンポーネント名 + `Props`
  - 例: `CategoryCardProps`, `AudioPlayerProps`

### 変数・関数

- **変数**: camelCase
  - 例: `currentSlide`, `isPlaying`, `audioUrl`
- **関数**: camelCase + 動詞で始める
  - 例: `playAudio()`, `navigateToSlide()`, `fetchContents()`
- **イベントハンドラー**: `handle` + 動詞
  - 例: `handlePlayClick()`, `handleSlideChange()`

### 定数

- **定数**: UPPER_SNAKE_CASE
  - 例: `MAX_SLIDE_COUNT`, `API_BASE_URL`, `AUDIO_FORMATS`
- **enum**: PascalCase
  - 例: `ContentCategory`, `SlideDirection`

## TypeScript 規約

### 型定義

```typescript
// ✅ 良い例
interface ContentItem {
  id: string;
  label: string;
  imageUrl: string;
  audioUrl: string;
  category: ContentCategory;
}

// ❌ 悪い例
interface contentitem {
  id: any;
  label: any;
  imageUrl: any;
  audioUrl: any;
}
```

### Props 定義

```typescript
// ✅ 良い例
interface CategoryCardProps {
  category: ContentCategory;
  onClick: (category: ContentCategory) => void;
  isSelected?: boolean;
}

export const CategoryCard: React.FC<CategoryCardProps> = ({
  category,
  onClick,
  isSelected = false,
}) => {
  // ...
};
```

### 関数の型定義

```typescript
// ✅ 良い例
type AudioPlayHandler = (audioUrl: string) => Promise<void>;

const useAudio = (): {
  play: AudioPlayHandler;
  pause: () => void;
  isPlaying: boolean;
} => {
  // ...
};
```

## React コンポーネント規約

### 関数コンポーネント

```typescript
// ✅ 良い例
interface SlideDisplayProps {
  content: ContentItem;
  onImageLoad?: () => void;
}

export const SlideDisplay: React.FC<SlideDisplayProps> = ({
  content,
  onImageLoad,
}) => {
  return (
    <div className="slide-display">
      <img
        src={content.imageUrl}
        alt={content.label}
        onLoad={onImageLoad}
        className="slide-image"
      />
      <h2 className="slide-title">{content.label}</h2>
    </div>
  );
};
```

### カスタムフック

```typescript
// ✅ 良い例
export const useSlideNavigation = (contents: ContentItem[]) => {
  const [currentIndex, setCurrentIndex] = useState(0);

  const nextSlide = useCallback(() => {
    setCurrentIndex((prev) => (prev + 1) % contents.length);
  }, [contents.length]);

  const prevSlide = useCallback(() => {
    setCurrentIndex((prev) => (prev - 1 + contents.length) % contents.length);
  }, [contents.length]);

  return {
    currentIndex,
    nextSlide,
    prevSlide,
    currentContent: contents[currentIndex],
  };
};
```

### 状態管理

```typescript
// ✅ 良い例 (Zustand)
interface AudioStore {
  isPlaying: boolean;
  currentAudioUrl: string | null;
  setIsPlaying: (playing: boolean) => void;
  setCurrentAudioUrl: (url: string | null) => void;
}

export const useAudioStore = create<AudioStore>((set) => ({
  isPlaying: false,
  currentAudioUrl: null,
  setIsPlaying: (playing) => set({ isPlaying: playing }),
  setCurrentAudioUrl: (url) => set({ currentAudioUrl: url }),
}));
```

## パフォーマンス最適化

### React.memo の使用

```typescript
// ✅ 良い例
export const CategoryCard = React.memo<CategoryCardProps>(
  ({ category, onClick, isSelected }) => {
    return (
      <div
        className={`category-card ${isSelected ? "selected" : ""}`}
        onClick={() => onClick(category)}
      >
        <img src={category.imageUrl} alt={category.name} />
        <span>{category.name}</span>
      </div>
    );
  }
);
```

### useMemo と useCallback

```typescript
// ✅ 良い例
export const LearningSlides: React.FC = () => {
  const [contents, setContents] = useState<ContentItem[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);

  const currentContent = useMemo(() => {
    return contents[currentIndex];
  }, [contents, currentIndex]);

  const handleNextSlide = useCallback(() => {
    setCurrentIndex((prev) => (prev + 1) % contents.length);
  }, [contents.length]);

  return (
    <div>
      <SlideDisplay content={currentContent} />
      <button onClick={handleNextSlide}>次へ</button>
    </div>
  );
};
```

## CSS / スタイリング規約

### Tailwind CSS

```typescript
// ✅ 良い例
export const Button: React.FC<ButtonProps> = ({
  children,
  variant = "primary",
  size = "md",
  onClick,
}) => {
  const baseClasses = "font-medium rounded-lg transition-colors";
  const variantClasses = {
    primary: "bg-blue-600 text-white hover:bg-blue-700",
    secondary: "bg-gray-200 text-gray-900 hover:bg-gray-300",
  };
  const sizeClasses = {
    sm: "px-3 py-1.5 text-sm",
    md: "px-4 py-2 text-base",
    lg: "px-6 py-3 text-lg",
  };

  return (
    <button
      className={`${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]}`}
      onClick={onClick}
    >
      {children}
    </button>
  );
};
```

### CSS Module（オプション）

```typescript
// styles/CategoryCard.module.css
.card {
  @apply bg-white rounded-lg shadow-md p-4 cursor-pointer;
  transition: transform 0.2s ease;
}

.card:hover {
  @apply shadow-lg;
  transform: translateY(-2px);
}

.selected {
  @apply ring-2 ring-blue-500;
}
```

## API 通信規約

### HTTP クライアント

```typescript
// ✅ 良い例
import axios from "axios";

const apiClient = axios.create({
  baseURL: import.meta.env.REACT_APP_API_BASE_URL,
  timeout: 10000,
});

// レスポンスインターセプター
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error("API Error:", error.response?.data || error.message);
    return Promise.reject(error);
  }
);

export const contentApi = {
  getContents: async (
    category: string,
    count: number
  ): Promise<ContentItem[]> => {
    const response = await apiClient.get<ContentItem[]>("/api/contents", {
      params: { category, count },
    });
    return response.data;
  },
};
```

### エラーハンドリング

```typescript
// ✅ 良い例
export const useContentData = (category: string) => {
  const [contents, setContents] = useState<ContentItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchContents = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const data = await contentApi.getContents(category, 10);
      setContents(data);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "データの取得に失敗しました"
      );
    } finally {
      setLoading(false);
    }
  }, [category]);

  return { contents, loading, error, fetchContents };
};
```

## アクセシビリティ

### 基本的なアクセシビリティ

```typescript
// ✅ 良い例
export const AudioPlayer: React.FC<AudioPlayerProps> = ({
  audioUrl,
  isPlaying,
  onPlay,
  onPause,
}) => {
  return (
    <div className="audio-player">
      <button
        onClick={isPlaying ? onPause : onPlay}
        aria-label={isPlaying ? "音声を停止" : "音声を再生"}
        className="play-button"
      >
        {isPlaying ? "⏸️" : "▶️"}
      </button>
      <audio src={audioUrl} aria-label="学習用音声" preload="metadata" />
    </div>
  );
};
```

### キーボードナビゲーション

```typescript
// ✅ 良い例
export const SlideNavigation: React.FC<SlideNavigationProps> = ({
  onNext,
  onPrev,
  currentIndex,
  totalSlides,
}) => {
  const handleKeyDown = useCallback(
    (event: KeyboardEvent) => {
      if (event.key === "ArrowRight") onNext();
      if (event.key === "ArrowLeft") onPrev();
    },
    [onNext, onPrev]
  );

  useEffect(() => {
    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [handleKeyDown]);

  return (
    <div className="slide-navigation">
      <button onClick={onPrev} aria-label="前のスライド">
        ← 前へ
      </button>
      <span aria-live="polite">
        {currentIndex + 1} / {totalSlides}
      </span>
      <button onClick={onNext} aria-label="次のスライド">
        次へ →
      </button>
    </div>
  );
};
```

## エラーハンドリング

### Error Boundary

```typescript
// ✅ 良い例
interface ErrorBoundaryState {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends React.Component<
  React.PropsWithChildren<{}>,
  ErrorBoundaryState
> {
  constructor(props: React.PropsWithChildren<{}>) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error("Error caught by boundary:", error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="error-boundary">
          <h2>申し訳ございません。エラーが発生しました。</h2>
          <button onClick={() => window.location.reload()}>
            ページを再読み込み
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
```

## 環境変数管理

### .env ファイル

```bash
# .env.local
REACT_APP_API_BASE_URL=http://localhost:8080
VITE_APP_NAME=音声スライド学習アプリ
VITE_AUDIO_PRELOAD=metadata
```

### 環境変数の使用

```typescript
// ✅ 良い例
const config = {
  apiBaseUrl: import.meta.env.REACT_APP_API_BASE_URL,
  appName: import.meta.env.VITE_APP_NAME,
  audioPreload: import.meta.env.VITE_AUDIO_PRELOAD || "metadata",
} as const;

export default config;
```

## 開発時のベストプラクティス

1. **ESLint と Prettier** を使用してコードフォーマットを統一
2. **型エラーは必ず解決**してからコミット
3. **console.log** は本番環境に残さない
4. **TODO コメント** は Issue と連携させる
5. **パフォーマンス測定** を定期的に実施
