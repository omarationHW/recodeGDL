# Documentación Técnica: Emisión de Recibos de Energía Eléctrica

## Arquitectura General
- **Backend:** Laravel Controller con endpoint único `/api/execute` que recibe un objeto `eRequest` con los parámetros de acción y datos.
- **Frontend:** Componente Vue.js independiente, página completa, sin tabs.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Comunicación:** El frontend consume el endpoint `/api/execute` enviando `{ eRequest: { action, params } }` y recibiendo `{ eResponse: { status, data, message } }`.

## Flujo de la Aplicación
1. El usuario selecciona recaudadora, mercado, año y periodo.
2. Puede:
   - Consultar la emisión (detalle de recibos a emitir)
   - Grabar la emisión (genera adeudos si no existen)
   - Facturar (genera datos para impresión/facturación)
3. Todas las operaciones se ejecutan vía el endpoint `/api/execute`.

## API Backend
- **Endpoint:** `/api/execute` (POST)
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getEmisionEnergia", // o grabarEmisionEnergia, facturarEmisionEnergia, etc.
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "ok|error",
      "data": [ ... ],
      "message": "..."
    }
  }
  ```

## Stored Procedures
- Toda la lógica de negocio y validación reside en stored procedures PostgreSQL.
- El controlador Laravel solo invoca los SP y retorna el resultado.

## Seguridad
- El usuario debe estar autenticado (no implementado aquí, pero debe obtenerse el ID de usuario para grabar).
- Validaciones de entrada en frontend y backend.

## Componentes Vue.js
- Página independiente, sin tabs.
- Navegación breadcrumb.
- Formulario reactivo.
- Mensajes de error y éxito.
- Tabla de resultados.

## Consideraciones
- El frontend debe manejar los estados de carga, error y éxito.
- El backend debe manejar excepciones y retornar mensajes claros.
- El endpoint es unificado para facilitar la integración y el mantenimiento.

# Estructura de la Base de Datos (Tablas Clave)
- ta_11_mercados
- ta_11_locales
- ta_11_kilowhatts
- ta_11_energia
- ta_11_adeudo_energ
- ta_12_recaudadoras

# Ejemplo de Llamadas API
- Obtener recaudadoras:
  ```json
  { "eRequest": { "action": "getRecaudadoras" } }
  ```
- Obtener mercados:
  ```json
  { "eRequest": { "action": "getMercadosByRecaudadora", "params": { "oficina": 1 } } }
  ```
- Obtener emisión:
  ```json
  { "eRequest": { "action": "getEmisionEnergia", "params": { "oficina": 1, "mercado": 1, "axo": 2024, "periodo": 6 } } }
  ```
- Grabar emisión:
  ```json
  { "eRequest": { "action": "grabarEmisionEnergia", "params": { "oficina": 1, "mercado": 1, "axo": 2024, "periodo": 6, "usuario": 5 } } }
  ```

# Manejo de Errores
- Si la emisión ya existe, el SP retorna status 'error' y un mensaje.
- Si ocurre un error de base de datos, el controlador retorna status 'error' y el mensaje de excepción.

# Pruebas y Validación
- El frontend debe validar que los campos requeridos estén completos antes de enviar la petición.
- El backend valida duplicidad antes de grabar.

# Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden evolucionar sin cambiar el frontend.
