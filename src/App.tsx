import { Routes, Route, HashRouter } from 'react-router-dom'
import { PetProvider } from './context/PetContext'
import ScrollToTop from './components/ScrollToTop'
import NavigationBar from './components/NavigationBar'
import Footer from './components/Footer'
import FeedbackFab from './components/FeedbackFab'
import LandingPage from './screens/LandingPage'
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
              <Route path="/add-pet" element={<AddPetScreen />} />
              <Route path="/kibble" element={<KibbleSelectorScreen />} />
              <Route path="/plan" element={<MealPlanScreen />} />
              <Route path="/supplements" element={<SupplementsScreen />} />
              <Route path="/dashboard" element={<DashboardScreen />} />
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
