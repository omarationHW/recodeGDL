# Documentación Técnica: Migración Formulario GAdeudos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API con endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (no tabs).
- **Base de Datos**: PostgreSQL, toda la lógica de negocio encapsulada en stored procedures.

## 2. API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: JSON con campos `action` (string) y `params` (objeto)
- **Salida**: JSON `{ success, data, message }`
- **Ejemplo**:
```json
{
  "action": "GAdeudos.buscar",
  "params": { "par_tab": "3", "par_control": "123-1" }
}
```

## 3. Stored Procedures (PostgreSQL)
- Toda la lógica de búsqueda, consulta y reporte está en SPs.
- Ejemplo: `sp_gadeudos_busca`, `sp_gadeudos_detalle`, etc.
- Los SPs devuelven tablas (resultsets) para ser consumidos por el frontend.

## 4. Laravel Controller
- Un solo controlador (`ExecuteController`) maneja todas las acciones.
- Cada acción del frontend se mapea a un método privado que llama al SP correspondiente.
- Manejo de errores y validaciones centralizado.

## 5. Vue.js Component
- Página independiente para GAdeudos.
- Formulario reactivo para búsqueda por expediente o local.
- Selección de periodo (vencidos/otro), año y mes.
- Botones para buscar e imprimir (simulado en frontend).
- Muestra cabecera y detalle de adeudos en tablas.
- Validaciones y mensajes de error amigables.

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej: JWT o session).
- Validar que los parámetros sean correctos y no permitan SQL injection (Laravel lo hace por defecto con bindings).

## 7. Extensibilidad
- Para agregar nuevas acciones, basta con agregar un nuevo case en el controlador y el SP correspondiente.
- El frontend puede consumir cualquier acción usando el mismo endpoint.

## 8. Consideraciones de Migración
- Los nombres de los SPs y parámetros siguen la lógica del Delphi original.
- Los reportes se generan en frontend (PDF/impresión) usando los datos JSON devueltos.
- No se usan tabs ni componentes tabulares: cada formulario es una página Vue independiente.

## 9. Ejemplo de Flujo
1. Usuario ingresa a la página de Estado de Cuenta.
2. Selecciona tipo de búsqueda (expediente/local), ingresa datos y periodo.
3. Al hacer clic en Buscar, se llama a `/api/execute` con acción `GAdeudos.buscar`.
4. Si existe, se muestra la cabecera y se consulta el detalle (`GAdeudos.detalle`).
5. El usuario puede imprimir (simulado en frontend).

## 10. Errores y Mensajes
- Si no existe el registro, se muestra mensaje amigable.
- Si hay error de conexión o SP, se muestra mensaje técnico.

## 11. Pruebas
- Se recomienda usar Postman para probar el endpoint `/api/execute`.
- El frontend puede ser probado con datos reales y simulados.

