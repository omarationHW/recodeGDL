# Instrucciones de Despliegue - Consulta de Usuarios

## Prerequisitos

1. PostgreSQL instalado y configurado
2. Base de datos `padron_licencias` creada
3. Esquema `comun` creado (si no existe, se creará automáticamente)
4. Tablas existentes:
   - `comun.c_dependencias`
   - `comun.deptos`
   - `comun.usuarios`

## Archivos de Stored Procedures

Los siguientes stored procedures están listos para despliegue:

1. **sp_catalogo_dependencias.sql**
   - Función: Consultar catálogo de dependencias
   - Esquema: comun
   - Sin parámetros

2. **sp_catalogo_deptos_por_dependencia.sql**
   - Función: Consultar departamentos por dependencia
   - Esquema: comun
   - Parámetro: p_id_dependencia (INTEGER)

3. **sp_consulta_usuario_por_usuario.sql**
   - Función: Buscar usuario por nombre de usuario exacto
   - Esquema: comun
   - Parámetro: p_usuario (VARCHAR)

4. **sp_consulta_usuario_por_nombre.sql**
   - Función: Buscar usuarios por nombre (LIKE)
   - Esquema: comun
   - Parámetro: p_nombre (VARCHAR)

5. **sp_consulta_usuario_por_dependencia_depto.sql**
   - Función: Buscar usuarios por dependencia y departamento
   - Esquema: comun
   - Parámetros: p_id_dependencia (INTEGER), p_cvedepto (INTEGER)

## Método de Despliegue

### Opción 1: Usando psql (Recomendado)

```bash
# Conectarse a la base de datos
psql -U postgres -d padron_licencias

# Ejecutar el script maestro
\i DEPLOY_CONSULTA_USUARIOS.sql
```

### Opción 2: Ejecutar cada SP individualmente

```bash
psql -U postgres -d padron_licencias -f sp_catalogo_dependencias.sql
psql -U postgres -d padron_licencias -f sp_catalogo_deptos_por_dependencia.sql
psql -U postgres -d padron_licencias -f sp_consulta_usuario_por_usuario.sql
psql -U postgres -d padron_licencias -f sp_consulta_usuario_por_nombre.sql
psql -U postgres -d padron_licencias -f sp_consulta_usuario_por_dependencia_depto.sql
```

### Opción 3: Usando pgAdmin

1. Abrir pgAdmin
2. Conectarse a la base de datos `padron_licencias`
3. Ir a Schemas → comun
4. Abrir Query Tool
5. Copiar y ejecutar el contenido de cada archivo .sql

## Verificación Post-Despliegue

Después de ejecutar los scripts, verificar que los SPs fueron creados correctamente:

```sql
-- Listar stored procedures en esquema comun
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'comun'
  AND (routine_name LIKE 'sp_%usuario%' OR routine_name LIKE 'sp_catalogo%')
ORDER BY routine_name;
```

Deberías ver 5 funciones listadas.

## Prueba de Funcionalidad

```sql
-- Probar catálogo de dependencias
SELECT * FROM comun.sp_catalogo_dependencias();

-- Probar catálogo de departamentos (reemplazar 1 con un ID válido)
SELECT * FROM comun.sp_catalogo_deptos_por_dependencia(1);

-- Probar consulta por usuario (reemplazar 'admin' con un usuario válido)
SELECT * FROM comun.sp_consulta_usuario_por_usuario('admin');

-- Probar consulta por nombre (reemplazar 'Juan' con un nombre válido)
SELECT * FROM comun.sp_consulta_usuario_por_nombre('Juan');

-- Probar consulta por dependencia y depto (reemplazar con IDs válidos)
SELECT * FROM comun.sp_consulta_usuario_por_dependencia_depto(1, 1);
```

## Integración con el Frontend

Una vez desplegados los SPs, el componente Vue debe llamarlos con el parámetro de esquema correcto:

```javascript
const response = await apiService.execute(
  'sp_catalogo_dependencias',  // Nombre del SP
  'padron_licencias',           // Base de datos
  [],                           // Parámetros
  'guadalajara',                // Tenant
  null,                         // Paginación
  'comun'                       // ⚠️ IMPORTANTE: Especificar esquema 'comun'
)
```

## Notas Importantes

- ✅ Todos los SPs usan el esquema `comun`
- ✅ Todas las tablas referenciadas usan prefijo `comun.`
- ⚠️ Las tablas ya deben existir antes de ejecutar los SPs
- ⚠️ El frontend debe especificar `esquema: 'comun'` en las llamadas al API
