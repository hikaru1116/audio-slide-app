import React, { createContext, useContext, useReducer } from 'react';
import type { ReactNode } from 'react';
import type { AppState, AppAction } from '../types';

// 初期状態
const initialState: AppState = {
  quiz: {
    category: null,
    questions: [],
    currentIndex: 0,
    isLoading: false,
    error: null,
    selectedAnswer: null,
    showResult: false,
    score: 0,
    totalQuestions: 0,
  },
  settings: {
    isAudioAutoPlay: true,
    volume: 0.8,
  },
};

// リデューサー関数
const appReducer = (state: AppState, action: AppAction): AppState => {
  switch (action.type) {
    case 'SET_CATEGORY':
      return {
        ...state,
        quiz: {
          ...state.quiz,
          category: action.payload,
        },
      };

    case 'SET_QUIZ_QUESTIONS':
      return {
        ...state,
        quiz: {
          ...state.quiz,
          questions: action.payload,
          totalQuestions: action.payload.length,
          currentIndex: 0,
          score: 0,
          selectedAnswer: null,
          showResult: false,
        },
      };

    case 'SET_CURRENT_INDEX':
      return {
        ...state,
        quiz: {
          ...state.quiz,
          currentIndex: action.payload,
          selectedAnswer: null,
          showResult: false,
        },
      };

    case 'SET_LOADING':
      return {
        ...state,
        quiz: {
          ...state.quiz,
          isLoading: action.payload,
        },
      };

    case 'SET_ERROR':
      return {
        ...state,
        quiz: {
          ...state.quiz,
          error: action.payload,
          isLoading: false,
        },
      };

    case 'SET_SELECTED_ANSWER':
      return {
        ...state,
        quiz: {
          ...state.quiz,
          selectedAnswer: action.payload,
        },
      };

    case 'SET_SHOW_RESULT':
      return {
        ...state,
        quiz: {
          ...state.quiz,
          showResult: action.payload,
        },
      };

    case 'INCREMENT_SCORE':
      return {
        ...state,
        quiz: {
          ...state.quiz,
          score: state.quiz.score + 1,
        },
      };

    case 'NEXT_QUESTION':
      return {
        ...state,
        quiz: {
          ...state.quiz,
          currentIndex: state.quiz.currentIndex + 1,
          selectedAnswer: null,
          showResult: false,
        },
      };

    case 'RESET_QUIZ':
      return {
        ...state,
        quiz: {
          ...initialState.quiz,
          category: state.quiz.category,
        },
      };

    case 'TOGGLE_AUTO_PLAY':
      return {
        ...state,
        settings: {
          ...state.settings,
          isAudioAutoPlay: !state.settings.isAudioAutoPlay,
        },
      };

    case 'SET_VOLUME':
      return {
        ...state,
        settings: {
          ...state.settings,
          volume: action.payload,
        },
      };

    default:
      return state;
  }
};

// コンテキスト作成
interface AppContextType {
  state: AppState;
  dispatch: React.Dispatch<AppAction>;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

// プロバイダーコンポーネント
interface AppProviderProps {
  children: ReactNode;
}

export const AppProvider: React.FC<AppProviderProps> = ({ children }) => {
  const [state, dispatch] = useReducer(appReducer, initialState);

  return (
    <AppContext.Provider value={{ state, dispatch }}>
      {children}
    </AppContext.Provider>
  );
};

// カスタムフック
export const useAppContext = () => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useAppContext must be used within an AppProvider');
  }
  return context;
};

export default AppContext;