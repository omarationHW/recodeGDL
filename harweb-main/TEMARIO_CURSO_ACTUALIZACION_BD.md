# CURSO DE ACTUALIZACIÓN DE BASE DE DATOS
## Migración INFORMIX a PostgreSQL - Sistema Municipal Guadalajara

**Modalidad:** Teórico-práctico
**Nivel:** Intermedio-Avanzado

---

## ÍNDICE DEL CURSO

### MÓDULO 1: INTRODUCCIÓN Y CONTEXTO DEL PROYECTO
- 1.1 El Sistema Municipal de Guadalajara
- 1.2 Arquitectura Modular del Sistema
- 1.3 Organización de Carpetas y Convenciones
- 1.4 Actividades prácticas

### MÓDULO 2: FUNDAMENTOS DE MIGRACIÓN INFORMIX A POSTGRESQL
- 2.1 ¿Por qué no es solo "copiar y pegar"?
- 2.2 Diferencias en la Definición de Stored Procedures
- 2.3 Manejo de Valores NULL
- 2.4 Paginación de Resultados
- 2.5 Tipos de Datos - Mapeo y Conversiones
- 2.6 Funciones de Conversión de Tipos
- 2.7 Operadores y Funciones de Cadenas
- 2.8 Actividades prácticas

### MÓDULO 3: PATRONES DE STORED PROCEDURES
- 3.1 ¿Por qué usar patrones de diseño?
- 3.2 Patrón de Nomenclatura
- 3.3 Categorización Funcional de Procedures
  - A. Catálogos (01_catalogs.sql)
  - B. CRUD (02_crud.sql)
  - C. Reportes (03_reports.sql)
- 3.4 Patrón de Parámetros
- 3.5 Manejo de Errores y Transacciones
- 3.6 Actividades prácticas

### MÓDULO 4: OPTIMIZACIÓN DE CONSULTAS
- 4.1 ¿Por qué optimizar?
- 4.2 Índices - El Fundamento de la Velocidad
- 4.3 EXPLAIN ANALYZE - El Detector de Problemas
- 4.4 El Problema N+1 Queries
- 4.5 Subconsultas vs JOINs
- 4.6 Uso Eficiente de Agregaciones
- 4.7 Optimización de Procedures con Reportes
- 4.8 Actividades prácticas

### MÓDULO 5: CASOS DE USO REALES POR MÓDULO
- 5.1 Módulo LICENCIAS - Gestión Integral de Permisos (709 scripts)
- 5.2 Módulo MERCADOS - Administración de Locales (624 scripts)
- 5.3 Módulo ASEO - Servicio de Limpia Urbana (483 scripts)
- 5.4 Módulo RECAUDADORA - Sistema Central de Pagos (473 scripts)
- 5.5 Módulo CONVENIOS - Gestión de Convenios de Pago (407 scripts)
- 5.6 Módulo ESTACIONAMIENTOS - Control de Multas (237 scripts)
- 5.7 Módulo APREMIOS - Cobro Coercitivo (222 scripts)
- 5.8 Módulo OTRAS OBLIGACIONES - Servicios Diversos (196 scripts)
- 5.9 Módulo CEMENTERIOS - Administración Cementerios (133 scripts)
- 5.10 Módulo TRÁMITE TRUNK - Trámites Administrativos (23 scripts)
- 5.11 Módulo SISTEMA - Infraestructura y Seguridad
- 5.12 Integración entre Módulos

### MÓDULO 6: DEPLOYMENT Y GESTIÓN DE VERSIONES
- 6.1 El Reto del Deployment en Bases de Datos
- 6.2 Scripts Maestros - Instalación Ordenada
- 6.3 Control de Versiones para SQL
- 6.4 Estrategias de Rollback
- 6.5 Monitoreo Post-Deployment
- 6.6 Actividades prácticas

### ANEXOS
- ANEXO A: Comandos PostgreSQL Útiles
- ANEXO B: Rutas de Archivos del Proyecto
- ANEXO C: Recursos Adicionales
- ANEXO D: Troubleshooting Común
- ANEXO E: Glosario de Términos

---

## OBJETIVOS GENERALES DEL CURSO

Al finalizar este curso, los participantes serán capaces de:

1. **Comprender** el proceso completo de migración de bases de datos desde sistemas propietarios (INFORMIX) hacia sistemas open source (PostgreSQL)
2. **Identificar** las diferencias críticas entre motores de base de datos y cómo adaptar código existente
3. **Aplicar** patrones de diseño y buenas prácticas en el desarrollo de stored procedures
4. **Implementar** estrategias de optimización de consultas para mejorar el rendimiento del sistema
5. **Gestionar** el ciclo de vida completo de objetos de base de datos en un ambiente de producción
6. **Resolver** problemas comunes relacionados con compatibilidad, performance y deployment

---

## MÓDULO 1: INTRODUCCIÓN Y CONTEXTO DEL PROYECTO

**Objetivo:** Comprender la arquitectura global del sistema y la justificación del proyecto de migración

### 1.1 El Sistema Municipal de Guadalajara

#### ¿Qué vamos a aprender?
En esta sección estudiaremos la arquitectura del sistema que administra los servicios municipales de Guadalajara, un sistema crítico que procesa diariamente miles de transacciones relacionadas con:
- Recaudación de impuestos y servicios
- Emisión de licencias comerciales
- Gestión de mercados públicos
- Cobro coercitivo (apremios)
- Administración de servicios urbanos

#### El contexto empresarial
El Municipio de Guadalajara operaba con un sistema basado en INFORMIX, un motor de base de datos propietario desarrollado por IBM en los años 80. Aunque robusto, presentaba limitaciones importantes:
- **Costos de licenciamiento elevados** que aumentaban cada año
- **Dependencia de un proveedor único** para soporte y actualizaciones
- **Dificultad para encontrar desarrolladores** especializados en tecnología legacy
- **Limitaciones en integración** con tecnologías modernas (APIs REST, microservicios)
- **Riesgos de obsolescencia** tecnológica a mediano plazo

#### La decisión de migrar
La migración a PostgreSQL se justificó por múltiples razones estratégicas:
- **Software libre y gratuito** - Eliminación de costos de licenciamiento
- **Comunidad activa** - Miles de desarrolladores contribuyendo mejoras constantemente
- **Compatibilidad SQL estándar** - Facilita futuras migraciones si fuera necesario
- **Extensibilidad** - Permite agregar funcionalidades personalizadas
- **Rendimiento comparable** - PostgreSQL compite con motores comerciales en velocidad
- **Soporte empresarial disponible** - Múltiples empresas ofrecen soporte profesional

### 1.2 Arquitectura Modular del Sistema

#### Concepto de modularización
El sistema se organizó en **11 módulos funcionales independientes**, cada uno responsable de un área específica de negocio. Esta arquitectura modular proporciona ventajas significativas:

**Ventajas de la modularización:**
- **Mantenibilidad** - Los cambios en un módulo no afectan a los demás
- **Escalabilidad** - Se pueden asignar equipos especializados por módulo
- **Despliegue independiente** - Actualizar un módulo sin tocar el resto del sistema
- **Reutilización de código** - Funcionalidades compartidas se centralizan
- **Facilita testing** - Pruebas unitarias por módulo

#### Los 11 módulos del sistema

**MÓDULO: LICENCIAS (709 scripts SQL)**
- **Propósito:** Gestionar el ciclo de vida completo de licencias comerciales
- **Operaciones:** Alta, baja, modificación, renovación, bloqueo, consulta
- **Complejidad:** ALTA - Es el módulo con más reglas de negocio
- **Volumen de datos:** Miles de licencias activas con historial de años
- **Particularidad:** Contiene los scripts INFORMIX originales para referencia de migración

**MÓDULO: MERCADOS (624 scripts SQL)**
- **Propósito:** Administrar locales en mercados públicos municipales
- **Operaciones:** Asignación de locales, cálculo de adeudos (renta + energía), contratos
- **Complejidad:** MEDIA-ALTA - Maneja múltiples tipos de adeudos simultáneos
- **Volumen de datos:** Cientos de locales distribuidos en decenas de mercados

**MÓDULO: RECAUDADORA (473 scripts SQL)**
- **Propósito:** Sistema central de recaudación de pagos
- **Operaciones:** Generación de recibos, aplicación de pagos, cierre de caja, remesas
- **Complejidad:** ALTA - Maneja transacciones financieras críticas
- **Volumen de datos:** Miles de recibos diarios
- **Criticidad:** CRÍTICA - Errores pueden generar pérdidas económicas

**MÓDULO: ASEO (483 scripts SQL)**
- **Propósito:** Gestión del servicio de limpia urbana (recolección de basura comercial)
- **Operaciones:** Contratos de servicio, facturación, adeudos
- **Complejidad:** MEDIA
- **Volumen de datos:** Miles de contratos activos con empresas y comercios

**MÓDULO: CONVENIOS (407 scripts SQL)**
- **Propósito:** Gestión de convenios de pago diferido
- **Operaciones:** Creación de convenios, parcialidades, afectación de pagos
- **Complejidad:** MEDIA - Requiere cálculos financieros (intereses, recargos)

**MÓDULO: ESTACIONAMIENTOS (237 scripts SQL)**
- **Propósito:** Control de multas por estacionamiento indebido
- **Operaciones:** Registro de infracciones, consulta, aplicación de pagos
- **Complejidad:** BAJA-MEDIA - Operaciones simples pero alto volumen

**MÓDULO: APREMIOS (222 scripts SQL)**
- **Propósito:** Gestión del cobro coercitivo (ejecutores fiscales)
- **Operaciones:** Asignación de folios a ejecutores, autorización, reportes de cobranza
- **Complejidad:** MEDIA - Involucra procesos legales de cobro

**MÓDULO: OTRAS OBLIGACIONES (196 scripts SQL)**
- **Propósito:** Gestión de obligaciones fiscales diversas
- **Operaciones:** Consultas, reportes
- **Complejidad:** BAJA

**MÓDULO: CEMENTERIOS (133 scripts SQL)**
- **Propósito:** Administración de servicios de cementerios municipales
- **Operaciones:** Registro de servicios, concesiones, adeudos
- **Complejidad:** BAJA-MEDIA

**MÓDULO: TRÁMITE TRUNK (23 scripts SQL)**
- **Propósito:** Gestión de trámites administrativos diversos
- **Operaciones:** Seguimiento de trámites
- **Complejidad:** BAJA

**MÓDULO: SISTEMA (scripts de infraestructura)**
- **Propósito:** Componentes transversales (autenticación, auditoría, configuración)
- **Operaciones:** Login, gestión de usuarios, parámetros del sistema
- **Complejidad:** MEDIA

#### Cifras del proyecto
- **Total de scripts SQL migrados:** 3,510 archivos
- **Total de stored procedures:** Más de 1,500 procedimientos almacenados
- **Líneas de código estimadas:** Más de 500,000 líneas de SQL
- **Tiempo de desarrollo:** 18 meses de trabajo de equipo
- **Estado actual:** PRODUCCIÓN - Sistema operativo al 100%

### 1.3 Organización de Carpetas y Convenciones

#### ¿Por qué es importante la estructura de carpetas?
En proyectos de esta magnitud, una estructura de carpetas clara y consistente es fundamental para:
- **Encontrar rápidamente** el código que necesitas modificar
- **Entender la historia** del código (¿qué cambió y por qué?)
- **Facilitar el trabajo en equipo** - Todos saben dónde colocar nuevos archivos
- **Automatizar despliegues** - Scripts de instalación que saben dónde buscar

#### Estructura estándar por módulo

**Carpeta `/database/database/`** - Scripts actuales en PostgreSQL
- Contiene la versión ACTUAL y OPERATIVA de todos los stored procedures
- Organizada por categoría de funcionalidad (catalogs, crud, reports)
- Es la fuente de verdad del sistema en producción

**Carpeta `/database/ok/`** - Scripts validados y legacy
- Versiones anteriores que funcionaron en algún momento
- Scripts de respaldo antes de refactorización mayor
- Útil para comparar "antes vs después" cuando hay problemas

**Carpeta `/database/informix_procedures/`** - Scripts originales INFORMIX
- **Solo en módulo LICENCIAS**
- Contiene el código ORIGINAL antes de la migración
- Incluye documentación de cómo se hizo la migración
- Recurso invaluable para entender la lógica de negocio original

**Carpeta `/docs/`** - Documentación técnica
- Casos de uso, diagramas de flujo, análisis de requerimientos
- Documentación de APIs de los stored procedures
- Casos de prueba y resultados esperados

#### Patrón de archivos SQL

El proyecto sigue un patrón consistente de nomenclatura:

**Archivos por categoría funcional:**
- `01_catalogs.sql` - Procedimientos de consulta de catálogos
- `02_crud.sql` - Operaciones de alta, baja, modificación
- `03_reports.sql` - Procedimientos de reportería

**Archivos por formulario/pantalla:**
- `[NombreFormulario]_all_procedures.sql` - Todos los SPs de esa pantalla
- `[NombreFormulario]_sp_[operación].sql` - Un SP específico
- Ejemplo: `BloquearLicenciafrm_sp_bloquear_licencia.sql`

**Archivos maestros:**
- `MASTER_StoredProcedures.sql` - Compilación de TODOS los SPs del módulo
- `INSTALL_QuickSetup.sql` - Script de instalación automatizada

### 1.4 Actividades prácticas del módulo

1. **Exploración de estructura** - Navegar por las carpetas del proyecto y familiarizarse con la organización
2. **Conteo de scripts** - Verificar el total de archivos SQL por módulo
3. **Comparación INFORMIX vs PostgreSQL** - Abrir un script de cada tipo y observar diferencias visuales
4. **Lectura de documentación** - Revisar los README.md de cada módulo

---

## MÓDULO 2: FUNDAMENTOS DE MIGRACIÓN INFORMIX A POSTGRESQL

**Objetivo:** Dominar las diferencias sintácticas y conceptuales entre INFORMIX y PostgreSQL para realizar migraciones exitosas

### 2.1 ¿Por qué no es solo "copiar y pegar"?

#### El mito del SQL universal
Muchos asumen que SQL es un lenguaje universal: "si funciona en una base de datos, debería funcionar en todas". Esto es **parcialmente falso**.

**Lo que SÍ es estándar:**
- Consultas SELECT básicas (`SELECT * FROM tabla WHERE condicion`)
- Operaciones de INSERT, UPDATE, DELETE simples
- Tipos de datos básicos (INT, VARCHAR, DATE)
- JOINs estándar (INNER, LEFT, RIGHT)

