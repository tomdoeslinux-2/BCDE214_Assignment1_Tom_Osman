CREATE DATABASE IF NOT EXISTS SysmexReferralsDB;
USE SysmexReferralsDB;

CREATE TABLE IF NOT EXISTS Patient (
    NHI VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100),
    DOB DATE
);

CREATE TABLE IF NOT EXISTS Referral (
    ReferralID INT PRIMARY KEY AUTO_INCREMENT,
    NHI VARCHAR(10),
    ReferralDate DATE,
    ReferredBy VARCHAR(100),
    Department VARCHAR(100),
    AddedToWaitlistDate DATE,
    Surgeon VARCHAR(100),
    FsaDate DATE,
    HealthTargetEligible BOOLEAN,
    FOREIGN KEY (NHI) REFERENCES Patient(NHI)
);