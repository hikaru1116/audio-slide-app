import { useRef, useCallback } from "react";

interface UseCorrectSoundReturn {
  playCorrectSound: () => void;
  stopCorrectSound: () => void;
}

export const useCorrectSound = (): UseCorrectSoundReturn => {
  const correctAudioRef = useRef<HTMLAudioElement | null>(null);

  const playCorrectSound = useCallback(() => {
    try {
      // 正解音声を初期化（初回のみ）
      if (!correctAudioRef.current) {
        correctAudioRef.current = new Audio("/sounds/correct.mp3");
        correctAudioRef.current.volume = 0.6; // 音量を60%に設定
        correctAudioRef.current.preload = "auto";
      }

      // 現在再生中の音声があれば停止してリセット
      if (!correctAudioRef.current.paused) {
        correctAudioRef.current.currentTime = 0;
      }

      // 音声を再生
      const playPromise = correctAudioRef.current.play();

      // 再生の Promise を適切にハンドリング
      if (playPromise !== undefined) {
        playPromise.catch((error) => {
          console.warn("正解音声の再生に失敗しました:", error);
        });
      }
    } catch (error) {
      console.warn("正解音声の初期化に失敗しました:", error);
    }
  }, []);

  const stopCorrectSound = useCallback(() => {
    try {
      if (correctAudioRef.current && !correctAudioRef.current.paused) {
        correctAudioRef.current.pause();
        correctAudioRef.current.currentTime = 0;
      }
    } catch (error) {
      console.warn("正解音声の停止に失敗しました:", error);
    }
  }, []);

  return {
    playCorrectSound,
    stopCorrectSound,
  };
};
