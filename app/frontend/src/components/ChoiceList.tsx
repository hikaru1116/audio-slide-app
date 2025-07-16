import React, { useMemo } from 'react';
import { shuffleArray } from '../utils/array';

interface ChoiceListProps {
  choices: string[];
  selectedAnswer: string | null;
  correctAnswer: string;
  onSelect: (choice: string) => void;
  showResult: boolean;
}

const ChoiceList: React.FC<ChoiceListProps> = ({
  choices,
  selectedAnswer,
  correctAnswer,
  onSelect,
  showResult,
}) => {
  // 選択肢をランダムにシャッフル（問題が変わった時のみ再計算）
  const shuffledChoices = useMemo(() => {
    return shuffleArray(choices);
  }, [choices]);
  const getChoiceButtonClass = (choice: string) => {
    const baseClass = "w-full p-6 md:p-8 text-center border-3 rounded-2xl font-semibold transition-all duration-300 transform active:scale-95 ";
    
    if (!showResult) {
      // 結果表示前
      if (selectedAnswer === choice) {
        return baseClass + "border-selected bg-blue-100 text-selected shadow-lg scale-105";
      }
      return baseClass + "border-border hover:border-primary hover:bg-blue-50 hover:scale-105 cursor-pointer shadow-md hover:shadow-lg";
    }
    
    // 結果表示後
    if (choice === correctAnswer) {
      return baseClass + "border-correct bg-green-100 text-correct shadow-lg";
    }
    
    if (selectedAnswer === choice && choice !== correctAnswer) {
      return baseClass + "border-incorrect bg-red-100 text-incorrect shadow-lg";
    }
    
    return baseClass + "border-border bg-gray-100 text-disabled cursor-not-allowed opacity-60";
  };

  const getChoiceIcon = (choice: string) => {
    if (!showResult) {
      return selectedAnswer === choice ? "🔵" : "⚪";
    }
    
    if (choice === correctAnswer) {
      return "✅";
    }
    
    if (selectedAnswer === choice && choice !== correctAnswer) {
      return "❌";
    }
    
    return "⚪";
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">
      {shuffledChoices.map((choice) => (
        <button
          key={choice}
          onClick={() => !showResult && onSelect(choice)}
          className={getChoiceButtonClass(choice)}
          disabled={showResult}
        >
          <div className="flex flex-col items-center space-y-3 md:space-y-4">
            <span className="text-4xl md:text-5xl">{getChoiceIcon(choice)}</span>
            <span className="text-xl md:text-2xl leading-relaxed">{choice}</span>
          </div>
        </button>
      ))}
    </div>
  );
};

export default ChoiceList;