import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAppContext } from '../context/AppContext';
import Header from '../components/Header';
import ScoreDisplay from '../components/ScoreDisplay';

const ResultsPage: React.FC = () => {
  const navigate = useNavigate();
  const { category } = useParams<{ category: string }>();
  const { state, dispatch } = useAppContext();

  // クイズ結果がない場合はカテゴリ選択ページにリダイレクト
  if (!state.quiz.category || state.quiz.totalQuestions === 0) {
    navigate('/');
    return null;
  }

  const handleRestart = () => {
    dispatch({ type: 'RESET_QUIZ' });
    if (category) {
      navigate(`/quiz/${category}`);
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />
      
      <main className="container mx-auto px-4 py-8 md:py-12 flex items-center justify-center">
        <ScoreDisplay
          score={state.quiz.score}
          total={state.quiz.totalQuestions}
          onRestart={handleRestart}
          category={state.quiz.category}
        />
      </main>
    </div>
  );
};

export default ResultsPage;