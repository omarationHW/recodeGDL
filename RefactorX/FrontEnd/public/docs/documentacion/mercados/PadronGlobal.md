# PadronGlobal

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Padrón Global de Locales

## Descripción General
Este módulo permite consultar y exportar el padrón global de locales de mercados, mostrando información relevante como ubicación, nombre, superficie, renta calculada y estado de pagos (corriente o con adeudo). Incluye filtros por año, mes y estado del local (vigente, baja, etc.), y permite exportar la información a Excel.

## Arquitectura
- **Backend (Laravel):**
  - Un único endpoint `/api/execute` que recibe peticiones eRequest/eResponse.
  - El controlador `PadronGlobalController` interpreta la acción (`action`) y delega a métodos internos.
  - Toda la lógica SQL reside en stored procedures de PostgreSQL.
- **Frontend (Vue.js):**
  - Componente de página independiente (`PadronGlobalPage.vue`), sin tabs.
  - Filtros de búsqueda, tabla de resultados, exportación a Excel y navegación breadcrumb.
- **Base de Datos (PostgreSQL):**
  - Stored procedures para consulta y lógica de negocio.

## API
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "getPadronGlobal",
    "params": {
      "axo": 2024,
      "mes": 6,
      "vig": "A"
    }
  }
  ```
- **Acciones soportadas:**
  - `getPadronGlobal`: Consulta el padrón global.
  - `exportPadronGlobalExcel`: Exporta el padrón global a Excel.
  - `getVencimientoRec`: Consulta vencimientos de recargos/descuentos.

## Stored Procedures
- `sp_padron_global(axo, mes, vig)`
- `sp_vencimiento_rec(mes)`

## Seguridad
- Validación de parámetros en backend.
- El endpoint requiere autenticación (middleware Laravel, no mostrado aquí).

## Manejo de Errores
- Respuestas JSON con `success: false` y mensaje de error.
- El frontend muestra notificaciones en caso de error.

## Exportación a Excel
- El backend genera el archivo y devuelve una URL temporal para descarga.

## Consideraciones
- El frontend es completamente independiente y funcional como página.
- No se usan tabs ni componentes tabulares.
- El backend es desacoplado y puede ser reutilizado por otros clientes.

# Esquema de Datos Relevante
- `ta_11_locales`: Información de locales.
- `ta_11_mercados`: Catálogo de mercados.
- `ta_11_cuo_locales`: Cuotas por local.
- `ta_11_adeudo_local`: Adeudos de locales.
- `ta_11_fecha_desc`: Fechas de vencimiento y descuentos.

# Ejemplo de eRequest/eResponse
**Request:**
```json
{
  "action": "getPadronGlobal",
  "params": { "axo": 2024, "mes": 6, "vig": "A" }
}
```
**Response:**
```json
{
  "success": true,
  "data": [
    { "id_local": 1, "oficina": 1, ... }
  ]
}
```

# Notas de Migración
- Todas las reglas de negocio de Delphi se trasladan a los stored procedures.
- El frontend Vue.js es una SPA moderna, sin dependencias de componentes legacy.
- El endpoint `/api/execute` es unificado para facilitar integración y pruebas.


## Casos de Uso

# Casos de Uso - PadronGlobal

**Categoría:** Form

## Caso de Uso 1: Consulta del Padrón Global de Locales Vigentes

**Descripción:** El usuario desea consultar todos los locales vigentes al mes y año actual.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de consulta.

**Pasos a seguir:**
1. Accede a la página 'Padrón Global de Locales'.
2. Selecciona el año y mes actual en los filtros.
3. Selecciona 'VIGENTES' como estado del local.
4. Haz clic en 'Consultar'.

**Resultado esperado:**
Se muestra la tabla con todos los locales vigentes, incluyendo cálculo de renta y leyenda de adeudo/corriente.

**Datos de prueba:**
{ "axo": 2024, "mes": 6, "vig": "A" }

---

## Caso de Uso 2: Exportación a Excel del Padrón Global de Locales con Baja

**Descripción:** El usuario requiere exportar a Excel el padrón de locales con baja total para un periodo específico.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de exportación.

**Pasos a seguir:**
1. Accede a la página 'Padrón Global de Locales'.
2. Selecciona el año 2023 y mes 12.
3. Selecciona 'CON BAJA TOTAL' como estado del local.
4. Haz clic en 'Consultar'.
5. Haz clic en 'Exportar Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos filtrados.

**Datos de prueba:**
{ "axo": 2023, "mes": 12, "vig": "B" }

---

## Caso de Uso 3: Visualización de Leyenda de Adeudo

**Descripción:** El usuario quiere identificar rápidamente qué locales tienen adeudo y cuáles están al corriente.

**Precondiciones:**
El usuario debe estar autenticado.

**Pasos a seguir:**
1. Accede a la página 'Padrón Global de Locales'.
2. Selecciona cualquier año y mes.
3. Haz clic en 'Consultar'.
4. Observa la columna 'Leyenda' en la tabla.

**Resultado esperado:**
La columna 'Leyenda' muestra 'Local con Adeudo' o 'Local al Corriente de Pagos' según corresponda.

**Datos de prueba:**
{ "axo": 2024, "mes": 5, "vig": "A" }

---



## Casos de Prueba

# Casos de Prueba: Padrón Global de Locales

## Caso 1: Consulta básica de locales vigentes
- **Entrada:** { "axo": 2024, "mes": 6, "vig": "A" }
- **Acción:** POST /api/execute con action=getPadronGlobal
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: array de locales con vigencia 'A'
  - Cada registro incluye cálculo correcto de renta y leyenda

## Caso 2: Exportación a Excel
- **Entrada:** { "axo": 2023, "mes": 12, "vig": "B" }
- **Acción:** POST /api/execute con action=exportPadronGlobalExcel
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data.url: contiene la URL de descarga del archivo Excel

## Caso 3: Consulta de vencimiento de recargos
- **Entrada:** { "mes": 6 }
- **Acción:** POST /api/execute con action=getVencimientoRec
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: array con información de vencimiento para el mes 6

## Caso 4: Consulta con filtros inexistentes
- **Entrada:** { "axo": 1900, "mes": 1, "vig": "A" }
- **Acción:** POST /api/execute con action=getPadronGlobal
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: array vacío

## Caso 5: Error de parámetros
- **Entrada:** { "axo": "", "mes": "", "vig": "" }
- **Acción:** POST /api/execute con action=getPadronGlobal
- **Resultado esperado:**
  - HTTP 200
  - success: false
  - message: error de parámetros o mensaje descriptivo



