import React from 'react';
import { Search, Bell, User } from 'lucide-react';

const Header = () => {
    return (
        <header className="header">
            <div className="search-bar">
                <Search size={20} className="search-icon" />
                <input type="text" placeholder="Search..." className="search-input" />
            </div>

            <div className="header-actions">
                <button className="icon-btn">
                    <Bell size={20} />
                    <span className="badge">3</span>
                </button>
                <div className="user-profile">
                    <div className="avatar">
                        <User size={20} />
                    </div>
                    <div className="user-info">
                        <span className="user-name">Admin User</span>
                        <span className="user-role">Super Admin</span>
                    </div>
                </div>
            </div>

            <style>{`
        .header {
          height: var(--header-height);
          background-color: var(--surface-color);
          border-bottom: 1px solid var(--border-color);
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 0 2rem;
          position: sticky;
          top: 0;
          z-index: 5;
        }

        .search-bar {
          position: relative;
          width: 300px;
        }

        .search-icon {
          position: absolute;
          left: 10px;
          top: 50%;
          transform: translateY(-50%);
          color: var(--text-secondary);
        }

        .search-input {
          width: 100%;
          padding: 0.5rem 1rem 0.5rem 2.5rem;
          border-radius: 20px;
          border: 1px solid var(--border-color);
          background-color: var(--background-color);
          transition: all 0.2s;
        }

        .search-input:focus {
          outline: none;
          border-color: var(--primary-color);
          background-color: var(--surface-color);
          box-shadow: 0 0 0 3px rgba(5, 150, 105, 0.1);
        }

        .header-actions {
          display: flex;
          align-items: center;
          gap: 1.5rem;
        }

        .icon-btn {
          position: relative;
          color: var(--text-secondary);
          padding: 0.5rem;
          border-radius: 50%;
          transition: background-color 0.2s;
        }

        .icon-btn:hover {
          background-color: var(--background-color);
          color: var(--text-primary);
        }

        .badge {
          position: absolute;
          top: 0;
          right: 0;
          background-color: #ef4444;
          color: white;
          font-size: 0.7rem;
          width: 16px;
          height: 16px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          border: 2px solid var(--surface-color);
        }

        .user-profile {
          display: flex;
          align-items: center;
          gap: 0.75rem;
          cursor: pointer;
          padding: 0.25rem 0.5rem;
          border-radius: var(--radius-md);
          transition: background-color 0.2s;
        }

        .user-profile:hover {
          background-color: var(--background-color);
        }

        .avatar {
          width: 36px;
          height: 36px;
          background-color: var(--primary-color);
          color: white;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
        }

        .user-info {
          display: flex;
          flex-direction: column;
        }

        .user-name {
          font-weight: 600;
          font-size: 0.9rem;
          color: var(--text-primary);
        }

        .user-role {
          font-size: 0.75rem;
          color: var(--text-secondary);
        }
      `}</style>
        </header>
    );
};

export default Header;
