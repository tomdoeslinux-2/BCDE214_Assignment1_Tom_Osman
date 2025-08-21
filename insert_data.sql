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
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(ReferralDate, ReferredBy, NHI, PatientName, DOB, Department, AddedToWaitlistDate, Surgeon, FsaDate, HealthTargetEligible);

INSERT IGNORE INTO Patient (NHI, Name, DOB)
SELECT DISTINCT 
  NHI, 
  PatientName, 
  STR_TO_DATE(NULLIF(DOB, ''), '%d/%m/%Y')
FROM StagingReferral;

INSERT IGNORE INTO Department (Name)
SELECT DISTINCT Department
FROM StagingReferral
WHERE Department IS NOT NULL AND Department <> '';

INSERT IGNORE INTO Worker (FullName, Role)
SELECT DISTINCT ReferredBy, 'Referrer'
FROM StagingReferral
WHERE ReferredBy IS NOT NULL AND ReferredBy <> '';

INSERT IGNORE INTO Worker (FullName, Role)
SELECT DISTINCT Surgeon, 'Surgeon'
FROM StagingReferral
WHERE Surgeon IS NOT NULL AND Surgeon <> '';

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
  s.NHI,
  STR_TO_DATE(NULLIF(s.ReferralDate, ''), '%d/%m/%Y'),
  d.DepartmentID,
  wr.WorkerID AS ReferrerID,
  ws.WorkerID AS SurgeonID,
  STR_TO_DATE(NULLIF(s.AddedToWaitlistDate, ''), '%d/%m/%Y'),
  STR_TO_DATE(NULLIF(s.FsaDate, ''), '%d/%m/%Y'),
  CASE 
    WHEN LOWER(TRIM(s.HealthTargetEligible)) = 'yes' THEN TRUE
    WHEN LOWER(TRIM(s.HealthTargetEligible)) = 'no'  THEN FALSE
    ELSE NULL
  END
FROM StagingReferral s
LEFT JOIN Department d ON d.Name = s.Department
LEFT JOIN Worker wr ON wr.FullName = s.ReferredBy AND wr.Role='Referrer'
LEFT JOIN Worker ws ON ws.FullName = s.Surgeon AND ws.Role='Surgeon';