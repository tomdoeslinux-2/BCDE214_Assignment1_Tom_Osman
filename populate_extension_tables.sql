SET SQL_SAFE_UPDATES = 0;

USE SysmexReferralsDB;

INSERT INTO WorkerAvailability (WorkerID, StartDT, EndDT)
SELECT SurgeonID,
       MIN(ReferralDate),
       MAX(COALESCE(FsaDate, ReferralDate))
FROM Referral
WHERE SurgeonID IS NOT NULL
GROUP BY SurgeonID;

INSERT INTO WorkerAvailability (WorkerID, StartDT, EndDT)
SELECT ReferrerID,
       MIN(ReferralDate),
       MAX(COALESCE(FsaDate, ReferralDate))
FROM Referral
WHERE ReferrerID IS NOT NULL
GROUP BY ReferrerID;

INSERT INTO Contact (ReferralID, WorkerID, ContactDate, ActionTaken)
SELECT ReferralID, ReferrerID, ReferralDate, 'Referral received'
FROM Referral
WHERE ReferralDate IS NOT NULL
  AND ReferrerID IS NOT NULL;

INSERT INTO Contact (ReferralID, WorkerID, ContactDate, ActionTaken)
SELECT ReferralID, SurgeonID, FsaDate, 'FSA scheduled'
FROM Referral
WHERE FsaDate IS NOT NULL
  AND SurgeonID IS NOT NULL;

UPDATE Contact c1
JOIN Contact c2
  ON c2.ReferralID = c1.ReferralID AND c2.ActionTaken = 'FSA scheduled'
SET c1.FollowUpContactID = c2.ContactID
WHERE c1.ActionTaken = 'Referral received';
