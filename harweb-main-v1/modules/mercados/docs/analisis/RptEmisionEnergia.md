# Documentación Técnica: Emisión de Recibos de Energía Eléctrica

## Descripción General
Este módulo permite la consulta, previsualización e impresión de los recibos de energía eléctrica para los mercados municipales, integrando la lógica de negocio y presentación en una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos).

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js independiente como página completa.
- **Base de Datos:** Stored Procedures en PostgreSQL para encapsular la lógica SQL y cálculos.

## Flujo de Datos
1. El usuario accede a la página de emisión de recibos de energía.
2. Selecciona los parámetros: oficina, mercado, año y periodo.
3. El frontend envía una petición POST a `/api/execute` con la acción `getEmisionEnergia` y los parámetros seleccionados.
4. El backend ejecuta el stored procedure `sp_rpt_emision_energia` y retorna los datos al frontend.
5. El usuario puede previsualizar o imprimir el reporte, lo que dispara las acciones `previewEmisionEnergia` o `printEmisionEnergia`.
6. Para impresión, el backend puede generar un PDF y devolver la URL para descarga o visualización.

## API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "getEmisionEnergia",
    "params": {
      "oficina": 5,
      "mercado": 1,
      "axo": 2024,
      "periodo": 6
    }
  }
  ```
- **Acciones soportadas:**
  - `getEmisionEnergia`: Devuelve los datos de emisión.
  - `previewEmisionEnergia`: (Opcional) Devuelve datos para previsualización.
  - `printEmisionEnergia`: Genera y devuelve la URL del PDF del reporte.

## Stored Procedures
- **sp_rpt_emision_energia:** Devuelve los datos de emisión de energía para los parámetros dados.
- **sp_rpt_emision_energia_pdf:** Genera el PDF del reporte y devuelve la URL.

## Frontend (Vue.js)
- Página independiente con formulario de parámetros y tabla de resultados.
- Botones para imprimir y previsualizar.
- Manejo de estados de carga y error.

## Seguridad
- Validación de parámetros en backend y frontend.
- El endpoint `/api/execute` debe estar protegido por autenticación (middleware Laravel).

## Consideraciones
- El frontend debe manejar correctamente los estados de carga, error y éxito.
- El backend debe manejar excepciones y devolver mensajes claros.
- Los stored procedures deben ser eficientes y seguros.

# Estructura de la Base de Datos
- Tablas principales: `ta_11_locales`, `ta_11_mercados`, `ta_11_kilowhatts`, `ta_11_energia`.
- Los cálculos de importe y descripción de consumo se realizan en el stored procedure.

# Integración
- El frontend y backend se comunican exclusivamente por el endpoint `/api/execute`.
- Los reportes PDF pueden ser generados por el backend y almacenados en `/storage/reports/`.

# Pruebas
- Se recomienda realizar pruebas unitarias y de integración para cada acción y escenario de negocio.
