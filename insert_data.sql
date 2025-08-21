USE SysmexReferralsDB;

SET GLOBAL local_infile = 1;

DROP TABLE IF EXISTS StagingReferral;
CREATE TABLE StagingReferral (
    ReferralDate VARCHAR(50),
    ReferredBy VARCHAR(100),
    NHI VARCHAR(10),
    PatientName VARCHAR(100),
    DOB VARCHAR(50),
    Department VARCHAR(100),
    AddedToWaitlistDate VARCHAR(50),
    Surgeon VARCHAR(100),
    FsaDate VARCHAR(50),
    HealthTargetEligible VARCHAR(10)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.4/Uploads/ARA July Data Wait Lists 2025.csv'
INTO TABLE StagingReferral
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(ReferralDate, ReferredBy, NHI, PatientName, DOB, Department, AddedToWaitlistDate, Surgeon, FsaDate, HealthTargetEligible);

INSERT IGNORE INTO Patient (NHI, Name, DOB)
SELECT DISTINCT
  TRIM(NHI),
  TRIM(PatientName),
  STR_TO_DATE(NULLIF(TRIM(DOB), ''), '%e/%c/%Y')
FROM StagingReferral
WHERE TRIM(NHI) <> '' AND NHI IS NOT NULL;

INSERT IGNORE INTO Department (Name)
SELECT DISTINCT TRIM(Department)
FROM StagingReferral
WHERE TRIM(Department) <> '' AND Department IS NOT NULL;

INSERT IGNORE INTO Worker (FullName, Role)
SELECT DISTINCT TRIM(ReferredBy), 'Referrer'
FROM StagingReferral
WHERE TRIM(ReferredBy) <> '' AND ReferredBy IS NOT NULL;

INSERT IGNORE INTO Worker (FullName, Role)
SELECT DISTINCT TRIM(Surgeon), 'Surgeon'
FROM StagingReferral
WHERE TRIM(Surgeon) <> '' AND Surgeon IS NOT NULL;

INSERT INTO Referral (
  NHI,
  ReferralDate,
  DepartmentID,
  ReferrerID,
  SurgeonID,
  AddedToWaitlistDate,
  FsaDate,
  HealthTargetEligible
)
SELECT
  TRIM(s.NHI),
  STR_TO_DATE(NULLIF(TRIM(s.ReferralDate), ''), '%e/%c/%Y'),
  d.DepartmentID,
  wr.WorkerID,
  ws.WorkerID,
  STR_TO_DATE(NULLIF(TRIM(s.AddedToWaitlistDate), ''), '%e/%c/%Y'),
  STR_TO_DATE(NULLIF(TRIM(s.FsaDate), ''), '%e/%c/%Y'),
  CASE 
    WHEN LOWER(TRIM(s.HealthTargetEligible)) = 'yes' THEN TRUE
    WHEN LOWER(TRIM(s.HealthTargetEligible)) = 'no'  THEN FALSE
    ELSE NULL
  END
FROM StagingReferral s
LEFT JOIN Department d ON d.Name = TRIM(s.Department)
LEFT JOIN Worker wr ON wr.FullName = TRIM(s.ReferredBy) AND wr.Role='Referrer'
LEFT JOIN Worker ws ON ws.FullName = TRIM(s.Surgeon)    AND ws.Role='Surgeon'
WHERE TRIM(s.NHI) <> '' AND s.NHI IS NOT NULL;
