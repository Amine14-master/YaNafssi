import React from 'react';

const StatsCard = ({ title, value, change, icon: Icon, trend }) => {
    const isPositive = trend === 'up';

    return (
        <div className="card stats-card">
            <div className="stats-info">
                <span className="stats-title">{title}</span>
                <h3 className="stats-value">{value}</h3>
                <div className={`stats-change ${isPositive ? 'positive' : 'negative'}`}>
                    <span>{isPositive ? '+' : ''}{change}%</span>
                    <span className="stats-period">vs last month</span>
                </div>
            </div>
            <div className="stats-icon-container">
                <Icon size={24} />
            </div>

            <style>{`
        .stats-card {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
        }

        .stats-title {
          color: var(--text-secondary);
          font-size: 0.875rem;
          font-weight: 500;
        }

        .stats-value {
          font-size: 1.75rem;
          font-weight: 700;
          color: var(--text-primary);
          margin: 0.5rem 0;
        }

        .stats-change {
          display: flex;
          align-items: center;
          gap: 0.5rem;
          font-size: 0.875rem;
          font-weight: 500;
        }

        .stats-change.positive {
          color: #10b981;
        }

        .stats-change.negative {
          color: #ef4444;
        }

        .stats-period {
          color: var(--text-secondary);
          font-weight: 400;
        }

        .stats-icon-container {
          padding: 0.75rem;
          border-radius: 12px;
          background-color: rgba(5, 150, 105, 0.1);
          color: var(--primary-color);
        }
      `}</style>
        </div>
    );
};

export default StatsCard;
