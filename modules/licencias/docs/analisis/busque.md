# Documentación Técnica: Migración de Formulario de Búsqueda Catastral (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario de búsqueda es una página independiente.
- **Base de Datos**: PostgreSQL, lógica SQL en stored procedures.
- **Comunicación**: Patrón eRequest/eResponse (JSON), desacoplado de la UI.

## 2. Endpoint Unificado
- **Ruta**: `/api/execute` (POST)
- **Entrada**: `{ eRequest: { action: 'buscar_por_nombre', params: { ... } } }`
- **Salida**: `{ eResponse: { success: bool, data: array|null, error: string|null } }`
- **Acciones soportadas**:
  - buscar_por_nombre
  - buscar_por_ubicacion
  - buscar_por_clave_catastral
  - buscar_por_rfc
  - buscar_por_cuenta

## 3. Controlador Laravel
- Valida la acción y los parámetros.
- Llama al stored procedure correspondiente vía DB::select('CALL ...').
- Devuelve los resultados en eResponse.
- Maneja errores y validaciones.

## 4. Stored Procedures PostgreSQL
- Cada búsqueda tiene su propio SP.
- Todos los SPs limitan los resultados a 300 registros.
- Uso de ILIKE para búsquedas insensibles a mayúsculas/minúsculas.
- JOINs para obtener información de propietario, predio y ubicación.

## 5. Componente Vue.js
- Cada formulario es una página independiente (no tabs).
- Menú para seleccionar el tipo de búsqueda.
- Cada formulario tiene su propio submit y validación.
- Resultados se muestran en tabla dinámica.
- Manejo de loading y errores.

## 6. Seguridad
- Validación de parámetros en backend.
- Límite de resultados para evitar abuso.
- No se exponen detalles internos de la base de datos.

## 7. Extensibilidad
- Se pueden agregar nuevas acciones/SPs fácilmente.
- El frontend puede agregar nuevas páginas de búsqueda sin afectar el backend.

## 8. Pruebas
- Casos de uso y escenarios de prueba incluidos.

---

# Esquema de Datos (Simplificado)
- **contrib**: Propietarios/contribuyentes
- **regprop**: Relación propietario-predio
- **convcta**: Cuentas catastrales
- **ubicacion**: Domicilio del predio
- **catastro**: Información adicional del predio
- **c_calidpro**: Catálogo de tipo de propietario

---

# Ejemplo de eRequest/eResponse

**Request:**
```json
{
  "eRequest": {
    "action": "buscar_por_nombre",
    "params": { "nombre": "JUAN PEREZ" }
  }
}
```

**Response:**
```json
{
  "eResponse": {
    "success": true,
    "data": [ { ... } ],
    "error": null
  }
}
```
