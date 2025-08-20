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
  programs_id bigint NOT NULL REFERENCES programs (id),
  PRIMARY KEY (module_id, programs_id)
);