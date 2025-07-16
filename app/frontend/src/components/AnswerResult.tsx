import React from 'react';

interface AnswerResultProps {
  isCorrect: boolean;
  explanation: string;
  onNext: () => void;
  isLastQuestion: boolean;
}

const AnswerResult: React.FC<AnswerResultProps> = ({
  isCorrect,
  explanation,
  onNext,
  isLastQuestion,
}) => {
  return (
    <div className="text-center">
      {/* 結果表示 */}
      <div className="mb-6">
        <div className="text-8xl mb-4 animate-bounce">
          {isCorrect ? '🎉' : '😔'}
        </div>
        <h3 className={`text-4xl font-bold mb-2 ${isCorrect ? 'text-correct' : 'text-incorrect'}`}>
          {isCorrect ? '正解！' : '不正解'}
        </h3>
        {!isCorrect && (
          <p className="text-xl text-text font-medium">
            正解は「{explanation.split('の')[0]}」でした
          </p>
        )}
      </div>

      {/* 解説 */}
      <div className="mb-8">
        <div className="bg-gray-50 rounded-xl p-6">
          <h4 className="text-lg font-semibold text-gray-700 mb-3">解説</h4>
          <p className="text-text text-lg leading-relaxed">
            {explanation}
          </p>
        </div>
      </div>

      {/* 次へ進むボタン */}
      <button
        onClick={onNext}
        className="bg-primary text-white px-12 py-4 rounded-xl text-xl font-medium hover:bg-blue-600 transition-all transform hover:scale-105 shadow-lg"
      >
        {isLastQuestion ? '🎯 クイズ完了' : '➡️ 次の問題へ'}
      </button>
    </div>
  );
};

export default AnswerResult;