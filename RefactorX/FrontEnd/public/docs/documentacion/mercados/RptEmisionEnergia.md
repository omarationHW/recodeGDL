# RptEmisionEnergia

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - RptEmisionEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Recibos de Energía para Mercado de Abastos

**Descripción:** El usuario desea consultar los recibos de energía eléctrica emitidos para el Mercado de Abastos en la oficina Cruz del Sur para el mes de junio de 2024.

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar reportes. Existen datos de energía para el mercado y periodo seleccionados.

**Pasos a seguir:**
- El usuario accede a la página de Emisión de Recibos de Energía.
- Selecciona 'Cruz del Sur' como oficina.
- Selecciona 'Mercado de Abastos' como mercado.
- Selecciona año 2024 y periodo 6 (junio).
- Hace clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los recibos de energía correspondientes, incluyendo datos de locales, nombre, descripción, cuenta de energía, kilowhatts, importe y tipo de consumo.

**Datos de prueba:**
{ "oficina": 5, "mercado": 1, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 2: Impresión de Recibos de Energía

**Descripción:** El usuario desea imprimir el reporte de recibos de energía para el Mercado Libertad en mayo de 2023.

**Precondiciones:**
El usuario está autenticado y tiene permisos de impresión. Existen datos para el mercado y periodo.

**Pasos a seguir:**
- Accede a la página de Emisión de Recibos de Energía.
- Selecciona 'Cruz del Sur' como oficina.
- Selecciona 'Mercado Libertad' como mercado.
- Selecciona año 2023 y periodo 5 (mayo).
- Hace clic en 'Consultar'.
- Hace clic en 'Imprimir'.

**Resultado esperado:**
Se genera y descarga (o muestra) un PDF con el reporte de recibos de energía para los parámetros seleccionados.

**Datos de prueba:**
{ "oficina": 5, "mercado": 2, "axo": 2023, "periodo": 5 }

---

## Caso de Uso 3: Manejo de Parámetros Inválidos

**Descripción:** El usuario intenta consultar recibos de energía sin seleccionar todos los parámetros requeridos.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
- Accede a la página de Emisión de Recibos de Energía.
- Deja vacío el campo 'Mercado'.
- Hace clic en 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que todos los campos son obligatorios.

**Datos de prueba:**
{ "oficina": 5, "mercado": "", "axo": 2024, "periodo": 6 }

---



## Casos de Prueba

## Casos de Prueba para Emisión de Recibos de Energía

### Caso 1: Consulta exitosa de recibos
- **Entrada:** oficina=5, mercado=1, axo=2024, periodo=6
- **Acción:** POST /api/execute { action: 'getEmisionEnergia', params: ... }
- **Esperado:** HTTP 200, success=true, data contiene array de recibos con campos correctos

### Caso 2: Impresión de reporte
- **Entrada:** oficina=5, mercado=2, axo=2023, periodo=5
- **Acción:** POST /api/execute { action: 'printEmisionEnergia', params: ... }
- **Esperado:** HTTP 200, success=true, data.pdf_url contiene URL válida de PDF

### Caso 3: Parámetros inválidos
- **Entrada:** oficina=5, mercado='', axo=2024, periodo=6
- **Acción:** POST /api/execute { action: 'getEmisionEnergia', params: ... }
- **Esperado:** HTTP 200, success=false, message indica error de validación

### Caso 4: Sin resultados
- **Entrada:** oficina=5, mercado=99, axo=2024, periodo=6 (mercado inexistente)
- **Acción:** POST /api/execute { action: 'getEmisionEnergia', params: ... }
- **Esperado:** HTTP 200, success=true, data es array vacío

### Caso 5: Error de base de datos
- **Simulación:** Desconectar base de datos y repetir consulta
- **Esperado:** HTTP 200, success=false, message indica error de conexión o excepción



