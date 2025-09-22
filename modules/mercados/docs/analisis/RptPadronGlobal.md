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
