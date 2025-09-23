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
