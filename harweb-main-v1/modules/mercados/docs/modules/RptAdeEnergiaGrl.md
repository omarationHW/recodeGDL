# Documentación Técnica: Adeudos Globales de Energía Eléctrica

## Descripción General
Este módulo permite consultar y exportar el listado global de adeudos de energía eléctrica por mercado, oficina, año y mes. Incluye la visualización de los meses de adeudo, cuota y total de adeudos por local.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` que recibe un objeto eRequest con acción y parámetros.
- **Frontend**: Componente Vue.js independiente, página completa, sin tabs.
- **Base de Datos**: Toda la lógica SQL se implementa en stored procedures PostgreSQL.
- **API**: El frontend consume el endpoint `/api/execute` enviando `{ action, params }` y recibe `{ success, data, message }`.

## Flujo de Datos
1. El usuario selecciona recaudadora, mercado, año y mes.
2. El frontend envía un eRequest con acción `getEnergyDebts` y los parámetros seleccionados.
3. El backend ejecuta el stored procedure `sp_get_ade_energia_grl` y retorna los resultados.
4. El frontend muestra la tabla de resultados y permite exportar a Excel.

## Endpoints y Acciones
- **/api/execute** (POST)
  - `action: getMarketsByOffice` → retorna mercados de una oficina
  - `action: getEnergyDebts` → retorna listado de adeudos globales
  - `action: exportEnergyDebtsExcel` → exporta a Excel (dummy)
  - `action: getYearsMonths` → retorna años y meses disponibles

## Stored Procedure Principal
- **sp_get_ade_energia_grl**: Recibe oficina, mercado, año y mes. Retorna tabla con los campos requeridos, incluyendo meses de adeudo y cuota.

## Validaciones
- Todos los campos de filtro son obligatorios.
- El backend valida que los parámetros sean correctos y retorna error si falta alguno.

## Seguridad
- El endpoint requiere autenticación (middleware Laravel, no mostrado aquí).
- El stored procedure no permite SQL injection (parámetros tipados).

## Exportación
- La exportación a Excel debe implementarse usando un paquete de Laravel (ejemplo: Laravel Excel) o en frontend usando una librería JS.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- El stored procedure puede extenderse para incluir más columnas si es necesario.

## Errores y Manejo de Excepciones
- Todos los errores se retornan en el campo `message` del eResponse.
- El frontend muestra mensajes de error amigables.

## Navegación
- Cada formulario es una página independiente con su propia ruta.
- Se incluye breadcrumb para navegación contextual.

---

# Esquema de Base de Datos (relevante)
- ta_11_locales
- ta_11_energia
- ta_11_adeudo_energ
- ta_11_mercados

---

# Ejemplo de eRequest/eResponse
**Request:**
```json
{
  "action": "getEnergyDebts",
  "params": {
    "office_id": 1,
    "market_id": 5,
    "year": 2024,
    "month": 6
  }
}
```
**Response:**
```json
{
  "success": true,
  "data": [ ... ],
  "message": ""
}
```
