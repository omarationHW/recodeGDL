# Documentación Técnica: Migración de Formulario RFacturacion (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (no tabs).
- **Backend**: Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.

## 2. Flujo de Datos
1. El usuario accede a la página de Facturación Rastro.
2. Selecciona los filtros (tipo de adeudo, recargos, periodo/año/mes).
3. Al hacer clic en "Previa", el frontend envía un POST a `/api/execute` con un objeto `eRequest`.
4. El backend interpreta la acción, llama al stored procedure correspondiente y retorna los datos en `eResponse`.
5. El frontend muestra el reporte tabular y el total.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": {
      "action": "getRFacturacionReport",
      "params": {
        "adeudo_status": "A|B|C",
        "adeudo_recargo": "S|N",
        "year": 2024,
        "month": 6,
        "periodo_actual": true|false
      }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": "Reporte generado correctamente."
    }
  }
  ```

## 4. Stored Procedure
- **Nombre**: `con34_gfact_02`
- **Parámetros**:
  - `p_adeudo_status`: 'A', 'B', 'C'
  - `p_adeudo_recargo`: 'S', 'N'
  - `p_year`: año
  - `p_month`: mes
- **Retorna**: Tabla con columnas `control`, `concesionario`, `superficie`, `tipo`, `licencia`, `importe`.
- **Lógica**: Filtra según los parámetros y retorna los registros de facturación.

## 5. Vue.js Component
- Página independiente `/rfacturacion`.
- Formulario con selectores para tipo de adeudo, recargo, periodo/año/mes.
- Botón "Previa" para consultar y mostrar el reporte.
- Botón "Salir" para regresar al inicio.
- Tabla con los resultados y total.

## 6. Laravel Controller
- Controlador único con método `execute`.
- Interpreta el campo `eRequest['action']` y ejecuta la lógica correspondiente.
- Llama al stored procedure usando DB::select.
- Retorna respuesta estructurada en `eResponse`.

## 7. Consideraciones
- El SP debe ajustarse a la estructura real de la tabla destino (`basephp.rastro_facturacion`).
- El frontend asume que la API responde en formato eResponse.
- El endpoint es seguro para POST y debe validarse autenticación si es necesario.

## 8. Seguridad
- Se recomienda proteger `/api/execute` con autenticación JWT o session según la política del sistema.
- Validar y sanear los parámetros recibidos.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar más acciones y formularios reutilizando el mismo endpoint.

