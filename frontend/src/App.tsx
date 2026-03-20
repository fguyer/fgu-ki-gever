import { Navigate, Route, Routes } from 'react-router-dom';
import { AppLayout } from './components/AppLayout';
import { DashboardPage } from './pages/DashboardPage';
import { LoginPage } from './pages/LoginPage';
import { TreePage } from './pages/TreePage';

function App() {
  return (
    <AppLayout>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/tree" element={<TreePage />} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </AppLayout>
  );
}

export default App;
