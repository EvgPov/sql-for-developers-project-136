SET search_path TO public;

-- enable the extension for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- crypt('john_password', gen_salt('bf', 12))

-- Add main entities to database schema
CREATE TABLE courses (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name varchar(255) NOT NULL,
  description text NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz,
  deleted_at timestamptz
);

CREATE TABLE lessons (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  course_id bigint NOT NULL REFERENCES courses (id),
  name varchar(255) NOT NULL,
  content text NOT NULL,
  video_url varchar(255),
  position integer NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz,
  deleted_at timestamptz
);

CREATE TABLE modules (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name varchar(255) NOT NULL,
  description text NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz,
  deleted_at timestamptz
);

CREATE TABLE course_modules (
  course_id bigint NOT NULL REFERENCES courses (id),
  module_id bigint NOT NULL REFERENCES  modules (id),
  PRIMARY KEY (course_id, module_id)
);

CREATE TABLE programs (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name varchar(255) NOT NULL,
  price numeric(10,2) NOT NULL,
  program_type varchar(255) NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz
);

CREATE TABLE program_modules (
  module_id bigint NOT NULL REFERENCES  modules (id),
  program_id bigint NOT NULL REFERENCES programs (id),
  PRIMARY KEY (module_id, program_id)
);

-- Add users to database schema
CREATE TABLE teaching_groups (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  slug varchar(255) NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz
);

CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');
CREATE TABLE users (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name varchar(255) NOT NULL,
  email varchar(255) UNIQUE NOT NULL,
  password_hash varchar(255) UNIQUE NOT NULL,
  teaching_group_id bigint NOT NULL REFERENCES teaching_groups (id),
  role user_role NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz,
  deleted_at timestamptz
);

-- Add tables for user interaction with the platform
CREATE TYPE enrollment_status AS ENUM ('active', 'pending', 'cancelled', 'completed');
CREATE TABLE enrollments (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id bigint NOT NULL REFERENCES users (id),
  program_id bigint NOT NULL REFERENCES programs (id),
  status enrollment_status NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz
);

CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TABLE payments (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  enrollment_id bigint NOT NULL REFERENCES enrollments (id),
  amount numeric(10, 2) NOT NULL,
  status  payment_status NOT NULL,
  paid_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz
);

CREATE TYPE program_completions_status AS ENUM ('active', 'completed', 'pending', 'cancelled');
CREATE TABLE program_completions (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id bigint NOT NULL REFERENCES users (id),
  program_id bigint NOT NULL REFERENCES programs (id),
  status program_completions_status NOT NULL,
  started_at timestamptz NOT NULL,
  completed_at timestamptz,
  created_at timestamptz NOT NULL,
  updated_at timestamptz
);

CREATE TABLE certificates (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id bigint NOT NULL REFERENCES users (id),
  program_id bigint NOT NULL REFERENCES programs (id),
  url varchar(255) NOT NULL,
  issued_at timestamptz,
  created_at timestamptz NOT NULL,
  updated_at timestamptz
);

-- Create additional content
CREATE TABLE quizzes (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  lesson_id bigint NOT NULL REFERENCES lessons (id),
  name varchar(255) NOT NULL,
  content varchar(255) NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz
);

CREATE TABLE exercises (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  lesson_id bigint NOT NULL REFERENCES lessons (id),
  name varchar(255) NOT NULL,
  url varchar(255) NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz
);

-- Social interaction
CREATE TABLE discussions (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id bigint NOT NULL REFERENCES users (id),
  lesson_id bigint NOT NULL REFERENCES lessons (id),
  text text NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz
);

CREATE TYPE blog_status AS ENUM ('created', 'in moderation', 'published', 'archived');
CREATE TABLE blogs (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id bigint NOT NULL REFERENCES users (id),
  name varchar(255) NOT NULL,
  content text NOT NULL,
  status blog_status NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz
);
