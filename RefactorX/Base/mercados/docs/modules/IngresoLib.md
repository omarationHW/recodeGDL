# Documentación Técnica: Migración Formulario IngresoLib (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, página independiente para IngresoLib)
- **Base de Datos:** PostgreSQL (toda la lógica SQL en stored procedures)
- **Comunicación:** Patrón eRequest/eResponse (todas las operaciones a través de `/api/execute`)

## 2. Flujo de la Aplicación
1. **Carga inicial:**
   - El componente Vue solicita la lista de mercados (`get_mercados`).
   - El usuario selecciona mes, año y mercado.
2. **Procesar:**
   - Al hacer submit, Vue envía la acción `get_ingresos` con parámetros mes, año, mercado_id.
   - El backend ejecuta el SP correspondiente y retorna los datos.
   - Vue muestra los ingresos por fecha y caja.
   - Vue solicita también los totales por caja (`get_cajas`) y los totales globales (`get_totals`).

## 3. API Backend
- **Endpoint:** `/api/execute` (POST)
- **Body:** `{ action: 'nombre_accion', params: { ... } }`
- **Acciones soportadas:**
  - `get_mercados`: Lista de mercados tipo 'D'.
  - `get_ingresos`: Ingresos por fecha y caja.
  - `get_cajas`: Totales por caja.
  - `get_totals`: Totales globales.
- **Respuesta:** `{ success: bool, data: ..., message: string }`

## 4. Stored Procedures
- Toda la lógica de consulta se implementa en SPs PostgreSQL.
- Los SPs reciben parámetros y retornan tablas (RETURNS TABLE ...).
- El controlador Laravel ejecuta los SPs vía DB::select.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para seleccionar mes, año y mercado.
- Botón Procesar ejecuta la consulta.
- Muestra tres tablas: ingresos por fecha/caja, totales por caja, totales globales.
- Manejo de loading y errores.

## 6. Validaciones
- El backend valida los parámetros recibidos.
- El frontend valida que todos los campos estén completos antes de enviar.

## 7. Seguridad
- Todas las consultas se parametrizan para evitar SQL Injection.
- El endpoint puede protegerse con middleware de autenticación si se requiere.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones/SPs fácilmente.
- El frontend puede adaptarse a otros formularios siguiendo el mismo patrón.

## 9. Pruebas
- Casos de uso y pruebas incluidas para validar la funcionalidad principal.

---
