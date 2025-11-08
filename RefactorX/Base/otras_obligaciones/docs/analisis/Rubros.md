# Documentación Técnica: Rubros (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite la administración de rubros de ingreso (catálogo de tablas/rubros) y la asignación de status a cada rubro. El flujo incluye:
- Consulta de rubros existentes
- Consulta de catálogo de status
- Alta de nuevo rubro (con nombre)
- Asignación de status seleccionados al nuevo rubro

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA (Single Page Application), página independiente para Rubros
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures

## 3. API (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  - `action`: string (ej: 'getRubros', 'getStatusCatalog', 'createRubro')
  - `params`: objeto con parámetros específicos de la acción
- **Response:**
  - `success`: boolean
  - `data`: datos de respuesta (si aplica)
  - `message`: mensaje de error o éxito

### Acciones soportadas
- `getRubros`: Lista todos los rubros existentes
- `getStatusCatalog`: Lista todos los status posibles
- `createRubro`: Crea un nuevo rubro y asigna status seleccionados

## 4. Stored Procedures
- **ins34_rubro_01(par_nombre):** Crea un nuevo rubro, retorna status y mensaje
- **ins34_status(par_cve_tab, par_cve_stat, par_descripcion):** Inserta un status para el rubro

## 5. Frontend (Vue.js)
- Página independiente `/rubros`
- Tabla de rubros existentes
- Formulario para alta de rubro (nombre, selección múltiple de status)
- Mensajes de éxito/error
- Validación de campos

## 6. Seguridad
- Validación de parámetros en backend
- Manejo de errores y transacciones en SP y Controller

## 7. Consideraciones
- El endpoint es unificado para facilitar integración y pruebas
- El frontend es desacoplado y puede integrarse en cualquier SPA
- El backend es fácilmente extensible para nuevas acciones

## 8. Ejemplo de Request/Response
### Crear Rubro
**Request:**
```json
{
  "action": "createRubro",
  "params": {
    "nombre": "RUBRO PRUEBA",
    "status_selected": [
      {"cve_stat": "A", "descripcion": "Activo"},
      {"cve_stat": "I", "descripcion": "Inactivo"}
    ]
  }
}
```
**Response:**
```json
{
  "success": true,
  "message": "Rubro creado correctamente"
}
```

## 9. Manejo de Errores
- Si el nombre ya existe, retorna error
- Si falta algún parámetro, retorna error
- Si ocurre error en SP, retorna mensaje descriptivo

## 10. Extensión
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón
- Los SP pueden evolucionar para lógica adicional (auditoría, validaciones, etc.)
