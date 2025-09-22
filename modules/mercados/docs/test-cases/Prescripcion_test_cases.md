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
