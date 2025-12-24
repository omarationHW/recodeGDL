# DocumentaciÃ³n TÃ©cnica: DatosConvenio

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario DatosConvenio (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo corresponde a la migración del formulario "DatosConvenio" de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original, presentando los datos generales de un convenio y sus parcialidades, con acceso unificado vía API REST.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3+, componente de página independiente.
- **Base de Datos:** PostgreSQL, lógica de consulta encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": "getDatosConvenio", // o "getParcialidadesConvenio", "getPagoParcialidad"
    "params": { "control": 123, "parcial": 1 }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
- Toda la lógica SQL se encapsula en funciones PostgreSQL:
  - `sp_get_datos_convenio(p_id_conv_resto INTEGER)`
  - `sp_get_parcialidades_convenio(p_id_conv_resto INTEGER)`
  - `sp_get_pago_parcialidad(p_id_conv_resto INTEGER, p_parcial INTEGER)`

## 5. Controlador Laravel
- El controlador `ExecuteController` recibe el `eRequest` y los parámetros, despacha la llamada al stored procedure correspondiente y retorna el resultado en el formato estándar.
- Maneja errores y validaciones de parámetros.

## 6. Componente Vue.js
- Página independiente, recibe `convenio` y `control` como props (por ejemplo, desde la ruta).
- Al montar, consulta datos generales y parcialidades vía `/api/execute`.
- Presenta los datos en formularios y tablas de solo lectura, siguiendo el layout original.
- Incluye navegación breadcrumb y botón de salida.

## 7. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar.
- Validar y sanear todos los parámetros recibidos.

## 8. Pruebas
- Casos de uso y pruebas detalladas incluidas para asegurar la funcionalidad y robustez del módulo.

## 9. Consideraciones de Migración
- Los nombres de campos y lógica de negocio se mantienen fieles al original Delphi.
- El layout visual se adapta a Bootstrap para una experiencia moderna y responsiva.
- El endpoint es extensible para futuras funcionalidades.

## 10. Ejemplo de Uso
- Para obtener los datos generales de un convenio:
  ```json
  {
    "eRequest": "getDatosConvenio",
    "params": { "control": 123 }
  }
  ```
- Para obtener las parcialidades:
  ```json
  {
    "eRequest": "getParcialidadesConvenio",
    "params": { "control": 123 }
  }
  ```

## 11. Extensibilidad
- Se pueden agregar nuevos eRequest fácilmente en el controlador y nuevos stored procedures en PostgreSQL.


## Casos de Prueba

# Casos de Prueba para DatosConvenio

## Caso 1: Consulta exitosa de datos generales
- **Entrada:**
  - eRequest: getDatosConvenio
  - params: { control: 123 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene los campos: nombre, calle, num_exterior, etc.

## Caso 2: Consulta exitosa de parcialidades
- **Entrada:**
  - eRequest: getParcialidadesConvenio
  - params: { control: 123 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un array con al menos un objeto con campos: parcial, impuesto_adeudo, periodos, etc.

## Caso 3: Consulta de pago de parcialidad existente
- **Entrada:**
  - eRequest: getPagoParcialidad
  - params: { control: 123, parcial: 2 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene los campos: id_conv_resto, pago_parcial, fecha_pago, etc.

## Caso 4: Consulta con control inexistente
- **Entrada:**
  - eRequest: getDatosConvenio
  - params: { control: 999999 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un array vacío

## Caso 5: Consulta con parámetros faltantes
- **Entrada:**
  - eRequest: getPagoParcialidad
  - params: { control: 123 }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message indica parámetros requeridos

## Caso 6: eRequest no soportado
- **Entrada:**
  - eRequest: getSomethingElse
  - params: {}
- **Esperado:**
  - eResponse.success = false
  - eResponse.message = 'eRequest no soportado'


## Casos de Uso

# Casos de Uso - DatosConvenio

**Categoría:** Form

## Caso de Uso 1: Visualización de datos generales de un convenio existente

**Descripción:** El usuario accede a la página de DatosConvenio para consultar la información general de un convenio específico.

**Precondiciones:**
El convenio con el identificador (control) existe en la base de datos y el usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario navega a la ruta de la página DatosConvenio con el parámetro 'control' correspondiente.
2. El frontend envía una petición POST a /api/execute con eRequest='getDatosConvenio' y el parámetro control.
3. El backend ejecuta el stored procedure y retorna los datos generales.
4. El frontend muestra los datos en el formulario de solo lectura.

**Resultado esperado:**
Se muestran correctamente todos los campos generales del convenio, incluyendo nombre, dirección, periodos, fechas y montos.

**Datos de prueba:**
{ "control": 123 }

---

## Caso de Uso 2: Consulta de parcialidades de un convenio

**Descripción:** El usuario revisa la tabla de parcialidades (adeudos parciales) asociadas a un convenio.

**Precondiciones:**
El convenio existe y tiene al menos una parcialidad registrada.

**Pasos a seguir:**
1. El usuario accede a la página DatosConvenio.
2. El frontend envía una petición POST a /api/execute con eRequest='getParcialidadesConvenio' y el parámetro control.
3. El backend ejecuta el stored procedure y retorna la lista de parcialidades.
4. El frontend muestra la tabla con las parcialidades y sus datos de pago.

**Resultado esperado:**
La tabla de parcialidades se muestra con todos los registros y columnas requeridas.

**Datos de prueba:**
{ "control": 123 }

---

## Caso de Uso 3: Consulta de pago de una parcialidad específica

**Descripción:** El usuario desea consultar el registro de pago de una parcialidad específica de un convenio.

**Precondiciones:**
El convenio y la parcialidad existen y tienen un pago registrado.

**Pasos a seguir:**
1. El usuario selecciona una parcialidad (por ejemplo, desde la tabla).
2. El frontend envía una petición POST a /api/execute con eRequest='getPagoParcialidad', control y parcial.
3. El backend ejecuta el stored procedure y retorna el registro de pago.
4. El frontend muestra los detalles del pago.

**Resultado esperado:**
Se muestran los datos del pago de la parcialidad seleccionada.

**Datos de prueba:**
{ "control": 123, "parcial": 2 }

---



---
**Componente:** `DatosConvenio.vue`
**MÃ³dulo:** `aseo_contratado`

