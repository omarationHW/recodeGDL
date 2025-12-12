# Instrucciones para crear el Stored Procedure de Fosas

## Base de datos: multas_reglamentos
## Esquema: public

### Pasos para ejecutar los scripts:

#### 1. Crear la tabla fosas (si no existe)
```bash
psql -U postgres -d multas_reglamentos -f tabla_fosas.sql
```

#### 2. Crear el stored procedure
```bash
psql -U postgres -d multas_reglamentos -f recaudadora_drecgo_fosa.sql
```

### Opción alternativa: Ejecutar desde psql

```bash
# Conectarse a la base de datos
psql -U postgres -d multas_reglamentos

# Dentro de psql, ejecutar:
\i tabla_fosas.sql
\i recaudadora_drecgo_fosa.sql
```

### Verificar que el procedimiento se creó correctamente:

```sql
-- Ver el procedimiento
SELECT routine_name, routine_schema, routine_type
FROM information_schema.routines
WHERE routine_name = 'recaudadora_drecgo_fosa'
  AND routine_schema = 'public';

-- Probar el procedimiento
SELECT * FROM public.recaudadora_drecgo_fosa(0);  -- Todas las fosas
SELECT * FROM public.recaudadora_drecgo_fosa(2);  -- Fosa con id_control = 2
```

### Estructura del Stored Procedure:

**Nombre:** `recaudadora_drecgo_fosa`

**Parámetro:**
- `p_folio` (INTEGER): ID de control de la fosa. Si es 0 o NULL, devuelve todas las fosas.

**Retorna:**
- `id_control` (INTEGER): ID de control
- `cementerio` (VARCHAR): Nombre del cementerio
- `clase` (VARCHAR): Clasificación
- `seccion` (VARCHAR): Sección
- `linea` (VARCHAR): Línea
- `fosa` (VARCHAR): Número de fosa
- `nombre_titular` (VARCHAR): Nombre del titular
- `anio_minimo` (INTEGER): Año inicial del período
- `anio_maximo` (INTEGER): Año final del período

### Notas:

1. La tabla `fosas` debe existir en el esquema `public` antes de crear el procedimiento.
2. Si la tabla ya existe con otra estructura, verifica que tenga las mismas columnas que el procedimiento espera.
3. Asegúrate de tener los permisos necesarios para crear funciones en el esquema `public`.
