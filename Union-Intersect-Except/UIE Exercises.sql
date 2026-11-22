/* 1. Combine in a result set , the names and the score of all who took ITIL ,or PMP certification, or both. 
If a person took both exams, then her name should appear twice in the list, together with her scores in both exams. */

SELECT Sname, Score 
FROM ITIL
UNION ALL
SELECT Sname, Score 
FROM PMP;

-- 2. List all who took both exams, name only --

SELECT i.Sname
FROM ITIL i
INNER JOIN PMP p ON i.Empno = p.Empno;

-- 3. List all passers of both exams (name only). The passing score is 60 for PMP and 50 for ITIL. --

SELECT i.Sname
FROM ITIL i
INNER JOIN PMP p ON i.Empno = p.Empno
WHERE i.Score >= 50 
  AND p.Score >= 60;
  
-- 4. List the names of all who took ITIL but who did not take PMP exam. --

SELECT i.Sname
FROM ITIL i
LEFT JOIN PMP p ON i.Empno = p.Empno
WHERE p.Empno IS NULL;

-- 5. List the names of all who took PMP but who did not take ITIL exam. --

SELECT p.Sname
FROM PMP p
LEFT JOIN ITIL i ON p.Empno = i.Empno
WHERE i.Empno IS NULL;

-- 6. List all who passed ITIL but who failed the PMP exam. --

SELECT i.Sname
FROM ITIL i
INNER JOIN PMP p ON i.Empno = p.Empno
WHERE i.Score >= 50 
  AND p.Score < 60;
  
-- 7. List all who passed PMP but who failed the ITIL exam. --

SELECT p.Sname
FROM PMP p
INNER JOIN ITIL i ON p.Empno = i.Empno
WHERE p.Score >= 60 
  AND i.Score < 50;
  
-- 8. List all who passed ITIL but who did not take the PMP exam. -- 

SELECT i.Sname
FROM ITIL i
LEFT JOIN PMP p ON i.Empno = p.Empno
WHERE i.Score >= 50 
  AND p.Empno IS NULL;
  
-- 9. List all names (with score) who got the same score in both exams. --

SELECT i.Sname, i.Score
FROM ITIL i
INNER JOIN PMP p ON i.Empno = p.Empno
WHERE i.Score = p.Score;