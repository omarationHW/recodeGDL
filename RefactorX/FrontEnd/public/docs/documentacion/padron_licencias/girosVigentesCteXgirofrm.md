# Documentación Técnica: girosVigentesCteXgirofrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario girosVigentesCteXgirofrm

## Descripción General
Este módulo implementa el formulario de reporte de giros vigentes/cancelados agrupados por giro, migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Toda la lógica de consulta y filtrado se realiza mediante un stored procedure en PostgreSQL, y la comunicación entre frontend y backend se realiza a través de un endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.

## Arquitectura
- **Backend:** Laravel 10+, controlador `GirosVigentesCteXgiroController`.
- **Frontend:** Vue.js 3+, componente de página independiente.
- **Base de datos:** PostgreSQL 13+, stored procedure `sp_reporte_giros_vigentes_cte_xgiro`.
- **API:** Endpoint único `/api/execute` que recibe `{ action, params }` y responde con `{ success, data, message }`.

## Flujo de Datos
1. El usuario accede a la página `/giros-vigentes` (o similar), que carga el componente Vue.
2. El usuario selecciona los filtros (año, rango de fechas, vigencia, clasificación, orden).
3. Al hacer clic en "Buscar", el frontend envía un POST a `/api/execute` con `action: 'getReporteGiros'` y los parámetros seleccionados.
4. El backend ejecuta el stored procedure correspondiente y retorna los datos agrupados.
5. El frontend muestra los resultados en una tabla y permite imprimir/exportar.

## Detalles Técnicos
### Endpoint API
- **Ruta:** `/api/execute`
- **Método:** POST
- **Cuerpo:**
  ```json
  {
    "action": "getReporteGiros",
    "params": {
      "year": 2024,
      "date_from": "2024-01-01",
      "date_to": "2024-12-31",
      "vigente": "V",
      "clasificacion": "A",
      "order_by": "cuantos"
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [
      { "cuantos": 12, "id_giro": 1, "cod_giro": 101, "descripcion": "ABARROTES" },
      ...
    ],
    "message": ""
  }
  ```

### Stored Procedure
- **Nombre:** `sp_reporte_giros_vigentes_cte_xgiro`
- **Parámetros:**
  - `p_vigente` (char): 'V' (vigente) o 'C' (cancelado)
  - `p_year` (int, opcional)
  - `p_date_from`, `p_date_to` (date, opcional)
  - `p_clasificacion` (char, opcional)
  - `p_order_by` (text, 'cuantos' o 'descripcion')
- **Retorna:** Tabla con columnas `cuantos`, `id_giro`, `cod_giro`, `descripcion`

### Validaciones
- Si no se indica año ni rango de fechas, se listan todos los registros según vigencia.
- Si se indica año, se filtra por el año en la fecha de alta o baja según vigencia.
- Si se indica rango de fechas, se filtra por ese rango.
- Si se indica clasificación, se filtra por la misma.
- El orden puede ser por concurrencias (desc) o por descripción.

### Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación JWT o sesión.
- El stored procedure no permite SQL injection, ya que usa parámetros.

### Extensibilidad
- Se pueden agregar más filtros (por zona, subzona, etc.) fácilmente.
- El endpoint puede ser reutilizado para otros reportes cambiando el `action`.

## Estructura de Archivos
- `app/Http/Controllers/GirosVigentesCteXgiroController.php`: Controlador principal.
- `resources/js/pages/GirosVigentesCteXgiro.vue`: Componente Vue.js.
- `database/migrations/`: Estructura de tablas `licencias`, `c_giros`.
- `database/functions/sp_reporte_giros_vigentes_cte_xgiro.sql`: Stored procedure.

## Consideraciones de Migración
- El formulario Delphi usaba componentes visuales y lógica procedural; ahora todo es reactivo y desacoplado.
- El reporte se puede exportar a PDF/Excel desde el frontend usando bibliotecas JS.
- El backend puede generar PDF si se requiere impresión oficial.

## Ejemplo de Llamada desde Frontend
```js
fetch('/api/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    action: 'getReporteGiros',
    params: {
      year: 2024,
      vigente: 'V',
      clasificacion: 'A',
      order_by: 'cuantos'
    }
  })
})
.then(res => res.json())
.then(json => console.log(json));
```

## Pruebas y Validación
- Se recomienda probar con distintos filtros y comparar resultados con el sistema original.
- Validar que los totales y agrupaciones coincidan.

## Mantenimiento
- El stored procedure puede ser modificado para agregar más columnas o filtros.
- El frontend puede ser extendido para exportar o imprimir el reporte.

## Casos de Prueba

