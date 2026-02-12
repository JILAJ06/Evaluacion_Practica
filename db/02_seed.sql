INSERT INTO teachers (name, email) VALUES
('Dr. Alan Turing', 'alan@university.edu'),       
('Mtra. Ada Lovelace', 'ada@university.edu'),     
('Lic. Grace Hopper', 'grace@university.edu'),    
('Ing. Nikola Tesla', 'nikola@university.edu'),   
('Dr. Richard Feynman', 'feynman@university.edu'),
('Mtra. Marie Curie', 'curie@university.edu'),    
('Lic. Tim Berners-Lee', 'timbl@university.edu'), 
('Dr. Carl Sagan', 'sagan@university.edu');      

INSERT INTO courses (code, name, credits) VALUES
('MAT101', 'Cálculo Diferencial', 8),             
('PROG101', 'Fundamentos de Programación', 10),   
('BD201', 'Bases de Datos Avanzadas', 8),         
('FIS101', 'Física Clásica', 6),                  
('ETH101', 'Ética y Valores', 4),                 
('ALG202', 'Algoritmos y Estructuras', 9),      
('AST301', 'Astronomía Moderna', 5);

INSERT INTO students (name, email, program, enrollment_year) VALUES
('Alexander Jiménez', 'alex@student.edu', 'Ing. Software', 2023), 
('Isaac Newton', 'isaac@student.edu', 'Física', 2023),            
('Rosalind Franklin', 'rosalind@student.edu', 'Ing. Software', 2024), 
('Albert Einstein', 'albert@student.edu', 'Física', 2025),        
('Steve Jobs', 'steve@student.edu', 'Arquitectura', 2025),        
('Linus Torvalds', 'linus@student.edu', 'Ing. Software', 2024),   
('Margaret Hamilton', 'maggie@student.edu', 'Ing. Software', 2023),
('Stephen Hawking', 'stephen@student.edu', 'Física', 2023),       
('Katherine Johnson', 'kat@student.edu', 'Matemáticas', 2024),   
('Dennis Ritchie', 'dennis@student.edu', 'Ing. Software', 2023), 
('Guido van Rossum', 'guido@student.edu', 'Ing. Software', 2025), 
('Ada Yonath', 'ada.y@student.edu', 'Química', 2024),            
('Niels Bohr', 'niels@student.edu', 'Física', 2023),              
('Hedy Lamarr', 'hedy@student.edu', 'Ing. Telecom', 2025),        
('Galileo Galilei', 'gali@student.edu', 'Astronomía', 2024);     

INSERT INTO groups (course_id, teacher_id, term) VALUES
(1, 1, '2025-A'),
(2, 2, '2025-A'), 
(3, 3, '2025-A'), 
(4, 4, '2025-A'), 
(6, 7, '2025-A'), 
(5, 8, '2025-A'); 
INSERT INTO enrollments (student_id, group_id, enrolled_at) VALUES
(2, 1, NOW()), (4, 1, NOW()), (8, 1, NOW()), (9, 1, NOW()),
(1, 2, NOW()), (3, 2, NOW()), (6, 2, NOW()), (7, 2, NOW()), (10, 2, NOW()),
(1, 3, NOW()), (11, 3, NOW()), (14, 3, NOW()),
(13, 4, NOW()), (15, 4, NOW()),
(6, 5, NOW()), (10, 5, NOW());

INSERT INTO grades (enrollment_id, partial1, partial2, final) VALUES
(1, 10, 10, 10), 
(2, 9, 9, 9), 
(3, 9.5, 9.5, 9.5), 
(4, 10, 9, 9.5),            
(5, 9.5, 9.0, 9.3),
(6, 4.0, 3.0, 3.5), 
(7, 8.0, 8.0, 8.0),
(8, 10, 10, 10),    
(9, 7.5, 7.0, 7.3), 
(10, 8.5, 9.0, 8.8), 
(11, 6.0, 6.0, 6.0), 
(12, 9.0, 9.0, 9.0); 

INSERT INTO attendance (enrollment_id, date, present) VALUES
(5, '2025-01-10', TRUE), (5, '2025-01-11', TRUE),
(6, '2025-01-10', FALSE), (6, '2025-01-11', FALSE), (6, '2025-01-12', FALSE), (6, '2025-01-13', FALSE),
(11, '2025-01-10', TRUE), (11, '2025-01-11', FALSE), (11, '2025-01-12', FALSE), (11, '2025-01-13', FALSE);