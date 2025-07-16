import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';

const Header: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const isHomePage = location.pathname === '/';

  return (
    <header className="bg-card shadow-sm border-b border-border">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <button
              onClick={() => navigate('/')}
              className="text-2xl font-bold text-primary hover:text-blue-600 transition-colors"
            >
              📚 Audio Slide Quiz
            </button>
          </div>

          <nav className="flex items-center space-x-4">
            {!isHomePage && (
              <button
                onClick={() => navigate('/')}
                className="flex items-center space-x-2 text-textSecondary hover:text-text transition-colors"
              >
                <span>←</span>
                <span>カテゴリ選択へ戻る</span>
              </button>
            )}
          </nav>
        </div>
      </div>
    </header>
  );
};

export default Header;