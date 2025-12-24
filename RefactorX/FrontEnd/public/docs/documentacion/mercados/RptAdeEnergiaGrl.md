# RptAdeEnergiaGrl

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - RptAdeEnergiaGrl

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Globales de Energía

**Descripción:** El usuario desea consultar los adeudos globales de energía eléctrica de un mercado específico para un año y mes determinados.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Adeudos Globales de Energía.
2. Selecciona la recaudadora (oficina).
3. Selecciona el mercado.
4. Selecciona el año y el mes.
5. Presiona el botón 'Consultar'.
6. El sistema muestra la tabla de adeudos.

**Resultado esperado:**
Se muestra la lista de locales con sus adeudos, meses de adeudo y cuota correspondiente.

**Datos de prueba:**
office_id: 1, market_id: 5, year: 2024, month: 6

---

## Caso de Uso 2: Exportación de Adeudos a Excel

**Descripción:** El usuario desea exportar el listado de adeudos globales de energía a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Exportar Excel'.
2. El sistema genera y descarga el archivo Excel con los datos mostrados.

**Resultado esperado:**
El archivo Excel contiene los mismos datos que la tabla en pantalla.

**Datos de prueba:**
office_id: 2, market_id: 10, year: 2023, month: 12

---

## Caso de Uso 3: Validación de Filtros Obligatorios

**Descripción:** El usuario intenta consultar sin seleccionar todos los filtros requeridos.

**Precondiciones:**
El usuario está en la página de Adeudos Globales de Energía.

**Pasos a seguir:**
1. El usuario deja uno o más filtros vacíos.
2. Presiona 'Consultar'.
3. El sistema muestra un mensaje de error.

**Resultado esperado:**
El sistema no realiza la consulta y muestra un mensaje indicando que todos los filtros son obligatorios.

**Datos de prueba:**
office_id: '', market_id: '', year: '', month: ''

---



## Casos de Prueba

# Casos de Prueba: Adeudos Globales de Energía Eléctrica

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|--------------------|
| TC01 | Consulta exitosa de adeudos | office_id=1, market_id=5, year=2024, month=6 | Lista de adeudos mostrada, total correcto |
| TC02 | Exportación a Excel | office_id=2, market_id=10, year=2023, month=12 | Archivo Excel descargado con datos correctos |
| TC03 | Filtros incompletos | office_id='', market_id='', year='', month='' | Mensaje de error: 'Todos los filtros son obligatorios' |
| TC04 | Mercado sin adeudos | office_id=3, market_id=99, year=2022, month=1 | Tabla vacía, mensaje 'No hay adeudos' |
| TC05 | Error de conexión | (Simular caída de DB) | Mensaje de error amigable en frontend |



