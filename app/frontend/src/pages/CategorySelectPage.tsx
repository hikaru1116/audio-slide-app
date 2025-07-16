import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAppContext } from '../context/AppContext';
import { getCategories } from '../services/api';
import type { Category } from '../types';
import Header from '../components/Header';
import CategoryCard from '../components/CategoryCard';

const CategorySelectPage: React.FC = () => {
  const navigate = useNavigate();
  const { dispatch } = useAppContext();
  const [categories, setCategories] = useState<Category[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        setIsLoading(true);
        setError(null);
        
        // バックエンド API からカテゴリ一覧を取得
        const fetchedCategories = await getCategories();
        setCategories(fetchedCategories);
      } catch (err) {
        console.error('カテゴリの取得に失敗しました:', err);
        setError(err instanceof Error ? err.message : 'カテゴリの取得に失敗しました。再度お試しください。');
      } finally {
        setIsLoading(false);
      }
    };

    fetchCategories();
  }, []);

  const handleCategorySelect = (category: Category) => {
    dispatch({ type: 'SET_CATEGORY', payload: category.id });
    navigate(`/quiz/${category.id}`);
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background">
        <Header />
        <div className="flex items-center justify-center h-96">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
            <p className="text-textSecondary">カテゴリを読み込み中...</p>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-background">
        <Header />
        <div className="flex items-center justify-center h-96">
          <div className="text-center">
            <div className="text-incorrect text-6xl mb-4">⚠️</div>
            <p className="text-text mb-4">{error}</p>
            <button
              onClick={() => window.location.reload()}
              className="bg-primary text-white px-6 py-2 rounded-lg hover:bg-blue-600 transition-colors"
            >
              再試行
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background flex flex-col">
      <Header />
      
      <main className="flex-1 container mx-auto px-4 py-8 md:py-12 flex flex-col justify-center">
        <div className="text-center mb-12 md:mb-16">
          <h1 className="text-5xl md:text-6xl font-bold text-text mb-6">
            🎯 音声スライド学習
          </h1>
          <p className="text-2xl md:text-3xl text-textSecondary">
            学習したいカテゴリを選択してください
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 md:gap-12 max-w-5xl mx-auto">
          {categories.map((category) => (
            <CategoryCard
              key={category.id}
              category={category}
              onClick={() => handleCategorySelect(category)}
            />
          ))}
        </div>
      </main>
    </div>
  );
};

export default CategorySelectPage;