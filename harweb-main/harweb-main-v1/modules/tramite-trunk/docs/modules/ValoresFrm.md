# Documentación Técnica: Migración de Formulario Valores (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API, con endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (no tabs).
- **Base de Datos**: PostgreSQL, lógica de negocio crítica en stored procedures.

## Flujo de Trabajo
1. **Inicio**: El usuario accede a la página de valores de una cuenta.
2. **Transacción**: Debe iniciar una transacción para editar/agregar valores.
3. **Edición**: Puede agregar, modificar o eliminar valores temporales (tabla `tmp_valadeudo`).
4. **Aplicar Cambios**: Al aplicar, los cambios se consolidan en la tabla principal (`valoradeudo`) y se actualiza la tabla `catastro`.
5. **Tasas**: Las tasas disponibles se consultan dinámicamente según el año.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "nombreAccion",
    "payload": { ... }
  }
  ```
- **Acciones soportadas**:
  - `listValores`: Lista valores temporales de una cuenta.
  - `getValor`: Obtiene un valor temporal por ID.
  - `insertValor`: Inserta un nuevo valor temporal.
  - `updateValor`: Actualiza un valor temporal existente.
  - `deleteValor`: Elimina un valor temporal.
  - `applyValores`: Aplica los cambios (llama stored procedure `upd_tmpvalade`).
  - `getTasas`: Obtiene tasas disponibles para un año.

## Validaciones
- Todos los campos requeridos deben ser validados en frontend y backend.
- No se permite aplicar cambios si hay errores de validación.
- El usuario debe iniciar una transacción antes de editar/agregar valores.

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej. JWT o session).
- Los stored procedures sólo pueden ser ejecutados por el usuario autenticado.

## Integración Vue.js
- Cada formulario es una página completa, sin tabs.
- El componente de valores permite CRUD sobre los valores temporales.
- El usuario sólo puede aplicar cambios si está en modo transacción.
- Mensajes de error y éxito se muestran en pantalla.

## Integración Laravel
- El controlador recibe la acción y el payload, despacha a la lógica correspondiente.
- Todas las operaciones de negocio críticas se delegan a stored procedures.
- El controlador es stateless y desacoplado de la UI.

## Integración PostgreSQL
- La lógica de consolidación y validación de valores se realiza en stored procedures.
- Las tablas temporales (`tmp_valadeudo`) se usan para staging antes de aplicar cambios.

## Consideraciones
- El sistema debe ser transaccional: los cambios sólo se aplican al confirmar.
- El frontend debe reflejar el estado de la transacción y bloquear acciones indebidas.
- El backend debe validar la integridad de los datos antes de aplicar cambios.

# Esquema de Tablas (simplificado)
- **valoradeudo**: cvecuenta, axoefec, bimefec, valfiscal, tasa, axosobre, observacion
- **tmp_valadeudo**: igual a valoradeudo + estado (N/M), id (PK)
- **c_tasas**: tasaporcen, axo
- **catastro**: cvecuenta, asiento, axoefec, bimefec, observacion

# Ejemplo de eRequest/eResponse
```json
{
  "action": "insertValor",
  "payload": {
    "cvecuenta": 12345,
    "axoefec": 2024,
    "bimefec": 1,
    "valfiscal": 100000.00,
    "tasa": 0.002,
    "axosobre": 0,
    "estado": "N",
    "observacion": "Alta de valor inicial"
  }
}
```

# Ejemplo de eResponse
```json
{
  "success": true,
  "data": { ... },
  "message": "Valor guardado correctamente."
}
```
