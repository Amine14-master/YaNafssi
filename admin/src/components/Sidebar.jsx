import { LayoutDashboard, Users, ShoppingBag, Settings, BarChart3, LogOut, FileCheck, Video } from 'lucide-react';

const Sidebar = ({ activePage, setActivePage }) => {
    const menuItems = [
        { icon: LayoutDashboard, label: 'Dashboard', id: 'dashboard' },
        { icon: Users, label: 'Helper', id: 'helper' },
        { icon: Video, label: 'Rooms', id: 'rooms' },
        { icon: FileCheck, label: 'Hooked', id: 'hooked' },
    ];

    return (
        <aside className="sidebar">
            <div className="logo-container">
                <img src="/logo.png" alt="Logo" className="logo-image" />
                <h1 className="logo-text">YaNafssi<span className="text-primary">Admin</span></h1>
            </div>

            <nav className="nav-menu">
                {menuItems.map((item, index) => (
                    <a
                        key={index}
                        href="#"
                        className={`nav-item ${activePage === item.id ? 'active' : ''}`}
                        onClick={(e) => {
                            e.preventDefault();
                            setActivePage(item.id);
                        }}
                    >
                        <item.icon size={20} />
                        <span>{item.label}</span>
                    </a>
                ))}
            </nav>

            <div className="sidebar-footer">
                <a href="#" className="nav-item logout">
                    <LogOut size={20} />
                    <span>Logout</span>
                </a>
            </div>

            <style>{`
        .sidebar {
          width: var(--sidebar-width);
          height: 100vh;
          background-color: var(--surface-color);
          border-right: 1px solid var(--border-color);
          display: flex;
          flex-direction: column;
          position: fixed;
          left: 0;
          top: 0;
          z-index: 10;
        }

        .logo-container {
          padding: 1.5rem;
          display: flex;
          align-items: center;
          gap: 0.75rem;
          border-bottom: 1px solid var(--border-color);
        }

        .logo-image {
          width: 40px;
          height: 40px;
          object-fit: contain;
          border-radius: 50%;
          background-color: white;
        }

        .logo-text {
          font-size: 1.25rem;
          font-weight: 700;
          color: var(--text-primary);
        }

        .nav-menu {
          padding: 1.5rem 1rem;
          flex: 1;
          display: flex;
          flex-direction: column;
          gap: 0.5rem;
        }

        .nav-item {
          display: flex;
          align-items: center;
          gap: 0.75rem;
          padding: 0.75rem 1rem;
          border-radius: var(--radius-md);
          color: var(--text-secondary);
          transition: all 0.2s;
          font-weight: 500;
        }

        .nav-item:hover {
          background-color: var(--background-color);
          color: var(--text-primary);
        }

        .nav-item.active {
          background-color: rgba(5, 150, 105, 0.1);
          color: var(--primary-color);
        }

        .sidebar-footer {
          padding: 1.5rem 1rem;
          border-top: 1px solid var(--border-color);
        }

        .nav-item.logout:hover {
          background-color: #fee2e2;
          color: #ef4444;
        }
      `}</style>
        </aside>
    );
};

export default Sidebar;