**Lo que NO es estándar:**
- Sintaxis de stored procedures (cada motor tiene la suya)
- Funciones especializadas (manejo de fechas, strings, conversiones)
- Tipos de datos avanzados (JSON, XML, geoespaciales)
- Optimizaciones (hints, índices especiales)
- Manejo de transacciones y concurrencia

#### Los dialectos de SQL
Cada motor de base de datos implementó extensiones propietarias:
- **Oracle** → PL/SQL
- **SQL Server** → T-SQL
- **INFORMIX** → SPL (Stored Procedure Language)
- **PostgreSQL** → PL/pgSQL

Estas extensiones no son compatibles entre sí, por eso la migración requiere **traducción** y no solo copia.

### 2.2 Diferencias en la Definición de Stored Procedures

#### Concepto: ¿Qué es un stored procedure?
Un **stored procedure** (procedimiento almacenado) es código SQL que se guarda dentro de la base de datos para ser ejecutado repetidamente. Son equivalentes a "funciones" en lenguajes de programación.

**Ventajas de usar stored procedures:**
- **Performance** - Se compilan una vez y se ejecutan múltiples veces
- **Seguridad** - Se pueden otorgar permisos a nivel de procedure, no de tablas
- **Lógica centralizada** - La lógica de negocio vive en un solo lugar
- **Reducción de tráfico** - Se procesa todo en el servidor, no se transfieren datos innecesarios

#### INFORMIX: CREATE PROCEDURE
En INFORMIX, los procedimientos se declaran con la palabra clave `PROCEDURE`:

```sql
CREATE PROCEDURE nombre_procedimiento(parametro1 INT, parametro2 VARCHAR(50))
  RETURNING INT, VARCHAR(100);  -- Define qué retorna

  DEFINE variable_local INT;    -- Declaración de variables
  DEFINE otra_variable VARCHAR(50);

  -- Lógica del procedimiento
  LET variable_local = parametro1 * 2;

  RETURN variable_local, 'Resultado exitoso';
END PROCEDURE;
```

**Características de INFORMIX SPL:**
- Usa `DEFINE` para declarar variables
- Usa `LET` para asignar valores
- `RETURNING` indica el tipo de retorno
- La sintaxis es más cercana a lenguajes procedurales antiguos

#### PostgreSQL: CREATE FUNCTION
En PostgreSQL, los procedimientos se declaran con la palabra clave `FUNCTION`:

```sql
CREATE OR REPLACE FUNCTION nombre_procedimiento(parametro1 INT, parametro2 VARCHAR(50))
RETURNS TABLE (resultado INT, mensaje VARCHAR(100)) AS $$
DECLARE
  variable_local INT;           -- Declaración de variables en bloque DECLARE
  otra_variable VARCHAR(50);
BEGIN
  -- Lógica del procedimiento
  variable_local := parametro1 * 2;  -- Asignación con :=

  RETURN QUERY SELECT variable_local, 'Resultado exitoso'::VARCHAR(100);
END;
$$ LANGUAGE plpgsql;  -- Especifica el lenguaje del procedure
```

**Características de PostgreSQL PL/pgSQL:**
- Usa `DECLARE` para declarar variables
- Usa `:=` para asignar valores
- `RETURNS` indica el tipo de retorno
- Requiere especificar el lenguaje (`LANGUAGE plpgsql`)
- `CREATE OR REPLACE` permite sobrescribir funciones existentes

#### Tabla comparativa de sintaxis

| Aspecto | INFORMIX | PostgreSQL |
|---------|----------|------------|
| **Palabra clave** | `CREATE PROCEDURE` | `CREATE FUNCTION` |
| **Declaración de retorno** | `RETURNING tipo` | `RETURNS tipo` |
| **Declaración de variables** | `DEFINE var tipo;` | `DECLARE var tipo;` (en bloque) |
| **Asignación de valores** | `LET var = valor;` | `var := valor;` |
| **Retorno de datos** | `RETURN valor;` | `RETURN valor;` o `RETURN QUERY SELECT...` |
| **Delimitadores** | `END PROCEDURE;` | `END; $$ LANGUAGE plpgsql;` |
| **Sobrescritura** | Requiere DROP previo | `CREATE OR REPLACE` |

### 2.3 Manejo de Valores NULL

#### ¿Qué es NULL y por qué importa?
`NULL` en SQL significa "ausencia de valor" o "valor desconocido". No es lo mismo que cero (0) o cadena vacía ('').

**Problemas comunes con NULL:**
- Cualquier operación aritmética con NULL resulta en NULL: `5 + NULL = NULL`
- Comparaciones con NULL requieren sintaxis especial: `columna IS NULL`, no `columna = NULL`
- En agregaciones (SUM, AVG), los NULL se ignoran, lo que puede causar resultados inesperados

#### INFORMIX: Función NVL()
INFORMIX proporciona la función `NVL(expresion, valor_por_defecto)` para manejar NULL:

```sql
-- Si precio es NULL, usa 0
SELECT NVL(precio, 0) FROM productos;

-- Si fecha_entrega es NULL, usa fecha actual
SELECT NVL(fecha_entrega, TODAY) FROM pedidos;
```

#### PostgreSQL: Función COALESCE()
PostgreSQL usa `COALESCE(expresion1, expresion2, ..., expresionN)`:

```sql
-- Si precio es NULL, usa 0
SELECT COALESCE(precio, 0) FROM productos;

-- Si fecha_entrega es NULL, usa fecha actual
SELECT COALESCE(fecha_entrega, CURRENT_DATE) FROM pedidos;

-- COALESCE evalúa múltiples expresiones y retorna la primera NO NULL
SELECT COALESCE(precio_especial, precio_normal, precio_base, 0) FROM productos;
```

**¿Por qué COALESCE es mejor?**
- Es parte del estándar SQL (ISO/ANSI)
- Acepta múltiples argumentos (NVL solo acepta 2)
- Más expresivo y legible

**Proceso de migración:**
Buscar y reemplazar todas las instancias de `NVL` por `COALESCE` en los scripts.

### 2.4 Paginación de Resultados

#### ¿Qué es la paginación?
En aplicaciones web, no se pueden mostrar miles de registros en una sola página. La **paginación** divide los resultados en "páginas" manejables (ej: 20 registros por página).

#### INFORMIX: SKIP y FIRST
INFORMIX usa una sintaxis única con las palabras clave `SKIP` (saltar) y `FIRST` (primeros):

```sql
-- Obtener los primeros 20 registros
SELECT FIRST 20 * FROM licencias ORDER BY fecha_alta DESC;

-- Obtener 20 registros saltando los primeros 40 (página 3)
SELECT SKIP 40 FIRST 20 * FROM licencias ORDER BY fecha_alta DESC;
```

**Interpretación:**
- `SKIP N` = Omitir los primeros N registros
- `FIRST M` = Tomar solo M registros
- Juntos: Saltar N y tomar M

#### PostgreSQL: OFFSET y LIMIT
PostgreSQL usa la sintaxis estándar SQL con `LIMIT` (límite) y `OFFSET` (desplazamiento):

```sql
-- Obtener los primeros 20 registros
SELECT * FROM licencias ORDER BY fecha_alta DESC LIMIT 20;

-- Obtener 20 registros saltando los primeros 40 (página 3)
SELECT * FROM licencias ORDER BY fecha_alta DESC LIMIT 20 OFFSET 40;
```

**Interpretación:**
- `LIMIT M` = Máximo M registros a retornar
- `OFFSET N` = Comenzar desde el registro N+1
- Más intuitivo y legible

**Cálculo de páginas:**
```
Página 1: OFFSET 0 LIMIT 20   (registros 1-20)
Página 2: OFFSET 20 LIMIT 20  (registros 21-40)
Página 3: OFFSET 40 LIMIT 20  (registros 41-60)

Fórmula: OFFSET = (número_página - 1) * registros_por_página
```

### 2.5 Tipos de Datos - Mapeo y Conversiones

#### Tipos numéricos

**SERIAL (autoincremento):**
- INFORMIX: `SERIAL` (hasta 2 mil millones)
- PostgreSQL: `SERIAL` (entero de 4 bytes) o `BIGSERIAL` (entero de 8 bytes)
- **Recomendación:** Usar `BIGSERIAL` en tablas que crecerán mucho

**MONEY (valores monetarios):**
- INFORMIX: `MONEY(p,d)` - Tipo especializado para dinero
- PostgreSQL: `NUMERIC(p,d)` - Tipo decimal de precisión fija
- **Razón del cambio:** PostgreSQL tiene tipo MONEY pero NUMERIC es más portable y preciso
- **Ejemplo:** `MONEY(15,2)` → `NUMERIC(15,2)` (15 dígitos totales, 2 decimales)

#### Tipos de fecha y hora

**DATETIME (fecha y hora):**
- INFORMIX: `DATETIME YEAR TO SECOND` - Especifica qué componentes incluir
- PostgreSQL: `TIMESTAMP` - Incluye fecha y hora sin zona horaria
- **Alternativa:** `TIMESTAMPTZ` si necesitas zona horaria

**Ejemplo de conversión:**
```sql
-- INFORMIX
fecha_registro DATETIME YEAR TO DAY  -- Solo fecha

-- PostgreSQL
fecha_registro DATE                  -- Solo fecha
fecha_registro TIMESTAMP              -- Fecha y hora
```

#### Tipos de texto

**VARCHAR con padding:**
- INFORMIX: `VARCHAR(n,m)` donde n=longitud, m=padding
- PostgreSQL: `VARCHAR(n)` - Sin segundo parámetro
- **Migración:** Ignorar el segundo parámetro: `VARCHAR(50,0)` → `VARCHAR(50)`

**CHAR (cadena de longitud fija):**
- Ambos: `CHAR(n)` - Compatible, pero PostgreSQL recomienda VARCHAR

#### Tipos binarios

**BYTE (datos binarios):**
- INFORMIX: `BYTE` - Para imágenes, archivos
- PostgreSQL: `BYTEA` - Byte Array
- **Uso:** Almacenar PDFs, imágenes, archivos comprimidos

### 2.6 Funciones de Conversión de Tipos

#### INFORMIX: Conversión de fechas
```sql
-- Convertir DATETIME a solo fecha
EXTEND(fecha_completa, YEAR TO DAY)

-- Convertir a solo hora
EXTEND(fecha_completa, HOUR TO SECOND)
```

#### PostgreSQL: CAST y operador ::
```sql
-- Convertir TIMESTAMP a DATE (solo fecha)
CAST(fecha_completa AS DATE)
fecha_completa::DATE               -- Sintaxis corta

-- Convertir texto a entero
CAST('123' AS INTEGER)
'123'::INTEGER

-- Convertir entero a texto
CAST(precio AS VARCHAR)
precio::VARCHAR
```

**Conversiones comunes en migración:**
```sql
-- Fechas
INFORMIX: EXTEND(fecha, YEAR TO DAY)
PostgreSQL: fecha::DATE

-- Números a texto
INFORMIX: valor::LVARCHAR
PostgreSQL: valor::VARCHAR

-- Texto a números
INFORMIX: texto::INT
PostgreSQL: texto::INTEGER o CAST(texto AS INTEGER)
```

### 2.7 Operadores y Funciones de Cadenas

#### Concatenación de texto

**INFORMIX:**
```sql
-- Usa comillas dobles para strings
SELECT "Nombre: " || nombre || " - RFC: " || rfc FROM contribuyentes;
```

**PostgreSQL:**
```sql
-- Usa comillas simples para strings (estándar SQL)
SELECT 'Nombre: ' || nombre || ' - RFC: ' || rfc FROM contribuyentes;

-- Función alternativa (más segura con NULL)
SELECT CONCAT('Nombre: ', nombre, ' - RFC: ', rfc) FROM contribuyentes;
```

**Diferencia clave:** PostgreSQL distingue entre comillas simples (valores) y dobles (identificadores de tablas/columnas).

### 2.8 Actividades prácticas del módulo

1. **Ejercicio de conversión básica:**
   - Tomar 5 procedures de INFORMIX del módulo licencias
   - Identificar las diferencias sintácticas con la versión PostgreSQL
   - Listar los cambios aplicados

2. **Práctica de paginación:**
   - Escribir consultas para obtener páginas 1, 2, 3 de una tabla
   - Comparar sintaxis INFORMIX vs PostgreSQL

3. **Manejo de NULL:**
   - Crear consultas que manejen valores NULL incorrectamente
   - Ver los problemas que causan
   - Corregirlas con COALESCE

4. **Conversión de tipos:**
   - Practicar conversiones entre tipos usando CAST y ::
   - Intentar conversiones inválidas para ver los errores

---

## MÓDULO 3: PATRONES DE STORED PROCEDURES

**Objetivo:** Aprender los patrones de diseño aplicados en el proyecto para crear procedures mantenibles y eficientes

### 3.1 ¿Por qué usar patrones de diseño?

#### El problema del "código espagueti"
Sin una estructura clara, los stored procedures pueden convertirse en código imposible de mantener:
- Nombres inconsistentes: `sp_obtener_datos`, `get_info`, `consulta_tabla`
- Lógica mezclada: Un procedure hace consultas + actualizaciones + reportes
- Parámetros desordenados: Diferentes convenciones en cada procedure
- Sin documentación: Nadie sabe qué hace cada procedure

#### La solución: Patrones consistentes
Un **patrón de diseño** es una solución probada a un problema recurrente. En este proyecto aplicamos patrones para:
- **Nomenclatura** - Todos los procedures siguen la misma convención de nombres
- **Organización** - Cada procedure tiene un propósito único y claro
- **Parámetros** - Convención consistente para nombrar parámetros
- **Retornos** - Formato estándar de resultados

### 3.2 Patrón de Nomenclatura

#### Estructura del nombre
```
[OrigenDelRequerimiento]_sp_[operación]_[entidad]
```

**Componentes:**
1. **Origen** - De dónde viene el requerimiento (formulario, reporte, proceso)
2. **sp_** - Prefijo que indica "stored procedure"
3. **Operación** - Verbo que indica qué hace (get, create, update, delete, list, search)
4. **Entidad** - Sobre qué objeto opera (licencia, mercado, recibo)

**Ejemplos reales del proyecto:**

