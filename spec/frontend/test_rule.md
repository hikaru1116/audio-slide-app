# フロントエンド テストルール

## 基本方針

音声スライド学習アプリのフロントエンドでは、以下の原則に従ってテストを実装します：

1. **ユーザー中心のテスト**: ユーザーの操作に基づいたテストを優先
2. **テストピラミッド**: 単体テスト > 統合テスト > E2Eテストの順で実装
3. **テスト容易性**: テストしやすいコンポーネント設計
4. **テストの可読性**: テストケースの意図が明確に理解できるようにする
5. **継続的品質保証**: CIでの自動テスト実行

## テストカバレッジ

各種テストのカバレッジ目標：
- **単体テスト**: 80%以上
- **統合テスト**: 主要ユーザーフローの網羅
- **E2Eテスト**: クリティカルパスの実装

## テスト環境・ツール

### テストフレームワーク
- **Vitest**: 高速なテスト実行環境
- **React Testing Library**: React コンポーネントのテスト
- **Playwright**: E2E テスト
- **MSW (Mock Service Worker)**: API モッキング

### アサーションライブラリ
- **Vitest**: 組み込みのアサーション
- **@testing-library/jest-dom**: DOM 要素の拡張マッチャー

### 設定ファイル
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/tests/setup.ts'],
    coverage: {
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'src/tests/'],
    },
  },
});
```

## テストファイル配置

```plaintext
src/
├── components/
│   ├── ui/
│   │   ├── Button/
│   │   │   ├── index.tsx
│   │   │   └── Button.test.tsx
│   │   └── AudioPlayer/
│   │       ├── index.tsx
│   │       └── AudioPlayer.test.tsx
│   └── layout/
├── pages/
│   ├── CategorySelection/
│   │   ├── index.tsx
│   │   └── CategorySelection.test.tsx
│   └── LearningSlides/
│       ├── index.tsx
│       └── LearningSlides.test.tsx
├── hooks/
│   ├── useAudio.ts
│   └── useAudio.test.ts
├── services/
│   ├── api/
│   │   ├── contentApi.ts
│   │   └── contentApi.test.ts
└── tests/
    ├── setup.ts
    ├── __mocks__/
    ├── fixtures/
    └── utils/
```

## 単体テスト

### コンポーネントテスト

```typescript
// components/ui/Button/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './index';

describe('Button', () => {
  test('正常にレンダリングされる', () => {
    render(<Button>テストボタン</Button>);
    expect(screen.getByRole('button', { name: 'テストボタン' })).toBeInTheDocument();
  });

  test('クリックイベントが発火する', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>クリック</Button>);
    
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  test('variantプロパティに応じたスタイルが適用される', () => {
    render(<Button variant="secondary">セカンダリボタン</Button>);
    const button = screen.getByRole('button');
    expect(button).toHaveClass('bg-gray-200');
  });

  test('disabled状態の時はクリックできない', () => {
    const handleClick = vi.fn();
    render(<Button disabled onClick={handleClick}>無効ボタン</Button>);
    
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).not.toHaveBeenCalled();
  });
});
```

### カスタムフックテスト

```typescript
// hooks/useAudio.test.ts
import { renderHook, act } from '@testing-library/react';
import { useAudio } from './useAudio';

// HTMLAudioElementのモック
const mockAudio = {
  play: vi.fn().mockResolvedValue(undefined),
  pause: vi.fn(),
  src: '',
  currentTime: 0,
  duration: 0,
  paused: true,
  ended: false,
};

Object.defineProperty(window, 'HTMLAudioElement', {
  writable: true,
  value: vi.fn().mockImplementation(() => mockAudio),
});

describe('useAudio', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  test('初期状態が正しく設定される', () => {
    const { result } = renderHook(() => useAudio());
    
    expect(result.current.isPlaying).toBe(false);
    expect(result.current.currentTime).toBe(0);
    expect(result.current.duration).toBe(0);
  });

  test('音声再生が正しく動作する', async () => {
    const { result } = renderHook(() => useAudio());
    
    await act(async () => {
      await result.current.play('https://example.com/audio.mp3');
    });
    
    expect(mockAudio.play).toHaveBeenCalledTimes(1);
    expect(mockAudio.src).toBe('https://example.com/audio.mp3');
  });

  test('音声停止が正しく動作する', () => {
    const { result } = renderHook(() => useAudio());
    
    act(() => {
      result.current.pause();
    });
    
    expect(mockAudio.pause).toHaveBeenCalledTimes(1);
  });
});
```

### API サービステスト

```typescript
// services/api/contentApi.test.ts
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import { contentApi } from './contentApi';
import { ContentItem } from '../../types/content';

