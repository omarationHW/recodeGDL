# DocumentaciÃ³n TÃ©cnica: Contratos_Upd_Und

## AnÃ¡lisis TÃ©cnico

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


## Casos de Prueba

## Casos de Prueba para Contratos_Upd_Und

### 1. Actualización exitosa
- **Entrada**: Contrato vigente, cantidad válida (>0), documento válido.
- **Acción**: Ejecutar acción 'actualizar_unidades' con datos correctos.
- **Esperado**: Respuesta success=true, message='Actualización exitosa.'

### 2. Contrato no existe o no vigente
- **Entrada**: Contrato inexistente o cancelado.
- **Acción**: Ejecutar acción 'buscar_contrato' con número inválido.
- **Esperado**: Respuesta success=false, message='No existe contrato vigente con esos datos.'

### 3. Cantidad inválida
- **Entrada**: cantidad=0
- **Acción**: Ejecutar acción 'actualizar_unidades' con cantidad=0
- **Esperado**: Respuesta success=false, message='Cantidad inválida.'

### 4. Documento vacío
- **Entrada**: documento=''
- **Acción**: Ejecutar acción 'actualizar_unidades' sin documento
- **Esperado**: Respuesta success=false, message='Documento requerido.'

### 5. Ejercicio sin costo de unidad
- **Entrada**: ejercicio sin registro en ta_16_unidades
- **Acción**: Ejecutar acción 'actualizar_unidades' con ejercicio inexistente
- **Esperado**: Respuesta success=false, message='No existe costo de unidad para el ejercicio actual.'

### 6. Catálogo de tipos de aseo
- **Entrada**: acción 'catalogo_tipo_aseo'
- **Esperado**: Lista de tipos de aseo

### 7. Catálogo de unidades
- **Entrada**: acción 'catalogo_unidades', ejercicio=2024
- **Esperado**: Lista de unidades para el ejercicio 2024


## Casos de Uso

# Casos de Uso - Contratos_Upd_Und

**Categoría:** Form

## Caso de Uso 1: Actualización exitosa de unidades de recolección

**Descripción:** El usuario busca un contrato vigente y actualiza la cantidad de unidades de recolección, registrando el cambio con documentación.

**Precondiciones:**
El contrato existe y está vigente. El usuario está autenticado.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. El sistema muestra los datos del contrato.
3. El usuario selecciona la nueva unidad de recolección y cantidad.
4. El usuario ingresa el ejercicio, mes, documento y descripción.
5. El usuario confirma la actualización.
6. El sistema actualiza el contrato, los pagos y guarda el histórico.

**Resultado esperado:**
El contrato se actualiza correctamente, los pagos futuros reflejan la nueva cantidad y el movimiento queda registrado en el histórico.

**Datos de prueba:**
{
  "num_contrato": 1803,
  "ctrol_aseo": 8,
  "ctrol_recolec": 5,
  "cantidad": 4,
  "ejercicio": 2024,
  "mes": 7,
  "documento": "DR/2024/001",
  "descripcion": "Cambio por ampliación de servicio"
}

---

## Caso de Uso 2: Intento de actualización con cantidad inválida

**Descripción:** El usuario intenta actualizar el contrato con una cantidad de unidades igual a cero.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. El usuario ingresa cantidad igual a 0.
3. El usuario intenta confirmar la actualización.

**Resultado esperado:**
El sistema rechaza la operación y muestra un mensaje de error indicando que la cantidad es inválida.

**Datos de prueba:**
{
  "num_contrato": 1803,
  "ctrol_aseo": 8,
  "ctrol_recolec": 5,
  "cantidad": 0,
  "ejercicio": 2024,
  "mes": 7,
  "documento": "DR/2024/002",
  "descripcion": "Prueba cantidad cero"
}

---

## Caso de Uso 3: Intento de actualización sin documento

**Descripción:** El usuario intenta actualizar el contrato sin ingresar el documento probatorio.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. El usuario ingresa todos los datos excepto el documento.
3. El usuario intenta confirmar la actualización.

**Resultado esperado:**
El sistema rechaza la operación y muestra un mensaje de error indicando que el documento es requerido.

**Datos de prueba:**
{
  "num_contrato": 1803,
  "ctrol_aseo": 8,
  "ctrol_recolec": 5,
  "cantidad": 3,
  "ejercicio": 2024,
  "mes": 7,
  "documento": "",
  "descripcion": "Sin documento"
}

---



---
**Componente:** `Contratos_Upd_Und.vue`
**MÃ³dulo:** `aseo_contratado`

