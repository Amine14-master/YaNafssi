import React, { useEffect, useState } from 'react';
import { ref, onValue } from 'firebase/database';
import { db } from '../firebase';
import { User, Activity, Flame } from 'lucide-react';
import { motion } from 'framer-motion';

const Hooked = () => {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const usersRef = ref(db, 'hooked_users');
        const unsubscribe = onValue(usersRef, (snapshot) => {
            const data = snapshot.val();
            if (data) {
                const usersList = Object.entries(data).map(([id, userData]) => ({
                    id,
                    ...userData
                }));
                // Sort by joinedAt descending
                usersList.sort((a, b) => (b.joinedAt || 0) - (a.joinedAt || 0));
                setUsers(usersList);
            } else {
                setUsers([]);
            }
            setLoading(false);
        }, (error) => {
            console.error("Error fetching hooked users: ", error);
            setLoading(false);
        });

        return () => unsubscribe();
    }, []);

    if (loading) {
        return (
            <div className="flex items-center justify-center p-12">
                <div className="w-10 h-10 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
            </div>
        );
    }

    return (
        <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="p-6"
        >
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
                                <td colSpan="4" className="p-8">
                                    <motion.div 
                                        initial={{ opacity: 0 }}
                                        animate={{ opacity: 1 }}
                                        className="flex flex-col items-center justify-center text-gray-500"
                                    >
                                        <Activity size={48} className="text-gray-300 mb-4" />
                                        <p className="text-lg">No users found in Hooked program.</p>
                                    </motion.div>
                                </td>
                            </tr>
                        ) : (
                            users.map((user, index) => (
                                <motion.tr 
                                    initial={{ opacity: 0, x: -20 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    transition={{ duration: 0.3, delay: index * 0.1 }}
                                    key={user.id} 
                                    className="border-b border-gray-100 last:border-0 hover:bg-gray-50 transition-colors"
                                >
                                    <td className="p-4">
                                        <div className="flex items-center gap-3">
                                            <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 shadow-sm">
                                                <User size={20} />
                                            </div>
                                            <div>
                                                <div className="font-medium text-gray-900">{user.name || 'Anonymous'}</div>
                                                <div className="text-xs text-gray-500">{user.email || user.phone || 'No contact info'}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="p-4">
                                        <span className={`px-3 py-1 rounded-full text-xs font-medium shadow-sm border ${
                                            user.status === 'Active' ? 'bg-blue-100 text-blue-700 border-blue-200' : 'bg-gray-100 text-gray-700 border-gray-200'
                                        }`}>
                                            {user.status || 'Active'}
                                        </span>
                                    </td>
                                    <td className="p-4 text-gray-500 text-sm">
                                        {user.joinedAt ? new Date(user.joinedAt).toLocaleDateString() : 'N/A'}
                                    </td>
                                    <td className="p-4">
                                        <div className="flex items-center gap-2 text-orange-500">
                                            <Flame size={18} />
                                            <span className="text-sm font-bold">{user.streak || 0} Days</span>
                                        </div>
                                    </td>
                                </motion.tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </motion.div>
    );
};

export default Hooked;
