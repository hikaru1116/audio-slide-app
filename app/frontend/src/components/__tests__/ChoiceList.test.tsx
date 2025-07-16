import { render, screen, fireEvent } from '@testing-library/react';
import { vi } from 'vitest';
import ChoiceList from '../ChoiceList';

const mockChoices = ['選択肢1', '選択肢2', '選択肢3', '選択肢4'];

describe('ChoiceList', () => {
  it('should render all choices', () => {
    const mockOnSelect = vi.fn();
    
    render(
      <ChoiceList
        choices={mockChoices}
        selectedAnswer={null}
        correctAnswer="選択肢1"
        onSelect={mockOnSelect}
        showResult={false}
      />
    );

    mockChoices.forEach(choice => {
      expect(screen.getByText(choice)).toBeInTheDocument();
    });
  });

  it('should handle choice selection', () => {
    const mockOnSelect = vi.fn();
    
    render(
      <ChoiceList
        choices={mockChoices}
        selectedAnswer={null}
        correctAnswer="選択肢1"
        onSelect={mockOnSelect}
        showResult={false}
      />
    );

    fireEvent.click(screen.getByText('選択肢1'));
    expect(mockOnSelect).toHaveBeenCalledWith('選択肢1');
  });

  it('should show correct/incorrect styling when result is shown', () => {
    const mockOnSelect = vi.fn();
    
    render(
      <ChoiceList
        choices={mockChoices}
        selectedAnswer="選択肢2"
        correctAnswer="選択肢1"
        onSelect={mockOnSelect}
        showResult={true}
      />
    );

    // 正解の選択肢にチェックマークが表示される
    expect(screen.getByText('✅')).toBeInTheDocument();
    // 不正解の選択肢にバツマークが表示される
    expect(screen.getByText('❌')).toBeInTheDocument();
  });

  it('should disable buttons when result is shown', () => {
    const mockOnSelect = vi.fn();
    
    render(
      <ChoiceList
        choices={mockChoices}
        selectedAnswer="選択肢1"
        correctAnswer="選択肢1"
        onSelect={mockOnSelect}
        showResult={true}
      />
    );

    const buttons = screen.getAllByRole('button');
    buttons.forEach(button => {
      expect(button).toBeDisabled();
    });
  });
});