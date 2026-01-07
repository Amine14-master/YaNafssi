import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, query, orderBy, onSnapshot, doc, updateDoc, deleteDoc } from 'firebase/firestore';
import { Check, Trash2, Video, Calendar } from 'lucide-react';

const Rooms = () => {
    const [rooms, setRooms] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const q = query(collection(db, 'rooms'), orderBy('createdAt', 'desc'));
        const unsubscribe = onSnapshot(q, (snapshot) => {
            const roomsData = snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            setRooms(roomsData);
            setLoading(false);
        });

        return () => unsubscribe();
    }, []);

    const handleAccept = async (id) => {
        try {
            await updateDoc(doc(db, 'rooms', id), {
                status: 'active'
            });
        } catch (error) {
            console.error("Error updating room: ", error);
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm('Are you sure you want to delete this room?')) {
            try {
                await deleteDoc(doc(db, 'rooms', id));
            } catch (error) {
                console.error("Error deleting room: ", error);
            }
        }
    };

    if (loading) {
        return <div className="p-6">Loading...</div>;
    }

    return (
        <div className="p-6">
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
                                <td colSpan="5" className="p-8 text-center text-gray-500">
                                    No rooms found.
                                </td>
                            </tr>
                        ) : (
                            rooms.map((room) => (
                                <tr key={room.id} className="border-b border-gray-100 last:border-0 hover:bg-gray-50 transition-colors">
                                    <td className="p-4 font-medium text-gray-900">{room.title}</td>
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
                                    <td className="p-4 text-gray-500">
                                        {room.createdAt?.toDate().toLocaleString() || 'N/A'}
                                    </td>
                                    <td className="p-4">
                                        <span className={`px-3 py-1 rounded-full text-xs font-medium ${room.status === 'active'
                                                ? 'bg-emerald-100 text-emerald-700'
                                                : 'bg-amber-100 text-amber-700'
                                            }`}>
                                            {room.status || 'pending'}
                                        </span>
                                    </td>
                                    <td className="p-4">
                                        <div className="flex items-center gap-2">
                                            {room.status !== 'active' && (
                                                <button
                                                    onClick={() => handleAccept(room.id)}
                                                    className="p-2 text-emerald-600 hover:bg-emerald-50 rounded-lg transition-colors"
                                                    title="Accept"
                                                >
                                                    <Check size={18} />
                                                </button>
                                            )}
                                            <button
                                                onClick={() => handleDelete(room.id)}
                                                className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                                                title="Delete"
                                            >
                                                <Trash2 size={18} />
                                            </button>
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

export default Rooms;
