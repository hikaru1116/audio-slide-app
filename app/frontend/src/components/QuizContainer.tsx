import React from 'react';
import type { QuizQuestion } from '../types';
import QuizQuestionComponent from './QuizQuestion';
import ChoiceList from './ChoiceList';
import AnswerResult from './AnswerResult';
import Modal from './Modal';

interface QuizContainerProps {
  question: QuizQuestion;
  selectedAnswer: string | null;
  showResult: boolean;
  onAnswerSelect: (answer: string) => void;
  onNext: () => void;
  isLastQuestion: boolean;
}

const QuizContainer: React.FC<QuizContainerProps> = ({
  question,
  selectedAnswer,
  showResult,
  onAnswerSelect,
  onNext,
  isLastQuestion,
}) => {
  const isCorrect = selectedAnswer === question.correctAnswer;

  const handleModalClose = () => {
    // モーダルはボタンクリックでのみ閉じるため、オーバーレイクリックでは閉じない
    return;
  };

  return (
    <>
      {/* メインクイズ画面 - タブレット向け最適化 */}
      <div className="bg-card rounded-2xl shadow-xl border border-border overflow-hidden slide-enter min-h-[85vh] flex flex-col">
        {/* 問題表示部分 */}
        <div className="flex-1 p-6 md:p-8">
          <QuizQuestionComponent
            question={question}
            selectedAnswer={selectedAnswer}
            showResult={showResult}
          />
        </div>

        {/* 選択肢表示部分 */}
        <div className="p-6 md:p-8 pt-0">
          <ChoiceList
            choices={question.choices}
            selectedAnswer={selectedAnswer}
            correctAnswer={question.correctAnswer}
            onSelect={onAnswerSelect}
            showResult={showResult}
          />
        </div>
      </div>

      {/* 結果表示モーダル */}
      <Modal isOpen={showResult} onClose={handleModalClose}>
        <AnswerResult
          isCorrect={isCorrect}
          explanation={question.explanation}
          onNext={onNext}
          isLastQuestion={isLastQuestion}
        />
      </Modal>
    </>
  );
};

export default QuizContainer;