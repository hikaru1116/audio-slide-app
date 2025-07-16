import React from 'react';

interface ProgressIndicatorProps {
  current: number;
  total: number;
}

const ProgressIndicator: React.FC<ProgressIndicatorProps> = ({ current, total }) => {
  const progressPercentage = (current / total) * 100;

  return (
    <div className="mb-8">
      <div className="flex justify-between items-center mb-2">
        <span className="text-textSecondary text-sm">進捗</span>
        <span className="text-text font-medium">
          {current} / {total}
        </span>
      </div>
      
      {/* プログレスバー */}
      <div className="w-full bg-gray-200 rounded-full h-3">
        <div
          className="h-3 bg-primary rounded-full transition-all duration-500 ease-out"
          style={{ width: `${progressPercentage}%` }}
        />
      </div>

      {/* ドット表示 */}
      <div className="flex justify-center mt-4 space-x-2">
        {Array.from({ length: total }, (_, index) => (
          <div
            key={index}
            className={`w-3 h-3 rounded-full transition-colors duration-300 ${
              index < current
                ? 'bg-primary'
                : index === current - 1
                ? 'bg-accent'
                : 'bg-gray-300'
            }`}
          />
        ))}
      </div>
    </div>
  );
};

export default ProgressIndicator;