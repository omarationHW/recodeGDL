# RptPadronGlobal

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Padrón Global de Locales

## Descripción General
Este módulo permite consultar, exportar y reportar el padrón global de locales de mercados municipales, mostrando información relevante como renta calculada, estatus de adeudo y datos de identificación del local. Incluye integración con frontend Vue.js, backend Laravel y lógica de negocio en stored procedures PostgreSQL.

## Arquitectura
- **Frontend**: Componente Vue.js independiente, página completa, sin tabs.
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: Lógica de negocio y reportes en stored procedures PostgreSQL.

## API
### Endpoint Unificado
- **POST** `/api/execute`
- **Body:**
  ```json
  {
    "action": "getPadronGlobal",
    "params": {
      "year": 2024,
      "month": 6,
      "status": "A"
    }
  }
  ```
- **Acciones soportadas:**
  - `getPadronGlobal`: Consulta el padrón global.
  - `exportPadronGlobalExcel`: Exporta a Excel.
  - `getPadronGlobalReport`: Genera PDF (simulado).

### Respuesta
- **Éxito:**
  ```json
  {
    "success": true,
    "data": [ ... ]
  }
  ```
- **Error:**
  ```json
  {
    "success": false,
    "message": "Error en la consulta"
  }
  ```

## Stored Procedure: `sp_padron_global`
- **Entradas:**
  - `p_year` (integer): Año de consulta
  - `p_month` (integer): Mes de consulta
  - `p_status` (varchar): Estatus ('A', 'B', 'C', 'D', 'T')
- **Salidas:**
  - Tabla con todos los campos relevantes del padrón, renta calculada, leyenda y estatus de adeudo.
- **Lógica:**
  - Calcula la renta según reglas de negocio.
  - Determina si el local tiene adeudo.
  - Permite filtrar por estatus.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- Validación de parámetros en backend.

## Integración Frontend
- El componente Vue.js realiza la consulta vía Axios al endpoint `/api/execute`.
- Permite exportar a Excel y PDF (simulado).
- Muestra totales y desglose de estatus.

## Consideraciones
- El stored procedure puede ser extendido para incluir más lógica de negocio.
- El endpoint puede ser reutilizado para otros reportes cambiando el parámetro `action`.

# Estructura de la Base de Datos (Resumen)
- `ta_11_locales`: Datos de locales
- `ta_11_mercados`: Catálogo de mercados
- `ta_11_cuo_locales`: Cuotas por local
- `ta_11_adeudo_local`: Adeudos por local
- `ta_11_fecha_desc`: Fechas de vencimiento y descuentos

# Flujo de Datos
1. Usuario ingresa año, mes y estatus en la página Vue.js.
2. Se envía petición a `/api/execute` con acción `getPadronGlobal`.
3. Laravel ejecuta el stored procedure `sp_padron_global`.
4. Se retorna el resultado al frontend para mostrarlo en tabla.
5. Opcionalmente, el usuario puede exportar a Excel o PDF.

# Errores Comunes
- Parámetros inválidos: retorna error 422.
- Acción no soportada: retorna error 400.
- Problemas de conexión o permisos: retorna error 500.

# Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute`.
- El stored procedure puede ser modificado para incluir más reglas.


## Casos de Uso

# Casos de Uso - RptPadronGlobal

**Categoría:** Form

## Caso de Uso 1: Consulta del Padrón Global de Locales Vigentes

**Descripción:** El usuario desea consultar todos los locales vigentes al mes actual para identificar cuáles están al corriente y cuáles tienen adeudo.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar el padrón.

**Pasos a seguir:**
1. El usuario accede a la página 'Padrón Global de Locales'.
2. Selecciona el año y mes actual.
3. Selecciona 'Vigentes' en el campo Estatus.
4. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con todos los locales vigentes, indicando nombre, superficie, renta calculada, estatus de adeudo y adicionales.

**Datos de prueba:**
{ "year": 2024, "month": 6, "status": "A" }

---

## Caso de Uso 2: Exportación a Excel del Padrón Global

**Descripción:** El usuario requiere exportar el padrón global de locales con estatus 'Todos' para análisis externo.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de exportación.

**Pasos a seguir:**
1. El usuario accede a la página 'Padrón Global de Locales'.
2. Selecciona el año y mes deseado.
3. Selecciona 'Todos' en el campo Estatus.
4. Presiona el botón 'Exportar Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos del padrón global filtrados.

**Datos de prueba:**
{ "year": 2024, "month": 6, "status": "T" }

---

## Caso de Uso 3: Reporte PDF del Padrón Global de Locales con Adeudo

**Descripción:** El usuario necesita un reporte en PDF de todos los locales con adeudo para presentarlo a la dirección.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de reporte.

**Pasos a seguir:**
1. El usuario accede a la página 'Padrón Global de Locales'.
2. Selecciona el año y mes deseado.
3. Selecciona 'Baja' en el campo Estatus.
4. Presiona el botón 'Reporte PDF'.

**Resultado esperado:**
Se genera y descarga un archivo PDF con los locales en baja y su estatus de adeudo.

**Datos de prueba:**
{ "year": 2024, "month": 6, "status": "B" }

---



## Casos de Prueba

# Casos de Prueba: Padrón Global de Locales

## Caso 1: Consulta de Locales Vigentes
- **Entrada:** year=2024, month=6, status='A'
- **Acción:** POST /api/execute { action: 'getPadronGlobal', params: { year:2024, month:6, status:'A' } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: Array de locales con leyenda 'Local al Corriente de Pagos' o 'Local con Adeudo'
  - No errores

## Caso 2: Exportación a Excel
- **Entrada:** year=2024, month=6, status='T'
- **Acción:** POST /api/execute { action: 'exportPadronGlobalExcel', params: { year:2024, month:6, status:'T' } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - message: 'Exportación a Excel generada (simulada)'

## Caso 3: Reporte PDF
- **Entrada:** year=2024, month=6, status='B'
- **Acción:** POST /api/execute { action: 'getPadronGlobalReport', params: { year:2024, month:6, status:'B' } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - message: 'Reporte PDF generado (simulado)'

## Caso 4: Parámetros Inválidos
- **Entrada:** year='abc', month=13, status='Z'
- **Acción:** POST /api/execute { action: 'getPadronGlobal', params: { year:'abc', month:13, status:'Z' } }
- **Resultado esperado:**
  - HTTP 422
  - success: false
  - errors: Detalle de validación

## Caso 5: Acción No Soportada
- **Entrada:** action='unknownAction'
- **Acción:** POST /api/execute { action: 'unknownAction', params: {} }
- **Resultado esperado:**
  - HTTP 400
  - success: false
  - message: 'Acción no soportada.'