```
BloquearLicenciafrm_sp_bloquear_licencia
├─ BloquearLicenciafrm = Formulario "Bloquear Licencia"
├─ sp = Stored Procedure
├─ bloquear = Operación
└─ licencia = Entidad afectada

Individual_Folio_sp_individual_folio_search
├─ Individual_Folio = Pantalla de consulta individual por folio
├─ sp = Stored Procedure
├─ search = Operación de búsqueda
└─ folio = Se busca por folio

ReportAutor_sp_report_autorizados
├─ ReportAutor = Reporte de autorizados
├─ sp = Stored Procedure
├─ report = Es un reporte
└─ autorizados = Reporta elementos autorizados
```

#### Ventajas de este patrón
1. **Rastreabilidad** - Sabiendo el nombre del formulario, encuentras sus procedures
2. **Autoexplicativo** - El nombre te dice qué hace sin leer el código
3. **Búsqueda fácil** - Puedes buscar por operación (`sp_create_*`) o por entidad (`*_licencia`)
4. **Evita conflictos** - Nombres únicos y descriptivos

### 3.3 Categorización Funcional de Procedures

El proyecto organiza los procedures en **3 categorías** según su propósito:

#### A. CATÁLOGOS (01_catalogs.sql)

**Propósito:** Procedimientos que retornan listas de valores para catálogos, menús desplegables, y consultas de referencia.

**Características:**
- **Solo lectura** - Nunca modifican datos
- **Retornan conjuntos** - Listas de opciones
- **Sin parámetros o parámetros simples** - Filtros básicos
- **Uso frecuente** - Se ejecutan constantemente en la interfaz

**Ejemplos conceptuales:**

```sql
-- Obtener lista de giros comerciales disponibles
sp_get_giros()
- Retorna: id, nombre_giro, descripcion
- Uso: Llenar dropdown "Seleccione un giro"

-- Obtener categorías de mercados
sp_get_categorias()
- Retorna: id_categoria, nombre, tipo
- Uso: Filtrar locales por categoría

-- Obtener vigencias fiscales disponibles
sp_get_vigencias()
- Retorna: año, bimestre, fecha_inicio, fecha_fin, activo
- Uso: Seleccionar período a consultar

-- Función de conversión de fecha a palabras
date_to_words(fecha DATE)
- Entrada: 2024-03-15
- Retorna: "quince de marzo de dos mil veinticuatro"
- Uso: Documentos oficiales que requieren fecha en letras
```

**Patrón de implementación:**
```sql
CREATE OR REPLACE FUNCTION sp_get_[entidad]()
RETURNS TABLE (
  id INT,
  nombre VARCHAR,
  otros_campos tipo
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    campo_id,
    campo_nombre,
    otros_campos
  FROM tabla_catalogo
  WHERE activo = true
  ORDER BY campo_nombre;
END;
$$ LANGUAGE plpgsql;
```

**¿Cuándo usar procedures de catálogo?**
- Llenar listas desplegables (combos)
- Obtener opciones de filtros
- Consultar datos maestros (maestros de municipios, estados, etc.)
- Convertir valores para presentación (fechas, números a palabras)

#### B. CRUD - Create, Read, Update, Delete (02_crud.sql)

**Propósito:** Procedimientos que realizan operaciones fundamentales sobre las entidades del sistema.

**Las 4 operaciones CRUD:**

**CREATE - Crear nuevos registros**
```sql
sp_[entidad]_create(parámetros...) RETURNS INT

Ejemplo: sp_ejecutor_create(
  nombre VARCHAR,
  rfc VARCHAR,
  telefono VARCHAR
) RETURNS INT  -- Retorna el ID del registro creado

Flujo:
1. Validar datos de entrada
2. Insertar en la tabla
3. Retornar el ID generado (para usarlo en operaciones posteriores)
```

**READ - Consultar registros**
```sql
-- Obtener UN registro específico por ID
sp_[entidad]_get(id INT) RETURNS TABLE(...)

Ejemplo: sp_licencia_get(id_licencia INT)
- Retorna: TODOS los campos de esa licencia
- Uso: Cargar formulario de edición con datos existentes

-- Obtener MÚLTIPLES registros con filtros
sp_[entidad]_list(filtros...) RETURNS TABLE(...)

Ejemplo: sp_licencias_list(
  giro_id INT DEFAULT NULL,
  fecha_desde DATE DEFAULT NULL,
  fecha_hasta DATE DEFAULT NULL,
  page INT DEFAULT 1,
  page_size INT DEFAULT 20
)
- Retorna: Lista paginada de licencias que cumplen filtros
- Uso: Mostrar tabla de resultados con paginación
```

**UPDATE - Actualizar registros**
```sql
sp_[entidad]_update(id INT, otros_parametros...) RETURNS BOOLEAN

Ejemplo: sp_contrato_update(
  id_contrato INT,
  nuevo_monto NUMERIC,
  nueva_fecha_fin DATE,
  usuario_modifica VARCHAR
) RETURNS BOOLEAN  -- TRUE = éxito, FALSE = error

Flujo:
1. Validar que el registro existe
2. Validar que los nuevos datos son válidos
3. Actualizar el registro
4. Registrar en historial de cambios (auditoría)
5. Retornar TRUE si todo salió bien
```

**DELETE - Eliminar registros (lógico)**
```sql
sp_[entidad]_delete(id INT, motivo VARCHAR) RETURNS BOOLEAN

Ejemplo: sp_anuncio_delete(
  id_anuncio INT,
  motivo_baja VARCHAR
) RETURNS BOOLEAN

IMPORTANTE: En este proyecto NO se eliminan registros físicamente.
Se hace "baja lógica":
- Se marca el campo "activo = false"
- Se registra fecha_baja = fecha actual
- Se guarda el motivo_baja
- El registro sigue en la base de datos para historial

Razones para baja lógica:
- Auditoría - Saber qué se eliminó y cuándo
- Trazabilidad - Referencias a registros eliminados no se rompen
- Recuperación - Se puede "reactivar" un registro si fue error
```

**Patrón de validaciones en CRUD:**
Todos los procedures CRUD deben validar:
1. **Existencia** - ¿El registro a modificar/eliminar existe?
2. **Permisos** - ¿El usuario puede hacer esta operación?
3. **Integridad** - ¿Los datos relacionados son consistentes?
4. **Reglas de negocio** - ¿Se cumplen las reglas específicas del municipio?

Ejemplo de validación:
```sql
-- Al intentar bloquear una licencia, validar:
- ¿La licencia existe?
- ¿No está ya bloqueada?
- ¿El usuario tiene permiso para bloquear?
- ¿Existe un adeudo que justifique el bloqueo?
```

#### C. REPORTES (03_reports.sql)

**Propósito:** Procedimientos especializados en generar información agregada, consolidada o analítica para toma de decisiones.

**Características de los reportes:**
- **Consultas complejas** - Múltiples JOINs, subconsultas, agregaciones
- **Filtros múltiples** - Muchos parámetros opcionales para personalizar reporte
- **Agrupaciones** - GROUP BY para totales, promedios, conteos
- **Ordenamiento relevante** - Generalmente DESC por importancia/monto
- **Performance crítico** - Pueden procesar miles de registros

**Tipos de reportes en el proyecto:**

**Reportes de adeudos:**
```sql
sp_adeudos_report(
  fecha_inicio DATE,
  fecha_fin DATE,
  mercado_id INT DEFAULT NULL,  -- NULL = todos los mercados
  categoria_id INT DEFAULT NULL -- NULL = todas las categorías
) RETURNS TABLE (
  folio VARCHAR,
  contribuyente VARCHAR,
  mercado VARCHAR,
  adeudo_monto NUMERIC,
  adeudo_antigüedad INT  -- días de antigüedad
)

Uso: "Reporte de adeudos por mercado del mes de marzo"
- Muestra quién debe, cuánto y desde cuándo
- Permite filtrar por mercado específico o ver todos
- Ordenado por monto (del mayor al menor adeudo)
```

**Reportes de recaudación:**
```sql
sp_recaudacion_diaria(fecha DATE) RETURNS TABLE (
  concepto VARCHAR,
  cantidad_recibos INT,
  monto_total NUMERIC
)

Uso: Corte de caja diario
- Total recaudado por cada concepto (licencias, mercados, apremios)
- Cantidad de recibos emitidos
- Para validar cierre de caja

sp_recaudacion_mensual(año INT, mes INT) RETURNS TABLE (
  semana INT,
  concepto VARCHAR,
  monto NUMERIC
)

Uso: Análisis mensual de ingresos
- Compara semanas del mes
- Identifica tendencias de pago
```

**Reportes de cobranza (apremios):**
```sql
sp_apremios_ejecutor(
  id_ejecutor INT,
  fecha_desde DATE,
  fecha_hasta DATE
) RETURNS TABLE (
  folio_apremio VARCHAR,
  contribuyente VARCHAR,
  monto_cobrado NUMERIC,
  fecha_cobro DATE,
  comision NUMERIC  -- calculada según porcentaje
)

Uso: Reporte de productividad de ejecutor fiscal
- Cuánto cobró en el período
- Su comisión correspondiente
```

**Patrón de parámetros opcionales:**
Los reportes suelen tener filtros opcionales que se manejan así:

```sql
CREATE FUNCTION sp_reporte(
  p_filtro1 INT DEFAULT NULL,
  p_filtro2 VARCHAR DEFAULT NULL,
  p_fecha_desde DATE DEFAULT NULL,
  p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(...) AS $$
BEGIN
  RETURN QUERY
  SELECT ...
  FROM tablas
  WHERE
    -- Filtro 1: Si es NULL, no filtra. Si tiene valor, filtra.
    (p_filtro1 IS NULL OR campo1 = p_filtro1)
    -- Filtro 2: Similar
    AND (p_filtro2 IS NULL OR campo2 LIKE '%' || p_filtro2 || '%')
    -- Rango de fechas
    AND (p_fecha_desde IS NULL OR fecha >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR fecha <= p_fecha_hasta);
END;
$$ LANGUAGE plpgsql;
```

**Técnica explicada:** `(p_filtro IS NULL OR campo = p_filtro)`
- Si el parámetro es NULL: La expresión `(NULL IS NULL)` = TRUE, entonces no filtra
- Si el parámetro tiene valor: La expresión `(valor IS NULL)` = FALSE, entonces evalúa `campo = p_filtro`

### 3.4 Patrón de Parámetros

#### Convención de prefijos en variables

El proyecto usa **prefijos** para identificar el origen de cada variable:

**p_** = Parámetro de entrada
```sql
CREATE FUNCTION sp_ejemplo(
  p_mercado_id INT,      -- Parámetro: ID de mercado
  p_fecha_inicio DATE,   -- Parámetro: Fecha de inicio
  p_usuario VARCHAR      -- Parámetro: Usuario que ejecuta
)
```

**v_** = Variable local
```sql
DECLARE
  v_total NUMERIC := 0;       -- Variable local: acumulador de total
  v_contador INT := 0;        -- Variable local: contador de registros
  v_existe BOOLEAN;           -- Variable local: flag de existencia
```

**cur_** = Cursor (para recorrer resultados)
```sql
DECLARE
  cur_registros CURSOR FOR SELECT * FROM tabla;
```

**CONSTANTES** = En mayúsculas
```sql
DECLARE
  MAX_INTENTOS INT := 3;
  COMISION_PORCENTAJE NUMERIC := 0.05;  -- 5%
```

**Ventajas de esta convención:**
- **Legibilidad** - Se distingue inmediatamente el origen de cada variable
- **Prevención de errores** - No confundes un parámetro con una variable local
- **Mantenibilidad** - Al leer código ajeno, entiendes qué es cada cosa

### 3.5 Manejo de Errores y Transacciones

#### ¿Qué es una transacción?

Una **transacción** es un conjunto de operaciones que deben ejecutarse TODAS o NINGUNA. Concepto clave: **atomicidad**.

**Ejemplo del mundo real:** Transferencia bancaria
```
Operación: Transferir $1000 de cuenta A a cuenta B
Paso 1: Restar $1000 de cuenta A
Paso 2: Sumar $1000 a cuenta B

¿Qué pasa si hay un error entre paso 1 y 2?
- Sin transacción: Cuenta A pierde $1000, cuenta B no lo recibe (¡dinero desaparecido!)
- Con transacción: Si falla paso 2, se revierte paso 1 (rollback). Todo queda como estaba.
```

#### Transacciones en stored procedures

**Patrón básico:**
```sql
CREATE FUNCTION sp_proceso_transaccional(parametros...)
RETURNS BOOLEAN AS $$
DECLARE
  v_success BOOLEAN := false;
BEGIN
  -- PostgreSQL inicia transacción automáticamente

  -- Operación 1
  INSERT INTO tabla1 VALUES (...);

  -- Operación 2
  UPDATE tabla2 SET ... WHERE ...;

  -- Operación 3
  DELETE FROM tabla3 WHERE ...;

  -- Si llegamos aquí sin errores, se hace COMMIT automático
  v_success := true;
  RETURN v_success;

EXCEPTION
  WHEN OTHERS THEN
    -- Si hubo cualquier error, se hace ROLLBACK automático
    RAISE NOTICE 'Error: %', SQLERRM;  -- Log del error
    v_success := false;
    RETURN v_success;
END;
$$ LANGUAGE plpgsql;
```

**Explicación del flujo:**
1. PostgreSQL inicia transacción al entrar al procedure
2. Se ejecutan todas las operaciones
3. Si todo sale bien → COMMIT (se guardan cambios)
4. Si hay error → ROLLBACK (se deshacen cambios)

#### Validaciones previas

**Patrón de validación:**
```sql
CREATE FUNCTION sp_bloquear_licencia(p_id_licencia INT, p_motivo VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
  v_existe BOOLEAN;
  v_ya_bloqueada BOOLEAN;
BEGIN
  -- VALIDACIÓN 1: ¿Existe la licencia?
  SELECT EXISTS(SELECT 1 FROM ta_licencias WHERE id = p_id_licencia)
  INTO v_existe;

  IF NOT v_existe THEN
    RAISE EXCEPTION 'Licencia % no existe', p_id_licencia;
  END IF;

  -- VALIDACIÓN 2: ¿Ya está bloqueada?
  SELECT bloqueada INTO v_ya_bloqueada
  FROM ta_licencias WHERE id = p_id_licencia;

  IF v_ya_bloqueada THEN
    RAISE EXCEPTION 'Licencia % ya está bloqueada', p_id_licencia;
  END IF;

  -- Si pasó todas las validaciones, proceder
  UPDATE ta_licencias
  SET bloqueada = true,
      motivo_bloqueo = p_motivo,
      fecha_bloqueo = CURRENT_TIMESTAMP
  WHERE id = p_id_licencia;

  -- Registrar en historial
  INSERT INTO ta_historial_bloqueos (licencia_id, motivo, fecha)
  VALUES (p_id_licencia, p_motivo, CURRENT_TIMESTAMP);

  RETURN true;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error al bloquear licencia: %', SQLERRM;
    RETURN false;
END;
$$ LANGUAGE plpgsql;
```

