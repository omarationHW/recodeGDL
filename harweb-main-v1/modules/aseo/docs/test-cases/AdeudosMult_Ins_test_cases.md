## Casos de Prueba para AdeudosMult_Ins

### Caso 1: Carga exitosa de excedentes
- **Input:**
  - tipoAseo: 9
  - tipoOper: 7
  - anio: 2024
  - mes: '06'
  - oficio: 'OF-1234'
  - rows: [{contrato: 12345, excedencia: 2}, {contrato: 23456, excedencia: 1}]
- **Acción:** Validar y grabar
- **Esperado:** Respuesta success true, mensaje de éxito

### Caso 2: Contrato inexistente
- **Input:**
  - tipoAseo: 9
  - tipoOper: 7
  - anio: 2024
  - mes: '06'
  - oficio: 'OF-1234'
  - rows: [{contrato: 99999, excedencia: 1}]
- **Acción:** Validar
- **Esperado:** Error en la fila: "Contrato 99999 no existe o no corresponde al tipo de aseo"

### Caso 3: Excedente duplicado
- **Input:**
  - tipoAseo: 9
  - tipoOper: 7
  - anio: 2024
  - mes: '06'
  - oficio: 'OF-1234'
  - rows: [{contrato: 12345, excedencia: 1}] (ya existe ese excedente)
- **Acción:** Validar
- **Esperado:** Error en la fila: "Contrato 12345: Ya existe excedente para el periodo"

### Caso 4: Falta de cuota normal
- **Input:**
  - tipoAseo: 9
  - tipoOper: 7
  - anio: 2024
  - mes: '06'
  - oficio: 'OF-1234'
  - rows: [{contrato: 12345, excedencia: 1}] (no existe cuota normal para ese periodo)
- **Acción:** Validar
- **Esperado:** Error en la fila: "Contrato 12345: No existe cuota normal para el periodo"

### Caso 5: Excedencia no numérica
- **Input:**
  - tipoAseo: 9
  - tipoOper: 7
  - anio: 2024
  - mes: '06'
  - oficio: 'OF-1234'
  - rows: [{contrato: 12345, excedencia: 'abc'}]
- **Acción:** Validar
- **Esperado:** Error en la fila: "Contrato y Excedencia deben ser numéricos"
