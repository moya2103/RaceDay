IF EXISTS (SELECT name FROM sys.databases WHERE name = N'RaceDayDB')
BEGIN
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
END
GO

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

-- Table 1: Users

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Organiser', 'Participant')),
    PhoneNumber NVARCHAR(20) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1
);
GO

-- Table 2: Participants

CREATE TABLE Participants (
    ParticipantID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    DateOfBirth DATE NOT NULL,
    Gender NVARCHAR(10) NOT NULL CHECK (Gender IN ('Male', 'Female', 'Other')),
    PhoneNumber NVARCHAR(20) NULL,
    EmergencyContact NVARCHAR(255) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_Participants_Users FOREIGN KEY (UserID) 
        REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

-- Table 3: Organisers

CREATE TABLE Organisers (
    OrganiserID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    CompanyName NVARCHAR(255) NULL,
    OrganisationPhoneNumber NVARCHAR(20) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_Organisers_Users FOREIGN KEY (UserID) 
        REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

-- Table 4: Events

CREATE TABLE Events (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID INT NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    EventDate DATETIME NOT NULL,
    Location NVARCHAR(255) NOT NULL,
    Distance DECIMAL(10,2) NOT NULL,
    EventType NVARCHAR(20) NOT NULL CHECK (EventType IN ('Run', 'Walk', 'Cycle')),
    BannerImage NVARCHAR(500) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1,
    
    CONSTRAINT FK_Events_Organisers FOREIGN KEY (OrganiserID) 
        REFERENCES Organisers(OrganiserID) ON DELETE CASCADE
);
GO

-- Table 5: Categories

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255) NULL,
    MinAge INT NULL,
    MaxAge INT NULL,
    Distance DECIMAL(10,2) NULL,
    EntryFee DECIMAL(10,2) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventID) 
        REFERENCES Events(EventID) ON DELETE CASCADE
);
GO

-- Table 6: Enrolments

CREATE TABLE Enrolments (
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    EventID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending' 
        CHECK (Status IN ('Pending', 'Confirmed', 'Completed', 'Cancelled')),
    PaymentStatus NVARCHAR(20) NOT NULL DEFAULT 'Unpaid'
        CHECK (PaymentStatus IN ('Unpaid', 'Paid', 'Refunded')),
    
    CONSTRAINT FK_Enrolments_Participants FOREIGN KEY (ParticipantID) 
        REFERENCES Participants(ParticipantID) ON DELETE CASCADE,
    CONSTRAINT FK_Enrolments_Events FOREIGN KEY (EventID) 
        REFERENCES Events(EventID),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryID) 
        REFERENCES Categories(CategoryID),
    
    CONSTRAINT UQ_Enrolments_ParticipantEvent UNIQUE (ParticipantID, EventID)
);
GO

-- Table 7: Results

CREATE TABLE Results (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL UNIQUE,
    FinishTime TIME NULL,
    Position INT NULL,
    IsCompleted BIT NOT NULL DEFAULT 0,
    Notes NVARCHAR(500) NULL,
    RecordedAt DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentID) 
        REFERENCES Enrolments(EnrolmentID) ON DELETE CASCADE
);
GO

CREATE INDEX IX_Events_EventDate ON Events(EventDate);
CREATE INDEX IX_Events_EventType ON Events(EventType);
CREATE INDEX IX_Events_OrganiserID ON Events(OrganiserID);
CREATE INDEX IX_Categories_EventID ON Categories(EventID);
CREATE INDEX IX_Enrolments_ParticipantID ON Enrolments(ParticipantID);
CREATE INDEX IX_Enrolments_EventID ON Enrolments(EventID);
CREATE INDEX IX_Enrolments_Status ON Enrolments(Status);
CREATE INDEX IX_Results_EnrolmentID ON Results(EnrolmentID);
GO

-- SEED DATA - USERS (2 Organisers, 4 Participants)

INSERT INTO Users (Email, PasswordHash, FullName, Role, PhoneNumber, CreatedAt, IsActive)
VALUES 
    ('bongani.zulu@raceday.co.za', 'hashed_password_1', 'Bongani Zulu', 'Organiser', '0829876543', GETDATE(), 1),
    ('nomvula.dube@raceday.co.za', 'hashed_password_2', 'Nomvula Dube', 'Organiser', '0838765432', GETDATE(), 1),
    ('sandile.mkhize@gmail.com', 'hashed_password_3', 'Sandile Mkhize', 'Participant', '0713456789', GETDATE(), 1),
    ('amanda.ngcobo@gmail.com', 'hashed_password_4', 'Amanda Ngcobo', 'Participant', '0724567890', GETDATE(), 1),
    ('thulani.sibiya@gmail.com', 'hashed_password_5', 'Thulani Sibiya', 'Participant', '0735678901', GETDATE(), 1),
    ('nokuthula.mthembu@gmail.com', 'hashed_password_6', 'Nokuthula Mthembu', 'Participant', '0746789012', GETDATE(), 1);
