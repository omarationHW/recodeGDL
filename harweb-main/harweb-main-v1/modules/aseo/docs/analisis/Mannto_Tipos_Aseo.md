# Documentación Técnica: Migración de Mannto_Tipos_Aseo (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel API, endpoint único `/api/execute` (eRequest/eResponse)
- **Frontend:** Vue.js SPA, cada formulario es una página independiente
- **Base de Datos:** PostgreSQL, toda la lógica de negocio en stored procedures
- **Patrón de integración:**
  - El frontend envía requests a `/api/execute` con `{ action, data }`
  - El backend interpreta `action` y llama al stored procedure correspondiente
  - El backend retorna `{ success, message, data }`

## Endpoints y Acciones
- `/api/execute` (POST)
  - `action: list` → Lista todos los tipos de aseo
  - `action: get` → Obtiene un tipo de aseo por clave
  - `action: create` → Crea un nuevo tipo de aseo
  - `action: update` → Actualiza un tipo de aseo
  - `action: delete` → Elimina un tipo de aseo
  - `action: validate_cta_aplicacion` → Valida existencia de cuenta de aplicación

## Validaciones
- No se permite crear un tipo de aseo con clave repetida
- No se permite crear/actualizar si la cuenta de aplicación no existe
- No se permite eliminar si existen contratos asociados

## Stored Procedures
- Toda la lógica de negocio y validación reside en los SPs
- El controlador Laravel solo enruta y valida datos básicos

## Frontend
- Página independiente `/tipos-aseo`
- Tabla de consulta, botones de alta/edición/eliminación
- Formulario modal para alta/edición
- Validación en frontend y backend
- Navegación breadcrumb

## Seguridad
- Se recomienda proteger `/api/execute` con autenticación JWT o similar
- Validar permisos de usuario en el backend si aplica

## Errores y Mensajes
- Todos los errores de negocio se retornan en el campo `message` del JSON
- El frontend muestra los mensajes al usuario

## Ejemplo de Request/Response
### Crear tipo de aseo
```json
POST /api/execute
{
  "action": "create",
  "data": {
    "tipo_aseo": "H",
    "descripcion": "Hospitalario",
    "cta_aplicacion": 12345
  }
}
```

### Respuesta
```json
{
  "success": true,
  "message": "Tipo de aseo creado correctamente",
  "data": { "success": true, "message": "Tipo de aseo creado correctamente", "ctrol_aseo": 5 }
}
```

## Estructura de la Tabla
```sql
CREATE TABLE ta_16_tipo_aseo (
    ctrol_aseo serial PRIMARY KEY,
    tipo_aseo varchar(1) UNIQUE NOT NULL,
    descripcion varchar(80) NOT NULL,
    cta_aplicacion integer NOT NULL
);
```

## Integración con Contratos
- Antes de eliminar un tipo de aseo, se verifica que no existan contratos con ese tipo

## Navegación
- El componente Vue es una página completa, sin tabs ni subcomponentes
- Navegación por rutas (ej: `/tipos-aseo`)

## Pruebas
- Se recomienda usar Postman para probar el endpoint `/api/execute`
- El frontend puede ser probado con Cypress o Jest
