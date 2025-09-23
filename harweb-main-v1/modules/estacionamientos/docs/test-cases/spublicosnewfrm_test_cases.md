# Casos de Prueba

## Caso 1: Alta exitosa de estacionamiento
- **Entradas:**
  - RFC: GOMC800101XXX
  - Clave predial: 12345678901 (existente)
  - Categoría: 2
  - Cajones: 20
  - Teléfono: 3312345678
  - No. Estacionamiento: 101
- **Pasos:**
  1. Buscar RFC y seleccionar propietario.
  2. Buscar predio y verificar datos.
  3. Completar formulario y dar de alta.
- **Esperado:** Mensaje de éxito, registro creado en pubmain y pubadeudo.

## Caso 2: Clave predial inexistente
- **Entradas:**
  - RFC: GOMC800101XXX
  - Clave predial: 00000000000 (no existe)
- **Pasos:**
  1. Buscar RFC y seleccionar propietario.
  2. Buscar predio.
- **Esperado:** Mensaje de error: 'Cuenta Predial Incorrecta o Cancelada'.

## Caso 3: RFC con menos de 4 caracteres
- **Entradas:**
  - RFC: GOM
- **Pasos:**
  1. Ingresar RFC y presionar buscar.
- **Esperado:** Mensaje: 'Ingrese al menos 4 caracteres para buscar RFC'.

## Caso 4: Falta de categoría
- **Entradas:**
  - Todos los campos correctos excepto categoría vacía
- **Pasos:**
  1. Completar formulario sin seleccionar categoría.
  2. Dar de alta.
- **Esperado:** Mensaje de error: 'Debe seleccionar una categoría'.

## Caso 5: Cajones en cero
- **Entradas:**
  - Cajones: 0
- **Pasos:**
  1. Completar formulario con cajones en 0.
  2. Dar de alta.
- **Esperado:** Mensaje de error: 'Debe indicar el número de cajones'.
