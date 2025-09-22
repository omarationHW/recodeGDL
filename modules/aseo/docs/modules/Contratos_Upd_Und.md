# Documentación Técnica: Actualización de Unidades de Recolección (Contratos_Upd_Und)

## Descripción General
Este módulo permite la actualización de la cantidad y tipo de unidades de recolección asociadas a un contrato vigente. Incluye la consulta de contratos, la visualización de datos relacionados y la actualización de unidades, ajustando los pagos correspondientes y registrando el movimiento en el histórico.

## Arquitectura
- **Backend**: Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js SPA (Single Page Application), página independiente
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures
- **Patrón API**: eRequest/eResponse (acción + parámetros)

## Flujo de Trabajo
1. **Consulta de Contrato**: El usuario ingresa el número de contrato y tipo de aseo. El sistema consulta el contrato vigente y muestra los datos.
2. **Selección de Nueva Unidad y Cantidad**: El usuario selecciona la nueva unidad de recolección y la cantidad, así como el periodo de inicio del cambio.
3. **Documentación**: El usuario debe ingresar el documento y descripción que avalan el cambio.
4. **Actualización**: Al confirmar, el sistema ejecuta el stored procedure que:
   - Actualiza el contrato
   - Actualiza los pagos futuros
   - Inserta registro en el histórico

## API (Laravel Controller)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "buscar_contrato",
    "params": {
      "num_contrato": 1234,
      "ctrol_aseo": 8,
      "ejercicio": 2024
    }
  }
  ```
  ```json
  {
    "action": "actualizar_unidades",
    "params": {
      "control_contrato": 123,
      "ctrol_recolec": 5,
      "cantidad": 3,
      "ejercicio": 2024,
      "mes": 6,
      "documento": "DR/2024/001",
      "descripcion": "Cambio por ampliación de servicio"
    }
  }
  ```
- **Respuesta**: JSON con `success`, `message`, y datos relevantes.

## Stored Procedures
- **buscar_contrato_upd_und**: Devuelve los datos completos del contrato vigente.
- **catalogo_tipo_aseo**: Catálogo de tipos de aseo.
- **catalogo_unidades**: Catálogo de unidades de recolección para un ejercicio.
- **actualizar_unidades_contrato**: Realiza la actualización de unidades, pagos y guarda histórico.

## Validaciones
- El contrato debe estar vigente.
- La cantidad debe ser mayor a cero.
- El documento debe tener al menos 3 caracteres.
- El usuario debe estar autenticado para registrar el cambio.

## Seguridad
- El endpoint requiere autenticación (token JWT o sesión Laravel).
- El usuario que realiza el cambio queda registrado en el histórico.

## Manejo de Errores
- Todos los errores se devuelven en el campo `message` del JSON de respuesta.
- Los stored procedures devuelven un código de estado y leyenda para interpretación por el frontend.

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario de búsqueda y formulario de actualización.
- Mensajes de éxito/error claros.
- Navegación breadcrumb.

## Integración
- El frontend consume el endpoint `/api/execute` para todas las acciones.
- El backend delega la lógica a los stored procedures.

# Casos de Uso
