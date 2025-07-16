import { useState, useRef, useEffect } from 'react';

interface UseAudioPlayerReturn {
  isPlaying: boolean;
  duration: number;
  currentTime: number;
  play: () => void;
  pause: () => void;
  stop: () => void;
  audioRef: React.RefObject<HTMLAudioElement | null>;
}

export const useAudioPlayer = (audioUrl: string, autoPlay: boolean = false): UseAudioPlayerReturn => {
  const [isPlaying, setIsPlaying] = useState(false);
  const [duration, setDuration] = useState(0);
  const [currentTime, setCurrentTime] = useState(0);
  const audioRef = useRef<HTMLAudioElement>(null);

  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const setAudioData = () => {
      setDuration(audio.duration);
      setCurrentTime(audio.currentTime);
    };

    const setAudioTime = () => setCurrentTime(audio.currentTime);

    const onPlay = () => setIsPlaying(true);
    const onPause = () => setIsPlaying(false);
    const onEnded = () => {
      setIsPlaying(false);
      setCurrentTime(0);
    };

    // イベントリスナー追加
    audio.addEventListener('loadeddata', setAudioData);
    audio.addEventListener('timeupdate', setAudioTime);
    audio.addEventListener('play', onPlay);
    audio.addEventListener('pause', onPause);
    audio.addEventListener('ended', onEnded);

    // 自動再生
    if (autoPlay && audio.readyState >= 2) {
      audio.play().catch(console.error);
    }

    return () => {
      audio.removeEventListener('loadeddata', setAudioData);
      audio.removeEventListener('timeupdate', setAudioTime);
      audio.removeEventListener('play', onPlay);
      audio.removeEventListener('pause', onPause);
      audio.removeEventListener('ended', onEnded);
    };
  }, [audioUrl, autoPlay]);

  const play = () => {
    const audio = audioRef.current;
    if (audio) {
      audio.play().catch(console.error);
    }
  };

  const pause = () => {
    const audio = audioRef.current;
    if (audio) {
      audio.pause();
    }
  };

  const stop = () => {
    const audio = audioRef.current;
    if (audio) {
      audio.pause();
      audio.currentTime = 0;
    }
  };

  return {
    isPlaying,
    duration,
    currentTime,
    play,
    pause,
    stop,
    audioRef,
  };
};