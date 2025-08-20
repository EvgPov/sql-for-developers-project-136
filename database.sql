-- enable the extension for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- crypt('john_password', gen_salt('bf', 12))

-- Add main entities to database schema

CREATE TABLE lessons (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title varchar(255) NOT NULL,
  body text NOT NULL,
  link_to_video varchar(255),
  order_of_lesson integer NOT NULL,
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL,
  course_id bigint NOT NULL REFERENCES courses (id),
  is_deleted boolean NOT NULL DEFAULT false
);

CREATE TABLE courses (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title varchar(255) NOT NULL,
  description_course text NOT NULL,
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL,
  is_deleted boolean NOT NULL DEFAULT false
);

CREATE TABLE modules (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  course_id bigint REFERENCES courses (id) NOT NULL,
  title varchar(255) NOT NULL,
  description_module text NOT NULL,
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL,
  is_deleted boolean NOT NULL DEFAULT false
);

CREATE course_module (
  course_id bigint NOT NULL REFERENCES courses (id),
  module_id bigint NOT NULL REFERENCES  modules (id),
  PRIMARY KEY (course_id, module_id)
);

CREATE TABLE programs (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  module_id bigint REFERENCES modules (id) NOT NULL,
  title varchar(255) NOT NULL,
  cost numeric(10,2) NOT NULL,
  type_program varchar(255) NOT NULL,
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL
);

CREATE module_program (
  module_id bigint NOT NULL REFERENCES  modules (id),
  program_id bigint NOT NULL REFERENCES programs (id),
  PRIMARY KEY (module_id, programs_id)
);

-- Add users to database schema
CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');
CREATE TABLE users (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  full_name varchar(255) NOT NULL,
  email varchar(255) UNIQUE NOT NULL,
  password varchar(255) UNIQUE NOT NULL,
  teaching_group_id bigint NOT NULL REFERENCES teaching_groups (id),
  role user_role NOT NULL,
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL
);

CREATE TABLE teaching_groups (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  slag varchar(255) NOT NULL,
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL
);

-- Add tables for user interaction with the platform

CREATE TYPE enrollment_status AS ENUM ('active', 'pending', 'cancelled', 'completed');
CREATE TABLE enrollments (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id bigint NOT NULL REFERENCES users (id),
  program_id bigint NOT NULL REFERENCES programs (id),
  status enrollments_status NOT NULL,
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL
);

CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TABLE payments (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  enrollment_id bigint NOT NULL REFERENCES enrollments (id),
  amount numeric(10, 2) NOT NULL,
  status  payment_status NOT NULL,
  payment_at timestamptz NOT NULL,
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL
);

CREATE TYPE program_completions_status AS ENUM ('active', 'completed', 'pending', 'cancelled');
CREATE TABLE program_completions (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id bigint NOT NULL REFERENCES users (id),
  program_id bigint NOT NULL REFERENCES programs (id),
  status program_completions_status NOT NULL,
  beginning_at timestamptz NOT NULL,
  ending_at timestamptz NOT NULL
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL
);

CREATE TABLE certificates (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id bigint NOT NULL REFERENCES users (id),
  program_id bigint NOT NULL REFERENCES programs (id),
  url varchar(255) NOT NULL,
  issue_at timestamptz NOT NULL,
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL
);

-- Create additional content

CREATE TABLE quizzes (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  lesson_id bigint NOT NULL REFERENCES lessons (id),
  title varchar(255) NOT NULL,
  body varchar(255) NOT NULL,
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL
);

CREATE TABLE exercises (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  lesson_id bigint NOT NULL REFERENCES lessons (id),
  title varchar(255) NOT NULL,
  url varchar(255) NOT NULL,
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL
);

-- Social interaction

CREATE TABLE discussions (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  lesson_id bigint NOT NULL REFERENCES lessons (id),
  body text NOT NULL,
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL
);

CREATE TYPE blog_status AS ENUM ('created', 'in moderation', 'published', 'archived');
CREATE TABLE blog (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id bigint NOT NULL REFERENCES users (id),
  title varchar(255) NOT NULL,
  body text NOT NULL,
  status blog_status NOT NULL,
  create_at timestamptz NOT NULL,
  update_at timestamptz NOT NULL
);