## Casos de Prueba para Reactiva_Folios

### Caso 1: Reactivación exitosa por Placa y Folio
- **Entrada:**
  - opcion: 0
  - placa: 'ABC1234'
  - folio: 1001
- **Precondición:** Existe el registro en ta14_folios_histo.
- **Acción:** Ejecutar proceso de reactivación.
- **Esperado:**
  - Mensaje de éxito.
  - Registro migrado a ta14_folios_adeudo.
  - Eliminado de ta14_folios_histo y ta14_condonado.

### Caso 2: Reactivación fallida por Año y Folio inexistente
- **Entrada:**
  - opcion: 1
  - axo: 2022
  - folio: 9999
- **Precondición:** No existe el registro en ta14_folios_histo.
- **Acción:** Ejecutar proceso de reactivación.
- **Esperado:**
  - Mensaje de error 'No existe registro como adeudo'.
  - No hay cambios en la base de datos.

### Caso 3: Error de base de datos (duplicado en adeudo)
- **Entrada:**
  - opcion: 0
  - placa: 'XYZ9999'
  - folio: 2002
- **Precondición:** El registro ya existe en ta14_folios_adeudo.
- **Acción:** Ejecutar proceso de reactivación.
- **Esperado:**
  - Mensaje de error 'Error al grabar EN ADEUDO y borrar HISTÓRICO: ...'.
  - No se elimina el registro de ta14_folios_histo ni ta14_condonado.

### Caso 4: Validación de campos obligatorios en frontend
- **Entrada:**
  - opcion: 0
  - placa: ''
  - folio: ''
- **Acción:** Presionar 'APLICA'.
- **Esperado:**
  - Mensaje de error en frontend: 'La Placa y Folio son obligatorios'.

### Caso 5: Validación de campos obligatorios en frontend (Año y Folio)
- **Entrada:**
  - opcion: 1
  - axo: ''
  - folio: ''
- **Acción:** Presionar 'APLICA'.
- **Esperado:**
  - Mensaje de error en frontend: 'El Año y Folio son obligatorios'.
