import React, { useRef, useEffect } from 'react';
import type { QuizQuestion } from '../types';
import ImageDisplay from './ImageDisplay';

interface QuizQuestionProps {
  question: QuizQuestion;
  selectedAnswer: string | null;
  showResult: boolean;
}

const QuizQuestionComponent: React.FC<QuizQuestionProps> = ({
  question,
}) => {
  const audioRef = useRef<HTMLAudioElement>(null);

  // 問題が変更されたときに音声を自動再生
  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.currentTime = 0;
      audioRef.current.play().catch(console.error);
    }
  }, [question.id]);

  // 画像クリック時に音声を最初から再生
  const handleImageClick = () => {
    if (audioRef.current) {
      audioRef.current.currentTime = 0;
      audioRef.current.play().catch(console.error);
    }
  };

  return (
    <div className="text-center">
      <div className="mb-6 md:mb-8">
        <h2 className="text-3xl md:text-4xl font-bold text-text mb-6 md:mb-8">
          この画像は何でしょう？
        </h2>
      </div>

      {/* 隠れた音声要素（UIは非表示） */}
      <audio
        ref={audioRef}
        src={question.questionAudioUrl}
        preload="metadata"
        style={{ display: 'none' }}
      />

      {/* 画像表示（クリック可能） - タブレット向け最適化 */}
      <div className="mb-6 md:mb-8 cursor-pointer flex justify-center" onClick={handleImageClick}>
        <div className="relative">
          <ImageDisplay
            imageUrl={question.questionImageUrl}
            alt={`${question.category} クイズ問題`}
            className="max-w-sm md:max-w-md lg:max-w-lg"
          />
          {/* 音声再生のヒント */}
          <div className="absolute -bottom-2 left-1/2 transform -translate-x-1/2 bg-primary text-white px-4 py-2 rounded-full text-sm font-medium shadow-lg">
            🔊 タップで音声再生
          </div>
        </div>
      </div>

      <div className="text-center">
        <p className="text-textSecondary text-lg md:text-xl">
          下の選択肢から正しい答えを選んでください
        </p>
      </div>
    </div>
  );
};

export default QuizQuestionComponent;