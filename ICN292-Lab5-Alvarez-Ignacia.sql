DROP DATABASE IF EXISTS andesbike;
CREATE DATABASE andesbike;
USE andesbike;

CREATE TABLE tiendas (
    id_tienda  INT          NOT NULL AUTO_INCREMENT,
    nombre     VARCHAR(60)  NOT NULL,
    comuna     VARCHAR(50)  NOT NULL,
    PRIMARY KEY (id_tienda)
);

CREATE TABLE vendedores (
    id_vendedor    INT          NOT NULL AUTO_INCREMENT,
    nombre         VARCHAR(80)  NOT NULL,
    id_tienda      INT          NULL,
    fecha_ingreso  DATE         NOT NULL,
    PRIMARY KEY (id_vendedor),
    FOREIGN KEY (id_tienda) REFERENCES tiendas(id_tienda)
);

CREATE TABLE bicicletas (
    id_bicicleta  INT            NOT NULL AUTO_INCREMENT,
    modelo        VARCHAR(60)    NOT NULL,
    categoria     ENUM('Eléctrica','Infantil','Montaña','Ruta','Urbana') NOT NULL,
    precio        DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (id_bicicleta),
    CHECK (precio > 0)
);

CREATE TABLE ventas (
    id_venta      INT   NOT NULL AUTO_INCREMENT,
    id_vendedor   INT   NOT NULL,
    id_bicicleta  INT   NOT NULL,
    fecha         DATE  NOT NULL,
    unidades      INT   NOT NULL,
    PRIMARY KEY (id_venta),
    FOREIGN KEY (id_vendedor)  REFERENCES vendedores(id_vendedor),
    FOREIGN KEY (id_bicicleta) REFERENCES bicicletas(id_bicicleta),
    CHECK (unidades > 0)
);

INSERT INTO tiendas (id_tienda, nombre, comuna) VALUES
    (1, 'Andes Providencia', 'Providencia'),
    (2, 'Andes Maipú',       'Maipú'),
    (3, 'Andes Concepción',  'Concepción'),
    (4, 'Andes La Serena',   'La Serena');

INSERT INTO vendedores (id_vendedor, nombre, id_tienda, fecha_ingreso) VALUES
    (1, 'Camila Ortiz',    1,    '2024-06-20'),
    (2, 'Diego Fuentes',   1,    '2024-01-15'),
    (3, 'Javiera Soto',    2,    '2023-07-24'),
    (4, 'Matías Herrera',  2,    '2024-01-15'),
    (5, 'Paula Riquelme',  3,    '2022-11-02'),
    (6, 'Ignacio Vera',    3,    '2024-08-19'),
    (7, 'Fernanda Lillo',  1,    '2025-02-03'),
    (8, 'Rubén Castro',    NULL, '2025-06-10');

INSERT INTO bicicletas (id_bicicleta, modelo, categoria, precio) VALUES
    (1, 'Cordillera 29', 'Montaña',   549990.00),
    (2, 'Ruta Austral',  'Ruta',      899990.00),
    (3, 'Urbana Pro',    'Urbana',    329990.00),
    (4, 'Pequeño Andes', 'Infantil',  149990.00),
    (5, 'Volt City',     'Eléctrica', 1249990.00),
    (6, 'Trail Master',  'Montaña',   749990.00),
    (7, 'Urbana Lite',   'Urbana',    229990.00),
    (8, 'Sprint R7',     'Ruta',      1099990.00);

