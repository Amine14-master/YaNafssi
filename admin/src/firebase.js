// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getDatabase } from "firebase/database";

// Your web app's Firebase configuration
const firebaseConfig = {
    apiKey: "AIzaSyBI-eWBa14Z3jrOaY_Y6A-lsmfoL7z4D9c",
    authDomain: "yanafssi.firebaseapp.com",
    projectId: "yanafssi",
    storageBucket: "yanafssi.firebasestorage.app",
    messagingSenderId: "863516411610",
    appId: "1:863516411610:web:2e87b1120e703e011a87e3",
    measurementId: "G-F1Z88B0873",
    databaseURL: "https://yanafssi-default-rtdb.europe-west1.firebasedatabase.app"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const db = getDatabase(app);

export { app, analytics, db };
