# SQL Activities

A collection of SQL and Database Administration exercises (MySQL).

## Structure

```text
sql-activities/
├── Stored-Procedure/
│   ├── Stored Proc-Multi Tables-Subq.pdf
│   ├── stored-procedure.sql
│   ├── course.csv
│   ├── program.csv
│   └── student.csv
├── Trigger/
│   ├── Trigger-v1/
│   │   ├── Exercises-Trigger.pdf
│   │   ├── Trigger v1.sql
│   │   ├── Customer_T.csv
│   │   └── Salesman_T.csv
│   └── Trigger-v2/
│       ├── Trigger Room Exercises 2026.pdf
│       └── Trigger v2.sql
└── Union-Intersect-Except/
    ├── Union-Int-Exc Exercises.pdf
    ├── UIE Exercises.sql
    ├── ITIL.csv
    ├── Master.csv
    └── PMP.csv
```

### Activities

- **Stored-Procedure** — Solution for **Stored Proc-Multi Tables-Subq**: Stored procedures for student enrollment and academic reporting (`sp_CountEnrolleesPerProgram`, `sp_CountEnrolleesPerSubject`, `sp_GetExceededTenure`, `sp_GetDeansListers`, `sp_ListStudentGrades`, `sp_GetHonorsCandidates`) using `course.csv`, `program.csv`, and `student.csv`.
- **Trigger / Trigger-v1** — Solution for **Exercises-Trigger** (`EXER0927`): Audit logging triggers (`TR_InsCust`, `TR_UpdCust`, `TR_DelCust`), stored procedure with explicit transaction control (`SP_DelCust`), and view (`CustSman_V`) using `Customer_T.csv` and `Salesman_T.csv`.
- **Trigger / Trigger-v2** — Solution for **Trigger Room Exercises 2026** (`RoomDB`): Room booking status trigger (`TR_UpdateRoomStatus`) and stored procedures in autocommit (`SP_InsertTrans_Auto`) and explicit transaction (`SP_InsertTrans_Explicit`) modes.
- **Union-Intersect-Except** — Solution for **Union-Int-Exc Exercises**: Set-operation and join queries (`UNION ALL`, `INNER JOIN`, `LEFT JOIN`) comparing ITIL and PMP exam takers, passers, and scores using `ITIL.csv`, `PMP.csv`, and `Master.csv`.
