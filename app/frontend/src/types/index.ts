// クイズ関連
export interface QuizQuestion {
  id: string;
  questionImageUrl: string;
  questionAudioUrl: string;
  correctAnswer: string;
  choices: string[];
  category: string;
  explanation: string;
}

// カテゴリ関連
export type CategoryType = "flags" | "animals" | "words";

export interface Category {
  id: CategoryType;
  name: string;
  thumbnail: string;
  description: string;
}

// API関連
export interface ApiResponse<T> {
  data: T;
  success: boolean;
  message?: string;
}

// エラー関連
export interface ApiError {
  code: string;
  message: string;
}

// クイズ結果関連
export interface QuizResult {
  isCorrect: boolean;
  selectedAnswer: string;
  correctAnswer: string;
  explanation: string;
}

// スコア関連
export interface ScoreState {
  correct: number;
  total: number;
  percentage: number;
}

// アプリケーション状態
export interface AppState {
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

// アクション型定義
export type AppAction =
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