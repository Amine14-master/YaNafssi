import React, { useEffect, useState } from 'react';
import { collection, getDocs, query, orderBy } from 'firebase/firestore';
import { db } from '../firebase';
import { User, Activity } from 'lucide-react';

const Hooked = () => {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchUsers();
    }, []);

    const fetchUsers = async () => {
        try {
            // Assuming a 'hooked_users' collection exists or we might want to query 'users'
            // For now, let's try to fetch from 'hooked_users'
            const q = query(collection(db, 'hooked_users'), orderBy('joinedAt', 'desc'));
            const querySnapshot = await getDocs(q);
            const data = querySnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            setUsers(data);
        } catch (error) {
            console.error("Error fetching hooked users: ", error);
            // Fallback to empty list if collection doesn't exist
            setUsers([]);
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return <div className="p-6">Loading...</div>;
    }

    return (
        <div className="p-6">
            <div className="mb-6">
                <h2 className="text-2xl font-bold text-primary">Hooked Users</h2>
                <p className="text-gray-500">Users seeking support and recovery.</p>
            </div>

            <div className="card overflow-hidden bg-white rounded-xl shadow-sm border border-gray-100">
                <table className="w-full">
                    <thead>
                        <tr className="text-left border-b border-gray-200 bg-gray-50">
                            <th className="p-4 text-sm font-medium text-gray-500">User</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Status</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Joined Date</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Progress</th>
                        </tr>
                    </thead>
                    <tbody>
                        {users.length === 0 ? (
                            <tr>
                                <td colSpan="4" className="p-8 text-center text-gray-500">
                                    No users found in Hooked program.
                                </td>
                            </tr>
                        ) : (
                            users.map((user) => (
                                <tr key={user.id} className="border-b border-gray-100 last:border-0 hover:bg-gray-50 transition-colors">
                                    <td className="p-4">
                                        <div className="flex items-center gap-3">
                                            <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600">
                                                <User size={20} />
                                            </div>
                                            <div>
                                                <div className="font-medium text-gray-900">{user.name || 'Anonymous'}</div>
                                                <div className="text-xs text-gray-500">{user.email || user.phone || 'No contact info'}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="p-4">
                                        <span className="px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-700">
                                            {user.status || 'Active'}
                                        </span>
                                    </td>
                                    <td className="p-4 text-gray-500">
                                        {user.joinedAt?.toDate().toLocaleDateString() || 'N/A'}
                                    </td>
                                    <td className="p-4">
                                        <div className="flex items-center gap-2 text-emerald-600">
                                            <Activity size={16} />
                                            <span className="text-sm font-medium">{user.streak || 0} Days Streak</span>
                                        </div>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default Hooked;
