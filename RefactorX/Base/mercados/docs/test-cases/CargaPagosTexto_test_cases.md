# Casos de Prueba: Carga de Pagos Texto

## Caso 1: Importación Exitosa
- **Precondición:** Archivo de texto válido con 3 pagos, ninguno duplicado.
- **Pasos:**
  1. Cargar archivo.
  2. Previsualizar pagos.
  3. Confirmar importación.
- **Esperado:** 3 pagos grabados, 0 ya grabados, 3 adeudos borrados, importe total correcto.

## Caso 2: Pagos Duplicados
- **Precondición:** Archivo de texto con 2 pagos ya existentes y 1 nuevo.
- **Pasos:**
  1. Cargar archivo.
  2. Previsualizar pagos.
  3. Confirmar importación.
- **Esperado:** 1 pago grabado, 2 ya grabados, 1 adeudo borrado, importe total suma solo el nuevo pago.

## Caso 3: Error de Formato en Archivo
- **Precondición:** Archivo de texto con líneas incompletas o campos no numéricos.
- **Pasos:**
  1. Cargar archivo.
  2. Intentar previsualizar.
- **Esperado:** El sistema muestra error de formato y no permite continuar.

## Caso 4: Archivo Vacío
- **Precondición:** Archivo de texto vacío.
- **Pasos:**
  1. Cargar archivo.
  2. Intentar previsualizar.
- **Esperado:** El sistema indica que no hay pagos para importar.

## Caso 5: Importación Parcial (algunos pagos con error)
- **Precondición:** Archivo de texto con 2 pagos válidos y 1 línea malformada.
- **Pasos:**
  1. Cargar archivo.
  2. Previsualizar (debe mostrar solo los válidos).
  3. Confirmar importación.
- **Esperado:** Solo los pagos válidos se importan, el resumen indica cuántos fueron procesados.
