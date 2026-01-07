import React, { useEffect, useState } from 'react';
import { collection, getDocs, updateDoc, doc, query, orderBy } from 'firebase/firestore';
import { db } from '../firebase';
import { Check, X, FileText, User } from 'lucide-react';

const Requests = () => {
    const [requests, setRequests] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selectedImage, setSelectedImage] = useState(null);

    useEffect(() => {
        fetchRequests();
    }, []);

    const fetchRequests = async () => {
        try {
            const q = query(collection(db, 'specialist_requests'), orderBy('timestamp', 'desc'));
            const querySnapshot = await getDocs(q);
            const data = querySnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            setRequests(data);
        } catch (error) {
            console.error("Error fetching requests: ", error);
        } finally {
            setLoading(false);
        }
    };

    const handleStatusUpdate = async (id, newStatus) => {
        try {
            const requestRef = doc(db, 'specialist_requests', id);
            await updateDoc(requestRef, {
                status: newStatus
            });

            // Update local state
            setRequests(requests.map(req =>
                req.id === id ? { ...req, status: newStatus } : req
            ));

            alert(`Request ${newStatus} successfully!`);
        } catch (error) {
            console.error("Error updating status: ", error);
            alert("Failed to update status.");
        }
    };

    if (loading) {
        return <div className="p-6">Loading requests...</div>;
    }

    return (
        <div className="p-6">
            <h2 className="text-2xl font-bold text-primary mb-6">Helper Requests</h2>

            <div className="card overflow-hidden">
                <table className="w-full">
                    <thead>
                        <tr className="text-left border-b border-gray-200">
                            <th className="p-4 text-sm font-medium text-gray-500">Applicant</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Specialty</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Location</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Documents</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Status</th>
                            <th className="p-4 text-sm font-medium text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {requests.map((request) => (
                            <tr key={request.id} className="border-b border-gray-100 last:border-0 hover:bg-gray-50 transition-colors">
                                <td className="p-4">
                                    <div className="flex items-center gap-3">
                                        <div className="w-10 h-10 rounded-full bg-gray-200 overflow-hidden">
                                            {request.selfieUrl ? (
                                                <img src={request.selfieUrl} alt="Selfie" className="w-full h-full object-cover" />
                                            ) : (
                                                <User className="w-6 h-6 m-2 text-gray-500" />
                                            )}
                                        </div>
                                        <div>
                                            <div className="font-medium">{request.name}</div>
                                            <div className="text-xs text-gray-500">{request.phone}</div>
                                        </div>
                                    </div>
                                </td>
                                <td className="p-4 font-medium text-primary">{request.specialty}</td>
                                <td className="p-4 text-sm">
                                    {request.wilaya}, {request.commune}
                                </td>
                                <td className="p-4">
                                    <div className="flex gap-2">
                                        <button
                                            onClick={() => setSelectedImage(request.licenseUrl)}
                                            className="p-2 bg-blue-50 text-blue-600 rounded-lg hover:bg-blue-100 transition-colors"
                                            title="View License"
                                        >
                                            <FileText size={18} />
                                        </button>
                                        <button
                                            onClick={() => setSelectedImage(request.idFrontUrl)}
                                            className="p-2 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition-colors"
                                            title="View ID Front"
                                        >
                                            <span className="text-xs font-bold">ID</span>
                                        </button>
                                    </div>
                                </td>
                                <td className="p-4">
                                    <span className={`status-badge ${request.status === 'approved' ? 'completed' :
                                        request.status === 'rejected' ? 'rejected' : 'pending'
                                        }`}>
                                        {request.status.charAt(0).toUpperCase() + request.status.slice(1)}
                                    </span>
                                </td>
                                <td className="p-4">
                                    {request.status === 'pending' && (
                                        <div className="flex gap-2">
                                            <button
                                                onClick={() => handleStatusUpdate(request.id, 'approved')}
                                                className="p-2 bg-green-100 text-green-600 rounded-full hover:bg-green-200 transition-colors"
                                                title="Approve"
                                            >
                                                <Check size={18} />
                                            </button>
                                            <button
                                                onClick={() => handleStatusUpdate(request.id, 'rejected')}
                                                className="p-2 bg-red-100 text-red-600 rounded-full hover:bg-red-200 transition-colors"
                                                title="Reject"
                                            >
                                                <X size={18} />
                                            </button>
                                        </div>
                                    )}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>

                {requests.length === 0 && (
                    <div className="p-8 text-center text-gray-500">
                        No requests found.
                    </div>
                )}
            </div>

            {/* Image Modal */}
            {selectedImage && (
                <div className="fixed inset-0 bg-black bg-opacity-80 z-50 flex items-center justify-center p-4" onClick={() => setSelectedImage(null)}>
                    <div className="max-w-4xl max-h-[90vh] relative">
                        <img src={selectedImage} alt="Document" className="max-w-full max-h-[90vh] rounded-lg" />
                        <button
                            className="absolute top-4 right-4 bg-white rounded-full p-2 text-black"
                            onClick={() => setSelectedImage(null)}
                        >
                            <X size={24} />
                        </button>
                    </div>
                </div>
            )}

            <style>{`
        .status-badge.rejected {
          background-color: #fee2e2;
          color: #b91c1c;
        }
      `}</style>
        </div>
    );
};

export default Requests;
