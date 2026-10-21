# WhyWait - Real-Time Taxi Tracking Platform

![Status](https://img.shields.io/badge/status-in%20development-yellow)
![Frontend](https://img.shields.io/badge/frontend-Flutter-blue)
![Backend](https://img.shields.io/badge/backend-Go-00ADD8)
![Database](https://img.shields.io/badge/database-PostgreSQL-336791)

---

## Short Description

**WhyWait** is a modern, real-time taxi tracking platform that connects passengers with nearby drivers through a seamless mobile application. Built with Flutter for the frontend, Go for the backend, and PostgreSQL for data storage, WhyWait eliminates the uncertainty of traditional taxi hailing by providing live vehicle tracking, estimated arrival times, and secure user authentication.

---

## The Problem Project Solves

In many cities, especially in developing regions, taxi services face significant challenges:

- **Unreliable pickup times** – Passengers often wait 30+ minutes without knowing if a taxi is actually coming.
- **Lack of transparency** – No real-time visibility into taxi locations or estimated arrival times.
- **Drivers leaving their assigned lanes** – Without enforcement, drivers deviate from their designated routes, causing longer waits and unpredictable service for passengers.
- **No route guidance** – Passengers don't know the fastest way to reach their destination or which corridor to take, leading to wasted time and inefficient trips.
- **Safety concerns** – Passengers and drivers have no verification or tracking system.
- **No direct channel for reporting issues** – When problems occur (overcharging, misconduct, route violations), passengers have no way to report them directly to the people responsible for fixing them.
- **No digital record** – Trips are not logged, making dispute resolution difficult.

**WhyWait** solves these problems by providing a **real-time taxi tracking platform** that connects passengers with nearby drivers through a modern, user-friendly mobile application. Drivers are assigned to specific lanes and routes to keep service predictable. Passengers receive recommended shortest-path guidance to reach their destination faster. And reports go directly to the admin team responsible for resolving them — so issues actually get fixed.

---

## Current Status

| Component | Status | Notes |
|---|---|---|
| Backend (Go + Postgres) | 🟡 In progress | REST + gRPC endpoints, JWT auth |
| Passenger Frontend (Flutter) | ✅ Complete | All screens built, merged to `main` |
| Driver Frontend (Flutter) | 🟡 In progress | Driver dashboard, seat counter, safety actions |
| Admin Panel (Flutter Web) | 🟡 Planned | Next milestone |
| Deployment | 🔴 Not started | Render (backend) + Vercel (frontend) |

---

## Main Features

### Backend
- [x] **Secure User Authentication** – Register, login, token-based sessions with JWT and bcrypt password hashing.
- [x] **PostgreSQL Database** – Stores user profiles, trip history, driver information, terminals, routes, and reports.
- [x] **RESTful API** – Fast and scalable Go backend with well-defined endpoints across 8 domain packages.
- [x] **gRPC API** – Real-time streaming for taxi positions and trip updates.
- [x] **Role-based access** – Passenger, driver, admin.
- [x] **User management** – Roles, status, driver approval workflow.
- [x] **Terminal & Route management** – CRUD for hubs and corridors.
- [x] **Route assignment** – Each driver is bound to a specific lane/corridor.
- [x] **Trip records** – History, fares, vehicle details.
- [x] **Report routing** – Reports go to the admin queue for action.
- [x] **Taxi simulator** – Test tool that moves taxis around for demo.

### Passenger Frontend (Flutter)
- [x] **Authentication** – Login and register with client-side validation, loading states, error snackbars.
- [x] **Home Dashboard** – Greeting, search, station card, summary stats, popular routes.
- [x] **Trip History** – Analytics (spend, time saved, breakdown), month picker, commute shortcuts, detailed trip cards.
- [x] **Live Tracking** – Interactive OpenStreetMap with taxi markers, ETAs, zoom controls.
- [x] **Shortest-path route recommendations** – Passengers see the fastest corridors to their destination.
- [x] **Direct incident reporting** – Reports route to admin queue for resolution.
- [x] **Profile** – Stats, settings, sign out.
- [x] **Route Planner** – Plan trips with fare and time estimates.
- [x] **Trip Details** – Leg-by-leg breakdown.
- [x] **Report Incident** – Multiple categories with filter tabs.
- [x] **Error / Loading / Empty States** – Every data screen handles all states.

### Driver Frontend (Flutter)
- [ ] **Driver Home** – Shift badge, dispatch queue, plate and route strip.
- [ ] **Seat Counter** – Increment/decrement open seats, mark full.
- [ ] **Daily Performance** – Trips completed, revenue, quota progress.
- [ ] **Traffic Alerts** – Corridor bottleneck notifications.
- [ ] **Safety Actions** – Report incident, dispatch hotline.
- [ ] **Route adherence** – Driver UI shows the assigned corridor; deviating triggers a warning.

### Admin Panel (Flutter Web) — Planned
- [ ] **Dashboard** – User counts, active taxis, pending reports.
- [ ] **Driver Approvals** – Review and approve pending drivers.
- [ ] **Driver Assignment** – Assign drivers to terminals and routes.
- [ ] **Reports Queue** – Review and resolve passenger reports.
- [ ] **Report resolution workflow** – Assign reports to staff, track resolution status.
- [ ] **Terminal Management** – Add/edit/delete terminals with GPS coordinates.
- [ ] **Taxi Management** – Register taxis, update driver details, change status.
- [ ] **User Management** – View users, change roles, ban accounts.

---

Name	CTC Number	Classroom Number	Role
Surafel Yihun	CTC-10004-26	3006	Backend Developer
Wengelle Yohannes	CTC-5554-26	3006	Backend Developer
Victory Bedru	CTC-4461-26	3006	Frontend Developer
Sabah Fuad	CTC-1156-26	3006	Frontend Developer
Siham Baharu	CTC-6989-26	3006	Database