#### Niveles de errores

**RAISE NOTICE** - Mensaje informativo
```sql
RAISE NOTICE 'Procesando registro %', id_registro;
-- Continúa la ejecución
```

**RAISE EXCEPTION** - Error que aborta la transacción
```sql
RAISE EXCEPTION 'Registro no encontrado';
-- Se hace ROLLBACK y se aborta el procedure
```

**RAISE WARNING** - Advertencia que se registra pero no aborta
```sql
RAISE WARNING 'Este valor parece incorrecto: %', valor;
-- Continúa la ejecución
```

### 3.6 Actividades prácticas del módulo

1. **Ejercicio de nomenclatura:**
   - Dado un requerimiento, proponer nombres de procedures siguiendo el patrón
   - Ejemplo: "Crear un reporte de licencias vencidas por giro"
   - Respuesta: `ReportLicVencidas_sp_report_licencias_vencidas_by_giro`

2. **Clasificación de procedures:**
   - Dada una lista de 20 procedures del proyecto, clasificarlos en: Catalog, CRUD, Report
   - Justificar la clasificación

3. **Implementación de validaciones:**
   - Escribir un procedure que valide datos antes de insertar
   - Probar con datos inválidos y ver cómo se manejan los errores

4. **Práctica de transacciones:**
   - Crear un procedure que haga múltiples operaciones
   - Provocar un error en la operación 2 de 3
   - Verificar que las operaciones 1 y 3 no se guardaron (rollback correcto)

---

## MÓDULO 4: OPTIMIZACIÓN DE CONSULTAS

**Objetivo:** Aprender técnicas para mejorar el rendimiento de consultas SQL y stored procedures

### 4.1 ¿Por qué optimizar?

#### El costo de las consultas lentas

Una consulta que tarda 5 segundos parece poco. Pero:
- 100 usuarios ejecutándola simultáneamente = 500 segundos de tiempo de servidor
- El sistema se vuelve lento y los usuarios se frustran
- En hora pico, el sistema puede colapsar

**Impacto en el negocio:**
- Ciudadanos esperando en ventanilla mientras "carga el sistema"
- Empleados municipales improductivos por sistema lento
- Costos de infraestructura: Se compran servidores más caros innecesariamente

**La regla de oro:** Una consulta debe ejecutarse en menos de 1 segundo para sentirse "instantánea".

### 4.2 Índices - El Fundamento de la Velocidad

#### ¿Qué es un índice?

Un **índice** en una base de datos es como el índice de un libro:
- Sin índice: Lees TODO el libro página por página hasta encontrar lo que buscas
- Con índice: Vas directo a la página que necesitas

**Ejemplo práctico:**
```sql
-- Sin índice: Buscar una licencia por folio
-- PostgreSQL debe recorrer TODAS las filas de la tabla (100,000 filas)
SELECT * FROM ta_licencias WHERE folio = 'LIC-2024-12345';
-- Tiempo: 2 segundos (Scan completo)

-- Con índice en columna folio:
-- PostgreSQL va directo a la fila que necesita
SELECT * FROM ta_licencias WHERE folio = 'LIC-2024-12345';
-- Tiempo: 0.01 segundos (Index Scan)
```

#### Tipos de índices

**Índice simple (una columna):**
```sql
CREATE INDEX idx_licencias_folio ON ta_licencias(folio);
```
Acelera búsquedas por ese campo específico.

**Índice compuesto (múltiples columnas):**
```sql
CREATE INDEX idx_recibos_fecha_status
ON ta_recibos(fecha_pago, status_recibo);
```
Acelera búsquedas que filtran por ambas columnas o solo por la primera.

**¿Cuándo usar índice compuesto?**
Cuando frecuentemente filtras así:
```sql
-- Esta consulta se beneficia del índice compuesto
SELECT * FROM ta_recibos
WHERE fecha_pago = '2024-03-01'
  AND status_recibo = 'PAGADO';

-- Esta también (usa solo la primera columna del índice)
SELECT * FROM ta_recibos WHERE fecha_pago = '2024-03-01';

-- Esta NO (usa solo la segunda columna)
SELECT * FROM ta_recibos WHERE status_recibo = 'PAGADO';
```

**Regla:** En índices compuestos, el orden de las columnas importa. Pon primero la columna más selectiva.

#### ¿Qué columnas indexar?

**SÍ indexar:**
- Columnas usadas en WHERE frecuentemente: `folio`, `rfc`, `email`
- Columnas usadas en JOIN: `licencia_id`, `contribuyente_id`
- Columnas usadas en ORDER BY: `fecha_alta`, `monto`
- Claves foráneas (foreign keys)

**NO indexar:**
- Columnas con pocos valores distintos: `activo` (solo true/false)
- Columnas que nunca se consultan
- Tablas muy pequeñas (< 1000 filas)

**Trade-off:** Los índices aceleran SELECT pero enlentecen INSERT/UPDATE/DELETE (porque hay que actualizar el índice también).

### 4.3 EXPLAIN ANALYZE - El Detector de Problemas

#### ¿Qué hace EXPLAIN ANALYZE?

Es una herramienta que te muestra:
- ¿Cómo ejecutó PostgreSQL tu consulta?
- ¿Cuánto tiempo tomó cada paso?
- ¿Usó índices o recorrió toda la tabla?
- ¿Cuántas filas procesó?

**Sintaxis:**
```sql
EXPLAIN ANALYZE
SELECT * FROM ta_licencias
WHERE folio = 'LIC-2024-12345';
```

**Salida ejemplo (simplificada):**
```
Index Scan using idx_licencias_folio on ta_licencias (cost=0.42..8.44 rows=1 width=256) (actual time=0.023..0.024 rows=1 loops=1)
  Index Cond: (folio = 'LIC-2024-12345'::varchar)
Planning Time: 0.082 ms
Execution Time: 0.045 ms
```

**Interpretación:**
- `Index Scan using idx_licencias_folio` → ¡Bien! Usó el índice
- `actual time=0.023..0.024` → Tardó 0.024 milisegundos
- `rows=1` → Encontró 1 fila (lo esperado)
- `Execution Time: 0.045 ms` → Total: 0.045 milisegundos (excelente)

#### Señales de problemas en EXPLAIN

**Seq Scan (Sequential Scan) - Bandera roja:**
```
Seq Scan on ta_licencias (cost=0.00..2500.00 rows=100000)
```
Significa: Recorrió TODA la tabla. Solución: Crear un índice.

**High cost - Costo elevado:**
```
cost=0.00..50000.00
```
El segundo número (50000) es el costo estimado. Si es > 10000, hay problema.

**Filas procesadas vs filas retornadas:**
```
rows=100000 (estimado) ... actual rows=1
```
Si procesa muchas filas pero retorna pocas, hay ineficiencia. Necesita mejor filtrado.

### 4.4 El Problema N+1 Queries

#### ¿Qué es el problema N+1?

Es cuando ejecutas 1 consulta principal + N consultas adicionales en un loop.

**Ejemplo del problema:**
```sql
-- Consulta 1: Obtener todas las licencias
SELECT * FROM ta_licencias LIMIT 100;  -- Retorna 100 filas

-- Luego, POR CADA licencia (100 veces):
SELECT * FROM ta_contribuyentes WHERE id = [licencia.contribuyente_id];

Total de consultas: 1 + 100 = 101 consultas
```

**Impacto:** Si cada consulta tarda 10ms, total = 1010ms (1 segundo). ¡Inaceptable!

#### La solución: JOINs

```sql
-- UNA SOLA consulta con JOIN
SELECT
  l.*,
  c.nombre,
  c.rfc,
  c.domicilio
FROM ta_licencias l
INNER JOIN ta_contribuyentes c ON l.contribuyente_id = c.id
LIMIT 100;

Total de consultas: 1
Tiempo: ~20ms (50 veces más rápido)
```

**Regla:** Si necesitas datos de tablas relacionadas, usa JOIN. Nunca consultes en loop.

### 4.5 Subconsultas vs JOINs

#### Subconsulta en WHERE (puede ser lenta)
```sql
-- Obtener licencias cuyos contribuyentes tienen adeudos
SELECT *
FROM ta_licencias
WHERE contribuyente_id IN (
  SELECT DISTINCT contribuyente_id
  FROM ta_adeudos
  WHERE monto > 0
);
```

**Problema:** La subconsulta se ejecuta primero y puede generar un set grande.

#### Equivalente con JOIN (generalmente más rápido)
```sql
SELECT DISTINCT l.*
FROM ta_licencias l
INNER JOIN ta_adeudos a ON l.contribuyente_id = a.contribuyente_id
WHERE a.monto > 0;
```

**Ventaja:** El optimizador puede elegir el mejor orden de ejecución.

**Recomendación:** Usa EXPLAIN ANALYZE para comparar. En PostgreSQL moderno, a veces optimiza ambas igual.

### 4.6 Uso Eficiente de Agregaciones

#### COUNT(*) en tablas grandes

**Lento:**
```sql
-- Contar TODOS los registros de tabla gigante
SELECT COUNT(*) FROM ta_recibos;
-- Puede tardar segundos en tablas de millones de filas
```

**Alternativas:**

1. **Si solo necesitas saber "hay datos":**
```sql
SELECT EXISTS(SELECT 1 FROM ta_recibos LIMIT 1);
-- Retorna true/false en microsegundos
```

2. **Si necesitas un conteo aproximado:**
```sql
SELECT reltuples::BIGINT AS estimado
FROM pg_class
WHERE relname = 'ta_recibos';
-- Estadística mantenida por PostgreSQL, instantánea
```

#### GROUP BY con miles de grupos

**Potencial problema:**
```sql
SELECT contribuyente_id, COUNT(*), SUM(monto)
FROM ta_adeudos
GROUP BY contribuyente_id;
-- Si hay 50,000 contribuyentes, genera 50,000 grupos
```

**Optimización:** Filtrar antes de agrupar
```sql
SELECT contribuyente_id, COUNT(*), SUM(monto)
FROM ta_adeudos
WHERE fecha_adeudo >= '2024-01-01'  -- Reduce filas a procesar
GROUP BY contribuyente_id
HAVING SUM(monto) > 1000;  -- Filtra grupos después de agrupar
```

### 4.7 Optimización de Procedures con Reportes

#### Problema: Reporte que tarda 30 segundos

**Causas comunes:**
1. JOINs sin índices en las columnas de unión
2. Subconsultas correlacionadas en SELECT
3. Múltiples agregaciones sobre misma tabla
4. Ordenamiento de muchos registros sin índice

#### Técnica: Vista Materializada

Una **vista materializada** es una tabla que almacena el resultado de una consulta compleja.

**Crear vista materializada:**
```sql
CREATE MATERIALIZED VIEW mv_adeudos_resumen AS
SELECT
  DATE_TRUNC('month', fecha_adeudo) as mes,
  mercado_id,
  categoria_id,
  COUNT(*) as cantidad_adeudos,
  SUM(monto) as total_adeudo
FROM ta_adeudos
GROUP BY DATE_TRUNC('month', fecha_adeudo), mercado_id, categoria_id;

-- Crear índice en la vista
CREATE INDEX idx_mv_adeudos_resumen_fecha
ON mv_adeudos_resumen(mes);
```

**Usar la vista:**
```sql
-- En lugar de calcular cada vez, consultar la vista
SELECT * FROM mv_adeudos_resumen
WHERE mes = '2024-03-01'
  AND mercado_id = 5;
-- ¡Instantáneo!
```

**Refrescar la vista (actualizar datos):**
```sql
-- Refrescar cada noche con un cron job
REFRESH MATERIALIZED VIEW mv_adeudos_resumen;
```

**Cuándo usar vistas materializadas:**
- Reportes que se ejecutan muchas veces con los mismos datos
- Cálculos complejos que no cambian frecuentemente
- Trade-off: Datos no en tiempo real (se actualizan periódicamente)

### 4.8 Actividades prácticas del módulo

1. **Análisis de performance:**
   - Ejecutar 5 procedures sin usar EXPLAIN ANALYZE, medir tiempo
   - Re-ejecutar con EXPLAIN ANALYZE
   - Identificar cuáles usan Seq Scan
   - Proponer índices

2. **Crear índices:**
   - Identificar 10 columnas que se usan frecuentemente en WHERE
   - Crear índices en ellas
   - Re-ejecutar consultas y comparar tiempos

3. **Detectar N+1:**
   - Buscar en el código procedures que hacen consultas en loop
   - Reescribirlos usando JOINs
   - Comparar performance

4. **Vista materializada:**
   - Identificar un reporte lento
   - Crear una vista materializada para ese reporte
   - Comparar tiempo antes/después

---

## MÓDULO 5: CASOS DE USO REALES POR MÓDULO

**Objetivo:** Entender la lógica de negocio aplicada en cada módulo funcional del sistema

### 5.1 Módulo LICENCIAS - Gestión Integral de Permisos (709 scripts)

#### Contexto del negocio
Las licencias comerciales son permisos que el municipio otorga a negocios para operar legalmente. El módulo gestiona el ciclo de vida completo desde la solicitud inicial hasta la cancelación o renovación. Este es el módulo más complejo del sistema con más de 700 scripts SQL.

#### Flujos de trabajo principales

**A. Alta de nueva licencia**

**Proceso:**
1. El contribuyente solicita una licencia para un giro específico (restaurant, comercio, bar, etc.)
2. El sistema valida:
   - Que no exista otra licencia activa en el mismo domicilio para el mismo giro
   - Que el contribuyente no tenga adeudos pendientes
   - Que el RFC no esté bloqueado
   - Que el giro sea compatible con la zonificación del domicilio
3. Se genera un folio único para la licencia
4. Se calcula el monto a pagar según tablas de cuotas y contribuciones
5. Se emite el recibo de pago
6. Una vez pagado, se activa la licencia

