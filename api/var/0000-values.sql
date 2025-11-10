BEGIN TRANSACTION;
INSERT INTO clubs
(name, website, contact, description, status, created_at, updated_at, member_fee, member_count, registration, audience)
VALUES
('Actuarial Club',
 'https://win.wisc.edu/organization/actsciclub',
 'mailto:actsciclub@wsb.wisc.edu',
 'A student-run organization for those interested in or majoring in actuarial science.',
 'active',
 '2025-03-15 10:30:00',
 '2025-10-15 10:45:35',
 '35.00',
 120,
 'open',
 'Undergraduates and Graduates');

INSERT INTO clubs
(name, website, contact, description, status, created_at, updated_at, member_fee, member_count, registration, audience)
VALUES
('Software Development Club',
 'https://win.wisc.edu/organization/softwaredevclub',
 'mailto:wisconsinsdc@gmail.com',
 'A vibrant community dedicated to enhancing students'' skills in computer science and software engineering/development through collaborative learning and projects.',
 'active',
 '2025-04-15 10:30:00',
 '2025-10-15 10:51:10',
 'free',
 140,
 'open',
 'Undergraduates');

INSERT INTO clubs
(name, website, contact, description, status, created_at, updated_at, member_fee, member_count, registration, audience)
VALUES
('Math Club',
 'https://win.wisc.edu/organization/mathclub',
 'mailto:saldin@wisc.edu',
 'Math Club provides a space for students interested in mathematics to connect with each other through academic talks and social events.',
 'active',
 '2023-04-15 10:30:00',
 '2025-10-15 10:51:10',
 'free',
 180,
 'open',
 'Undergraduates and Graduates');

INSERT INTO clubs
(name, website, contact, description, status, created_at, updated_at, member_fee, member_count, registration, audience)
VALUES
('Web Development Club',  -- more common known by WebDevUW (not to be confused with WebLabs though...)
 'https://win.wisc.edu/organization/webdevuw',
 'mailto:webdev@rso.wisc.edu',
 'A student-run organization at UW-Madison aimed at exploring the field of Web Development through events, applications, panels, and hands-on experience.',
 'inactive',
 '2023-04-15 10:30:00',
 '2024-10-15 10:56:14',
 'free',
 20,
 'open',
 'Undergraduates and Graduates');

INSERT INTO clubs
(name, website, contact, description, status, created_at, updated_at, member_fee, member_count, registration, audience)
VALUES
('WebLabs',
 'https://win.wisc.edu/organization/weblabs',
 'mailto:weblabsUW@gmail.com',
 'A student organization dedicated to making web development accessible to everyone, regardless of major or prior experience.',
 'active',
 '2024-10-01 10:30:00',
 '2025-10-15 10:57:44',
 'free',
 100,
 'open',
 'Undergraduates and Graduates');
COMMIT;
