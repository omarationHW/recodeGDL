# Condonacion

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Módulo de Condonación de Adeudos

## Descripción General
Este módulo permite la condonación de adeudos de locales comerciales en mercados municipales. Permite buscar un local, listar sus adeudos, condonar uno o varios adeudos (moviéndolos a una tabla de condonados), y deshacer la condonación si es necesario. Todo el flujo está centralizado en un endpoint API único (`/api/execute`) siguiendo el patrón eRequest/eResponse.

## Arquitectura
- **Backend:** Laravel (PHP), PostgreSQL (con stored procedures)
- **Frontend:** Vue.js (SPA, página independiente)
- **API:** Endpoint único `/api/execute` que recibe `{ action, data }` y responde `{ status, data, message }`
- **Seguridad:** Autenticación Laravel (token o session), cada acción requiere usuario autenticado

## Flujo de Trabajo
1. **Búsqueda de Local:**
   - El usuario ingresa los datos del local (oficina, mercado, categoría, sección, local, letra, bloque)
   - Se llama a `buscar_local_condonacion` para validar y obtener el local
2. **Listado de Adeudos:**
   - Se llama a `spd_11_condonacion` para obtener los adeudos vigentes del local
3. **Condonación de Adeudos:**
   - El usuario selecciona uno o varios adeudos y proporciona el número de oficio
   - Por cada adeudo seleccionado, se llama a `condonar_adeudo_local`, que mueve el adeudo a la tabla de condonados y lo elimina de la tabla de adeudos
4. **Listado de Condonados:**
   - Se listan los adeudos condonados actuales del local
5. **Deshacer Condonación:**
   - El usuario puede seleccionar condonaciones y deshacerlas, regresando el adeudo a la tabla de adeudos

## API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `action`: string (buscar_local, listar_adeudos, condonar_adeudos, listar_condonados, deshacer_condonacion)
  - `data`: objeto con los parámetros necesarios para cada acción
- **Salida:**
  - `status`: success|error
  - `data`: datos de respuesta (si aplica)
  - `message`: mensaje de error o éxito

## Stored Procedures
- **buscar_local_condonacion:** Busca local vigente y activo
- **spd_11_condonacion:** Lista adeudos del local
- **condonar_adeudo_local:** Realiza la condonación (mueve de adeudo a condonados)
- **deshacer_condonacion_local:** Revierte la condonación

## Frontend (Vue.js)
- Página independiente `/condonacion`
- Formulario de búsqueda de local
- Tabla de adeudos con selección múltiple
- Campo para número de oficio
- Botón para condonar seleccionados
- Tabla de condonados con opción de deshacer
- Mensajes de error y éxito

## Validaciones
- Todos los campos requeridos deben estar completos
- El número de oficio debe tener formato válido
- No se puede condonar si no hay adeudos seleccionados
- No se puede deshacer si no hay condonados seleccionados

## Seguridad
- Todas las acciones requieren usuario autenticado
- El backend valida permisos y existencia de datos

## Manejo de Errores
- Mensajes claros en frontend y backend
- Rollback de transacciones en caso de error

## Integración
- El frontend se comunica exclusivamente con `/api/execute` usando Axios
- El backend enruta cada acción a la función correspondiente

# Tablas Involucradas
- `ta_11_locales`: Locales comerciales
- `ta_11_adeudo_local`: Adeudos vigentes
- `ta_11_ade_loc_canc`: Adeudos condonados

# Notas
- Todas las operaciones de condonación y reversión son transaccionales
- El historial de condonaciones queda en `ta_11_ade_loc_canc`



## Casos de Uso

# Casos de Uso - Condonacion

**Categoría:** Form

## Caso de Uso 1: Condonar Adeudos de un Local

**Descripción:** El usuario busca un local, selecciona adeudos y los condona con un número de oficio.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de condonación.

**Pasos a seguir:**
- Ingresar los datos del local (oficina, mercado, categoría, sección, local, letra, bloque)
- Presionar 'Buscar'
- Visualizar los datos del local
- Presionar 'Listar Adeudos'
- Seleccionar uno o varios adeudos
- Ingresar el número de oficio
- Presionar 'Condonar Seleccionados'

**Resultado esperado:**
Los adeudos seleccionados desaparecen de la lista de adeudos y aparecen en la lista de condonados.

**Datos de prueba:**
{
  "oficina": 1,
  "num_mercado": 2,
  "categoria": 1,
  "seccion": "SS",
  "local": 1,
  "letra_local": null,
  "bloque": null,
  "oficio": "ABC/2024/001"
}

---

## Caso de Uso 2: Deshacer una Condonación

**Descripción:** El usuario selecciona condonaciones previas y las revierte, regresando los adeudos a la lista de adeudos.

**Precondiciones:**
Debe existir al menos una condonación previa para el local.

**Pasos a seguir:**
- Buscar el local
- Presionar 'Listar Condonados'
- Seleccionar uno o varios condonados
- Presionar 'Deshacer Condonación'

**Resultado esperado:**
Los adeudos seleccionados desaparecen de la lista de condonados y reaparecen en la lista de adeudos.

**Datos de prueba:**
{
  "id_local": 1,
  "condonados": [
    { "id_cancelacion": 10, "id_local": 1, "axo": 2023, "periodo": 5, "importe": 100.00 }
  ]
}

---

## Caso de Uso 3: Validación de Número de Oficio

**Descripción:** El usuario intenta condonar adeudos sin ingresar el número de oficio.

**Precondiciones:**
El usuario debe haber seleccionado al menos un adeudo.

**Pasos a seguir:**
- Buscar el local
- Listar adeudos
- Seleccionar uno o varios adeudos
- Dejar el campo de oficio vacío
- Presionar 'Condonar Seleccionados'

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el número de oficio es obligatorio.

**Datos de prueba:**
{
  "id_local": 1,
  "adeudos": [ { "axo": 2023, "periodo": 5, "importe": 100.00 } ],
  "oficio": ""
}

---



## Casos de Prueba

# Casos de Prueba: Condonación de Adeudos

## Caso 1: Condonar Adeudos Correctamente
- **Entrada:** Datos completos de local, selección de adeudos, número de oficio válido
- **Acción:** Ejecutar acción 'condonar_adeudos'
- **Esperado:** status=success, los adeudos se mueven a condonados

## Caso 2: Deshacer Condonación
- **Entrada:** Selección de condonados existentes
- **Acción:** Ejecutar acción 'deshacer_condonacion'
- **Esperado:** status=success, los adeudos reaparecen en la lista de adeudos

## Caso 3: Validación de Oficio Vacío
- **Entrada:** Selección de adeudos, campo oficio vacío
- **Acción:** Ejecutar acción 'condonar_adeudos'
- **Esperado:** status=error, mensaje 'Debe ingresar el número de oficio válido'

## Caso 4: Buscar Local Inexistente
- **Entrada:** Datos de local que no existe
- **Acción:** Ejecutar acción 'buscar_local'
- **Esperado:** status=error, mensaje 'No existe el local digitado'

## Caso 5: Listar Adeudos sin Local
- **Entrada:** id_local inválido
- **Acción:** Ejecutar acción 'listar_adeudos'
- **Esperado:** status=error, mensaje de validación