**Stored procedures involucrados:**
- `sp_licencia_create()` - Crea el registro inicial
- `sp_validar_domicilio()` - Verifica que no existan conflictos
- `sp_calcular_cuota()` - Calcula el monto según giro y superficie
- `sp_generar_folio()` - Genera folio único con formato LIC-YYYY-NNNNN

**B. Sistema de bloqueos**

**¿Cuándo se bloquea una licencia?**
- El contribuyente tiene adeudos mayores a 3 bimestres
- Incumplimiento de requisitos de protección civil
- Incumplimiento de requisitos ecológicos
- Cambio de giro sin autorización
- Denuncia ciudadana validada

**Consecuencias del bloqueo:**
- No se puede renovar la licencia
- No se pueden hacer modificaciones (cambio de domicilio, giro, etc.)
- No se emiten constancias de vigencia
- El negocio técnicamente no puede operar

**Proceso de desbloqueo:**
1. El contribuyente debe resolver la causa del bloqueo
2. Presentar evidencia (comprobante de pago de adeudos, documento de protección civil, etc.)
3. Un supervisor autoriza el desbloqueo
4. Se registra en historial el motivo del desbloqueo
5. La licencia vuelve a status activo

**Stored procedures:**
- `sp_bloquear_licencia()` - Marca la licencia como bloqueada
- `sp_bloquear_por_adeudo()` - Bloqueo automático por deuda
- `sp_desbloquear_licencia()` - Desbloquea y registra en historial
- `sp_historial_bloqueos()` - Consulta todos los bloqueos/desbloqueos

**C. Renovaciones**

Las licencias deben renovarse anualmente. El proceso:
1. El sistema genera automáticamente la cuota de renovación en enero de cada año
2. El contribuyente tiene hasta marzo para pagar sin recargos
3. Después de marzo, se generan recargos por mora (2% mensual)
4. Si no renueva en el año, la licencia pasa a status "vencida"
5. Una licencia vencida puede reactivarse pagando adeudos + multa

**Stored procedures:**
- `sp_generar_renovaciones()` - Proceso batch que genera cuotas de renovación
- `sp_calcular_recargos()` - Calcula recargos por pago extemporáneo
- `sp_renovar_licencia()` - Marca como renovada al recibir pago

**D. Constancias**

Los contribuyentes solicitan constancias de vigencia para trámites (bancos, proveedores, licitaciones).

**Requisitos para emitir constancia:**
- Licencia en status activo (no bloqueada, no vencida)
- Adeudos pagados
- Último holograma colocado
- Formato de protección civil vigente

**Stored procedures:**
- `sp_generar_constancia()` - Genera el documento PDF
- `sp_validar_requisitos_constancia()` - Verifica que se cumplan requisitos

**E. Hologramas**

Cada año se debe colocar un holograma físico en el negocio que indica que la licencia está vigente.

**Proceso:**
1. Se genera el holograma al pagar la renovación
2. Tiene un número único y código de barras
3. El inspector verifica físicamente que esté colocado
4. Si no lo tiene, el negocio puede ser clausurado

**Stored procedures:**
- `sp_generar_holograma()` - Crea registro del holograma
- `sp_consultar_holograma()` - Inspección lo consulta con código de barras
- `sp_validar_vigencia_holograma()` - Verifica que sea del año actual

#### Reglas de negocio críticas

1. **Un domicilio puede tener múltiples licencias** pero no del mismo giro
2. **Los giros tienen categorías** (bajo riesgo, mediano riesgo, alto riesgo) que determinan requisitos
3. **Giros de alto riesgo** (bares, cantinas) requieren inspecciones periódicas
4. **Superficie del local** afecta el cálculo de cuotas
5. **Cambio de giro** se considera una nueva licencia (debe pasar por todo el proceso)

### 5.2 Módulo MERCADOS - Administración de Locales (624 scripts)

#### Contexto del negocio
El municipio administra decenas de mercados públicos donde cientos de comerciantes rentan locales. El módulo gestiona contratos, pagos de renta, cobro de servicios (luz, agua), y control de adeudos.

#### Flujos de trabajo principales

**A. Asignación de locales**

**Proceso:**
1. Se publica convocatoria cuando hay locales disponibles
2. Interesados presentan solicitud
3. Comité evalúa y asigna locales según criterios (antigüedad, giro, inversión propuesta)
4. Se firma contrato con:
   - Monto mensual de renta
   - Giro autorizado
   - Horarios
   - Obligaciones
5. Se genera la cuenta en el sistema

**Stored procedures:**
- `sp_local_create()` - Crea registro del local
- `sp_contrato_create()` - Genera el contrato
- `sp_asignar_cuenta()` - Vincula local con cuenta de pagos

**B. Adeudos de renta**

**Cómo se generan:**
1. Al inicio de cada mes, proceso batch genera adeudos de renta para todos los locales activos
2. Monto base según contrato + ajuste por inflación anual
3. Se suma el adeudo a la cuenta del local
4. Locatario tiene hasta el día 10 del mes para pagar sin recargos
5. Después del 10, se generan recargos del 2% mensual
6. Si acumula más de 3 meses sin pagar, se inicia proceso de rescisión de contrato

**Stored procedures:**
- `sp_generar_adeudos_mensuales()` - Proceso batch de inicio de mes
- `sp_calcular_renta()` - Calcula renta con ajuste inflacionario
- `sp_aplicar_recargos()` - Calcula y aplica recargos por mora
- `sp_adeudos_por_local()` - Consulta total adeudado

**C. Adeudos de energía eléctrica**

Los mercados tienen medidores por local para distribuir el costo de la luz.

**Proceso:**
1. Al llegar recibo de CFE del mercado (monto total)
2. Se consulta lectura individual de cada medidor
3. Se distribuye proporcionalmente el costo entre los locales según consumo
4. Se genera adeudo de energía por local
5. Este adeudo es adicional a la renta

**Problemas comunes:**
- Medidores descompuestos → Se estima consumo promedio
- Locales que manipulan medidores → Inspecciones y multas
- Áreas comunes sin medidor → Se distribuye proporcionalmente

**Stored procedures:**
- `sp_distribuir_energia()` - Distribuye costo del recibo CFE
- `sp_registrar_lectura_medidor()` - Captura lectura mensual
- `sp_adeudo_energia_por_local()` - Consulta adeudo eléctrico

**D. Reportes de recaudación**

Los administradores de mercado necesitan reportes de:
- Recaudación mensual del mercado
- Locales con adeudos
- Morosidad por categoría de local
- Comparativos mensuales/anuales

**Stored procedures:**
- `sp_recaudacion_por_mercado()` - Total recaudado por mercado
- `sp_reporte_morosidad()` - Listado de locales morosos
- `sp_estadisticas_mercado()` - Métricas generales

#### Reglas de negocio críticas

1. **Un local solo puede tener un locatario activo** a la vez
2. **Traspaso de local** requiere autorización y pago de derechos
3. **Cambio de giro** debe ser compatible con el mercado
4. **Locales de esquina o con más visibilidad** tienen renta más alta
5. **Descuentos especiales** para adultos mayores o personas con discapacidad

### 5.3 Módulo ASEO - Servicio de Limpia Urbana (483 scripts)

#### Contexto del negocio
Gestiona el servicio de recolección de residuos sólidos y limpieza urbana. Controla rutas de recolección, vehículos, personal operativo, y genera cobros por servicios especiales (recolección de cascajo, eventos especiales, contenedores adicionales).

#### Stored Procedures principales migrados

**Alta de servicios**
- `sp_alta_servicio_aseo()` - Registra solicitud de servicio especial
- `sp_asignar_ruta_vehiculo()` - Planifica rutas de recolección
- `sp_registrar_personal_turno()` - Control de turnos del personal

**Consultas y reportes**
- `sp_consulta_servicios_activos()` - Servicios programados
- `sp_reporte_rutas_dia()` - Rutas del día por zona
- `sp_calculo_tarifa_servicio()` - Cálculo de cobro por servicio especial

**Facturación de servicios**
- `sp_generar_cargo_servicio()` - Genera cargo por servicio prestado
- `sp_reporte_ingresos_aseo()` - Ingresos por servicios de limpia
- `sp_cancelar_servicio()` - Cancelación de servicio solicitado

#### Reglas de negocio críticas

1. **Servicios residenciales** son gratuitos y forman parte del predial
2. **Servicios especiales** (cascajo, poda, eventos) tienen costo adicional
3. **Rutas de recolección** están predefinidas por colonia y día de semana
4. **Vehículos deben tener mantenimiento vigente** para operar
5. **Personal operativo** debe estar certificado en manejo de residuos

### 5.7 Módulo APREMIOS - Cobro Coercitivo (222 scripts)

#### Contexto del negocio
Cuando un contribuyente tiene adeudos que no ha pagado voluntariamente, el municipio puede iniciar proceso de cobro coercitivo (apremio) a través de ejecutores fiscales.

#### Flujos de trabajo principales

**A. Generación de apremios**

**¿Cuándo se genera un apremio?**
- Adeudos mayores a 6 meses sin pago
- Contribuyente no responde a requerimientos de pago
- Dirección de Ingresos autoriza inicio de procedimiento

**Proceso:**
1. Se genera folio de apremio con el monto total adeudado
2. Se calcula gastos de ejecución (porcentaje sobre el adeudo)
3. Se asigna a un ejecutor fiscal
4. Ejecutor notifica al contribuyente personalmente
5. Contribuyente tiene 3 días para pagar voluntariamente
6. Si no paga, se inicia embargo

**Stored procedures:**
- `sp_generar_apremio()` - Crea el folio de apremio
- `sp_calcular_gastos_ejecucion()` - Calcula gastos (10% del adeudo)
- `sp_asignar_ejecutor()` - Asigna a ejecutor disponible

**B. Asignación a ejecutores**

El municipio tiene ejecutores fiscales que trabajan comisionados.

**Cómo se asignan:**
- Sistema de turnos rotativos
- Se balancean según carga de trabajo
- Ejecutor con menos folios activos recibe el siguiente
- Se considera ubicación geográfica para optimizar rutas

**Comisiones:**
- 5% del monto cobrado va para el ejecutor
- Se paga mensualmente con corte el último día del mes

**Stored procedures:**
- `sp_ejecutores_disponibles()` - Lista ejecutores activos
- `sp_folios_por_ejecutor()` - Carga de trabajo actual
- `sp_calcular_comisiones()` - Cierre mensual de comisiones

**C. Seguimiento de cobro**

**Estados del apremio:**
1. **Generado** - Creado en el sistema
2. **Asignado** - Tiene ejecutor asignado
3. **Notificado** - Ejecutor notificó al contribuyente
4. **En proceso** - En trámite de embargo
5. **Pagado** - Contribuyente pagó
6. **Incobrable** - No se pudo cobrar (contribuyente inexistente, sin bienes embargables)

**Stored procedures:**
- `sp_actualizar_estado_apremio()` - Cambia status
- `sp_registrar_pago_apremio()` - Aplica pago y cierra folio
- `sp_marcar_incobrable()` - Cierra folio como incobrable

**D. Reportes de productividad**

Los supervisores necesitan reportes de:
- Cuánto ha cobrado cada ejecutor
- Folios pagados vs incobrab

les
- Tiempo promedio de cobro
- Eficiencia por ejecutor

**Stored procedures:**
- `sp_reporte_ejecutor()` - Productividad individual
- `sp_reporte_apremios_periodo()` - Resumen por período
- `sp_estadisticas_cobro()` - Métricas generales

#### Reglas de negocio críticas

1. **Apremio no se puede cancelar** una vez notificado
2. **Contribuyente puede acordar plan de pagos** antes del embargo
3. **Ejecutor debe notificar personalmente** (no vale dejar citatorio)
4. **Si contribuyente paga, apremio se cierra automáticamente** y ejecutor cobra comisión
5. **Apremios prescriben en 5 años** si no se ejecutan

### 5.4 Módulo RECAUDADORA - Sistema de Pagos (473 scripts)

#### Contexto del negocio
Este es el módulo central que procesa todos los pagos del municipio. Maneja recibos, aplicación de pagos, cierres de caja, y conciliación bancaria.

#### Flujos de trabajo principales

**A. Generación de recibos**

**Proceso:**
1. Contribuyente se presenta a ventanilla o paga en línea
2. Cajero consulta adeudos del contribuyente
3. Se genera recibo con:
   - Folio único
   - Concepto(s) a pagar
   - Monto
   - Fecha y hora
   - Cajero que atendió
4. Contribuyente paga efectivo, tarjeta o transferencia
5. Se imprime recibo y se entrega
6. El pago se aplica automáticamente a los adeudos

**Stored procedures:**
- `sp_generar_recibo()` - Crea el recibo
- `sp_aplicar_pago()` - Afecta los adeudos correspondientes
- `sp_cancelar_recibo()` - Cancela si hubo error (requiere supervisor)

**B. Cierre de caja diario**

Al final del día cada cajero hace su corte:

**Proceso:**
1. Sistema suma todos los recibos del día del cajero
2. Cajero entrega efectivo, comprobantes de tarjeta
3. Supervisor verifica que el monto físico coincida con el sistema
4. Si hay faltante, se registra y se descuenta al cajero
5. Si hay sobrante, se registra como ingreso extraordinario
6. Se genera reporte de cierre de caja

**Stored procedures:**
- `sp_corte_caja()` - Genera reporte del día
- `sp_verificar_cuadre()` - Compara sistema vs físico
- `sp_registrar_diferencia()` - Registra faltantes/sobrantes

**C. Remesas**

El dinero recaudado se deposita en el banco en remesas:

**Proceso:**
1. Se acumula efectivo de varios días
2. Se prepara remesa (relación de recibos + monto total)
3. Se deposita en el banco
4. Banco devuelve comprobante de depósito
5. Se concilia: monto depositado debe coincidir con remesa
6. Si no coincide, se investiga y ajusta

**Stored procedures:**
- `sp_generar_remesa()` - Agrupa recibos para depositar
- `sp_registrar_deposito()` - Registra comprobante bancario
- `sp_conciliar_remesa()` - Valida coincidencia

**D. Reportes financieros**

La tesorería necesita reportes de:
- Recaudación diaria por concepto
- Recaudación mensual comparativa
- Recaudación por cajero
- Recaudación por forma de pago (efectivo, tarjeta, transferencia)

**Stored procedures:**
- `sp_recaudacion_diaria()` - Corte del día
- `sp_recaudacion_mensual()` - Corte del mes
- `sp_recaudacion_por_concepto()` - Desglose por tipo de pago
- `sp_estadisticas_recaudacion()` - Métricas y tendencias

