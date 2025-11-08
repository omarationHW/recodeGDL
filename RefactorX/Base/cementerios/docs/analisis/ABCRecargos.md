# Documentación Técnica: Migración Formulario ABCRecargos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute` para todas las operaciones (patrón eRequest/eResponse).
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente (sin tabs), navegación por rutas.
- **Base de Datos**: PostgreSQL 13+, toda la lógica de negocio y reglas de cálculo en stored procedures (PL/pgSQL).

## API Unificada
- **Endpoint**: `POST /api/execute`
- **Request**:
  ```json
  {
    "action": "recargos.create", // o recargos.update, recargos.list, recargos.get, recargos.acumulado
    "params": { ... }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [...],
    "message": "OK"
  }
  ```

## Controlador Laravel
- Un solo método `execute` que despacha según el campo `action`.
- Cada acción llama a un stored procedure correspondiente.
- Validación de parámetros con Laravel Validator.
- Manejo de errores y mensajes amigables.

## Stored Procedures PostgreSQL
- Toda la lógica de inserción, actualización y cálculo de acumulados está en SPs.
- Los SPs devuelven tablas o mensajes de resultado.
- El cálculo de acumulado replica la lógica Delphi, actualizando los porcentajes globales según reglas.

## Componente Vue.js
- Página independiente `/recargos`.
- Formulario para año y mes, botón Verificar.
- Si existe registro: permite modificar; si no, permite alta.
- Muestra lista/histórico de recargos del mes seleccionado.
- Llama a la API con fetch y muestra mensajes de éxito/error.
- No usa tabs ni componentes tabulares anidados.

## Seguridad
- El usuario debe estar autenticado (Laravel Sanctum/JWT recomendado).
- El ID de usuario se pasa a los SPs para auditoría.

## Consideraciones de Migración
- Los nombres de campos y lógica de negocio se respetan.
- Los mensajes de error y validaciones replican el comportamiento Delphi.
- El cálculo de acumulado se hace en el SP `sp_recargos_acumulado`.
- El frontend es reactivo y muestra mensajes en tiempo real.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar el endpoint.
- Los SPs pueden ser versionados y auditados.

## Pruebas
- Casos de uso y pruebas cubren altas, modificaciones, acumulados y errores.

# Esquema de Base de Datos (Tabla principal)
```sql
CREATE TABLE ta_13_recargosrcm (
    axo integer NOT NULL,
    mes smallint NOT NULL,
    porcentaje_parcial float NOT NULL,
    porcentaje_global float NOT NULL DEFAULT 0,
    usuario integer NOT NULL,
    fecha_mov date NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (axo, mes)
);
```

# Ejemplo de llamada API
```js
// Alta de recargo
fetch('/api/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    action: 'recargos.create',
    params: { axo: 2024, mes: 6, porcentaje_parcial: 1.5, usuario: 1 }
  })
})
```
