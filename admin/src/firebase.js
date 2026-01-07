// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
    apiKey: "AIzaSyBI-eWBa14Z3jrOaY_Y6A-lsmfoL7z4D9c",
    authDomain: "yanafssi.firebaseapp.com",
    projectId: "yanafssi",
    storageBucket: "yanafssi.firebasestorage.app",
    messagingSenderId: "863516411610",
    appId: "1:863516411610:web:2e87b1120e703e011a87e3",
    measurementId: "G-F1Z88B0873"
};

import { getFirestore } from "firebase/firestore";

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const db = getFirestore(app);

export { app, analytics, db };
