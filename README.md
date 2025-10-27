# DISCLAIMER
**This Company and Application are completely fictionals.**
These have been created for the purpose of Learning:
- Manage a Project E2E by collecting the requirement to a TestFlight publication.
- Build with Swift/SwiftUI

---

## 🎯 Project Vision

**"Your library, always at hand"**

MyBookShelf is an iOS application built with SwiftUI that helps organized readers manage their personal book library simply. This app allows users to catalog their books, track reading progress, and organize their collection directly from their smartphone.

## ✨ MVP Features

### Book Management (CRUD)
- **Add books** via Google Books API search or manual entry
- **Edit books** with title, author, and reading status
- **Delete books** with confirmation dialog
- **Book covers** automatically retrieved from Google Books API when added via API

### Library Organization
- **Main list view** displaying all books with covers
- **Multiple sort options**: by Title, Author, Date Added, or Status
- **Ascending/descending** order for each sort option
- **Search functionality** to quickly find books
- **Persistent preferences** for default sort settings

### Progress Tracking
- **Visual statistics** with pie chart or bar chart (user choice)
- **Count display** showing books in each status category
- **Percentage calculations** of reading progress
- **Global overview** of entire library

### Reading Reminders
- **Daily notifications** for books with "Reading" status


### User Experience Philosophy
- **Simplicity first**: Focus on essential features
- **Ergonomics over effects**: Functional and pleasant to use
- **iOS native patterns**: TabBar navigation, standard components
- **Visual coherence**: Brand colors used for accents throughout

## 📱 Screenshots

| Library Tab | Progress Tab | Settings Tab | Book Search | Add/Edit Book |
|:---:|:---:|:---:|:---:|:---:|
| <img width="200" alt="Main list with books, covers, and sort options" src="https://github.com/user-attachments/assets/161f0351-45bd-45b2-8431-74fd861be313" /> | <img width="200" alt="Pie/bar charts showing reading statistics" src="https://github.com/user-attachments/assets/2c84f7cd-d2c4-4c03-a171-92e442ba49ce" /> | <img width="200" alt="Sort preferences and notification settings" src="https://github.com/user-attachments/assets/ca9583bf-c49d-4e56-953b-f877276f908c" /> | <img width="200" alt="Google Books API results" src="https://github.com/user-attachments/assets/2a79385b-8337-45f1-aaff-bc2c31872833" /> | <img width="200" alt="Form with title, author, status fields" src="https://github.com/user-attachments/assets/cf661f51-64c5-4ef1-83b8-4f483db430f5" /> |


## 🔧 Technical Architecture

### Technologies
- **Framework**: SwiftUI
- **Database**: SwiftData
- **API**: Google Books API with anonymous access
- **Notifications**: Local notifications with UserNotifications framework

---

## 📄 License

This project is under MIT License. See the [LICENSE](LICENSE) file for more details.