#### Reglas de negocio críticas

1. **Un recibo no se puede modificar** una vez impreso
2. **Cancelación de recibo** requiere autorización de supervisor y motivo justificado
3. **Los pagos se aplican primero a adeudos más antiguos** (FIFO)
4. **Recibo cancelado genera un recibo de reversa** para auditoría
5. **Todo movimiento de dinero debe estar respaldado** por comprobante físico

### 5.5 Módulo CONVENIOS - Gestión de Convenios de Pago (407 scripts)

#### Contexto del negocio
Permite a contribuyentes con adeudos negociar planes de pago a plazos. El módulo controla que se cumplan los pagos parciales según calendario acordado, y en caso de incumplimiento, puede cancelar el convenio y reactivar el adeudo original con recargos.

#### Stored Procedures principales migrados

**Alta y gestión de convenios**
- `sp_calcular_convenio()` - Calcula plan de pagos según adeudo y plazo
- `sp_alta_convenio()` - Registra convenio autorizado
- `sp_consulta_convenios_vigentes()` - Convenios activos del contribuyente
- `sp_historial_convenios()` - Convenios anteriores (cumplidos/incumplidos)

**Control de pagos**
- `sp_registrar_pago_parcialidad()` - Aplica pago de una parcialidad
- `sp_consulta_parcialidades_pendientes()` - Pagos pendientes del convenio
- `sp_validar_convenio_al_corriente()` - Verifica si está al día

**Cancelación y refinanciamiento**
- `sp_cancelar_convenio_incumplido()` - Cancela por falta de pago
- `sp_refinanciar_convenio()` - Renegocia plazo o monto
- `sp_liquidar_convenio()` - Cierra convenio al pagarse completo

#### Reglas de negocio críticas

1. **Monto mínimo por parcialidad** según políticas municipales
2. **Plazo máximo** generalmente 12 o 24 meses según monto
3. **Incumplir 2 parcialidades consecutivas** cancela el convenio automáticamente
4. **Convenio cancelado** reactiva adeudo original con recargos acumulados
5. **No se pueden hacer dos convenios simultáneos** sobre el mismo adeudo

### 5.6 Módulo ESTACIONAMIENTOS - Control de Multas de Estacionamiento (237 scripts)

#### Contexto del negocio
Administra infracciones por mal estacionamiento. Los agentes de tránsito generan boletas de infracción que deben pagarse en ventanilla o pueden generar apremio si no se pagan a tiempo.

#### Stored Procedures principales migrados

**Generación de infracciones**
- `sp_generar_infraccion()` - Registra boleta de infracción
- `sp_consulta_infracciones_vehiculo()` - Historial por placas
- `sp_calcular_monto_infraccion()` - Tarifa según tipo de falta

**Pagos y descuentos**
- `sp_aplicar_descuento_pronto_pago()` - Descuento si paga en primeros días
- `sp_registrar_pago_infraccion()` - Marca infracción como pagada
- `sp_infracciones_vencidas()` - Infracciones que pasan a apremio

**Reportes**
- `sp_reporte_infracciones_dia()` - Infracciones generadas por día
- `sp_estadisticas_agente()` - Productividad por agente
- `sp_puntos_conflictivos()` - Zonas con más infracciones

#### Reglas de negocio críticas

1. **Descuento por pronto pago** (ej: 50% si paga en 15 días)
2. **Después de 30 días** sin pagar, pasa automáticamente a apremio
3. **Placas con más de 3 infracciones sin pagar** pueden generar orden de inmovilización
4. **Fotos de infracción** deben almacenarse como evidencia
5. **Agente debe estar certificado y activo** para generar infracciones válidas

### 5.8 Módulo OTRAS OBLIGACIONES - Servicios Diversos (196 scripts)

#### Contexto del negocio
Módulo genérico que administra obligaciones y servicios que no encajan en otros módulos específicos. Incluye servicios como certificaciones, permisos especiales, uso de espacios públicos, eventos, etc.

#### Stored Procedures principales migrados

**Gestión de servicios**
- `sp_catalogo_servicios_disponibles()` - Lista de servicios ofrecidos
- `sp_calcular_costo_servicio()` - Tarifa según tipo y parámetros
- `sp_solicitar_servicio()` - Registra solicitud de servicio
- `sp_autorizar_servicio()` - Aprobación por autoridad competente

**Seguimiento**
- `sp_consulta_servicios_solicitados()` - Estado de solicitudes
- `sp_reportes_servicios_periodo()` - Servicios otorgados en periodo
- `sp_cancelar_servicio_solicitado()` - Cancela solicitud pendiente

#### Reglas de negocio críticas

1. **Cada servicio tiene requisitos específicos** documentados
2. **Algunos servicios requieren inspección previa** antes de autorización
3. **Vigencia del servicio** varía según tipo (temporal/permanente)
4. **Pago debe estar cubierto** antes de iniciar trámite
5. **Servicios en espacio público** requieren póliza de seguro

### 5.9 Módulo CEMENTERIOS - Administración de Cementerios Municipales (133 scripts)

#### Contexto del negocio
Gestiona la asignación, mantenimiento y control de fosas en panteones municipales. Controla perpetuidades, renovaciones, inhumaciones, exhumaciones y mantenimiento de espacios.

#### Stored Procedures principales migrados

**Gestión de fosas**
- `sp_consulta_fosas_disponibles()` - Fosas libres por panteón
- `sp_asignar_fosa()` - Otorga fosa a titular
- `sp_renovar_perpetuidad()` - Renueva derecho de uso
- `sp_consulta_titulares_fosa()` - Información del titular

**Servicios de inhumación**
- `sp_registrar_inhumacion()` - Registra entrada de difunto
- `sp_registrar_exhumacion()` - Registra salida (cambio de panteón)
- `sp_historial_fosa()` - Histórico de ocupantes
- `sp_autorizar_trabajo_fosa()` - Permisos para construcción de gaveta

**Administración**
- `sp_reporte_ocupacion_panteon()` - % de ocupación por cementerio
- `sp_fosas_proximas_vencer()` - Perpetuidades por renovar
- `sp_generar_cobro_mantenimiento()` - Cargo anual de mantenimiento

#### Reglas de negocio críticas

1. **Perpetuidad debe renovarse** cada X años (5, 10, 20 años según tipo)
2. **Fosa vencida y sin renovar** puede reasignarse después de proceso legal
3. **Inhumación requiere acta de defunción** y certificado médico
4. **Familiar directo** debe autorizar exhumaciones
5. **Mantenimiento general** se financia con cuota anual de perpetuidades

### 5.10 Módulo TRÁMITE TRUNK - Trámites Administrativos (23 scripts)

#### Contexto del negocio
Módulo de trámites administrativos generales y control de flujos de trabajo. Sirve como sistema de tickets o seguimiento para trámites que requieren aprobaciones de múltiples áreas.

#### Stored Procedures principales migrados

**Control de trámites**
- `sp_iniciar_tramite()` - Crea nuevo trámite con folio
- `sp_consulta_estatus_tramite()` - Estado actual del trámite
- `sp_asignar_responsable()` - Asigna trámite a funcionario
- `sp_avanzar_etapa_tramite()` - Pasa a siguiente fase

**Seguimiento**
- `sp_tramites_pendientes_area()` - Trámites asignados a área
- `sp_historial_tramite()` - Bitácora completa del trámite
- `sp_tramites_vencidos()` - Trámites que excedieron tiempo límite

#### Reglas de negocio críticas

1. **Cada tipo de trámite tiene flujo predefinido** de etapas
2. **Tiempo máximo por etapa** para evitar rezagos
3. **Notificaciones automáticas** al contribuyente en cambios de estado
4. **Trazabilidad completa** de quién autorizó cada etapa
5. **Documentación digitalizada** debe adjuntarse al expediente

### 5.11 Módulo SISTEMA - Infraestructura y Seguridad

#### Contexto del negocio
Módulo transversal que provee servicios de autenticación, autorización, auditoría, catálogos compartidos y configuraciones globales para todos los demás módulos.

#### Stored Procedures principales migrados

**Seguridad y usuarios**
- `sp_autenticar_usuario()` - Valida credenciales de acceso
- `sp_validar_permisos()` - Verifica si usuario puede ejecutar acción
- `sp_registrar_sesion()` - Control de sesiones activas
- `sp_cambiar_password()` - Actualiza contraseña de usuario
- `sp_usuarios_por_rol()` - Lista usuarios por perfil

**Auditoría**
- `sp_registrar_auditoria()` - Log de todas las operaciones críticas
- `sp_consulta_auditoria()` - Búsqueda en logs de auditoría
- `sp_reporte_actividad_usuario()` - Qué hizo cada usuario

**Catálogos maestros**
- `sp_colonias()` - Catálogo de colonias
- `sp_calles()` - Catálogo de calles
- `sp_codigos_postales()` - Catálogo de CP
- `sp_tipos_contribuyente()` - Catálogo de tipos (físico/moral)

**Configuración global**
- `sp_parametros_sistema()` - Configuraciones generales
- `sp_actualizar_parametro()` - Modifica configuración
- `sp_tasas_recargos()` - Tasas de interés y recargos vigentes

#### Reglas de negocio críticas

1. **Toda operación sensible debe auditarse** (quién, cuándo, qué)
2. **Contraseñas deben cumplir política de seguridad** (longitud, complejidad)
3. **Sesiones inactivas** se cierran automáticamente después de X minutos
4. **Cambios en catálogos maestros** requieren autorización especial
5. **Parámetros del sistema** solo modificables por administrador

### 5.12 Integración entre Módulos

#### Flujo completo: Alta de licencia

1. **LICENCIAS**: Se genera solicitud de licencia → Monto a pagar: $5,000
2. **RECAUDADORA**: Se genera recibo de pago por $5,000
3. **RECAUDADORA**: Contribuyente paga y se genera recibo
4. **LICENCIAS**: Al detectar pago, se activa la licencia automáticamente
5. **LICENCIAS**: Se genera holograma para entrega

#### Flujo completo: Adeudo de mercado no pagado

1. **MERCADOS**: Se genera adeudo de renta mensual
2. **MERCADOS**: Pasan 3 meses sin pago → Total $3,000
3. **APREMIOS**: Se genera apremio por $3,000 + $300 gastos de ejecución
4. **APREMIOS**: Se asigna a ejecutor fiscal
5. **APREMIOS**: Ejecutor notifica y contribuyente paga
6. **RECAUDADORA**: Se genera recibo de pago
7. **APREMIOS**: Se cierra folio de apremio
8. **MERCADOS**: Se marcan adeudos como pagados

#### Tablas compartidas entre módulos

- `ta_contribuyentes` - Información del contribuyente (usada por todos)
- `ta_12_recibos` - Todos los pagos (módulo recaudadora, leída por todos)
- `ta_domicilios` - Catálogo de domicilios (licencias, mercados)
- `ta_12_passwords` - Usuarios del sistema (todos los módulos)

---

## MÓDULO 6: DEPLOYMENT Y GESTIÓN DE VERSIONES

**Objetivo:** Aprender a desplegar cambios de forma segura y gestionar versiones de objetos de base de datos

### 6.1 El Reto del Deployment en Bases de Datos

#### ¿Por qué es diferente a desplegar código de aplicación?

Desplegar código de aplicación:
- Reemplazas archivos
- Si algo falla, regresas a la versión anterior
- Sin pérdida de datos

Desplegar cambios en base de datos:
- Modificas estructura (tablas, procedures)
- Si algo falla, puede haber inconsistencia de datos
- **Rollback puede ser imposible** si ya se modificaron datos
- **El sistema está en uso 24/7**, no puedes "apagarlo para actualizar"

#### Principios de deployment seguro

1. **Cambios deben ser reversibles** - Siempre tener plan B
2. **Probar en ambiente de desarrollo/QA primero** - Nunca directo a producción
3. **Hacer backup antes de cambios críticos** - Por si acaso
4. **Desplegar en ventanas de menor uso** - Madrugada, domingo
5. **Comunicar a usuarios** - "El sistema estará lento 5 minutos"
6. **Monitorear después del cambio** - Ver que todo funciona

### 6.2 Scripts Maestros - Instalación Ordenada

#### Problema: Dependencias entre procedures

Si el `procedure_B` llama al `procedure_A`, debes crear A antes que B. El **script maestro** organiza esto.

**Ejemplo de dependencias:**
```
sp_calcular_total()
  └─ llama a sp_calcular_impuestos()
      └─ llama a sp_obtener_tasa_impuesto()
```

**Orden correcto de instalación:**
1. Primero: `sp_obtener_tasa_impuesto()` (no depende de nadie)
2. Segundo: `sp_calcular_impuestos()` (depende de 1)
3. Tercero: `sp_calcular_total()` (depende de 2)

#### Estructura del script maestro

**MASTER_StoredProcedures.sql** de cada módulo:

```sql
-- ============================================
-- SCRIPT MAESTRO DE STORED PROCEDURES
-- Proyecto: Módulo Licencias
-- Fecha: 2024-10-15
-- Total SPs: 150
-- ============================================

-- PASO 1: Eliminar procedures existentes (opcional)
-- Solo si quieres empezar limpio
DO $$
BEGIN
  DROP FUNCTION IF EXISTS sp_ejemplo CASCADE;
  -- ... más drops
END $$;

-- PASO 2: Crear en orden de dependencia
-- Primero: Funciones base sin dependencias
\i 01_catalogs.sql

-- Segundo: Operaciones CRUD
\i 02_crud.sql

-- Tercero: Reportes que usan los anteriores
\i 03_reports.sql

-- PASO 3: Validar instalación
SELECT
  COUNT(*) as total_procedures,
  routine_schema
FROM information_schema.routines
WHERE routine_schema = 'informix'
  AND routine_type = 'FUNCTION'
GROUP BY routine_schema;

-- PASO 4: Probar un procedure de cada categoría
SELECT * FROM sp_get_giros() LIMIT 1;
SELECT * FROM sp_licencias_list(NULL, NULL, NULL, 1, 10) LIMIT 1;
```

**Ventajas:**
- Un solo archivo instala todo el módulo
- Orden garantizado
- Validación automática al final

#### Script de instalación automatizada

**INSTALL_QuickSetup.sql:**