GO

INSERT INTO Organisers (UserID, CompanyName, OrganisationPhoneNumber, CreatedAt)
VALUES 
    (1, 'Durban Running Club', '0317654321', GETDATE()),
    (2, 'Cape Town Sports Events', '0218765432', GETDATE());
GO

INSERT INTO Participants (UserID, DateOfBirth, Gender, PhoneNumber, EmergencyContact, CreatedAt)
VALUES 
    (3, '1992-07-20', 'Male', '0713456789', 'Lindiwe Mkhize - 0713456790', GETDATE()),
    (4, '1987-09-15', 'Female', '0724567890', 'Sipho Ngcobo - 0724567891', GETDATE()),
    (5, '1998-02-28', 'Male', '0735678901', 'Gugu Sibiya - 0735678902', GETDATE()),
    (6, '1990-06-12', 'Female', '0746789012', 'Moses Mthembu - 0746789013', GETDATE());
GO

INSERT INTO Events (OrganiserID, Name, Description, EventDate, Location, Distance, EventType, BannerImage, CreatedAt, IsActive)
VALUES 
    (
        1, 
        'Durban City Marathon 2026', 
        'A scenic marathon along the Durban beachfront.',
        '2026-05-20 05:30:00',
        'Durban, KwaZulu-Natal',
        42.20,
        'Run',
        'https://storage.blob.core.windows.net/events/durbanmarathon2026.jpg',
        GETDATE(),
        1
    ),
    (
        2,
        'Stellenbosch Cycle Challenge 2026',
        'A challenging cycling event through the Stellenbosch Winelands.',
        '2026-06-10 06:30:00',
        'Stellenbosch, Western Cape',
        85.00,
        'Cycle',
        'https://storage.blob.core.windows.net/events/stellenboschcycle2026.jpg',
        GETDATE(),
        1
    ),
    (
        2,
        'Knysna Forest Half Marathon 2026',
        'A beautiful half marathon through the Knysna forest.',
        '2026-07-05 06:00:00',
        'Knysna, Western Cape',
        21.10,
        'Run',
        'https://storage.blob.core.windows.net/events/knysnahalf2026.jpg',
        GETDATE(),
        1
    );
GO

INSERT INTO Categories (EventID, Name, Description, MinAge, MaxAge, Distance, EntryFee, CreatedAt)
VALUES 
    (1, 'Senior Men', 'Open category for male runners', 20, 39, NULL, 600.00, GETDATE()),
    (1, 'Senior Women', 'Open category for female runners', 20, 39, NULL, 600.00, GETDATE()),
    (1, 'Masters Men', 'Masters category for men 40+', 40, 99, NULL, 500.00, GETDATE()),
    (1, 'Masters Women', 'Masters category for women 40+', 40, 99, NULL, 500.00, GETDATE()),
    (2, 'Elite Men', 'Competitive category for men', 18, 45, NULL, 650.00, GETDATE()),
    (2, 'Elite Women', 'Competitive category for women', 18, 45, NULL, 650.00, GETDATE()),
    (2, 'Open Men', 'Open category for men', 46, 99, NULL, 550.00, GETDATE()),
    (2, 'Open Women', 'Open category for women', 46, 99, NULL, 550.00, GETDATE()),
    (3, 'Junior', 'Category for runners under 20', 10, 19, NULL, 350.00, GETDATE()),
    (3, 'Senior', 'Open category for runners 20-39', 20, 39, NULL, 500.00, GETDATE()),
    (3, 'Masters', 'Category for runners 40+', 40, 99, NULL, 450.00, GETDATE());
GO

INSERT INTO Enrolments (ParticipantID, EventID, CategoryID, EnrolmentDate, Status, PaymentStatus)
VALUES 
    (1, 1, 1, DATEADD(DAY, -25, GETDATE()), 'Confirmed', 'Paid'),
    (1, 2, 5, DATEADD(DAY, -18, GETDATE()), 'Pending', 'Unpaid'),
    (2, 1, 2, DATEADD(DAY, -20, GETDATE()), 'Confirmed', 'Paid'),
    (2, 3, 10, DATEADD(DAY, -12, GETDATE()), 'Pending', 'Unpaid'),
    (3, 1, 3, DATEADD(DAY, -8, GETDATE()), 'Pending', 'Unpaid'),
    (3, 2, 6, DATEADD(DAY, -5, GETDATE()), 'Confirmed', 'Paid'),
    (4, 2, 5, DATEADD(DAY, -30, GETDATE()), 'Completed', 'Paid'),
    (4, 3, 9, DATEADD(DAY, -28, GETDATE()), 'Completed', 'Paid');
GO

INSERT INTO Results (EnrolmentID, FinishTime, Position, IsCompleted, Notes, RecordedAt)
VALUES 
    (7, '04:15:30', 28, 1, 'Strong performance on the hills', GETDATE()),
    (8, '01:55:20', 156, 1, 'Steady pace throughout', GETDATE());
GO