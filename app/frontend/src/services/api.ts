import axios from "axios";
import type { Category, QuizQuestion } from "../types";

// API ベース URL の設定
const API_BASE_URL =
  import.meta.env.VITE_REACT_APP_API_BASE_URL ||
  import.meta.env.VITE_API_BASE_URL ||
  "http://localhost:8080";

// Axios インスタンスの作成
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    "Content-Type": "application/json",
  },
});

// API エラーハンドリング用の型定義
export interface ApiError {
  code: string;
  message: string;
  details?: string;
}

// API エラーレスポンス
export interface ApiErrorResponse {
  error: ApiError;
}

// レスポンスインターセプターでエラーハンドリング
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.data?.error) {
      // API 標準エラーレスポンス
      throw new Error(
        error.response.data.error.message || "API エラーが発生しました"
      );
    } else if (error.code === "ECONNABORTED") {
      // タイムアウトエラー
      throw new Error(
        "リクエストがタイムアウトしました。しばらく後に再試行してください。"
      );
    } else if (error.code === "ERR_NETWORK") {
      // ネットワークエラー
      throw new Error(
        "サーバーに接続できません。ネットワーク接続を確認してください。"
      );
    } else {
      // その他のエラー
      throw new Error("予期しないエラーが発生しました。");
    }
  }
);

/**
 * ヘルスチェック API
 */
export const healthCheck = async (): Promise<{
  status: string;
  timestamp: string;
}> => {
  const response = await api.get("/health");
  return response.data;
};

/**
 * カテゴリ一覧取得 API
 */
export const getCategories = async (): Promise<Category[]> => {
  const response = await api.get("/categories");
  return response.data;
};

/**
 * クイズ問題取得 API
 * @param category カテゴリ ID
 * @param count 取得する問題数（デフォルト: 10, 最大: 50）
 */
export const getQuizQuestions = async (
  category: string,
  count: number = 10
): Promise<QuizQuestion[]> => {
  const response = await api.get("/quiz", {
    params: {
      category,
      count,
    },
  });
  return response.data;
};

/**
 * 個別クイズ問題取得 API
 * @param id クイズ ID
 */
export const getQuizQuestion = async (id: string): Promise<QuizQuestion> => {
  const response = await api.get(`/quiz/${id}`);
  return response.data;
};

export default api;
