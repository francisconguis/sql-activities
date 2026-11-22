# SQL Activities

A collection of SQL and Database Administration exercises (MySQL).

## Structure

```text
sql-activities/
└── Trigger/
    ├── Trigger-v1/
    │   ├── Trigger v1.sql
    │   ├── Customer_T.csv
    │   └── Salesman_T.csv
    └── Trigger-v2/
        └── Trigger v2.sql
```

### Activities

- **Trigger / Trigger-v1** — Solution for **Exercises-Trigger** (`EXER0927`): Audit logging triggers (`TR_InsCust`, `TR_UpdCust`, `TR_DelCust`), stored procedure with explicit transaction control (`SP_DelCust`), and view (`CustSman_V`) using `Customer_T.csv` and `Salesman_T.csv`.
- **Trigger / Trigger-v2** — Solution for **Trigger Room Exercises 2026** (`RoomDB`): Room booking status trigger (`TR_UpdateRoomStatus`) and stored procedures in autocommit (`SP_InsertTrans_Auto`) and explicit transaction (`SP_InsertTrans_Explicit`) modes.
