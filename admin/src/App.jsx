import React, { useState, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import Header from './components/Header';
import StatsCard from './components/StatsCard';
import Requests from './components/Requests';
import Rooms from './components/Rooms';
import Hooked from './components/Hooked';
import { Users, Video, FileCheck, Activity } from 'lucide-react';
import { collection, getCountFromServer } from 'firebase/firestore';
import { db } from './firebase';
import './App.css';

function App() {
  const [activePage, setActivePage] = useState('dashboard');
  const [stats, setStats] = useState([
    { title: 'Total Helpers', value: '0', change: 0, icon: Users, trend: 'neutral' },
    { title: 'Active Rooms', value: '0', change: 0, icon: Video, trend: 'neutral' },
    { title: 'Hooked Users', value: '0', change: 0, icon: FileCheck, trend: 'neutral' },
    { title: 'Total Activity', value: '0', change: 0, icon: Activity, trend: 'neutral' },
  ]);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const helpersCount = await getCountFromServer(collection(db, 'specialist_requests'));
      const roomsCount = await getCountFromServer(collection(db, 'rooms'));
      // const hookedCount = await getCountFromServer(collection(db, 'hooked_users')); // Uncomment when collection exists

      setStats([
        { title: 'Total Helpers', value: helpersCount.data().count.toString(), change: 12.5, icon: Users, trend: 'up' },
        { title: 'Active Rooms', value: roomsCount.data().count.toString(), change: 8.2, icon: Video, trend: 'up' },
        { title: 'Hooked Users', value: '0', change: 0, icon: FileCheck, trend: 'neutral' }, // Placeholder
        { title: 'Total Activity', value: 'Active', change: 4.1, icon: Activity, trend: 'up' },
      ]);
    } catch (error) {
      console.error("Error fetching stats:", error);
    }
  };

  const renderContent = () => {
    if (activePage === 'helper') {
      return <Requests />;
    }
    if (activePage === 'rooms') {
      return <Rooms />;
    }
    if (activePage === 'hooked') {
      return <Hooked />;
    }

    // Default Dashboard Content
    return (
      <div className="dashboard-content p-6">
        <div className="mb-6">
          <h2 className="text-2xl font-bold text-primary">Dashboard Overview</h2>
          <p className="text-gray-500">Welcome back, here's what's happening today.</p>
        </div>

        <div className="stats-grid">
          {stats.map((stat, index) => (
            <StatsCard key={index} {...stat} />
          ))}
        </div>

        <div className="recent-orders-section mt-8">
          <h3 className="text-xl font-bold mb-4">Recent Activity</h3>
          <div className="card overflow-hidden bg-white rounded-xl shadow-sm border border-gray-100 p-8 text-center text-gray-500">
            <p>Activity feed coming soon...</p>
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="app-container">
      <Sidebar activePage={activePage} setActivePage={setActivePage} />
      <main className="main-content">
        <Header />
        {renderContent()}
      </main>

      <style>{`
        .dashboard-content {
          max-width: 1400px;
          margin: 0 auto;
          width: 100%;
        }

        .stats-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
          gap: 1.5rem;
        }

        .mt-8 { margin-top: 2rem; }
        .mb-6 { margin-bottom: 1.5rem; }
        .mb-4 { margin-bottom: 1rem; }
        .text-2xl { font-size: 1.5rem; }
        .text-xl { font-size: 1.25rem; }
        .overflow-hidden { overflow: hidden; }
        
        .status-badge {
          padding: 0.25rem 0.75rem;
          border-radius: 9999px;
          font-size: 0.75rem;
          font-weight: 500;
        }

        .status-badge.completed {
          background-color: #d1fae5;
          color: #065f46;
        }

        .status-badge.pending {
          background-color: #fef3c7;
          color: #92400e;
        }

        table {
          border-collapse: collapse;
        }
      `}</style>
    </div>
  );
}

export default App;
