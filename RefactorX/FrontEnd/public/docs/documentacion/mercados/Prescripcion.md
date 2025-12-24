# Prescripcion

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Prescripción de Adeudos de Energía Eléctrica

## Descripción General
Este módulo permite la prescripción o condonación de adeudos de energía eléctrica asociados a locales de mercados. El proceso consiste en mover los adeudos seleccionados de la tabla de adeudos activos (`ta_11_adeudo_energ`) a la tabla de prescripciones/condonaciones (`ta_11_ade_ene_canc`), y viceversa.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js de página completa, sin tabs.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "nombre_accion",
      "data": { ... },
      "user": { "id": 1 }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "success|error",
      "data": { ... },
      "message": "..."
    }
  }
  ```

### Acciones soportadas
- `buscar_local`: Busca un local y su id_energia.
- `listar_adeudos`: Lista adeudos activos de energía eléctrica.
- `listar_prescripcion`: Lista adeudos prescritos/condonados.
- `prescribir_adeudos`: Prescribe/condona los adeudos seleccionados.
- `quitar_prescripcion`: Quita la prescripción y restaura el adeudo.
- `catalogo_mercados`: Catálogo de mercados con energía eléctrica.
- `catalogo_secciones`: Catálogo de secciones.

## Stored Procedures
- **sp_prescribir_adeudo**: Inserta en `ta_11_ade_ene_canc` y elimina de `ta_11_adeudo_energ`.
- **sp_quitar_prescripcion**: Inserta en `ta_11_adeudo_energ` y elimina de `ta_11_ade_ene_canc`.

## Flujo de la Página Vue.js
1. Selección de mercado, sección, local, letra, bloque y tipo de movimiento.
2. Búsqueda del local y carga de adeudos y prescripciones.
3. Selección de adeudos a prescribir/condonar, captura de número de oficio.
4. Ejecución de prescripción (llamada a stored procedure por cada adeudo).
5. Visualización y posible reversión de prescripciones.

## Validaciones
- El número de oficio es obligatorio para prescribir/condonar.
- No se puede prescribir/condonar sin seleccionar al menos un adeudo.
- Solo se pueden quitar prescripciones seleccionando al menos una.

## Seguridad
- Todas las operaciones requieren usuario autenticado (user.id en eRequest).
- Las operaciones de prescripción y reversión quedan auditadas por usuario y fecha.

## Errores comunes
- Local no encontrado o dado de baja.
- Adeudo ya prescrito/condonado.
- Error de concurrencia en la base de datos.

## Integración
- El frontend Vue.js consume el endpoint `/api/execute` con la acción y los datos necesarios.
- El backend ejecuta el stored procedure correspondiente y retorna el resultado en eResponse.

## Ejemplo de llamada para prescribir adeudos
```json
{
  "eRequest": {
    "action": "prescribir_adeudos",
    "data": {
      "id_energia": 123,
      "adeudos": [
        { "id_energia": 123, "axo": 2023, "periodo": 5, "cve_consumo": "F", "cantidad": 100, "importe": 500.00 },
        ...
      ],
      "oficio": "ABC/2023/0001",
      "movimiento": "Prescripcion"
    },
    "user": { "id": 1 }
  }
}
```

## Ejemplo de llamada para quitar prescripción
```json
{
  "eRequest": {
    "action": "quitar_prescripcion",
    "data": {
      "id_energia": 123,
      "prescripciones": [
        { "id_cancelacion": 456, "id_energia": 123, "axo": 2023, "periodo": 5, "cve_consumo": "F", "cantidad": 100, "importe": 500.00 }
      ]
    },
    "user": { "id": 1 }
  }
}
```


## Casos de Uso

# Casos de Uso - Prescripcion

**Categoría:** Form

## Caso de Uso 1: Prescribir adeudos de energía eléctrica a un local

**Descripción:** El usuario selecciona un local con adeudos de energía eléctrica y realiza la prescripción de uno o varios adeudos, registrando el número de oficio.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos. El local debe tener adeudos activos.

**Pasos a seguir:**
1. El usuario accede a la página de Prescripción.
2. Selecciona el mercado, sección, local, letra y bloque.
3. Selecciona el tipo de movimiento (Prescripción).
4. Da clic en 'Buscar'.
5. Visualiza los adeudos activos.
6. Selecciona uno o varios adeudos a prescribir.
7. Captura el número de oficio.
8. Da clic en 'Prescribir'.

**Resultado esperado:**
Los adeudos seleccionados desaparecen de la lista de adeudos activos y aparecen en la lista de prescripciones. Se muestra mensaje de éxito.

**Datos de prueba:**
Mercado: 1-2-1-SS, Local: 10, Movimiento: Prescripción, Oficio: ABC/2024/0001

---

## Caso de Uso 2: Quitar prescripción y restaurar adeudo

**Descripción:** El usuario selecciona una prescripción existente y la revierte, restaurando el adeudo original.

**Precondiciones:**
Debe existir al menos una prescripción para el local.

**Pasos a seguir:**
1. El usuario accede a la página de Prescripción.
2. Busca el local correspondiente.
3. Visualiza la lista de prescripciones.
4. Selecciona una o varias prescripciones.
5. Da clic en 'Quitar'.

**Resultado esperado:**
Las prescripciones seleccionadas desaparecen de la lista y los adeudos reaparecen en la lista de adeudos activos.

**Datos de prueba:**
Prescripción con id_cancelacion: 456, Local: 10

---

## Caso de Uso 3: Validación de oficio obligatorio

**Descripción:** El usuario intenta prescribir adeudos sin capturar el número de oficio.

**Precondiciones:**
El usuario debe estar autenticado y haber seleccionado al menos un adeudo.

**Pasos a seguir:**
1. El usuario accede a la página de Prescripción.
2. Busca un local con adeudos.
3. Selecciona uno o varios adeudos.
4. Deja el campo de oficio vacío.
5. Da clic en 'Prescribir'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el número de oficio es obligatorio y no realiza ninguna operación.

**Datos de prueba:**
Mercado: 1-2-1-SS, Local: 10, Movimiento: Prescripción, Oficio: (vacío)

---



## Casos de Prueba

# Casos de Prueba: Prescripción de Adeudos

## Caso 1: Prescribir adeudos exitosamente
- **Precondición:** Local con adeudos activos.
- **Pasos:**
  1. Buscar local.
  2. Seleccionar adeudos.
  3. Capturar oficio.
  4. Prescribir.
- **Esperado:** Adeudos movidos a prescripción, mensaje de éxito.

## Caso 2: Quitar prescripción
- **Precondición:** Local con prescripciones existentes.
- **Pasos:**
  1. Buscar local.
  2. Seleccionar prescripción.
  3. Quitar.
- **Esperado:** Prescripción eliminada, adeudo restaurado.

## Caso 3: Validación de oficio obligatorio
- **Precondición:** Local con adeudos activos.
- **Pasos:**
  1. Buscar local.
  2. Seleccionar adeudos.
  3. Dejar oficio vacío.
  4. Prescribir.
- **Esperado:** Mensaje de error, no se realiza operación.

## Caso 4: Intentar prescribir sin seleccionar adeudos
- **Precondición:** Local con adeudos activos.
- **Pasos:**
  1. Buscar local.
  2. No seleccionar ningún adeudo.
  3. Capturar oficio.
  4. Prescribir.
- **Esperado:** Mensaje de error, no se realiza operación.

## Caso 5: Buscar local inexistente
- **Precondición:** Local no existe o está dado de baja.
- **Pasos:**
  1. Ingresar datos de local inexistente.
  2. Buscar.
- **Esperado:** Mensaje de error indicando que el local no existe.



