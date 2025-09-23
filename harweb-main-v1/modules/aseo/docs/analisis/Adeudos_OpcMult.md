# Documentación Técnica: Migración Formulario Adeudos_OpcMult (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (API RESTful)
- **Frontend:** Vue.js 3 (SPA, página independiente)
- **Base de Datos:** PostgreSQL 13+
- **API Unificada:** Un solo endpoint `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Stored Procedures:** Toda la lógica de negocio y reportes SQL se implementa en funciones y vistas PostgreSQL.

## 2. Flujo de Trabajo
1. **Carga inicial:**
   - El frontend solicita los catálogos de tipo de aseo y recaudadoras.
2. **Búsqueda de contrato:**
   - El usuario ingresa número de contrato y tipo de aseo.
   - El frontend consulta `/api/execute` con acción `buscar_contrato`.
   - Si existe, muestra datos y busca convenio asociado.
   - Si el contrato está vigente, muestra los adeudos pendientes (`listar_adeudos`).
3. **Selección de adeudos:**
   - El usuario selecciona uno o varios adeudos de la lista.
4. **Ejecución de opción:**
   - El usuario elige la opción (Pagar, Condonar, Cancelar, Prescribir) y llena los datos requeridos.
   - El frontend envía la acción `ejecutar_opcion` con los adeudos seleccionados y los datos de operación.
   - El backend ejecuta el SP `upd16_ade` para cada adeudo seleccionado.
   - Se retorna el resultado de cada operación.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "listar_tipo_aseo|buscar_contrato|listar_recaudadoras|listar_cajas|listar_adeudos|ejecutar_opcion",
      ... parámetros ...
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [...],
      "message": "..."
    }
  }
  ```

## 4. Stored Procedures y Vistas
- **con16_detade_021:** Devuelve los adeudos vigentes de un contrato.
- **upd16_ade:** Actualiza el estado de un adeudo (pagado, condonado, cancelado, prescrito).
- **vw_contratos_detalle:** Vista para obtener detalle de contrato.
- **vw_convenios:** Vista para obtener convenio asociado a un contrato.

## 5. Validaciones y Seguridad
- Validar que el usuario tenga permisos para ejecutar la acción (por implementar en middleware Laravel).
- Validar que los datos requeridos estén presentes antes de ejecutar la acción.
- Todas las operaciones de actualización se ejecutan en transacción.

## 6. Consideraciones de Migración
- Los combos y catálogos Delphi se migran a endpoints de catálogo.
- El grid de selección múltiple se implementa como tabla con checkboxes en Vue.js.
- El SP `upd16_ade` encapsula toda la lógica de actualización de adeudos.
- El frontend es una página independiente, sin tabs ni componentes compartidos.

## 7. Estructura de Carpetas Sugerida
- `app/Http/Controllers/Api/AdeudosOpcMultController.php`
- `resources/js/pages/AdeudosOpcMult.vue`
- `database/migrations/` y `database/functions/` para SP y vistas

## 8. Ejemplo de Llamada API
```js
// Buscar contrato
fetch('/api/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ eRequest: { action: 'buscar_contrato', num_contrato: 123, ctrol_aseo: 9 } })
})
```

## 9. Notas
- El endpoint es único y todas las acciones se discriminan por el campo `action`.
- El frontend debe manejar los estados de error y éxito según la respuesta.
- Los nombres de los campos y combos deben coincidir con los del backend.
