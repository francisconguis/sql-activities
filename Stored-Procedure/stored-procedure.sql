-- 1. Count Total Enrollees Per Program for a Given Academic Year/Semester --
DELIMITER $$

CREATE PROCEDURE sp_CountEnrolleesPerProgram(
    IN p_AYSem VARCHAR(15)
)
BEGIN
    SELECT 
        s.Program,
        COUNT(DISTINCT c.StudentID) AS TotalEnrollees
    FROM course c
    INNER JOIN student s ON c.StudentID = s.StudentID
    WHERE c.AYSem = p_AYSem
    GROUP BY s.Program
    ORDER BY TotalEnrollees DESC;
END$$

DELIMITER ;

-- 2. Count Total Enrollees per Course Subject for a Given Academic Year --
DELIMITER $$

CREATE PROCEDURE sp_CountEnrolleesPerSubject(
    IN p_AY VARCHAR(10)
)
BEGIN
    SELECT 
        c.CourseCode,
        p.Description,
        COUNT(DISTINCT c.StudentID) AS TotalEnrollees
    FROM course c
    LEFT JOIN (
        SELECT DISTINCT CourseCode, Description 
        FROM program
    ) p ON c.CourseCode = p.CourseCode
    WHERE c.AYSem LIKE CONCAT(p_AY, '%')
    GROUP BY c.CourseCode, p.Description
    ORDER BY TotalEnrollees DESC;
END$$

DELIMITER ;

-- 3. Students Who Exceeded Allowed Tenure --
DELIMITER $$

CREATE PROCEDURE sp_GetExceededTenure(
    IN p_AllowedTenure INT
)
BEGIN
    SELECT 
        StudentID,
        StudentName,
        Program AS Course,
        ContactNo
    FROM student
    WHERE YearGraduated IS NULL
      AND (YEAR(CURDATE()) - CAST(LEFT(StudentID, 4) AS SIGNED)) > p_AllowedTenure;
END$$

DELIMITER ;

-- 4. Dean's Listers (Average Grade <= 1.5) --
DELIMITER $$

CREATE PROCEDURE sp_GetDeansListers(
    IN p_AYSem VARCHAR(15),
    IN p_Program VARCHAR(10)
)
BEGIN
    SELECT 
        s.StudentID,
        s.StudentName
    FROM student s
    INNER JOIN course c ON s.StudentID = c.StudentID
    WHERE c.AYSem = p_AYSem
      AND s.Program = p_Program
    GROUP BY s.StudentID, s.StudentName
    HAVING AVG(c.Grade) <= 1.5;
END$$

DELIMITER ;

-- 5. List Student ID and All Subjects with Grades -- 
DELIMITER $$

CREATE PROCEDURE sp_ListStudentGrades()
BEGIN
    SELECT 
        c.StudentID,
        c.CourseCode,
        p.Description,
        c.Grade
    FROM course c
    LEFT JOIN (
        SELECT DISTINCT CourseCode, Description 
        FROM program
    ) p ON c.CourseCode = p.CourseCode
    ORDER BY c.StudentID, c.CourseCode;
END$$

DELIMITER ;

-- 6. Candidates for Latin Honors (Top 3) -- 
DELIMITER $$

CREATE PROCEDURE sp_GetHonorsCandidates(
    IN p_Program VARCHAR(10)
)
BEGIN
    SELECT 
        s.StudentID,
        s.StudentName
    FROM student s
    INNER JOIN course c ON s.StudentID = c.StudentID
    WHERE s.Program = p_Program
      -- 6.1: Must not have a failing grade of 5.0
      AND s.StudentID NOT IN (
          SELECT StudentID 
          FROM course 
          WHERE Grade >= 5.0
      )
      -- 6.2: Must not have a grade lower/worse than 1.75 (i.e. > 1.75)
      AND s.StudentID NOT IN (
          SELECT StudentID 
          FROM course 
          WHERE Grade > 1.75
      )
    GROUP BY s.StudentID, s.StudentName
    ORDER BY AVG(c.Grade) ASC
    LIMIT 3;
END$$

DELIMITER ;

-- 1. Enrollees per Program for a Term
CALL sp_CountEnrolleesPerProgram('2016-2017S1');

-- 2. Enrollees per Subject for a School Year
CALL sp_CountEnrolleesPerSubject('2014-2015');

-- 3. Students Exceeding Allowed Tenure
CALL sp_GetExceededTenure(5);

-- 4. Dean's Listers
CALL sp_GetDeansListers('2016-2017S1', 'BSIT');

-- 5. All Students with Subjects and Grades
CALL sp_ListStudentGrades();

-- 6. Latin Honors Candidates (Top 3)
CALL sp_GetHonorsCandidates('BSCS');

