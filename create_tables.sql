CREATE DATABASE IF NOT EXISTS SysmexReferralsDB;
USE SysmexReferralsDB;

CREATE TABLE IF NOT EXISTS Patient (
    NHI VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    DOB DATE
);

CREATE TABLE IF NOT EXISTS Department (
    DepartmentID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Worker (
    WorkerID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Role ENUM('Surgeon', 'Referrer', 'Other') NOT NULL
);

CREATE TABLE IF NOT EXISTS WorkerAvailability (
    AvailabilityID INT AUTO_INCREMENT PRIMARY KEY,
    WorkerID INT NOT NULL,
    StartDT DATETIME NOT NULL,
    EndDT DATETIME NOT NULL,
    FOREIGN KEY (WorkerID) REFERENCES Worker(WorkerID)
);

CREATE TABLE IF NOT EXISTS Referral (
    ReferralID INT AUTO_INCREMENT PRIMARY KEY,
    NHI VARCHAR(10) NOT NULL,
    ReferralDate DATE NOT NULL,
    DepartmentID INT,
    ReferrerID INT,
    SurgeonID INT,
    AddedToWaitlistDate DATE,
    FsaDate DATE,
    HealthTargetEligible BOOLEAN,
    FOREIGN KEY (NHI) REFERENCES Patient(NHI),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    FOREIGN KEY (ReferrerID) REFERENCES Worker(WorkerID),
    FOREIGN KEY (SurgeonID) REFERENCES Worker(WorkerID)
);

CREATE TABLE IF NOT EXISTS Contact (
    ContactID INT AUTO_INCREMENT PRIMARY KEY,
    ReferralID INT NOT NULL,
    WorkerID INT NULL,
    ContactDate DATETIME NOT NULL,
    ActionTaken VARCHAR(255) NOT NULL,
    FollowUpContactID INT NULL,
    FOREIGN KEY (ReferralID) REFERENCES Referral(ReferralID),
    FOREIGN KEY (WorkerID) REFERENCES Worker(WorkerID),
    FOREIGN KEY (FollowUpContactID) REFERENCES Contact(ContactID)
);