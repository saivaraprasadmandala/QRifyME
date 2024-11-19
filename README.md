# QRify ME - An event tracking app.

Welcome to **QRify ME**, an innovative app designed to simplify event hosting and attendance tracking! With features like QR code-based registration, location tracking, real-time notifications, and feedback collection, QRify ME is your all-in-one solution for managing events effortlessly.

## 🌟 **Features at a Glance**
- **Event Hosting**: Manage and organize events with ease.
- **Location-Based Tracking**: Ensure attendee presence within the event radius.
- **QR Code Verification**: Authenticate attendees for seamless entry.
- **Real-Time Updates**: Send event-related updates to attendees present at the event location.
- **Feedback Collection**: Gather attendee feedback during the event.
- **Smart Blocking**: Restrict users who fail to attend multiple registered events.

## 🛠 **Problem Statement**

Organizing events often involves challenges like verifying attendees, tracking their presence, and collecting feedback. QRify ME addresses these issues with:
- QR code-based event registration and attendance tracking.
- Real-time location-based updates.
- Automated feedback collection.
- A mechanism to block users absent from multiple events.

## 🚀 **Solution**
### **1️⃣ QR Code Generation**
Utilizing the `qr_flutter` package, we generate unique QR codes for attendees. These codes serve as digital tickets for authentication.

### **2️⃣ Location-Based Tracking**
Integrated with **Google Maps API**, QRify ME allows hosts to:
- Set event locations.
- Define a radius for attendance tracking.
- Store latitude and longitude coordinates for precise monitoring.

### **3️⃣ Real-Time User Database**
A dynamic user collection in **Firebase Firestore** tracks attendees present at the event location. This ensures accurate attendance records.

### **4️⃣ Attendance & Blocking Mechanism**
- Attendees' QR codes are scanned to verify their presence.
- Hosts can block users absent from three or more events.
- Each user’s attendance status is tracked using a `blockCount` field, ensuring fair participation.


## 💻 **Tech Stack**
| **Technology** | **Purpose**       |
|-----------------|-------------------|
| **Flutter**     | Frontend Framework |
| **Firebase**    | Backend as a Service |

## 🛠 **Workflow**
1. Event hosts set up event details, including location and radius.
2. Attendees register and receive QR codes.
3. QR codes are scanned for authentication at the venue.
4. Location-based tracking ensures attendees are within the event radius.
5. Feedback collection and notifications enhance engagement.
6. Block absent attendees automatically after three no-shows.

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/c8df3e09-1a29-4f47-8b8e-2e42aa3d373b) 

## QRify ME app

**[Download the App Here](https://drive.google.com/file/d/1Np-RL-XyX2NONKjGhxxfBxP7LbBHxhFA/view?usp=sharing)**

![Logo](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/5a0a350e-7c79-4af3-9115-f43ca0fe8acb)

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/8da161d6-f045-4313-91a5-83cbd873d641)

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/a6c0bcf4-78d3-4de0-aa04-0b327fde1892)

### 📝 **Registration & Login**
- **Firebase Authentication** ensures secure login and user verification.
- New users receive a verification email upon registration.
- Login options include:
  - **Host Login**: For event organizers.
  - **Attendee Login**: For event participants.
- User will be stay logged in after reopening the app again.

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/bb42e7e4-e978-44da-b468-a0d521ddd365)

### 🎉 **Hosting an Event**

- Host an event by filling out a form that includes event details.
- Set the event location and radius on Google Maps.
- Store these details in Firebase Firestore.
- Retrieve a list of registered users.
- Retrieve a list of users present at the event location.
- Collect feedback from attendees.
- Send notifications to users present at the event location and to all users who have registered for the event.
- Block attendees from future registrations: If an attendee registers for an event but fails to attend, the host can block the attendee by clicking on the "Block Users" button.

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/969db31f-70e3-4243-96bc-15610949ed84)

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/c1c73e9d-14fb-4ad6-ac25-bf3acc3b4f00)

### 🧑‍🤝‍🧑 **Attending an Event**

- Attendees can view all the hosted events and register for them.
- Once a user successfully registers for an event, they will receive an event-related QR code. The QR code will contain the user's email and the timestamp of the event when it was hosted.
- When the user arrives at the event location, they need to present the QR code.
- The data in the QR code will be verified against the data present in the Firestore database. If the data doesn't match, the user will not be allowed entry.
- After a successful entry, the Firestore database will update the 'time' field, preventing the user from being blocked by the host.
- The user will now be tracked by accessing his device location.
- If the user doesn't allow permission then no tracking will happen.
- Only if the user is present inside the event location, they can submit feedback.
- Users will receive notifications based on the host's interest.

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/3937d89e-df76-47d9-b607-27cfec8c5808)

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/f236cd73-b688-472e-b890-67be98428990)

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/417053e7-4dd8-4427-b7d5-95372b7c72f6)

## 🔧 **Backend Overview**

**Firebase Authentication :**

- Sign-in method used : email/password.
- With the help of firebase authentication user will be registered and user's email is visible at backend.
- A verification email will be sent to user when the user registers through which user gets verified.

**Firebase Firestore:**

- This is our database.
- It has 2 collections 'events' and 'users'.
- events is used to store all event related info.
- users collection will store users email, phone and username. In users there is a subcollection with name 'registeredEvents'.

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/6d16302f-aced-480a-8626-656b8cf6cfdb)

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/10d642ec-d26d-4f8b-af3f-fdb8fcfe9e17)

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/f94e2f5c-65c2-4ea5-8a5c-8112c3f34372)

## 🎯 **QR Code Scanning**

**Programming language:** python

- We used the OpenCV package to access the device camera and enable QR code scanning functionality. By utilizing OpenCV, we were able to capture frames from the camera feed and process them for QR code detection.
- To validate the scanned QR codes, we established a connection with my database and retrieved the relevant data,compared it with the data extracted from the scanned QR codes.
- Upon QR code detection and data retrieval, we implemented a verification mechanism to check if the scanned QR code data matched the data stored in the database. If a match was found, we allowed access or granted permission to the person associated with that QR code.

  ![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/1efeeca9-f067-4f9d-977f-633b6cf12eee)


## 🌐 **Applications**
QRify ME is ideal for:
- 🏢 **Workshops and Training Sessions**  
- 🎓 **Educational Events**  
- 🎭 **Cultural Gatherings**  
- 🏅 **Sporting Events**  
- 🏛 **Corporate Conferences**  

## 🧑‍💻 **Author**
- GitHub: [saivaraprasadmandala](https://github.com/saivaraprasadmandala)
- **Repository**: [QRify ME Repository](https://github.com/saivaraprasadmandala/Event-Tracker)
- **Email**: mandalasaivaraprasad@gmail.com

## 💬 **Feedback**
We value your feedback! Please share your thoughts with us at **mandalasaivaraprasad@gmail.com**.
