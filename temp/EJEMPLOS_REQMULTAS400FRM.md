# EJEMPLOS DE DATOS PARA REQMULTAS400FRM

## Estructura de la tabla req_mul_400

Basándome en los SPs encontrados, la tabla tiene los siguientes campos:

- **cvelet** (VARCHAR): Clave de letra/identificador (ej: "ABC001234")
- **cvenum** (INTEGER): Año de acta
- **ctarfc** (INTEGER): Número de acta
- **cveapl** (INTEGER): Tipo de multa (5=Municipal, 6=Federal)
- **axoreq** (INTEGER): Año del requerimiento
- **folreq** (INTEGER): Folio del requerimiento
- **nombre** (VARCHAR): Nombre del infractor
- **domicilio** (VARCHAR): Domicilio
- **importe** (NUMERIC): Monto de la multa
- **fecha** (DATE): Fecha del requerimiento

## Ejemplos de Búsqueda

### Ejemplo 1: Buscar todos los registros recientes
```sql
SELECT * FROM recaudadora_reqmultas400frm(NULL) LIMIT 10;
```

### Ejemplo 2: Buscar por folio específico
```sql
-- Primero obtén folios disponibles:
SELECT DISTINCT folreq
FROM comun.req_mul_400
WHERE folreq IS NOT NULL
ORDER BY folreq DESC
LIMIT 5;

-- Luego busca con alguno de esos folios
SELECT * FROM req_mul_400_by_folio(2024, 12345, 6);
```

### Ejemplo 3: Buscar por acta
```sql
-- Primero obtén actas disponibles:
SELECT DISTINCT
    SUBSTRING(cvelet FROM 4 FOR 3) as dep,
    cvenum as axo,
    ctarfc as numacta,
    cveapl as tipo
FROM comun.req_mul_400
WHERE cvelet IS NOT NULL
LIMIT 5;

-- Luego busca con alguna combinación:
SELECT * FROM req_mul_400_by_acta('001', 2024, 5678, 5);
```

## Datos de ejemplo (estructura estimada)

Estos son ejemplos ficticios basados en la estructura identificada:

### Registro 1 - Multa Federal
```json
{
  "cvelet": "MUL001234",
  "cvenum": 2024,
  "ctarfc": 5678,
  "cveapl": 6,
  "axoreq": 2024,
  "folreq": 12345,
  "nombre": "JUAN PEREZ GARCIA",
  "domicilio": "AV JUAREZ 123, GUADALAJARA",
  "importe": 2500.00,
  "fecha": "2024-03-15",
  "tipo_multa": "Federal"
}
```

### Registro 2 - Multa Municipal
```json
{
  "cvelet": "REQ002567",
  "cvenum": 2024,
  "ctarfc": 9012,
  "cveapl": 5,
  "axoreq": 2024,
  "folreq": 12346,
  "nombre": "MARIA LOPEZ HERNANDEZ",
  "domicilio": "CALLE REFORMA 456, GUADALAJARA",
  "importe": 1800.00,
  "fecha": "2024-04-20",
  "tipo_multa": "Municipal"
}
```

### Registro 3 - Multa Federal
```json
{
  "cvelet": "ACT003890",
  "cvenum": 2024,
  "ctarfc": 3456,
  "cveapl": 6,
  "axoreq": 2024,
  "folreq": 12347,
  "nombre": "CARLOS RODRIGUEZ MARTINEZ",
  "domicilio": "BLVD MARCELINO GARCIA 789, GUADALAJARA",
  "importe": 3200.00,
  "fecha": "2024-05-10",
  "tipo_multa": "Federal"
}
```

## Comandos para probar en tu base de datos

Una vez que ejecutes el SQL (DEPLOY_REQMULTAS400FRM.sql), puedes obtener datos reales con:

```sql
-- 1. Ver si la tabla existe y en qué schema
SELECT table_schema, table_name,
       (SELECT COUNT(*) FROM information_schema.columns
        WHERE table_schema = t.table_schema
        AND table_name = t.table_name) as num_columns
FROM information_schema.tables t
WHERE table_name = 'req_mul_400';

-- 2. Obtener 3 ejemplos reales
SELECT * FROM comun.req_mul_400
ORDER BY axoreq DESC, folreq DESC
LIMIT 3;

-- 3. Ver tipos de multa disponibles
SELECT cveapl, COUNT(*) as total
FROM comun.req_mul_400
GROUP BY cveapl;

-- 4. Ver años disponibles
SELECT DISTINCT axoreq
FROM comun.req_mul_400
ORDER BY axoreq DESC
LIMIT 10;

-- 5. Ver folios recientes
SELECT DISTINCT folreq
FROM comun.req_mul_400
WHERE folreq IS NOT NULL
ORDER BY folreq DESC
LIMIT 10;
```

## Notas importantes

1. **Schema**: Los SPs asumen que la tabla está en `comun.req_mul_400`. Si está en otro schema, ajusta las referencias.

2. **Permisos**: Asegúrate de que el usuario de la aplicación tenga permisos EXECUTE en las funciones:
   ```sql
   GRANT EXECUTE ON FUNCTION recaudadora_reqmultas400frm(VARCHAR) TO refact;
   GRANT EXECUTE ON FUNCTION req_mul_400_by_acta(VARCHAR, INTEGER, INTEGER, INTEGER) TO refact;
   GRANT EXECUTE ON FUNCTION req_mul_400_by_folio(INTEGER, INTEGER, INTEGER) TO refact;
   ```

3. **Testing**: Después de desplegar, verifica que las funciones funcionen:
   ```sql
   SELECT * FROM recaudadora_reqmultas400frm(NULL) LIMIT 5;
   ```
