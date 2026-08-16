import React, { useEffect, useState } from 'react';
import { ref, onValue, update } from 'firebase/database';
import { db } from '../firebase';
import { Check, X, FileText, User } from 'lucide-react';
import { motion } from 'framer-motion';

const Requests = () => {
    const [requests, setRequests] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selectedImage, setSelectedImage] = useState(null);

    useEffect(() => {
        const requestsRef = ref(db, 'specialist_requests');
        const unsubscribe = onValue(requestsRef, (snapshot) => {
            const data = snapshot.val();
            if (data) {
                const requestsList = Object.entries(data).map(([id, requestData]) => ({
                    id,
                    ...requestData
                }));
                // Sort by timestamp descending
                requestsList.sort((a, b) => (b.timestamp || 0) - (a.timestamp || 0));
                setRequests(requestsList);
            } else {
                setRequests([]);
            }
            setLoading(false);
        }, (error) => {
            console.error("Error fetching requests: ", error);
            setLoading(false);
        });

        return () => unsubscribe();
    }, []);

    const handleStatusUpdate = async (id, newStatus) => {
        try {
            const requestRef = ref(db, `specialist_requests/${id}`);
            await update(requestRef, {
                status: newStatus
            });
            alert(`Request ${newStatus} successfully!`);
        } catch (error) {
            console.error("Error updating status: ", error);
            alert("Failed to update status.");
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
            <h2 className="text-2xl font-bold text-primary mb-6">Helper Requests</h2>

            <div className="card overflow-hidden bg-white rounded-xl shadow-sm border border-gray-100">
                <table className="w-full">
                    <thead>
                        <tr className="text-left border-b border-gray-200 bg-gray-50">
                            <th className="p-4 text-sm font-medium text-gray-500">Applicant</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Specialty</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Location</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Documents</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Status</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {requests.map((request, index) => (
                            <motion.tr 
                                initial={{ opacity: 0, x: -20 }}
                                animate={{ opacity: 1, x: 0 }}
                                transition={{ duration: 0.3, delay: index * 0.1 }}
                                key={request.id} 
                                className="border-b border-gray-100 last:border-0 hover:bg-gray-50 transition-colors"
                            >
                                <td className="p-4">
                                    <div className="flex items-center gap-3">
                                        <div className="w-10 h-10 rounded-full bg-gray-200 overflow-hidden shadow-sm">
                                            {request.selfieUrl ? (
                                                <img src={request.selfieUrl} alt="Selfie" className="w-full h-full object-cover" />
                                            ) : (
                                                <User className="w-6 h-6 m-2 text-gray-500" />
                                            )}
                                        </div>
                                        <div>
                                            <div className="font-medium text-gray-900">{request.name}</div>
                                            <div className="text-xs text-gray-500">{request.phone}</div>
                                        </div>
                                    </div>
                                </td>
                                <td className="p-4 font-medium text-primary capitalize">{request.specialty?.replace('_', ' ')}</td>
                                <td className="p-4 text-sm text-gray-600">
                                    {request.wilaya}, {request.commune}
                                </td>
                                <td className="p-4">
                                    <div className="flex gap-2">
                                        <button
                                            onClick={() => setSelectedImage(request.licenseUrl)}
                                            className="p-2 bg-blue-50 text-blue-600 rounded-lg hover:bg-blue-100 transition-colors shadow-sm"
                                            title="View License"
                                        >
                                            <FileText size={18} />
                                        </button>
                                        <button
                                            onClick={() => setSelectedImage(request.idFrontUrl)}
                                            className="p-2 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition-colors shadow-sm"
                                            title="View ID Front"
                                        >
                                            <span className="text-xs font-bold px-1">ID</span>
                                        </button>
                                    </div>
                                </td>
                                <td className="p-4">
                                    <span className={`status-badge shadow-sm ${
                                        request.status === 'approved' ? 'completed' :
                                        request.status === 'rejected' ? 'rejected' : 'pending'
                                    }`}>
                                        {request.status.charAt(0).toUpperCase() + request.status.slice(1)}
                                    </span>
                                </td>
                                <td className="p-4">
                                    {request.status === 'pending' && (
                                        <div className="flex gap-2">
                                            <motion.button
                                                whileHover={{ scale: 1.1 }}
                                                whileTap={{ scale: 0.95 }}
                                                onClick={() => handleStatusUpdate(request.id, 'approved')}
                                                className="p-2 bg-green-100 text-green-600 rounded-full shadow-sm hover:bg-green-200 transition-colors"
                                                title="Approve"
                                            >
                                                <Check size={18} />
                                            </motion.button>
                                            <motion.button
                                                whileHover={{ scale: 1.1 }}
                                                whileTap={{ scale: 0.95 }}
                                                onClick={() => handleStatusUpdate(request.id, 'rejected')}
                                                className="p-2 bg-red-100 text-red-600 rounded-full shadow-sm hover:bg-red-200 transition-colors"
                                                title="Reject"
                                            >
                                                <X size={18} />
                                            </motion.button>
                                        </div>
                                    )}
                                </td>
                            </motion.tr>
                        ))}
                    </tbody>
                </table>

                {requests.length === 0 && !loading && (
                    <motion.div 
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        className="p-12 text-center text-gray-500"
                    >
                        <div className="flex flex-col items-center justify-center">
                            <FileText size={48} className="text-gray-300 mb-4" />
                            <p className="text-lg">No requests found at the moment.</p>
                        </div>
                    </motion.div>
                )}
            </div>

            {/* Image Modal */}
            {selectedImage && (
                <div 
                    className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4" 
                    onClick={() => setSelectedImage(null)}
                >
                    <motion.div 
                        initial={{ scale: 0.9, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        className="max-w-4xl max-h-[90vh] relative"
                        onClick={e => e.stopPropagation()}
                    >
                        <img src={selectedImage} alt="Document" className="max-w-full max-h-[90vh] rounded-xl shadow-2xl" />
                        <button
                            className="absolute -top-4 -right-4 bg-white rounded-full p-2 text-black shadow-lg hover:bg-gray-100 transition-colors"
                            onClick={() => setSelectedImage(null)}
                        >
                            <X size={24} />
                        </button>
                    </motion.div>
                </div>
            )}

            <style>{`
        .status-badge {
            padding: 0.35rem 0.85rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 600;
            letter-spacing: 0.025em;
        }
        .status-badge.completed {
            background-color: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }
        .status-badge.pending {
            background-color: #fef3c7;
            color: #92400e;
            border: 1px solid #fde68a;
        }
        .status-badge.rejected {
            background-color: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fecaca;
        }
      `}</style>
        </motion.div>
    );
};

export default Requests;
