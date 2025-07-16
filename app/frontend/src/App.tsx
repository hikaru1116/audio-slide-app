import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AppProvider } from './context/AppContext';
import CategorySelectPage from './pages/CategorySelectPage';
import QuizPage from './pages/QuizPage';
import ResultsPage from './pages/ResultsPage';
import './index.css';

function App() {
  return (
    <AppProvider>
      <Router>
        <div className="min-h-screen bg-background">
          <Routes>
            <Route path="/" element={<CategorySelectPage />} />
            <Route path="/quiz/:category" element={<QuizPage />} />
            <Route path="/quiz/:category/results" element={<ResultsPage />} />
          </Routes>
        </div>
      </Router>
    </AppProvider>
  );
}

export default App;
