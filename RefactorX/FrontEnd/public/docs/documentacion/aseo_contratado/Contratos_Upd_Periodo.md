# DocumentaciÃ³n TÃ©cnica: Contratos_Upd_Periodo

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Actualización de Periodo de Inicio de Obligación (Contratos)

## Descripción General
Este módulo permite consultar y actualizar el periodo de inicio de obligación de un contrato de recolección de residuos. Incluye:
- Consulta de contrato por número y tipo de aseo
- Visualización de datos relevantes del contrato
- Actualización del periodo de inicio de obligación (año y mes)
- Registro de documento y descripción justificativa en el histórico

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js como página independiente
- **Base de Datos:** PostgreSQL con stored procedures para lógica de negocio
- **API:** Todas las operaciones se realizan vía POST a `/api/execute` con parámetros `action` y `params`

## Flujo de Trabajo
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. El sistema consulta el contrato y muestra los datos.
3. El usuario ingresa el nuevo año, mes, documento y descripción.
4. El sistema valida y ejecuta la actualización vía stored procedure.
5. El resultado (éxito o error) se muestra al usuario.

## Seguridad
- El endpoint requiere autenticación (Laravel middleware `auth` recomendado).
- El usuario autenticado se utiliza para registrar el movimiento.
- Validaciones de parámetros en backend y frontend.

## Validaciones
- El documento es obligatorio y debe tener longitud mínima.
- El año y mes deben ser válidos.
- No se permite actualizar al mismo periodo actual.
- El contrato debe existir.

## API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Ejemplo para buscar contrato:**
  ```json
  {
    "action": "buscarContrato",
    "params": {
      "num_contrato": 1234,
      "ctrol_aseo": 8
    }
  }
  ```
- **Ejemplo para actualizar periodo:**
  ```json
  {
    "action": "actualizarPeriodoObligacion",
    "params": {
      "control_contrato": 5678,
      "anio": 2024,
      "mes": "03",
      "documento": "DR/14/2024",
      "descripcion": "Cambio por resolución administrativa"
    }
  }
  ```

## Stored Procedures
- **sp_contratos_buscar:** Devuelve todos los datos relevantes del contrato.
- **sp_contratos_actualizar_periodo_obligacion:** Realiza la actualización y registra en histórico.

## Manejo de Errores
- Todos los errores se devuelven en el campo `message` del JSON de respuesta.
- El campo `status` indica el código de resultado (0 = éxito, >0 = error).

## Consideraciones de Integración
- El frontend debe mostrar mensajes claros según el resultado de la operación.
- El backend debe registrar todos los movimientos en el histórico.
- El endpoint es extensible para otras acciones del sistema.


## Casos de Prueba

# Casos de Prueba: Actualización de Periodo de Inicio de Obligación

## Caso 1: Consulta de Contrato Existente
- **Entrada:** num_contrato=1803, ctrol_aseo=8
- **Acción:** buscarContrato
- **Esperado:** Devuelve datos completos del contrato, incluyendo aso_mes_oblig

## Caso 2: Actualización Exitosa
- **Entrada:** control_contrato=5678, anio=2024, mes="03", documento="DR/14/2024", descripcion="Cambio por resolución administrativa"
- **Acción:** actualizarPeriodoObligacion
- **Esperado:** status=0, message indica éxito, periodo actualizado en base de datos y registro en histórico

## Caso 3: Actualización con Mismo Periodo
- **Entrada:** control_contrato=5678, anio=2023, mes="01", documento="DR/14/2023", descripcion="Intento sin cambio"
- **Acción:** actualizarPeriodoObligacion
- **Esperado:** status=3, message indica que el periodo es igual al actual, no hay cambios

## Caso 4: Faltan Parámetros
- **Entrada:** control_contrato=5678, anio=2024, mes="03", documento="", descripcion=""
- **Acción:** actualizarPeriodoObligacion
- **Esperado:** status=1, message indica falta de documento

## Caso 5: Contrato No Existe
- **Entrada:** num_contrato=999999, ctrol_aseo=8
- **Acción:** buscarContrato
- **Esperado:** success=false, message indica que no existe contrato


## Casos de Uso

# Casos de Uso - Contratos_Upd_Periodo

**Categoría:** Form

## Caso de Uso 1: Consulta de Contrato para Actualización de Periodo

**Descripción:** El usuario consulta un contrato existente para visualizar su periodo de inicio de obligación actual.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta. El contrato existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de actualización de periodo de obligación.
2. Ingresa el número de contrato y selecciona el tipo de aseo.
3. Presiona el botón 'Buscar'.
4. El sistema muestra los datos del contrato, incluyendo el periodo de inicio de obligación.

**Resultado esperado:**
Se muestran correctamente los datos del contrato y el periodo de inicio de obligación actual.

**Datos de prueba:**
{ "num_contrato": 1803, "ctrol_aseo": 8 }

---

## Caso de Uso 2: Actualización Exitosa del Periodo de Inicio de Obligación

**Descripción:** El usuario actualiza el periodo de inicio de obligación de un contrato, registrando el documento y la descripción justificativa.

**Precondiciones:**
El usuario está autenticado y tiene permisos de actualización. El contrato existe y el nuevo periodo es diferente al actual.

**Pasos a seguir:**
1. El usuario consulta el contrato como en el caso anterior.
2. Ingresa el nuevo año y mes, el documento y la descripción.
3. Presiona el botón 'Actualizar Periodo'.
4. El sistema valida los datos y ejecuta la actualización.
5. El sistema muestra un mensaje de éxito.

**Resultado esperado:**
El periodo de inicio de obligación se actualiza correctamente y se registra en el histórico.

**Datos de prueba:**
{ "control_contrato": 5678, "anio": 2024, "mes": "03", "documento": "DR/14/2024", "descripcion": "Cambio por resolución administrativa" }

---

## Caso de Uso 3: Intento de Actualización con el Mismo Periodo

**Descripción:** El usuario intenta actualizar el periodo de inicio de obligación al mismo periodo actual.

**Precondiciones:**
El usuario está autenticado. El contrato existe y el periodo ingresado es igual al actual.

**Pasos a seguir:**
1. El usuario consulta el contrato.
2. Ingresa el mismo año y mes que el periodo actual.
3. Ingresa documento y descripción.
4. Presiona 'Actualizar Periodo'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el periodo es igual al actual y no realiza cambios.

**Datos de prueba:**
{ "control_contrato": 5678, "anio": 2023, "mes": "01", "documento": "DR/14/2023", "descripcion": "Intento sin cambio" }

---



---
**Componente:** `Contratos_Upd_Periodo.vue`
**MÃ³dulo:** `aseo_contratado`

