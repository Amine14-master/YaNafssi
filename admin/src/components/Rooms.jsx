import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { ref, onValue, update, remove } from 'firebase/database';
import { Check, Trash2, Video, Calendar, Monitor } from 'lucide-react';
import { motion } from 'framer-motion';

const Rooms = () => {
    const [rooms, setRooms] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const roomsRef = ref(db, 'rooms');
        const unsubscribe = onValue(roomsRef, (snapshot) => {
            const data = snapshot.val();
            if (data) {
                const roomsList = Object.entries(data).map(([id, roomData]) => ({
                    id,
                    ...roomData
                }));
                // Sort by createdAt descending
                roomsList.sort((a, b) => (b.createdAt || 0) - (a.createdAt || 0));
                setRooms(roomsList);
            } else {
                setRooms([]);
            }
            setLoading(false);
        }, (error) => {
            console.error("Error fetching rooms: ", error);
            setLoading(false);
        });

        return () => unsubscribe();
    }, []);

    const handleAccept = async (id) => {
        try {
            await update(ref(db, `rooms/${id}`), {
                status: 'active'
            });
        } catch (error) {
            console.error("Error updating room: ", error);
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm('Are you sure you want to delete this room?')) {
            try {
                await remove(ref(db, `rooms/${id}`));
            } catch (error) {
                console.error("Error deleting room: ", error);
            }
        }
    };

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
                <h2 className="text-2xl font-bold text-primary">Rooms Management</h2>
                <p className="text-gray-500">Manage support rooms created by specialists.</p>
            </div>

            <div className="card overflow-hidden bg-white rounded-xl shadow-sm border border-gray-100">
                <table className="w-full">
                    <thead>
                        <tr className="text-left border-b border-gray-200 bg-gray-50">
                            <th className="p-4 text-sm font-medium text-gray-500">Room Title</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Type</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Created At</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Status</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {rooms.length === 0 ? (
                            <tr>
                                <td colSpan="5" className="p-8">
                                    <motion.div 
                                        initial={{ opacity: 0 }}
                                        animate={{ opacity: 1 }}
                                        className="flex flex-col items-center justify-center text-gray-500"
                                    >
                                        <Monitor size={48} className="text-gray-300 mb-4" />
                                        <p className="text-lg">No rooms found.</p>
                                    </motion.div>
                                </td>
                            </tr>
                        ) : (
                            rooms.map((room, index) => (
                                <motion.tr 
                                    initial={{ opacity: 0, x: -20 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    transition={{ duration: 0.3, delay: index * 0.1 }}
                                    key={room.id} 
                                    className="border-b border-gray-100 last:border-0 hover:bg-gray-50 transition-colors"
                                >
                                    <td className="p-4">
                                        <div className="font-medium text-gray-900">{room.title}</div>
                                        <div className="text-xs text-gray-500">{room.description || 'No description'}</div>
                                    </td>
                                    <td className="p-4">
                                        <div className="flex items-center gap-2">
                                            {room.type === 'now' ? (
                                                <Video size={16} className="text-emerald-500" />
                                            ) : (
                                                <Calendar size={16} className="text-blue-500" />
                                            )}
                                            <span className="capitalize">{room.type}</span>
                                        </div>
                                    </td>
                                    <td className="p-4 text-gray-500 text-sm">
                                        {room.createdAt ? new Date(room.createdAt).toLocaleString() : 'N/A'}
                                    </td>
                                    <td className="p-4">
                                        <span className={`px-3 py-1 rounded-full text-xs font-medium shadow-sm border ${
                                            room.status === 'active'
                                                ? 'bg-emerald-100 text-emerald-700 border-emerald-200'
                                                : 'bg-amber-100 text-amber-700 border-amber-200'
                                            }`}>
                                            {room.status || 'pending'}
                                        </span>
                                    </td>
                                    <td className="p-4">
                                        <div className="flex items-center gap-2">
                                            {room.status !== 'active' && (
                                                <motion.button
                                                    whileHover={{ scale: 1.1 }}
                                                    whileTap={{ scale: 0.95 }}
                                                    onClick={() => handleAccept(room.id)}
                                                    className="p-2 text-emerald-600 bg-emerald-50 hover:bg-emerald-100 rounded-lg transition-colors shadow-sm"
                                                    title="Accept"
                                                >
                                                    <Check size={18} />
                                                </motion.button>
                                            )}
                                            <motion.button
                                                whileHover={{ scale: 1.1 }}
                                                whileTap={{ scale: 0.95 }}
                                                onClick={() => handleDelete(room.id)}
                                                className="p-2 text-red-600 bg-red-50 hover:bg-red-100 rounded-lg transition-colors shadow-sm"
                                                title="Delete"
                                            >
                                                <Trash2 size={18} />
                                            </motion.button>
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

export default Rooms;