# Casos de Prueba: Giros Vigentes Cte X Giro

## Caso 1: Consulta por año y clasificación
- **Entrada:** year=2024, vigente='V', clasificacion='A', order_by='cuantos'
- **Acción:** POST /api/execute { action: 'getReporteGiros', params: { year: 2024, vigente: 'V', clasificacion: 'A', order_by: 'cuantos' } }
- **Esperado:** Respuesta success=true, data con lista de giros vigentes año 2024, solo clasificación A, agrupados y ordenados por concurrencias.

## Caso 2: Consulta por rango de fechas y cancelados
- **Entrada:** date_from='2023-01-01', date_to='2023-03-31', vigente='C', clasificacion='', order_by='descripcion'
- **Acción:** POST /api/execute { action: 'getReporteGiros', params: { date_from: '2023-01-01', date_to: '2023-03-31', vigente: 'C', clasificacion: '', order_by: 'descripcion' } }
- **Esperado:** Respuesta success=true, data con lista de giros cancelados en ese rango, agrupados y ordenados por descripción.

## Caso 3: Consulta sin filtros de año ni fechas
- **Entrada:** vigente='V', clasificacion='', order_by='cuantos'
- **Acción:** POST /api/execute { action: 'getReporteGiros', params: { vigente: 'V', clasificacion: '', order_by: 'cuantos' } }
- **Esperado:** Respuesta success=true, data con todos los giros vigentes agrupados y ordenados por concurrencias.

## Caso 4: Validación de error por falta de parámetros
- **Entrada:** action='getReporteGiros', params={}
- **Acción:** POST /api/execute { action: 'getReporteGiros', params: {} }
- **Esperado:** Respuesta success=true, data con todos los giros vigentes agrupados y ordenados por concurrencias (comportamiento por defecto).

## Caso 5: Impresión del reporte
- **Entrada:** year=2022, vigente='V', clasificacion='B', order_by='cuantos'
- **Acción:** POST /api/execute { action: 'printReporteGiros', params: { year: 2022, vigente: 'V', clasificacion: 'B', order_by: 'cuantos' } }
- **Esperado:** Respuesta success=true, data igual que en getReporteGiros, o bien descarga de PDF si está implementado.

## Casos de Uso

# Casos de Uso - girosVigentesCteXgirofrm

**Categoría:** Form

## Caso de Uso 1: Consulta de giros vigentes por año y clasificación

**Descripción:** El usuario desea obtener un reporte de los giros vigentes en el año 2024, filtrando solo los de clasificación 'A', ordenados por concurrencias.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo de reportes.

**Pasos a seguir:**
1. Accede a la página de 'Reporte de Giros Vigentes'.
2. Selecciona 'Año de alta' = 2024.
3. Selecciona 'Filtrado por' = Vigentes.
4. Selecciona 'Clasificación' = Solo A.
5. Selecciona 'Ordenado por' = Número de concurrencias.
6. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los giros vigentes del año 2024, solo clasificación A, agrupados y ordenados por concurrencias.

**Datos de prueba:**
{ "year": 2024, "vigente": "V", "clasificacion": "A", "order_by": "cuantos" }

---

## Caso de Uso 2: Reporte de giros cancelados en un rango de fechas

**Descripción:** El usuario requiere un listado de giros cancelados entre el 01/01/2023 y el 31/03/2023, de cualquier clasificación, ordenados por descripción.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página de reporte.
2. Deja vacío el campo 'Año'.
3. Selecciona 'Fecha desde' = 2023-01-01 y 'Fecha hasta' = 2023-03-31.
4. Selecciona 'Filtrado por' = Cancelados.
5. Selecciona 'Clasificación' = Todas.
6. Selecciona 'Ordenado por' = Descripción.
7. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra la lista de giros cancelados en el rango de fechas, agrupados y ordenados por descripción.

**Datos de prueba:**
{ "date_from": "2023-01-01", "date_to": "2023-03-31", "vigente": "C", "clasificacion": "", "order_by": "descripcion" }

---

## Caso de Uso 3: Impresión del reporte de giros vigentes

**Descripción:** El usuario desea imprimir el reporte actual de giros vigentes filtrados por año 2022 y clasificación B.

**Precondiciones:**
El usuario ya realizó una búsqueda y tiene resultados en pantalla.

**Pasos a seguir:**
1. Realiza la búsqueda con año 2022, vigente, clasificación B.
2. Da clic en 'Imprimir'.

**Resultado esperado:**
Se genera un PDF o vista de impresión con el reporte mostrado.

**Datos de prueba:**
{ "year": 2022, "vigente": "V", "clasificacion": "B", "order_by": "cuantos" }

---
