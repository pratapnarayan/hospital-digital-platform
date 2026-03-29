# Patient Service API Documentation

## Base URL
```
http://localhost:8082/patient
```

## Endpoints

### 1. Health Check
- **GET** `/patient/health`
- **Description**: Check if the patient service is running
- **Response**: `Patient Service running`

### 2. Patient Registration
- **POST** `/patient/register`
- **Description**: Register a new patient
- **Content-Type**: `application/json`

#### Request Body
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phone": "1234567890",
  "dateOfBirth": "1990-01-01",
  "gender": "Male",
  "address": "123 Main St",
  "emergencyContact": "Jane Doe",
  "emergencyPhone": "0987654321",
  "bloodType": "O+",
  "allergies": "None",
  "medicalHistory": "No significant medical history"
}
```

#### Required Fields
- `firstName` (string)
- `lastName` (string)
- `email` (string, must be unique)
- `dateOfBirth` (string, format: yyyy-MM-dd)
- `gender` (string)

#### Optional Fields
- `phone` (string, must be unique if provided)
- `address` (string)
- `emergencyContact` (string)
- `emergencyPhone` (string)
- `bloodType` (string)
- `allergies` (string)
- `medicalHistory` (string)

#### Response
- **201 Created**: Returns the created patient object
- **400 Bad Request**: Missing required fields or invalid date format
- **409 Conflict**: Email or phone already exists

### 3. Get All Patients
- **GET** `/patient/list`
- **Description**: Retrieve all patients
- **Response**: Array of patient objects

### 4. Get Patient by ID
- **GET** `/patient/{patientId}`
- **Description**: Retrieve a specific patient by ID
- **Response**: Patient object
- **404 Not Found**: Patient not found

### 5. Update Patient
- **PUT** `/patient/{patientId}`
- **Description**: Update patient information (partial update)
- **Content-Type**: `application/json`

#### Request Body
```json
{
  "firstName": "John",
  "lastName": "Smith",
  "phone": "1234567890",
  "address": "456 Oak Ave",
  "emergencyContact": "Jane Smith",
  "emergencyPhone": "0987654321",
  "bloodType": "A+",
  "allergies": "Peanuts",
  "medicalHistory": "Updated medical history"
}
```

#### Response
- **200 OK**: Updated patient object
- **404 Not Found**: Patient not found
- **409 Conflict**: Phone number already exists

### 6. Delete Patient
- **DELETE** `/patient/{patientId}`
- **Description**: Delete a patient by ID
- **Response**: 204 No Content
- **404 Not Found**: Patient not found

### 7. Search Patients
- **GET** `/patient/search?firstName={firstName}&lastName={lastName}`
- **Description**: Search patients by name (case-insensitive)
- **Parameters**:
  - `firstName` (optional): First name to search
  - `lastName` (optional): Last name to search
- **Response**: Array of matching patient objects
- **400 Bad Request**: No search parameters provided

### 8. Get Patient by Email
- **GET** `/patient/email/{email}`
- **Description**: Retrieve a patient by email address
- **Response**: Patient object
- **404 Not Found**: Patient not found

## Patient Object Structure
```json
{
  "id": "string",
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "phone": "string",
  "dateOfBirth": "yyyy-MM-dd",
  "gender": "string",
  "address": "string",
  "emergencyContact": "string",
  "emergencyPhone": "string",
  "bloodType": "string",
  "allergies": "string",
  "medicalHistory": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Error Responses
All error responses return a JSON object with an error message:
```json
{
  "error": "Error description"
}
```

## Database
- **Database**: MongoDB
- **Collection**: `patients`
- **Connection**: `mongodb://localhost:27017/hospitalDB`
