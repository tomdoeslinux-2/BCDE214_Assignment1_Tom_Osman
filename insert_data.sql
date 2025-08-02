USE SysmexReferralsDB;

SET GLOBAL local_infile = 1;

DROP TABLE IF EXISTS StagingReferral;
CREATE TABLE StagingReferral (
    ReferralDate VARCHAR(20),
    ReferredBy VARCHAR(100),
    NHI VARCHAR(10),
    PatientName VARCHAR(100),
    DOB VARCHAR(20),
    Department VARCHAR(100),
    AddedToWaitlistDate VARCHAR(20),
    Surgeon VARCHAR(100),
    FsaDate VARCHAR(20),
    HealthTargetEligible VARCHAR(10)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.4/Uploads/ARA July Data Wait Lists 2025.csv'
INTO TABLE StagingReferral
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'  -- Use '\n' if needed
IGNORE 1 ROWS
(ReferralDate, ReferredBy, NHI, PatientName, DOB, Department, AddedToWaitlistDate, Surgeon, FsaDate, HealthTargetEligible);

INSERT IGNORE INTO Patient (NHI, Name, DOB)
SELECT DISTINCT 
  NHI, 
  PatientName, 
  STR_TO_DATE(NULLIF(DOB, ''), '%d/%m/%Y')
FROM StagingReferral;

INSERT INTO Referral (
  NHI,
  ReferralDate,
  ReferredBy,
  Department,
  AddedToWaitlistDate,
  Surgeon,
  FsaDate,
  HealthTargetEligible
)
SELECT
  NHI,
  STR_TO_DATE(NULLIF(ReferralDate, ''), '%d/%m/%Y'),
  ReferredBy,
  Department,
  STR_TO_DATE(NULLIF(AddedToWaitlistDate, ''), '%d/%m/%Y'),
  Surgeon,
  STR_TO_DATE(NULLIF(FsaDate, ''), '%d/%m/%Y'),
  CASE 
    WHEN LOWER(TRIM(HealthTargetEligible)) = 'yes' THEN TRUE
    WHEN LOWER(TRIM(HealthTargetEligible)) = 'no' THEN FALSE
    ELSE NULL
  END
FROM StagingReferral;