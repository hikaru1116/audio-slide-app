import { render, screen, fireEvent } from '@testing-library/react';
import { vi } from 'vitest';
import CategoryCard from '../CategoryCard';
import type { Category } from '../../types';

const mockCategory: Category = {
  id: 'flags',
  name: '国旗',
  description: '世界各国の国旗を学習',
  thumbnail: '/images/flags-thumbnail.jpg'
};

describe('CategoryCard', () => {
  it('should render category information correctly', () => {
    const mockOnClick = vi.fn();
    
    render(
      <CategoryCard 
        category={mockCategory} 
        onClick={mockOnClick} 
      />
    );

    expect(screen.getByText('国旗')).toBeInTheDocument();
    expect(screen.getByText('世界各国の国旗を学習')).toBeInTheDocument();
    expect(screen.getByText('🚀 学習を開始')).toBeInTheDocument();
  });

  it('should call onClick when clicked', () => {
    const mockOnClick = vi.fn();
    
    render(
      <CategoryCard 
        category={mockCategory} 
        onClick={mockOnClick} 
      />
    );

    fireEvent.click(screen.getByText('🚀 学習を開始'));
    expect(mockOnClick).toHaveBeenCalledTimes(1);
  });

  it('should display correct icon for flags category', () => {
    const mockOnClick = vi.fn();
    
    render(
      <CategoryCard 
        category={mockCategory} 
        onClick={mockOnClick} 
      />
    );

    expect(screen.getByText('🏳️')).toBeInTheDocument();
  });
});