```sql
-- ============================================
-- INSTALACIÓN RÁPIDA - Módulo Licencias
-- ============================================

-- 1. Verificar conexión
\echo 'Verificando conexión a base de datos...'
SELECT version();

-- 2. Crear schema si no existe
CREATE SCHEMA IF NOT EXISTS informix;
SET search_path TO informix, public;
\echo 'Schema informix configurado'

-- 3. Ejecutar script maestro
\echo 'Instalando stored procedures...'
\i MASTER_StoredProcedures.sql

-- 4. Mensaje de confirmación
\echo '✓ Instalación completada exitosamente'
\echo 'Total de procedures instalados:'
SELECT COUNT(*) FROM information_schema.routines
WHERE routine_schema = 'informix';
```

### 6.3 Control de Versiones para SQL

#### El problema: ¿Qué versión está en producción?

Sin control de versiones:
- No sabes qué procedures están en qué servidor
- No puedes regresar a una versión anterior si algo falla
- No hay registro de quién hizo qué cambio

#### Solución: Versionado en Git

**Estructura de repositorio:**
```
/harweb-main-v1/
├── modules/
│   ├── licencias/
│   │   ├── database/
│   │   │   ├── database/              # Versión actual
│   │   │   │   ├── 01_catalogs.sql
│   │   │   │   ├── 02_crud.sql
│   │   │   │   └── 03_reports.sql
│   │   │   ├── ok/                    # Versiones anteriores
│   │   │   └── MASTER_StoredProcedures.sql
│   │   └── CHANGELOG.md               # Historial de cambios
```

#### Versionado semántico para scripts

**Formato:** v[MAYOR].[MENOR].[PARCHE]

- **MAYOR**: Cambios incompatibles (ALTER TABLE que rompe procedures)
- **MENOR**: Nueva funcionalidad compatible (nuevo stored procedure)
- **PARCHE**: Corrección de bugs (fix en procedure existente)

**Ejemplos:**
- v1.0.0 → v1.1.0: Se agregó `sp_nuevo_reporte()`
- v1.1.0 → v1.1.1: Se corrigió bug en `sp_calcular_total()`
- v1.1.1 → v2.0.0: Se cambió estructura de tabla `ta_licencias` (breaking change)

#### Header de versionado en cada procedure

```sql
-- ============================================
-- Nombre: sp_licencia_create
-- Versión: 1.2.3
-- Fecha: 2024-10-15
-- Autor: Juan Pérez
-- Changelog:
--   v1.2.3 (2024-10-15): Fix validación de RFC
--   v1.2.0 (2024-09-01): Agregada validación de domicilio
--   v1.1.0 (2024-08-15): Soporte para nuevos giros
--   v1.0.0 (2024-07-01): Versión inicial
-- ============================================
CREATE OR REPLACE FUNCTION sp_licencia_create(...)
```

#### Tabla de control de versiones

Crear una tabla en la base de datos para rastrear qué versión está instalada:

```sql
CREATE TABLE IF NOT EXISTS informix.db_version (
  id SERIAL PRIMARY KEY,
  modulo VARCHAR(50) NOT NULL,
  version VARCHAR(20) NOT NULL,
  script_ejecutado VARCHAR(200),
  fecha_instalacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  instalado_por VARCHAR(50),
  notas TEXT
);

-- Al terminar instalación, registrar:
INSERT INTO informix.db_version (modulo, version, script_ejecutado, instalado_por, notas)
VALUES ('licencias', 'v1.2.3', 'MASTER_StoredProcedures.sql', current_user, 'Actualización mensual octubre');
```

**Consultar versión instalada:**
```sql
SELECT modulo, version, fecha_instalacion
FROM informix.db_version
WHERE modulo = 'licencias'
ORDER BY fecha_instalacion DESC
LIMIT 1;
```

### 6.4 Estrategias de Rollback

#### ¿Qué es un rollback?

Regresar a la versión anterior cuando el deployment falla.

#### Tipos de rollback

**A. Rollback de código (fácil)**

Si solo modificaste stored procedures:
1. Restaurar archivos .sql de la versión anterior desde Git
2. Re-ejecutar el script maestro
3. Los procedures se sobrescriben con la versión anterior
4. ✓ Listo, sistema funciona de nuevo

```bash
# En Git, regresar al commit anterior
git checkout HEAD~1 -- modules/licencias/database/

# Re-instalar
psql -f modules/licencias/database/INSTALL_QuickSetup.sql
```

**B. Rollback de estructura (difícil)**

Si modificaste tablas (ALTER TABLE), el rollback es más complejo.

**Escenario problemático:**
```sql
-- Deployment que agrega columna
ALTER TABLE ta_licencias ADD COLUMN email VARCHAR(100);

-- Si falla algo después, ¿cómo haces rollback?
-- Opción 1: Eliminar la columna (pierdes datos si alguien ya capturó)
ALTER TABLE ta_licencias DROP COLUMN email;

-- Opción 2: Dejar la columna vacía (basura en la BD)
```

**Solución: Cambios de estructura hacia adelante (forward-only)**

1. **No elimines columnas**, márcalas como deprecated
2. **No renombres columnas**, crea nueva y copia datos
3. **Mantén compatibilidad** con versión anterior por un tiempo

**Ejemplo de migración segura:**
```sql
-- Mal: Renombrar columna (rompe procedures)
ALTER TABLE ta_licencias RENAME COLUMN nombre TO nombre_completo;

-- Bien: Agregar nueva columna, mantener la anterior
ALTER TABLE ta_licencias ADD COLUMN nombre_completo VARCHAR(200);
UPDATE ta_licencias SET nombre_completo = nombre;
-- Actualizar procedures para usar nombre_completo
-- Después de 1 mes, eliminar columna antigua
```

#### Plan de contingencia

Antes de cada deployment, documentar:

**PLAN_ROLLBACK.md:**
```markdown
# Plan de Rollback - Deployment Módulo Licencias v1.3.0
Fecha: 2024-10-15

## Cambios a desplegar
- Nuevo SP: sp_validar_email()
- Modificación: sp_licencia_create() ahora valida email
- Nueva columna: ta_licencias.email

## Pasos de rollback si falla
1. Restaurar procedures:
   git checkout v1.2.0 -- modules/licencias/database/
   psql -f INSTALL_QuickSetup.sql

2. Eliminar columna nueva (solo si no hay datos):
   ALTER TABLE ta_licencias DROP COLUMN IF EXISTS email;

3. Validar sistema:
   SELECT * FROM sp_licencias_list(NULL,NULL,NULL,1,10);

## Tiempo estimado de rollback: 5 minutos
## Contacto en caso de emergencia: Juan Pérez (ext. 1234)
```

### 6.5 Monitoreo Post-Deployment

#### ¿Qué monitorear después del deployment?

**Primeros 5 minutos:**
1. **Errores en logs de PostgreSQL**
   ```bash
   tail -f /var/log/postgresql/postgresql-16-main.log | grep ERROR
   ```

2. **Procedures que fallan**
   ```sql
   -- Ver errores recientes
   SELECT * FROM pg_stat_statements
   WHERE calls > 0 AND mean_exec_time > 1000
   ORDER BY mean_exec_time DESC;
   ```

3. **Performance de queries críticos**
   ```sql
   EXPLAIN ANALYZE SELECT * FROM sp_licencias_list(...);
   -- Verificar que sigue usando índices
   ```

**Primera hora:**
1. **Uso de CPU/Memoria del servidor**
   ```bash
   top -c -p $(pgrep postgres)
   ```

2. **Consultas lentas**
   ```sql
   SELECT pid, query, state, wait_event, query_start
   FROM pg_stat_activity
   WHERE state = 'active'
     AND query_start < NOW() - INTERVAL '5 seconds';
   ```

3. **Locks/Deadlocks**
   ```sql
   SELECT * FROM pg_locks WHERE NOT granted;
   ```

**Primer día:**
1. **Reportes de usuarios** - Tickets de soporte
2. **Métricas de negocio** - ¿Bajó la recaudación? ¿Aumentó el tiempo de atención?
3. **Logs de aplicación** - Errores en frontend/backend

#### Alertas automáticas

Configurar alertas que envíen email/SMS si:
- CPU > 80% por más de 5 minutos
- Más de 10 queries activos por más de 30 segundos
- Se detecta un DEADLOCK
- Procedure específico falla más de 5 veces

**Script de monitoreo (ejemplo):**
```sql
-- Guardar como monitor_post_deployment.sql
-- Ejecutar cada 30 segundos por 1 hora

\echo 'Monitoreo Post-Deployment - ' $(date)

-- 1. Queries lentas
\echo '=== QUERIES LENTAS ==='
SELECT pid, LEFT(query, 50) as query, query_start
FROM pg_stat_activity
WHERE state = 'active'
  AND query_start < NOW() - INTERVAL '10 seconds'
  AND query NOT LIKE '%pg_stat_activity%';

-- 2. Errors recientes
\echo '=== ERRORES RECIENTES ==='
-- (depende de configuración de logs)

-- 3. Performance de SPs críticos
\echo '=== PERFORMANCE SPs CRÍTICOS ==='
SELECT
  calls,
  total_exec_time::numeric(10,2) as total_ms,
  mean_exec_time::numeric(10,2) as mean_ms,
  query
FROM pg_stat_statements
WHERE query LIKE '%sp_licencia%'
  AND calls > 0
ORDER BY mean_exec_time DESC
LIMIT 10;
```

### 6.6 Actividades prácticas del módulo

1. **Simular deployment:**
   - Crear un módulo de prueba con 3 procedures
   - Crear script maestro de instalación
   - Ejecutar en base de datos de desarrollo
   - Validar que todo se instaló correctamente

2. **Práctica de rollback:**
   - Hacer un deployment de una nueva versión
   - Simular que algo falló
   - Hacer rollback a la versión anterior
   - Validar que el sistema volvió a funcionar

3. **Versionado:**
   - Tomar 5 procedures existentes
   - Agregarles headers de versionado
   - Documentar cambios en un CHANGELOG.md
   - Registrar versión en tabla db_version

4. **Plan de contingencia:**
   - Elegir un módulo real
   - Escribir un documento PLAN_ROLLBACK.md
   - Incluir todos los pasos necesarios
   - Estimar tiempos de ejecución

---

## CONCLUSIÓN Y CIERRE DEL CURSO

### Resumen de aprendizajes clave

Los participantes ahora son capaces de:
- Entender y ejecutar migraciones entre motores de bases de datos
- Diseñar stored procedures siguiendo patrones consistentes
- Optimizar consultas para mejorar rendimiento del sistema
- Desplegar cambios de forma segura en producción
- Resolver problemas comunes de SQL y PostgreSQL

### Proyecto integrador final

Ejercicio que integra todos los conocimientos: Migrar un módulo completo de INFORMIX a PostgreSQL, documentar el proceso, crear tests y desplegar.

### Recursos para continuar aprendiendo

- Documentación oficial de PostgreSQL
- Comunidad de PostgreSQL en Stack Overflow
- Libros recomendados
- Cursos avanzados

---

## ANEXOS

### ANEXO A: Comandos PostgreSQL Útiles

#### Conexión y navegación

```sql
-- Conectar a base de datos
psql -h localhost -U postgres -d guadalajara

-- Listar bases de datos
\l

-- Conectar a otra base de datos
\c nombre_bd

-- Ver tablas del schema actual
\dt

-- Ver todas las funciones
\df

-- Ver funciones de un schema específico
\df informix.*

-- Ver definición de una función
\sf informix.sp_licencias_list

-- Salir de psql
\q
```

#### Consultas de catálogo del sistema

```sql
-- Ver todas las funciones de un schema
SELECT
  routine_name,
  routine_type,
  data_type as return_type,
  routine_definition
FROM information_schema.routines
WHERE routine_schema = 'informix'
ORDER BY routine_name;

-- Ver parámetros de una función
SELECT
  parameter_name,
  data_type,
  parameter_mode,  -- IN, OUT, INOUT
  ordinal_position
FROM information_schema.parameters
WHERE specific_schema = 'informix'
  AND specific_name = 'sp_licencias_list'
ORDER BY ordinal_position;

-- Ver tamaño de tablas
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
  pg_total_relation_size(schemaname||'.'||tablename) AS size_bytes
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 20;

-- Ver índices de una tabla
SELECT
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'ta_licencias'
ORDER BY indexname;

-- Ver estadísticas de uso de índices
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan as veces_usado,
  idx_tup_read as filas_leidas,
  idx_tup_fetch as filas_retornadas
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- Ver conexiones activas
SELECT
  pid,
  usename,
  application_name,
  client_addr,
  state,
  query_start,
  LEFT(query, 50) as query
FROM pg_stat_activity
WHERE state = 'active'
ORDER BY query_start;
```

#### Mantenimiento

```sql
-- Análisis de tabla (actualiza estadísticas)
ANALYZE ta_licencias;

-- Vacuum (libera espacio)
VACUUM ta_licencias;

-- Vacuum completo (más agresivo, bloquea tabla)
VACUUM FULL ta_licencias;

-- Reindex (reconstruye índice)
REINDEX INDEX idx_licencias_folio;
REINDEX TABLE ta_licencias;

-- Ver tablas que necesitan vacuum
SELECT
  schemaname,
  tablename,
  n_dead_tup,
  n_live_tup,
  ROUND(n_dead_tup * 100.0 / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_percentage
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;
```

#### Backup y Restore

```bash
# Backup de base de datos completa
pg_dump -h localhost -U postgres -d guadalajara -F c -f backup_guadalajara_20241015.dump

# Backup solo de un schema
pg_dump -h localhost -U postgres -d guadalajara -n informix -F c -f backup_informix_20241015.dump

# Backup en formato SQL plano
pg_dump -h localhost -U postgres -d guadalajara -f backup_guadalajara_20241015.sql

# Restore de backup
pg_restore -h localhost -U postgres -d guadalajara_restore backup_guadalajara_20241015.dump

# Restore desde SQL plano
psql -h localhost -U postgres -d guadalajara_restore -f backup_guadalajara_20241015.sql
```

#### Performance y Monitoring

