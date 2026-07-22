CREATE TABLE IF NOT EXISTS "schedule" (
	"id"	INTEGER NOT NULL UNIQUE,
	"type"	INTEGER NOT NULL,
	"run_at"	TEXT NOT NULL,
	"run_interval"	INTEGER,
	"status"	INTEGER NOT NULL DEFAULT 0,
	"params"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("type") REFERENCES "job"("id") on update cascade on delete restrict
);
CREATE TABLE IF NOT EXISTS "job" (
	"id"	INTEGER NOT NULL UNIQUE,
	"type"	TEXT NOT NULL,
	"description"	TEXT,
	"enabled"	INTEGER COLLATE BINARY,
	"limited"	INTEGER NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "config" (
	"key"	TEXT NOT NULL UNIQUE,
	"value"	TEXT
);
CREATE TABLE IF NOT EXISTS "agent" (
	"code"	TEXT NOT NULL,
	"name"	TEXT NOT NULL,
	CONSTRAINT "pk_agent_code" PRIMARY KEY("code")
);
CREATE TABLE IF NOT EXISTS "call" (
	"linked_id"	TEXT NOT NULL UNIQUE,
	"peer_phone"	TEXT NOT NULL,
	"call_date_time"	TEXT NOT NULL,
	"bill_sec"	INTEGER NOT NULL DEFAULT 0,
	"direction"	INTEGER NOT NULL,
	"wait_time"	INTEGER NOT NULL DEFAULT 0,
	"queue"	TEXT NOT NULL,
	"protocol"	TEXT,
	CONSTRAINT "pk_call_linked_id" PRIMARY KEY("linked_id")
);
CREATE TABLE IF NOT EXISTS "call_event" (
	"id"	INTEGER NOT NULL UNIQUE,
	"linked_id"	TEXT NOT NULL,
	"agent_code"	TEXT NOT NULL DEFAULT 'NONE',
	"event_date_time"	TEXT NOT NULL UNIQUE,
	"status"	INTEGER NOT NULL,
	"hangup_cause"	INTEGER NOT NULL,
	"event"	INTEGER NOT NULL,
	"wait_time"	INTEGER NOT NULL DEFAULT 0,
	CONSTRAINT "idx_call_event_linkedid_eventdatetime" UNIQUE("linked_id","event_date_time"),
	CONSTRAINT "pk_call_event" PRIMARY KEY("id" AUTOINCREMENT)
);
