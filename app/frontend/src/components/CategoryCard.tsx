import React from 'react';
import type { Category } from '../types';

interface CategoryCardProps {
  category: Category;
  onClick: () => void;
}

const CategoryCard: React.FC<CategoryCardProps> = ({ category, onClick }) => {
  const getDefaultThumbnail = (categoryId: string) => {
    const icons = {
      flags: '🏳️',
      animals: '🦁',
      words: '📝'
    };
    return icons[categoryId as keyof typeof icons] || '📚';
  };

  return (
    <div
      onClick={onClick}
      className="group bg-card rounded-3xl shadow-xl border border-border cursor-pointer transition-all duration-300 hover:shadow-2xl hover:scale-105 hover:border-primary/50 transform active:scale-95"
    >
      <div className="p-8 md:p-12 text-center">
        {/* サムネイル画像またはアイコン */}
        <div className="mb-8">
          <div className="w-32 h-32 md:w-40 md:h-40 mx-auto bg-background rounded-full flex items-center justify-center text-7xl md:text-8xl shadow-inner group-hover:bg-blue-50 transition-colors">
            {getDefaultThumbnail(category.id)}
          </div>
        </div>

        {/* カテゴリ名 */}
        <h3 className="text-3xl md:text-4xl font-bold text-text mb-4 group-hover:text-primary transition-colors">
          {category.name}
        </h3>

        {/* 説明文 */}
        <p className="text-textSecondary text-lg md:text-xl leading-relaxed mb-8">
          {category.description}
        </p>

        {/* 開始ボタン */}
        <div className="bg-primary text-white py-4 px-8 rounded-2xl text-lg md:text-xl font-semibold group-hover:bg-blue-600 transition-all shadow-lg group-hover:shadow-xl">
          🚀 学習を開始
        </div>
      </div>
    </div>
  );
};

export default CategoryCard;