INSERT INTO ventas (id_vendedor, id_bicicleta, fecha, unidades) VALUES
    (1, 1, '2025-03-04', 1),
    (1, 2, '2025-03-18', 3),
    (1, 5, '2025-04-02', 1),
    (2, 2, '2025-03-04', 1),
    (2, 1, '2025-04-11', 3),
    (2, 7, '2025-05-06', 2),
    (3, 4, '2025-03-21', 4),
    (3, 3, '2025-04-15', 2),
    (3, 6, '2025-05-20', 1),
    (4, 2, '2025-03-27', 1),
    (4, 5, '2025-05-09', 2),
    (5, 2, '2025-04-08', 1),
    (5, 2, '2025-04-23', 2),
    (5, 4, '2025-06-02', 5),
    (6, 3, '2025-05-13', 3),
    (6, 7, '2025-06-17', 1),
    (6, 1, '2025-06-24', 2),
    (1, 6, '2025-06-30', 1);
    
    SELECT * FROM ventas;
    
   -- Consulta 1
   SELECT ve.nombre AS vendedor,
       COUNT(v.id_venta) AS cantidad_ventas
	FROM vendedores ve
	LEFT JOIN ventas v ON v.id_vendedor = ve.id_vendedor
	GROUP BY ve.id_vendedor, ve.nombre
	ORDER BY cantidad_ventas DESC, ve.nombre ASC;
    
    -- Consulta 2
    SELECT t.nombre AS tienda,
       COUNT(v.id_venta) AS cantidad_ventas,
       COALESCE(SUM(v.unidades), 0) AS unidades_vendidas
	FROM tiendas t
	LEFT JOIN vendedores ve ON ve.id_tienda = t.id_tienda
	LEFT JOIN ventas v ON v.id_vendedor = ve.id_vendedor
	GROUP BY t.id_tienda, t.nombre
	ORDER BY unidades_vendidas DESC;
    
    -- Consulta 3
    SELECT t.nombre AS tienda, t.comuna
	FROM tiendas t
	LEFT JOIN vendedores ve ON ve.id_tienda = t.id_tienda
	WHERE ve.id_vendedor IS NULL;
    
    -- Consulta 4
    SELECT b.modelo, b.categoria, b.precio
	FROM bicicletas b
	LEFT JOIN ventas v
		   ON v.id_bicicleta = b.id_bicicleta
		  AND v.fecha >= '2025-06-01' AND v.fecha < '2025-07-01'
	WHERE v.id_venta IS NULL
	ORDER BY b.modelo;
    
    -- Consulta5
    SELECT ve.nombre AS vendedor,
       t.nombre AS tienda
	FROM vendedores ve
	LEFT JOIN tiendas t ON t.id_tienda = ve.id_tienda
	LEFT JOIN ventas v ON v.id_vendedor = ve.id_vendedor
	WHERE v.id_venta IS NULL
	ORDER BY ve.nombre;
    
    -- Consulta 6 
    SELECT a.nombre AS vendedor_antiguo,
       a.fecha_ingreso AS ingreso_antiguo,
       b.nombre AS vendedor_reciente,
       b.fecha_ingreso AS ingreso_reciente,
       t.nombre AS tienda
	FROM vendedores a
	JOIN vendedores b ON b.id_tienda = a.id_tienda
					 AND a.fecha_ingreso < b.fecha_ingreso
	JOIN tiendas t ON t.id_tienda = a.id_tienda
	ORDER BY t.nombre, a.fecha_ingreso;
    
    -- Consulta 7
    SELECT t.nombre AS tienda,
       SUM(v.unidades * b.precio) AS monto_montana_ruta
	FROM tiendas t
	JOIN vendedores ve ON ve.id_tienda = t.id_tienda
	JOIN ventas v ON v.id_vendedor = ve.id_vendedor
	JOIN bicicletas b ON b.id_bicicleta = v.id_bicicleta
	WHERE b.categoria IN ('Montaña', 'Ruta')
	GROUP BY t.id_tienda, t.nombre
	HAVING SUM(v.unidades * b.precio) > 2000000
	ORDER BY monto_montana_ruta DESC;
    
    -- Consulta 8
    SELECT modelo, precio
	FROM bicicletas
	WHERE precio > (SELECT AVG(precio) FROM bicicletas)
	ORDER BY precio DESC;

	-- El valor del promedio:
	SELECT AVG(precio) AS promedio_catalogo FROM bicicletas;
    
    -- Consulta 9
    SELECT ve.nombre AS vendedor,
       AVG(v.unidades) AS promedio_unidades
	FROM vendedores ve
	JOIN ventas v ON v.id_vendedor = ve.id_vendedor
	GROUP BY ve.id_vendedor, ve.nombre
	HAVING AVG(v.unidades) > (SELECT AVG(unidades) FROM ventas)
	ORDER BY promedio_unidades DESC, ve.nombre ASC;
    
    -- Consulta 10
    SELECT ve.nombre AS vendedor,
       SUM(v.unidades * b.precio) AS monto_total
	FROM vendedores ve
	LEFT JOIN ventas v ON v.id_vendedor = ve.id_vendedor
	LEFT JOIN bicicletas b ON b.id_bicicleta = v.id_bicicleta
	GROUP BY ve.id_vendedor, ve.nombre
	ORDER BY monto_total DESC;
    