const mockContents: ContentItem[] = [
  {
    id: '1',
    label: 'テスト国旗',
    imageUrl: 'https://example.com/flag.png',
    audioUrl: 'https://example.com/audio.mp3',
    category: 'flags',
  },
];

const server = setupServer(
  http.get('/api/contents', ({ request }) => {
    const url = new URL(request.url);
    const category = url.searchParams.get('category');
    const count = url.searchParams.get('count');
    
    if (category === 'flags' && count === '10') {
      return HttpResponse.json(mockContents);
    }
    
    return HttpResponse.json([], { status: 404 });
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('contentApi', () => {
  test('コンテンツ取得が正常に動作する', async () => {
    const contents = await contentApi.getContents('flags', 10);
    
    expect(contents).toHaveLength(1);
    expect(contents[0]).toEqual(mockContents[0]);
  });

  test('APIエラー時に適切にエラーハンドリングする', async () => {
    server.use(
      http.get('/api/contents', () => {
        return HttpResponse.json(
          { error: 'Internal Server Error' },
          { status: 500 }
        );
      })
    );
    
    await expect(contentApi.getContents('invalid', 10)).rejects.toThrow();
  });
});
```

## 統合テスト

### ページコンポーネントテスト

```typescript
// pages/CategorySelection/CategorySelection.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { CategorySelection } from './index';
import { contentApi } from '../../services/api/contentApi';

// API のモック
vi.mock('../../services/api/contentApi');
const mockContentApi = vi.mocked(contentApi);

const renderWithRouter = (component: React.ReactElement) => {
  return render(<BrowserRouter>{component}</BrowserRouter>);
};

describe('CategorySelection', () => {
  beforeEach(() => {
    mockContentApi.getCategories.mockResolvedValue([
      { id: 'flags', name: '国旗', imageUrl: 'https://example.com/flags.png' },
      { id: 'animals', name: '動物', imageUrl: 'https://example.com/animals.png' },
    ]);
  });

  test('カテゴリ一覧が正常に表示される', async () => {
    renderWithRouter(<CategorySelection />);
    
    await waitFor(() => {
      expect(screen.getByText('国旗')).toBeInTheDocument();
      expect(screen.getByText('動物')).toBeInTheDocument();
    });
  });

  test('カテゴリ選択時にナビゲーションが動作する', async () => {
    const mockNavigate = vi.fn();
    vi.mock('react-router-dom', async () => {
      const actual = await vi.importActual('react-router-dom');
      return {
        ...actual,
        useNavigate: () => mockNavigate,
      };
    });

    renderWithRouter(<CategorySelection />);
    
    await waitFor(() => {
      expect(screen.getByText('国旗')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByText('国旗'));
    expect(mockNavigate).toHaveBeenCalledWith('/learning/flags');
  });

  test('API エラー時にエラーメッセージが表示される', async () => {
    mockContentApi.getCategories.mockRejectedValue(new Error('API Error'));
    
    renderWithRouter(<CategorySelection />);
    
    await waitFor(() => {
      expect(screen.getByText('データの取得に失敗しました')).toBeInTheDocument();
    });
  });
});
```

### ユーザーフローテスト

```typescript
// tests/integration/learningFlow.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { App } from '../../App';
import { contentApi } from '../../services/api/contentApi';

vi.mock('../../services/api/contentApi');
const mockContentApi = vi.mocked(contentApi);

describe('学習フロー統合テスト', () => {
  beforeEach(() => {
    mockContentApi.getCategories.mockResolvedValue([
      { id: 'flags', name: '国旗', imageUrl: 'https://example.com/flags.png' },
    ]);
    
    mockContentApi.getContents.mockResolvedValue([
      {
        id: '1',
        label: 'イタリア',
        imageUrl: 'https://example.com/italy.png',
        audioUrl: 'https://example.com/italy.mp3',
        category: 'flags',
      },
      {
        id: '2',
        label: 'フランス',
        imageUrl: 'https://example.com/france.png',
        audioUrl: 'https://example.com/france.mp3',
        category: 'flags',
      },
    ]);
  });

  test('カテゴリ選択から学習画面への遷移', async () => {
    render(
      <BrowserRouter>
        <App />
      </BrowserRouter>
    );

    // カテゴリ選択画面の表示確認
    await waitFor(() => {
      expect(screen.getByText('国旗')).toBeInTheDocument();
    });

    // カテゴリ選択
    fireEvent.click(screen.getByText('国旗'));

    // 学習画面の表示確認
    await waitFor(() => {
      expect(screen.getByText('イタリア')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: '音声を再生' })).toBeInTheDocument();
    });

    // スライドナビゲーション
    fireEvent.click(screen.getByRole('button', { name: '次のスライド' }));
    
    await waitFor(() => {
      expect(screen.getByText('フランス')).toBeInTheDocument();
    });
  });
});
```

## E2E テスト

### Playwright 設定

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:5173',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
  },
});
```

### E2E テスト実装

```typescript
// tests/e2e/learning-flow.spec.ts
import { test, expect } from '@playwright/test';

test.describe('学習フロー', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('基本的な学習フローが正常に動作する', async ({ page }) => {
    // カテゴリ選択
    await page.click('[data-testid="category-flags"]');
    await expect(page).toHaveURL('/learning/flags');

    // 学習画面の表示確認
    await expect(page.locator('[data-testid="slide-title"]')).toBeVisible();
    await expect(page.locator('[data-testid="slide-image"]')).toBeVisible();
    await expect(page.locator('[data-testid="audio-player"]')).toBeVisible();

    // 音声再生
    await page.click('[data-testid="play-button"]');
    await expect(page.locator('[data-testid="play-button"]')).toHaveAttribute('aria-label', '音声を停止');

    // スライドナビゲーション
    await page.click('[data-testid="next-button"]');
    await expect(page.locator('[data-testid="slide-counter"]')).toContainText('2 / 10');
  });

  test('キーボードナビゲーションが正常に動作する', async ({ page }) => {
    await page.click('[data-testid="category-flags"]');
    await expect(page).toHaveURL('/learning/flags');

    // 右矢印キーで次のスライド
    await page.keyboard.press('ArrowRight');
    await expect(page.locator('[data-testid="slide-counter"]')).toContainText('2 / 10');

    // 左矢印キーで前のスライド
    await page.keyboard.press('ArrowLeft');
    await expect(page.locator('[data-testid="slide-counter"]')).toContainText('1 / 10');
  });

  test('レスポンシブデザインが正常に動作する', async ({ page }) => {
    // モバイル表示
    await page.setViewportSize({ width: 375, height: 667 });
    await page.click('[data-testid="category-flags"]');

    await expect(page.locator('[data-testid="slide-container"]')).toHaveClass(/mobile-layout/);
    await expect(page.locator('[data-testid="navigation-buttons"]')).toBeVisible();
  });
});
```

## アクセシビリティテスト

```typescript
// tests/accessibility/a11y.test.ts
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';
import { CategorySelection } from '../../pages/CategorySelection';

expect.extend(toHaveNoViolations);

describe('アクセシビリティテスト', () => {
  test('CategorySelection にアクセシビリティ違反がない', async () => {
    const { container } = render(<CategorySelection />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  test('音声プレイヤーのアクセシビリティ', async () => {
    const { container } = render(
      <AudioPlayer 
        audioUrl="https://example.com/audio.mp3" 
        isPlaying={false} 
        onPlay={() => {}} 
        onPause={() => {}} 
      />
    );
    
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});
```

## テスト実行とCI設定

### テスト実行コマンド

```bash
# 単体テスト
npm run test

# 単体テスト (watch mode)
npm run test:watch

# カバレッジ付きテスト
npm run test:coverage

# E2E テスト
npm run test:e2e

# E2E テスト (headless)
npm run test:e2e:headless

# 全テスト実行
npm run test:all
```

### GitHub Actions 設定

```yaml
# .github/workflows/test.yml
name: Test
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run unit tests
        run: npm run test:coverage
      
      - name: Run E2E tests
        run: npm run test:e2e:headless
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## テスト作成時のベストプラクティス

1. **AAA パターン**: Arrange（準備）、Act（実行）、Assert（検証）
2. **テストの独立性**: テスト間の依存関係を避ける
3. **意味のあるテスト名**: テストの目的が明確にわかる名前
4. **適切なモック**: 外部依存は適切にモックする
5. **エラーケースのテスト**: 正常系だけでなく異常系もテストする
6. **パフォーマンス考慮**: テスト実行時間を最小限に抑える