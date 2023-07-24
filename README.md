# QRify ME - An event tracking app.

Introducing an innovative event hosting and attending app! With this platform, event hosts can effortlessly manage their events and track attendee's presence within the event location. Whether you're organizing a conference, workshop, or social gathering, the app provides an all-in-one solution for an enhanced event experience.

## Problem Statement

The problem statement is to develop a system that utilizes QR codes to register people to an event and track their attendance using location based tracking. The system will send event related information only to those who are online and in the location of the event. Additionally the system will allow for real time feedback collection from the attendees in the event. The system will also allow for pre-processing by identifying individuals who are absent for more than 3 events and block them from future events.

## Solution

**1) QR Code Generation for Attendees:**
To generate QR codes for attendees, I utilized the 'qr_flutter' package. This package allowed me to easily generate unique QR codes for each attendee. By using this package, I was able to generate QR codes that could be scanned later for attendee verification.

**2) Integration of Google Maps API for Event Location:**
To set the event location and define a radius, I incorporated the Google Maps API. This integration enabled me to select the event location on Google map and specify a radius around it. By leveraging the Google Maps API, I obtained the latitude and longitude coordinates for the event location, which I then stored in the backend system to track the users within the designated area.

**3) Creation of a Real-time User Collection in the Database:**
To keep track of users present in event location in real-time, I created a collection in the database. This collection was designed to store user email. By continuously updating this collection in real-time, I could monitor the presence of users within the specified event location.

**4) Tracking User Attendance and Blocking Functionality:**
To track user attendance and implement a blocking mechanism, I introduced a 'time' field in the user's record. Initially, the 'time' field was set to '0'. When a user successfully presented their QR code and gained entry, I updated the 'time' field with the timestamp of the scan. Additionally, I provided the host with the ability to block users whose 'time' field remained '0' by implementing a block button. To keep track of the number of times a user was blocked, I included a 'blockCount' field in the user's collection, which was incremented each time a user was blocked. Once the 'blockCount' reached 3, the user was restricted from registering for future events.

## Tech Stack

**Flutter:** Front-end framework

**Firebase:** Back-end as a service

## Workflow

<!-- ![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/c8df3e09-1a29-4f47-8b8e-2e42aa3d373b) -->

## QRify ME app

**App Link:** https://drive.google.com/file/d/1Np-RL-XyX2NONKjGhxxfBxP7LbBHxhFA/view?usp=sharing

- Event Hosting
- Location tracking
- Attendee insights
- Event related updates
- Blocking registrations

![Logo](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/5a0a350e-7c79-4af3-9115-f43ca0fe8acb)

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/8da161d6-f045-4313-91a5-83cbd873d641)

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/a6c0bcf4-78d3-4de0-aa04-0b327fde1892)

## App registration and login

- Using firebase authentication, users can be authenticated.
- Once the user registers using his email a verification mail will be sent to user's entered email.
- By clicking on the link user will be verified and he can login to app again using registered email.
- While logging in user will be displayed with 2 options:

  i. Login as Host

  ii. Login as attendee

- User will be stay logged in after reopening the app again.

![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/bb42e7e4-e978-44da-b468-a0d521ddd365)

## Your Journey as a User who wants to host an event

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

## Your Journey as a user who wants to attend an event

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

## Backend

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

## Scanner

**Programming language:** python

- I used the OpenCV package to access the device camera and enable QR code scanning functionality. By utilizing OpenCV, I was able to capture frames from the camera feed and process them for QR code detection.
- To validate the scanned QR codes, I established a connection with my database. I retrieved the relevant data from the database and compared it with the data extracted from the scanned QR codes.
- Upon QR code detection and data retrieval, I implemented a verification mechanism to check if the scanned QR code data matched the data stored in the database. If a match was found, I allowed access or granted permission to the person associated with that QR code.

  ![image](https://github.com/saiabhiramjaini/QRify_ME/assets/115941546/1efeeca9-f067-4f9d-977f-633b6cf12eee)

## Applications

**This app can be best suitable for :**

- Workshops and training sessions.
- Community gathering and social events.
- Events hosted for educational purpose.
- Coorporate events.
- Cultural events.
- Sporting Events.

## Author

- (https://github.com/Vara-2004)
- **Repository :** (https://github.com/Vara-2004/Event-Tracker)

## Feedback

If you have any feedback, please reach out me at abhiramjaini28@gmail.com
