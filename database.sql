-- enable the extension for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE user_role AS ENUM ('Student', 'Teacher', 'Admin');
CREATE TYPE enrollment_status AS ENUM ('active', 'pending', 'cancelled', 'completed');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TYPE program_completions_status AS ENUM ('active', 'completed', 'pending', 'cancelled');
CREATE TYPE blog_status AS ENUM ('created', 'in moderation', 'published', 'archived');

-- Add main entities to database schema
CREATE TABLE courses (
  id serial PRIMARY KEY,
  name varchar(255) NOT NULL,
  description text NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL,
  deleted_at timestamptz
);

CREATE TABLE lessons (
  id serial PRIMARY KEY,
  course_id bigint REFERENCES courses (id) ON DELETE CASCADE,
  name varchar(255) NOT NULL,
  content text NOT NULL,
  video_url varchar(255),
  position integer CHECK (position > 0),
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL,
  deleted_at timestamptz
);

CREATE TABLE modules (
  id serial PRIMARY KEY,
  name varchar(255) NOT NULL,
  description text,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL,
  deleted_at timestamptz
);

CREATE TABLE programs (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name varchar(255) NOT NULL,
  price numeric(10,2) NOT NULL,
  program_type varchar(255) NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL
);

CREATE TABLE program_modules (
  program_id bigint NOT NULL REFERENCES programs (id) ON DELETE CASCADE,
  module_id bigint NOT NULL REFERENCES modules (id) ON DELETE CASCADE,
  PRIMARY KEY (program_id, module_id)
);

CREATE TABLE course_modules (
  module_id bigint NOT NULL REFERENCES modules (id) ON DELETE CASCADE,
  course_id bigint NOT NULL REFERENCES courses (id) ON DELETE CASCADE,
  PRIMARY KEY (module_id, course_id)
);

-- Add users to database schema
CREATE TABLE teaching_groups (
  id serial PRIMARY KEY,
  slug varchar(255) NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL
);

CREATE TABLE users (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  teaching_group_id bigint REFERENCES teaching_groups (id) ON DELETE CASCADE,
  name varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  password_hash varchar(255),
  role user_role,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL,
  deleted_at timestamptz
);

-- Add tables for user interaction with the platform
CREATE TABLE enrollments (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id bigint REFERENCES users (id),
  program_id bigint REFERENCES programs (id) ON DELETE CASCADE,
  status enrollment_status,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL
);

CREATE TABLE payments (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  enrollment_id bigint REFERENCES enrollments (id),
  amount numeric(10, 2) NOT NULL,
  status payment_status,
  paid_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL
);

CREATE TABLE program_completions (
  id serial PRIMARY KEY,
  user_id bigint NOT NULL REFERENCES users (id),
  program_id bigint NOT NULL REFERENCES programs (id),
  status program_completions_status,
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL
);

CREATE TABLE certificates (
  id serial PRIMARY KEY,
  user_id bigint NOT NULL REFERENCES users (id),
  program_id bigint NOT NULL REFERENCES programs (id),
  url varchar(255),
  issued_at timestamptz,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL
);

-- Create additional content
CREATE TABLE quizzes (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  lesson_id bigint REFERENCES lessons (id),
  name varchar(255) NOT NULL,
  content JSONB,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL
);

CREATE TABLE exercises (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  lesson_id bigint REFERENCES lessons (id),
  name varchar(255) NOT NULL,
  url varchar(255) NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL
);

-- Social interaction
CREATE TABLE discussions (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id bigint REFERENCES users (id),
  lesson_id bigint REFERENCES lessons (id),
  text JSONB,
  created_at timestamptz NOT NULL,
  updated_at timestamptz
);


CREATE TABLE blogs (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id bigint REFERENCES users (id),
  name varchar(255) NOT NULL,
  content JSONB,
  status blog_status,
  created_at timestamptz NOT NULL,
  updated_at timestamptz
);
