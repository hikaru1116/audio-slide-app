import React from 'react';
import { useNavigate } from 'react-router-dom';

interface ScoreDisplayProps {
  score: number;
  total: number;
  onRestart: () => void;
  category: string;
}

const ScoreDisplay: React.FC<ScoreDisplayProps> = ({
  score,
  total,
  onRestart,
  category,
}) => {
  const navigate = useNavigate();
  const percentage = Math.round((score / total) * 100);

  const getScoreMessage = () => {
    if (percentage >= 90) return { emoji: '🏆', message: '素晴らしい！完璧です！' };
    if (percentage >= 70) return { emoji: '🎉', message: 'よくできました！' };
    if (percentage >= 50) return { emoji: '👍', message: 'もう少し頑張りましょう！' };
    return { emoji: '💪', message: '次回はもっと頑張りましょう！' };
  };

  const scoreMessage = getScoreMessage();

  const getCategoryName = (categoryId: string) => {
    const categoryNames = {
      flags: '国旗',
      animals: '動物',
      words: '言葉'
    };
    return categoryNames[categoryId as keyof typeof categoryNames] || categoryId;
  };

  return (
    <div className="max-w-2xl mx-auto text-center">
      <div className="bg-card rounded-xl shadow-lg border border-border p-8">
        {/* タイトル */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-text mb-2">
            クイズ完了！
          </h1>
          <p className="text-textSecondary">
            {getCategoryName(category)}クイズの結果
          </p>
        </div>

        {/* スコア表示 */}
        <div className="mb-8">
          <div className="text-8xl mb-4">{scoreMessage.emoji}</div>
          <div className="text-6xl font-bold text-primary mb-4">
            {score} / {total}
          </div>
          <div className="text-2xl font-semibold text-text mb-2">
            正答率: {percentage}%
          </div>
          <p className="text-lg text-textSecondary">
            {scoreMessage.message}
          </p>
        </div>

        {/* 円形プログレス */}
        <div className="mb-8 flex justify-center">
          <div className="relative w-32 h-32">
            <svg className="w-32 h-32 transform -rotate-90" viewBox="0 0 120 120">
              <circle
                cx="60"
                cy="60"
                r="54"
                stroke="#E5E7EB"
                strokeWidth="12"
                fill="transparent"
              />
              <circle
                cx="60"
                cy="60"
                r="54"
                stroke="#3B82F6"
                strokeWidth="12"
                fill="transparent"
                strokeDasharray={`${2 * Math.PI * 54}`}
                strokeDashoffset={`${2 * Math.PI * 54 * (1 - percentage / 100)}`}
                className="transition-all duration-1000 ease-out"
              />
            </svg>
            <div className="absolute inset-0 flex items-center justify-center">
              <span className="text-2xl font-bold text-primary">{percentage}%</span>
            </div>
          </div>
        </div>

        {/* ボタンエリア */}
        <div className="space-y-4">
          <button
            onClick={onRestart}
            className="w-full bg-primary text-white py-3 px-6 rounded-lg font-medium hover:bg-blue-600 transition-colors"
          >
            もう一度挑戦
          </button>
          
          <button
            onClick={() => navigate('/')}
            className="w-full bg-background border border-border text-text py-3 px-6 rounded-lg font-medium hover:bg-gray-50 transition-colors"
          >
            カテゴリ選択へ戻る
          </button>
        </div>
      </div>
    </div>
  );
};

export default ScoreDisplay;