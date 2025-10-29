# Documentación Técnica: Catálogo de Intereses (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite la administración del catálogo de intereses (por año y mes) utilizado para el cálculo de recargos/intereses en convenios. Incluye operaciones de alta, modificación, consulta y eliminación, con trazabilidad de usuario y fecha de actualización.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA, página independiente para el catálogo de intereses
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato:**
  - Entrada: `{ eRequest: { operation: 'list'|'create'|'update'|'delete', data: { ... } } }`
  - Salida: `{ eResponse: { success, message, data } }`

## 4. Stored Procedures
- `sp_intereses_list()`: Devuelve todos los registros de intereses
- `sp_intereses_create(axo, mes, porcentaje, id_usuario)`: Inserta un nuevo registro
- `sp_intereses_update(axo, mes, porcentaje, id_usuario)`: Actualiza un registro existente
- `sp_intereses_delete(axo, mes)`: Elimina un registro

## 5. Validaciones
- Año (`axo`): Obligatorio, entero
- Mes (`mes`): Obligatorio, entero (1-12)
- Porcentaje: Obligatorio, numérico, mínimo 0.01
- ID Usuario: Obligatorio, entero

## 6. Seguridad
- El endpoint debe estar protegido por autenticación (ejemplo: middleware Laravel auth/api)
- El ID de usuario debe provenir del contexto de sesión/token, no del frontend (en producción)

## 7. Manejo de Errores
- Todos los errores se devuelven en el campo `message` de `eResponse`
- Validaciones de datos y errores de base de datos son gestionados y reportados

## 8. Frontend
- Página Vue.js independiente
- Tabla con listado, botones para agregar, editar y eliminar
- Formularios modales para alta/edición
- Validación en frontend y backend
- Navegación breadcrumb

## 9. Base de Datos
- Tabla: `ta_12_intereses`
  - axo (smallint, PK)
  - mes (smallint, PK)
  - porcentaje (numeric(12,8))
  - id_usuario (integer, FK)
  - fecha_actual (timestamp)

- Tabla: `ta_12_passwords` (usuarios)

## 10. Pruebas
- Casos de uso y pruebas incluidas abajo