```sql
-- Activar registro de queries lentas (más de 1 segundo)
ALTER SYSTEM SET log_min_duration_statement = 1000;
SELECT pg_reload_conf();

-- Ver queries más lentas (requiere pg_stat_statements)
SELECT
  calls,
  total_exec_time::numeric(10,2) as total_time_ms,
  mean_exec_time::numeric(10,2) as mean_time_ms,
  max_exec_time::numeric(10,2) as max_time_ms,
  LEFT(query, 80) as query
FROM pg_stat_statements
WHERE calls > 10
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Reset estadísticas
SELECT pg_stat_statements_reset();

-- Ver cache hit ratio (debe ser > 90%)
SELECT
  SUM(heap_blks_read) as heap_read,
  SUM(heap_blks_hit) as heap_hit,
  SUM(heap_blks_hit) / NULLIF(SUM(heap_blks_hit) + SUM(heap_blks_read), 0) * 100 AS cache_hit_ratio
FROM pg_statio_user_tables;
```

---

### ANEXO B: Rutas de Archivos del Proyecto

#### Estructura de carpetas

```
C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\harweb-main\harweb-main-v1\

modules/
├── licencias/
│   ├── database/
│   │   ├── database/                 (709 scripts SQL - PostgreSQL actual)
│   │   ├── ok/                       (Scripts legacy validados)
│   │   ├── informix_procedures/      (Scripts originales INFORMIX)
│   │   └── MASTER_StoredProcedures.sql
│   ├── docs/
│   │   ├── analisis/
│   │   ├── modules/
│   │   └── use-cases/
│   └── frontend-vue/src/components/
│
├── mercados/
│   ├── database/database/            (624 scripts SQL)
│   ├── docs/
│   └── frontend-vue/src/components/
│
├── recaudadora/
│   ├── database/database/            (473 scripts SQL)
│   ├── docs/
│   └── frontend-vue/src/components/
│
├── aseo/
│   ├── database/database/            (483 scripts SQL)
│   └── ...
│
├── convenios/
│   ├── database/database/            (407 scripts SQL)
│   └── ...
│
├── estacionamientos/
│   ├── database/database/            (237 scripts SQL)
│   └── ...
│
├── apremiossvn/
│   ├── database/database/            (222 scripts SQL)
│   └── ...
│
├── otras-oblig/
│   ├── database/database/            (196 scripts SQL)
│   └── ...
│
├── cementerios/
│   ├── database/database/            (133 scripts SQL)
│   └── ...
│
├── tramite-trunk/
│   ├── database/database/            (23 scripts SQL)
│   └── ...
│
└── sistema/
    ├── database/database/            (Scripts de infraestructura)
    └── ...

database/
└── migrations/                       (Scripts de migración inicial)
    ├── licencias/
    │   ├── 18_SP_CONSTANCIAS_INFORMIX.sql
    │   └── 19_SP_CONSULTAPREDIAL_INFORMIX.sql
    └── ...

frontend-vue/
├── src/
│   ├── components/
│   │   └── modules/
│   │       ├── licencias/
│   │       ├── mercados/
│   │       └── ...
│   ├── views/
│   ├── router/
│   └── store/
└── package.json

backend-laravel/
├── app/
│   ├── Http/Controllers/
│   ├── Models/
│   └── Services/
├── routes/
│   └── api.php
└── composer.json
```

#### Archivos clave por módulo

**Módulo Licencias:**
```
modules/licencias/database/database/
├── 01_catalogs.sql                   (Procedimientos de catálogos)
├── 02_crud.sql                       (Operaciones CRUD)
├── 03_reports.sql                    (Reportes)
├── Agendavisitasfrm_all_procedures.sql
├── BloquearLicenciafrm_sp_bloquear_licencia.sql
├── constanciafrm_sp_generar_constancia.sql
└── ... (700+ archivos más)

modules/licencias/database/informix_procedures/
├── 00_MASTER_INSTALL_INFORMIX_PROCEDURES.sql
├── 01_SP_GIROS_ADEUDO_REPORT.sql
├── POSTGRESQL_MIGRATION_SCRIPT.sql
└── README_INFORMIX_PROCEDURES.md
```

#### Archivos de documentación

```
harweb-main-v1/
├── README.md                         (Documentación principal)
├── ANALISIS_COMPLETO_SISTEMAS_PAGO.md
├── TEMARIO_CURSO_ACTUALIZACION_BD.md (Este documento)
└── modules/[modulo]/docs/
    ├── README.md
    ├── API.md
    └── CHANGELOG.md
```

---

### ANEXO C: Recursos Adicionales

#### Documentación oficial PostgreSQL

**General:**
- Documentación completa: https://www.postgresql.org/docs/current/
- PL/pgSQL: https://www.postgresql.org/docs/current/plpgsql.html
- Funciones: https://www.postgresql.org/docs/current/functions.html
- Performance: https://www.postgresql.org/docs/current/performance-tips.html

**Temas específicos:**
- Índices: https://www.postgresql.org/docs/current/indexes.html
- EXPLAIN: https://www.postgresql.org/docs/current/using-explain.html
- Backup/Restore: https://www.postgresql.org/docs/current/backup.html
- Seguridad: https://www.postgresql.org/docs/current/user-manag.html

#### Herramientas recomendadas

**Administración:**
- **pgAdmin 4** - Cliente gráfico oficial de PostgreSQL
  - URL: https://www.pgadmin.org/
  - Funciones: Gestión de BD, editor de queries, visualización de explain

- **DBeaver** - Cliente universal multiplataforma
  - URL: https://dbeaver.io/
  - Ventaja: Soporta múltiples motores de BD

**Monitoreo:**
- **pgBadger** - Análisis de logs de PostgreSQL
  - URL: https://github.com/darold/pgbadger
  - Genera reportes HTML con estadísticas de performance

- **pg_stat_statements** - Extensión para rastrear queries
  - Incluida en PostgreSQL
  - Activar en postgresql.conf: `shared_preload_libraries = 'pg_stat_statements'`

**Backup:**
- **pg_dump / pg_restore** - Herramientas nativas
- **Barman** - Backup and Recovery Manager
  - URL: https://www.pgbarman.org/
  - Para backups enterprise

**Migración:**
- **ora2pg** - Migración desde Oracle
- **pgloader** - Migración desde MySQL, SQLite, MS SQL
- **AWS Database Migration Service** - Para migraciones en la nube

#### Libros recomendados

1. **"PostgreSQL: Up and Running"** - Regina Obe, Leo Hsu
   - Introducción práctica y completa

2. **"Mastering PostgreSQL 13"** - Hans-Jürgen Schönig
   - Temas avanzados de performance y optimización

3. **"PostgreSQL Query Optimization"** - Henrietta Dombrovskaya
   - Especializado en optimización de consultas

4. **"PostgreSQL High Performance"** - Gregory Smith
   - Configuración y tuning para sistemas de alta carga

#### Comunidades y Foros

- **Stack Overflow** - Tag: [postgresql]
  - https://stackoverflow.com/questions/tagged/postgresql

- **PostgreSQL Mailing Lists**
  - https://www.postgresql.org/list/

- **Reddit r/PostgreSQL**
  - https://www.reddit.com/r/PostgreSQL/

- **PostgreSQL Slack**
  - https://postgres-slack.heroku.com/

#### Cursos en línea

- **Coursera** - "Databases and SQL for Data Science with Python"
- **Udemy** - "SQL and PostgreSQL: The Complete Developer's Guide"
- **Pluralsight** - "PostgreSQL: Getting Started"
- **LinkedIn Learning** - "PostgreSQL Essential Training"

---

### ANEXO D: Troubleshooting Común

#### Problemas de Conexión

**Error: "FATAL: password authentication failed"**

Solución:
```bash
# Verificar pg_hba.conf
# Windows: C:\Program Files\PostgreSQL\16\data\pg_hba.conf
# Linux: /etc/postgresql/16/main/pg_hba.conf

# Agregar línea:
host    all             all             127.0.0.1/32            md5

# Reiniciar PostgreSQL
# Windows:
net stop postgresql-x64-16
net start postgresql-x64-16

# Linux:
sudo systemctl restart postgresql
```

**Error: "could not connect to server: Connection refused"**

Causas comunes:
1. PostgreSQL no está corriendo
2. Firewall bloqueando puerto 5432
3. PostgreSQL escuchando solo en localhost

Solución:
```bash
# Verificar si está corriendo
# Windows:
sc query postgresql-x64-16

# Linux:
sudo systemctl status postgresql

# Verificar puertos
netstat -an | findstr 5432  # Windows
netstat -an | grep 5432     # Linux

# Verificar postgresql.conf
# Buscar línea: listen_addresses = '*'  # Para aceptar conexiones remotas
```

#### Problemas de Performance

**Problema: Queries muy lentas**

Diagnóstico:
```sql
-- 1. Ver queries activas
SELECT pid, query_start, state, LEFT(query, 100)
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY query_start;

-- 2. Verificar uso de índices
EXPLAIN ANALYZE SELECT ...;

-- 3. Ver estadísticas de tabla
SELECT
  relname,
  n_live_tup,
  n_dead_tup,
  last_vacuum,
  last_autovacuum
FROM pg_stat_user_tables
WHERE relname = 'ta_licencias';

-- 4. Si last_vacuum es antiguo:
VACUUM ANALYZE ta_licencias;
```

**Problema: Locks y Deadlocks**

```sql
-- Ver locks activos
SELECT
  pg_stat_activity.pid,
  pg_stat_activity.query,
  pg_locks.mode,
  pg_locks.granted
FROM pg_stat_activity
JOIN pg_locks ON pg_stat_activity.pid = pg_locks.pid
WHERE NOT pg_locks.granted;

-- Terminar proceso problemático
SELECT pg_terminate_backend(pid);

-- Ver deadlocks en logs
# Buscar en postgresql.log líneas con "deadlock detected"
```

**Problema: Memoria insuficiente**

```sql
-- Ver configuración de memoria
SHOW shared_buffers;        -- Debe ser ~25% de RAM
SHOW work_mem;              -- Para ordenamiento
SHOW maintenance_work_mem;  -- Para VACUUM, CREATE INDEX

-- Ajustar en postgresql.conf:
shared_buffers = 2GB
work_mem = 16MB
maintenance_work_mem = 512MB

-- Reiniciar PostgreSQL para aplicar cambios
```

#### Problemas de Migración

**Error: "function does not exist"**

Causa: Schema incorrecto

```sql
-- Verificar en qué schema está
SELECT routine_schema, routine_name
FROM information_schema.routines
WHERE routine_name = 'sp_licencias_list';

-- Configurar search_path
SET search_path TO informix, public;

-- O llamar con schema explícito
SELECT * FROM informix.sp_licencias_list(...);
```

**Error: "column reference is ambiguous"**

Causa: Columnas con mismo nombre en múltiples tablas del JOIN

```sql
-- Mal
SELECT id, nombre
FROM tabla1
JOIN tabla2 ON tabla1.fk = tabla2.id;

-- Bien
SELECT t1.id, t1.nombre
FROM tabla1 t1
JOIN tabla2 t2 ON t1.fk = t2.id;
```

**Error: "invalid byte sequence for encoding"**

Causa: Problemas de encoding

```sql
-- Ver encoding actual
SHOW client_encoding;
SHOW server_encoding;

-- Cambiar encoding de cliente
SET client_encoding TO 'UTF8';

-- Si el problema persiste, convertir datos:
UPDATE tabla SET columna = convert_to(columna, 'UTF8');
```

#### Problemas de Espacio

**Problema: Disco lleno**

```sql
-- Ver tamaño de base de datos
SELECT
  pg_database.datname,
  pg_size_pretty(pg_database_size(pg_database.datname))
FROM pg_database
ORDER BY pg_database_size(pg_database.datname) DESC;

-- Ver tablas más grandes
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 20;

-- Liberar espacio
VACUUM FULL;  -- Cuidado: bloquea tabla

-- O eliminar datos antiguos
DELETE FROM ta_recibos WHERE fecha < '2020-01-01';
VACUUM ta_recibos;
```

---

### ANEXO E: Glosario de Términos

**ACID** - Atomicity, Consistency, Isolation, Durability. Propiedades de las transacciones en bases de datos.

**Baja lógica (Soft Delete)** - Marcar un registro como inactivo (activo=false) en lugar de eliminarlo físicamente.

**COALESCE** - Función que retorna el primer valor no nulo de una lista de expresiones.

**CRUD** - Create, Read, Update, Delete. Operaciones básicas sobre datos.

**Cursor** - Estructura que permite recorrer resultado de una consulta fila por fila.

**Deadlock** - Situación donde dos transacciones se bloquean mutuamente esperando recursos.

**EXPLAIN ANALYZE** - Comando que muestra el plan de ejecución real de una consulta.

**Foreign Key (FK)** - Clave foránea. Columna que referencia la clave primaria de otra tabla.

**Índice** - Estructura de datos que acelera búsquedas en una tabla.

**JOIN** - Operación que combina filas de múltiples tablas basándose en una condición.

**Lock** - Bloqueo que impide acceso concurrente a un recurso.

**Migración** - Proceso de mover datos/estructura de un sistema a otro.

**NULL** - Valor especial que indica ausencia de valor o valor desconocido.

**Optimización** - Proceso de mejorar el rendimiento de consultas.

**Paginación** - División de resultados en páginas para mostrar cantidades manejables.

**PL/pgSQL** - Lenguaje procedural de PostgreSQL para stored procedures.

**Primary Key (PK)** - Clave primaria. Identificador único de cada fila en una tabla.

**Procedure / Function** - Código SQL almacenado en la base de datos que se puede ejecutar.

**Query** - Consulta. Instrucción SQL para recuperar datos.

**Rollback** - Deshacer cambios de una transacción o deployment.

**Schema** - Namespace que agrupa objetos de base de datos (tablas, functions, etc.).

**Sequential Scan (Seq Scan)** - Recorrer toda una tabla secuencialmente (lento).

**Stored Procedure** - Procedimiento almacenado en la base de datos.

**Transacción** - Conjunto de operaciones que se ejecutan todas o ninguna (atomicidad).

**Trigger** - Función que se ejecuta automáticamente ante eventos (INSERT, UPDATE, DELETE).

**Tuple** - Término técnico de PostgreSQL para "fila" o "registro".

**VACUUM** - Proceso de mantenimiento que libera espacio y actualiza estadísticas.

**Vista Materializada** - Tabla que almacena el resultado de una consulta compleja.

---

**Modalidad:** 60% práctica, 40% teoría
**Evaluación:** Proyecto final integrador
**Certificación:** Curso de Actualización en Migración de Bases de Datos

---

**Elaborado:** Octubre 2025
**Proyecto:** Sistema Municipal Guadalajara - Migración BD
**Estado:** Documento de capacitación oficial
**Versión:** 1.0
