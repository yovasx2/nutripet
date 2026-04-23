import { Routes, Route, HashRouter } from 'react-router-dom'
import { PetProvider } from './context/PetContext'
import ScrollToTop from './components/ScrollToTop'
import NavigationBar from './components/NavigationBar'
import Footer from './components/Footer'
import FeedbackFab from './components/FeedbackFab'
import ProtectedRoute from './components/ProtectedRoute'
import LandingPage from './screens/LandingPage'
import LoginScreen from './screens/LoginScreen'
import RegisterScreen from './screens/RegisterScreen'
import ProfileScreen from './screens/ProfileScreen'
import AddPetScreen from './screens/AddPetScreen'
import KibbleSelectorScreen from './screens/KibbleSelectorScreen'
import MealPlanScreen from './screens/MealPlanScreen'
import SupplementsScreen from './screens/SupplementsScreen'
import DashboardScreen from './screens/DashboardScreen'
import EducationScreen from './screens/EducationScreen'

export default function App() {
  return (
    <HashRouter>
      <ScrollToTop />
      <PetProvider>
        <div className="min-h-[100dvh] bg-cream">
          <NavigationBar />
          <main>
            <Routes>
              <Route path="/" element={<LandingPage />} />
              <Route path="/login" element={<LoginScreen />} />
              <Route path="/register" element={<RegisterScreen />} />
              <Route path="/profile" element={
                <ProtectedRoute><ProfileScreen /></ProtectedRoute>
              } />
              <Route path="/add-pet" element={
                <ProtectedRoute><AddPetScreen /></ProtectedRoute>
              } />
              <Route path="/kibble" element={
                <ProtectedRoute><KibbleSelectorScreen /></ProtectedRoute>
              } />
              <Route path="/plan" element={
                <ProtectedRoute><MealPlanScreen /></ProtectedRoute>
              } />
              <Route path="/supplements" element={
                <ProtectedRoute><SupplementsScreen /></ProtectedRoute>
              } />
              <Route path="/dashboard" element={
                <ProtectedRoute><DashboardScreen /></ProtectedRoute>
              } />
              <Route path="/education" element={<EducationScreen />} />
            </Routes>
          </main>
          <Footer />
          <FeedbackFab />
        </div>
      </PetProvider>
    </HashRouter>
  )
}
