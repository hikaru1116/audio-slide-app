import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAppContext } from "../context/AppContext";
import { getQuizQuestions } from "../services/api";
import { useCorrectSound } from "../hooks/useCorrectSound";
import Header from "../components/Header";
import QuizContainer from "../components/QuizContainer";
import ProgressIndicator from "../components/ProgressIndicator";

const QuizPage: React.FC = () => {
  const { category } = useParams<{ category: string }>();
  const navigate = useNavigate();
  const { state, dispatch } = useAppContext();
  const { playCorrectSound } = useCorrectSound();
  const [isInitialized, setIsInitialized] = useState(false);

  const { quiz } = state;
  const {
    questions,
    currentIndex,
    isLoading,
    error,
    selectedAnswer,
    showResult,
    totalQuestions,
  } = quiz;

  useEffect(() => {
    const initializeQuiz = async () => {
      if (!category || isInitialized) return;

      try {
        dispatch({ type: "SET_LOADING", payload: true });
        dispatch({ type: "SET_ERROR", payload: null });
        dispatch({ type: "SET_CATEGORY", payload: category });

        // バックエンド API からクイズ問題を取得
        const fetchedQuestions = await getQuizQuestions(category, 10);

        // 問題が取得できなかった場合の処理
        if (!fetchedQuestions || fetchedQuestions.length === 0) {
          dispatch({
            type: "SET_ERROR",
            payload: `「${category}」カテゴリの問題が見つかりませんでした。他のカテゴリをお試しください。`,
          });
          return;
        }

        dispatch({ type: "SET_QUIZ_QUESTIONS", payload: fetchedQuestions });
        setIsInitialized(true);
      } catch (err) {
        console.error("クイズ問題の取得に失敗しました:", err);
        dispatch({
          type: "SET_ERROR",
          payload:
            err instanceof Error
              ? err.message
              : "クイズ問題の取得に失敗しました。再度お試しください。",
        });
      } finally {
        dispatch({ type: "SET_LOADING", payload: false });
      }
    };

    initializeQuiz();
  }, [category, dispatch, isInitialized]);

  const handleAnswerSelect = (answer: string) => {
    if (showResult || !questions[currentIndex]) return;

    dispatch({ type: "SET_SELECTED_ANSWER", payload: answer });

    // 正解判定
    const isCorrect = answer === questions[currentIndex].correctAnswer;
    if (isCorrect) {
      dispatch({ type: "INCREMENT_SCORE" });
      // 正解時に音声を再生
      playCorrectSound();
    }

    // 結果表示
    dispatch({ type: "SET_SHOW_RESULT", payload: true });
  };

  const handleNext = () => {
    if (currentIndex + 1 < questions.length) {
      dispatch({ type: "NEXT_QUESTION" });
    } else {
      // 最後の問題の場合、結果ページに遷移
      navigate(`/quiz/${category}/results`);
    }
  };

  const currentQuestion = questions[currentIndex];

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background">
        <Header />
        <div className="flex items-center justify-center h-96">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
            <p className="text-textSecondary">クイズ問題を読み込み中...</p>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    const isNoQuestionsError = error.includes("問題が見つかりませんでした");

    return (
      <div className="min-h-screen bg-background">
        <Header />
        <div className="flex items-center justify-center h-96">
          <div className="text-center max-w-md mx-auto px-4">
            <div className="text-6xl mb-4">
              {isNoQuestionsError ? "📝" : "⚠️"}
            </div>
            <p className="text-text mb-6 text-lg leading-relaxed">{error}</p>
            <div className="space-y-3">
              {isNoQuestionsError ? (
                <button
                  onClick={() => navigate("/")}
                  className="w-full bg-primary text-white px-6 py-3 rounded-lg hover:bg-blue-600 transition-colors font-semibold"
                >
                  カテゴリ一覧に戻る
                </button>
              ) : (
                <button
                  onClick={() => window.location.reload()}
                  className="w-full bg-primary text-white px-6 py-3 rounded-lg hover:bg-blue-600 transition-colors font-semibold"
                >
                  再試行
                </button>
              )}
              <button
                onClick={() => navigate("/")}
                className="w-full bg-gray-200 text-gray-700 px-6 py-3 rounded-lg hover:bg-gray-300 transition-colors font-semibold"
              >
                カテゴリ選択に戻る
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // クイズが完了した場合の処理は削除（結果ページに遷移するため）

  if (!currentQuestion) {
    return (
      <div className="min-h-screen bg-background">
        <Header />
        <div className="flex items-center justify-center h-96">
          <div className="text-center max-w-md mx-auto px-4">
            <div className="text-6xl mb-4">📝</div>
            <p className="text-text mb-6 text-lg leading-relaxed">
              現在表示できる問題がありません。
            </p>
            <button
              onClick={() => navigate("/")}
              className="bg-primary text-white px-6 py-3 rounded-lg hover:bg-blue-600 transition-colors font-semibold"
            >
              カテゴリ選択に戻る
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background flex flex-col">
      <Header />

      <main className="flex-1 container mx-auto px-4 py-4 md:py-6 flex flex-col">
        <div className="max-w-6xl mx-auto w-full flex-1 flex flex-col">
          {/* 進捗表示 - コンパクト */}
          <div className="mb-4 md:mb-6">
            <ProgressIndicator
              current={currentIndex + 1}
              total={totalQuestions}
            />
          </div>

          {/* クイズコンテナ - 画面いっぱいに */}
          <div className="flex-1">
            <QuizContainer
              question={currentQuestion}
              selectedAnswer={selectedAnswer}
              showResult={showResult}
              onAnswerSelect={handleAnswerSelect}
              onNext={handleNext}
              isLastQuestion={currentIndex === questions.length - 1}
            />
          </div>
        </div>
      </main>
    </div>
  );
};

export default QuizPage;
