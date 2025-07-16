import React from 'react';
import { useAudioPlayer } from '../hooks/useAudioPlayer';
import { useAppContext } from '../context/AppContext';

interface AudioPlayerProps {
  audioUrl: string;
  autoPlay?: boolean;
  onPlayStateChange?: (isPlaying: boolean) => void;
}

const AudioPlayer: React.FC<AudioPlayerProps> = ({
  audioUrl,
  autoPlay = false,
  onPlayStateChange,
}) => {
  const { state } = useAppContext();
  const { settings } = state;
  const { isAudioAutoPlay, volume } = settings;

  const {
    isPlaying,
    duration,
    currentTime,
    play,
    pause,
    stop,
    audioRef,
  } = useAudioPlayer(audioUrl, autoPlay && isAudioAutoPlay);

  React.useEffect(() => {
    if (audioRef.current) {
      audioRef.current.volume = volume;
    }
  }, [volume, audioRef]);

  React.useEffect(() => {
    onPlayStateChange?.(isPlaying);
  }, [isPlaying, onPlayStateChange]);

  const togglePlay = () => {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  };

  const formatTime = (time: number) => {
    if (isNaN(time)) return '0:00';
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60);
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  };

  const progressPercentage = duration > 0 ? (currentTime / duration) * 100 : 0;

  return (
    <div className="bg-background border border-border rounded-lg p-4 max-w-md">
      <audio
        ref={audioRef as React.RefObject<HTMLAudioElement>}
        src={audioUrl}
        preload={import.meta.env.VITE_AUDIO_PRELOAD || 'metadata'}
      />

      <div className="flex items-center space-x-4">
        {/* 再生/停止ボタン */}
        <button
          onClick={togglePlay}
          className="flex items-center justify-center w-12 h-12 bg-primary text-white rounded-full hover:bg-blue-600 transition-colors"
          aria-label={isPlaying ? '音声を停止' : '音声を再生'}
        >
          {isPlaying ? (
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 002 0V8a1 1 0 00-1-1z" clipRule="evenodd" />
            </svg>
          ) : (
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clipRule="evenodd" />
            </svg>
          )}
        </button>

        <div className="flex-1">
          {/* 進行バー */}
          <div className="relative bg-gray-200 h-2 rounded-full mb-2">
            <div
              className="absolute top-0 left-0 h-full bg-primary rounded-full transition-all duration-100"
              style={{ width: `${progressPercentage}%` }}
            />
          </div>

          {/* 時間表示 */}
          <div className="flex justify-between text-sm text-textSecondary">
            <span>{formatTime(currentTime)}</span>
            <span>{formatTime(duration)}</span>
          </div>
        </div>

        {/* 停止ボタン */}
        <button
          onClick={stop}
          className="p-2 text-textSecondary hover:text-text transition-colors"
          aria-label="音声を停止"
        >
          <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8 7a1 1 0 00-1 1v4a1 1 0 001 1h4a1 1 0 001-1V8a1 1 0 00-1-1H8z" clipRule="evenodd" />
          </svg>
        </button>
      </div>
    </div>
  );
};

export default AudioPlayer;