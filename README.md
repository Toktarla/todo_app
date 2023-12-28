# Project Report: To-Do Application

## Project Details
- **Project Name:** ToDo Application
- **Author:** Toktar Sultan
- **Group:** SE-2202

## Abstract
This project is a comprehensive to-do application designed to assist users in managing their tasks efficiently. Leveraging Firebase services such as Firestore, Firebase Authentication, and Cloud Storage, this application provides a secure and user-friendly environment for task management.

## Objectives
- Implement user authentication with email verification.
- Enable users to upload and manage their profile pictures using Cloud Storage.
- Develop a user-specific task list functionality stored and managed through Firestore.
- Allow users to mark tasks as complete or incomplete within the application.

## Technologies Used
- **Firebase Firestore:** Utilized for storing user-specific task lists.
- **Firebase Authentication:** Enabled secure user sign-in and sign-up processes with email verification.
- **Cloud Storage:** Used for securely storing user profile pictures.
- **Flutter:** Used for frontend to make comprehensive UI

## Features Implemented
1. **User Authentication:**
    - Sign-up and sign-in with email verification for secure access.
2. **Profile Management:**
    - Ability for users to upload and update their profile pictures.
3. **Task Management:**
    - User-specific to-do lists managed through Firestore.
    - Task completion status tracking.
    - Nested lists

## Implementation Details
- **User Authentication:**
    - Implemented Firebase Authentication SDK for sign-up, sign-in, and email verification.
- **Profile Management:**
    - Utilized Cloud Storage SDK to manage profile pictures associated with user accounts.
- **Task Management:**
    - Integrated Firestore to store and manage user-specific task lists based on unique user IDs (UIDs).

## Usage Instructions
1. **Sign Up / Sign In:**
    - Register a new account using the sign-up feature.
    - Verify the account through the email verification process.
    - Sign in using the created credentials.
2. **Profile Picture:**
    - Access the profile section to upload or update your profile picture.
3. **Task Management:**
    - Utilize the to-do list section to manage your tasks.
    - Mark tasks as complete or incomplete based on your progress.

## Conclusion
This project successfully implements a functional to-do application with user authentication, profile management, and task handling capabilities. Leveraging Firebase services ensured a robust and scalable solution, providing a seamless user experience.

## Future Enhancements
- **Task Scheduling and Expiry:** Implement scheduling functionalities and expiration dates for tasks.
- **Enhanced UI/UX:** Revamp the user interface for a more aesthetically pleasing and intuitive experience.
- **Additional Authentication Methods:** Incorporate alternative methods for authentication, such as OAuth for Gmail login.
- **Global Search Feature:** Enable users to search across all tasks for improved navigation and efficiency.
- **Theme Customization:** Introduce the ability for users to change application themes for a personalized experience.

