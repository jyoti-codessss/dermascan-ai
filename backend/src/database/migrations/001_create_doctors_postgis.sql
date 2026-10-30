-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: 001_create_doctors_postgis.sql
-- Description: Sets up PostGIS spatial database for DermaScan AI Nearby Doctors
-- ═══════════════════════════════════════════════════════════════════════════

-- 1. Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Specialties Table
CREATE TABLE IF NOT EXISTS specialties (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Clinics / Hospital Centers Table with PostGIS Geography (SRID 4326: WGS 84)
CREATE TABLE IF NOT EXISTS clinics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    phone VARCHAR(30),
    website TEXT,
    location GEOGRAPHY(Point, 4326) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- GIST Index for High-Performance Spatial Indexing
CREATE INDEX IF NOT EXISTS idx_clinics_location ON clinics USING GIST (location);

-- 4. Doctors Table
CREATE TABLE IF NOT EXISTS doctors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID REFERENCES clinics(id) ON DELETE SET NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    specialty_id INT NOT NULL REFERENCES specialties(id),
    sub_specialties TEXT[],
    license_number VARCHAR(80) NOT NULL UNIQUE,
    rating NUMERIC(2, 1) DEFAULT 4.8 CHECK (rating >= 0.0 AND rating <= 5.0),
    review_count INT DEFAULT 120,
    experience_years INT NOT NULL DEFAULT 8,
    consultation_fee NUMERIC(10, 2) NOT NULL DEFAULT 800.00,
    profile_image_url TEXT,
    bio TEXT,
    is_available_today BOOLEAN DEFAULT true,
    next_available_slot VARCHAR(50) DEFAULT 'Today at 04:30 PM',
    is_verified BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_doctors_specialty ON doctors(specialty_id);
CREATE INDEX IF NOT EXISTS idx_doctors_clinic ON doctors(clinic_id);

-- 5. Seed Specialties
INSERT INTO specialties (name, slug, description) VALUES
('General Dermatology', 'general-dermatology', 'Diagnosis and treatment of skin, hair, and nail disorders'),
('Mohs Micrographic Surgery', 'mohs-surgery', 'Specialized surgical excision of high-risk skin cancers such as melanoma and basal cell carcinoma'),
('Pediatric Dermatology', 'pediatric-dermatology', 'Specialized care for children, infants, and congenital skin conditions'),
('Dermatopathology', 'dermatopathology', 'Microscopic evaluation of skin biopsies and neoplastic diseases'),
('Cosmetic Dermatology', 'cosmetic-dermatology', 'Aesthetic treatments, laser therapy, and scar revision')
ON CONFLICT (slug) DO NOTHING;

-- 6. Seed Sample Clinics across Major Metro Centers
INSERT INTO clinics (name, address, city, phone, website, location) VALUES
(
    'DermaCare Institute & Skin Laser Center',
    'Plot 42, Connaught Place, Central Delhi',
    'New Delhi',
    '+91 11 4321 9876',
    'https://dermacareinstitute.org',
    ST_SetSRID(ST_MakePoint(77.2167, 28.6304), 4326)::geography
),
(
    'Max Skin Cancer & Mohs Surgical Suite',
    'Saket Institutional Area, South Delhi',
    'New Delhi',
    '+91 11 2651 5050',
    'https://maxhealthcare.in',
    ST_SetSRID(ST_MakePoint(77.2144, 28.5273), 4326)::geography
),
(
    'Apollo Pediatric & Family Dermatology',
    'Sarita Vihar, Mathura Road',
    'New Delhi',
    '+91 11 2692 5858',
    'https://apollohospitals.com',
    ST_SetSRID(ST_MakePoint(77.2917, 28.5367), 4326)::geography
),
(
    'Fortis Memorial Skin Research Centre',
    'Sector 44, Gurugram',
    'Gurugram',
    '+91 124 496 2200',
    'https://fortishealthcare.com',
    ST_SetSRID(ST_MakePoint(77.0725, 28.4595), 4326)::geography
),
(
    'AIIMS Department of Dermatology & Venereology',
    'Ansari Nagar East, New Delhi',
    'New Delhi',
    '+91 11 2658 8500',
    'https://aiims.edu',
    ST_SetSRID(ST_MakePoint(77.2100, 28.5672), 4326)::geography
)
ON CONFLICT DO NOTHING;

-- 7. Seed Specialist Doctors
INSERT INTO doctors (
    clinic_id, first_name, last_name, specialty_id, sub_specialties,
    license_number, rating, review_count, experience_years, consultation_fee,
    profile_image_url, bio, is_available_today, next_available_slot
)
SELECT 
    c.id,
    'Dr. Rajesh', 'Khurana',
    (SELECT id FROM specialties WHERE slug = 'mohs-surgery'),
    ARRAY['Melanoma Excision', 'Skin Oncology', 'Reconstructive Surgery'],
    'DMC-76451', 4.9, 312, 16, 1200.00,
    'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=200',
    'Board-certified Dermatologic Oncologist specializing in high-precision Mohs micrographic excision and melanoma staging.',
    true, 'Today at 05:00 PM'
FROM clinics c WHERE c.name LIKE '%Max Skin%'
LIMIT 1;

INSERT INTO doctors (
    clinic_id, first_name, last_name, specialty_id, sub_specialties,
    license_number, rating, review_count, experience_years, consultation_fee,
    profile_image_url, bio, is_available_today, next_available_slot
)
SELECT 
    c.id,
    'Dr. Ananya', 'Sen',
    (SELECT id FROM specialties WHERE slug = 'general-dermatology'),
    ARRAY['Eczema & Atopic Dermatitis', 'Psoriasis Management', 'Biologics Therapy'],
    'DMC-82190', 4.8, 194, 11, 900.00,
    'https://images.unsplash.com/photo-1594824813629-8736e4f0e4b2?w=200',
    'Senior Consultant Dermatologist with deep expertise in autoimmune skin conditions, chronic eczema, and systemic biologics.',
    true, 'Today at 03:45 PM'
FROM clinics c WHERE c.name LIKE '%DermaCare%'
LIMIT 1;

INSERT INTO doctors (
    clinic_id, first_name, last_name, specialty_id, sub_specialties,
    license_number, rating, review_count, experience_years, consultation_fee,
    profile_image_url, bio, is_available_today, next_available_slot
)
SELECT 
    c.id,
    'Dr. Meera', 'Nambiar',
    (SELECT id FROM specialties WHERE slug = 'pediatric-dermatology'),
    ARRAY['Infantile Hemangioma', 'Pediatric Eczema', 'Genodermatoses'],
    'DMC-91432', 4.9, 250, 14, 1000.00,
    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200',
    'Specialist in pediatric skin disorders, childhood rash diagnosis, and gentle non-invasive therapies for infants and young children.',
    true, 'Today at 04:15 PM'
FROM clinics c WHERE c.name LIKE '%Apollo Pediatric%'
LIMIT 1;

INSERT INTO doctors (
    clinic_id, first_name, last_name, specialty_id, sub_specialties,
    license_number, rating, review_count, experience_years, consultation_fee,
    profile_image_url, bio, is_available_today, next_available_slot
)
SELECT 
    c.id,
    'Dr. Vikramaditya', 'Roy',
    (SELECT id FROM specialties WHERE slug = 'dermatopathology'),
    ARRAY['Biopsy Analysis', 'Pigmented Lesion Clinic', 'Dermoscopy'],
    'DMC-65901', 4.9, 410, 20, 1500.00,
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=200',
    'Chief of Dermatopathology and Dermoscopy, specializing in early dermoscopic pattern analysis and melanoma margin diagnostics.',
    false, 'Tomorrow at 10:00 AM'
FROM clinics c WHERE c.name LIKE '%AIIMS%'
LIMIT 1;

INSERT INTO doctors (
    clinic_id, first_name, last_name, specialty_id, sub_specialties,
    license_number, rating, review_count, experience_years, consultation_fee,
    profile_image_url, bio, is_available_today, next_available_slot
)
SELECT 
    c.id,
    'Dr. Neha', 'Bhasin',
    (SELECT id FROM specialties WHERE slug = 'cosmetic-dermatology'),
    ARRAY['Acne Scars', 'Laser Resurfacing', 'Pigmentation'],
    'DMC-88312', 4.7, 168, 9, 850.00,
    'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=200',
    'Aesthetic and laser dermatologist focused on post-inflammatory hyperpigmentation, acne scar recovery, and barrier repair.',
    true, 'Today at 06:00 PM'
FROM clinics c WHERE c.name LIKE '%Fortis%'
LIMIT 1;
