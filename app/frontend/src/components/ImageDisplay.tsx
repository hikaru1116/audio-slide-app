import React, { useState } from 'react';

interface ImageDisplayProps {
  imageUrl: string;
  alt: string;
  className?: string;
}

const ImageDisplay: React.FC<ImageDisplayProps> = ({ 
  imageUrl, 
  alt, 
  className = '' 
}) => {
  const [isLoaded, setIsLoaded] = useState(false);
  const [hasError, setHasError] = useState(false);

  const handleLoad = () => {
    setIsLoaded(true);
  };

  const handleError = () => {
    setHasError(true);
    setIsLoaded(true);
  };

  return (
    <div className={`relative mx-auto w-full ${className}`} style={{ maxHeight: '400px', aspectRatio: '4/3' }}>
      {!isLoaded && (
        <div className="absolute inset-0 flex items-center justify-center bg-background border border-border rounded-lg">
          <div className="text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-2"></div>
            <p className="text-textSecondary text-sm">読み込み中...</p>
          </div>
        </div>
      )}

      {hasError ? (
        <div className="w-full h-full flex items-center justify-center bg-background border border-border rounded-lg hover:bg-gray-50 transition-colors">
          <div className="text-center">
            <div className="text-6xl mb-2">🖼️</div>
            <p className="text-textSecondary">画像を読み込めませんでした</p>
          </div>
        </div>
      ) : (
        <img
          src={imageUrl}
          alt={alt}
          onLoad={handleLoad}
          onError={handleError}
          className={`w-full h-full object-contain rounded-lg border border-border transition-all duration-300 hover:scale-105 hover:shadow-lg ${
            isLoaded ? 'opacity-100' : 'opacity-0'
          }`}
        />
      )}
    </div>
  );
};

export default ImageDisplay;