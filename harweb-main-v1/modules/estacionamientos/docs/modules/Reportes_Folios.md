# Documentación Técnica: Migración Formulario Reportes_Folios (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica de reportes en stored procedures.

## 2. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**: `{ eRequest: { action: string, params: object } }`
- **Response**: `{ eResponse: { success: bool, data: any, message: string } }`

### Acciones soportadas:
- `getInfracciones`: Lista de infracciones para el combo.
- `getConInfrac`: Consulta de infracciones filtrada.
- `getReportesFolios`: Ejecuta el reporte según parámetros.

## 3. Stored Procedures
- Toda la lógica de reportes se implementa en PostgreSQL como procedimientos almacenados.
- Ejemplo: `cons14_solicrep`, `cons14_solicrep_c`.
- Los procedimientos deben devolver los mismos campos que los reportes originales.

## 4. Frontend (Vue.js)
- Página independiente `/reportes-folios`.
- Formulario con combos y fechas.
- Al ejecutar, llama a `/api/execute` con los parámetros.
- Muestra resultados en tabla dinámica.
- No usa tabs ni componentes compartidos con otros formularios.

## 5. Backend (Laravel)
- Controlador único `ExecuteController`.
- Cada acción del frontend se mapea a una acción en el switch del controlador.
- Llama a los stored procedures usando `DB::select('CALL ...')`.
- Maneja errores y retorna siempre el formato eResponse.

## 6. Seguridad
- Validar y sanear todos los parámetros recibidos.
- Limitar acceso a usuarios autenticados si es necesario.

## 7. Pruebas
- Casos de uso y pruebas unitarias deben cubrir todos los flujos principales y errores.

## 8. Consideraciones de Migración
- Los nombres de tablas y campos deben coincidir con los usados en los stored procedures.
- Si la estructura de datos cambia, actualizar tanto el SP como el frontend.

## 9. Extensibilidad
- Para agregar nuevos reportes, crear nuevos SP y mapear en el controlador.
- El frontend puede adaptarse a nuevos campos dinámicamente.
