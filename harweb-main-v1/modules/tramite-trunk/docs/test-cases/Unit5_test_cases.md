## Casos de Prueba Unit5 (Transmisión Patrimonial)

### Caso 1: Registro exitoso
- **Entradas:** Todos los campos obligatorios llenos y válidos
- **Acción:** Guardar
- **Esperado:** Registro creado, mensaje de éxito

### Caso 2: Año fuera de rango
- **Entradas:** axoefec=1950
- **Acción:** Guardar
- **Esperado:** Error 'Revise el año...'

### Caso 3: Bimestre fuera de rango
- **Entradas:** bimefec=7
- **Acción:** Guardar
- **Esperado:** Error 'Revise el bimestre...'

### Caso 4: Porcentaje fuera de rango
- **Entradas:** porcbase=150
- **Acción:** Guardar
- **Esperado:** Error 'Revise el porcentaje...'

### Caso 5: Falta notario
- **Entradas:** idnotaria vacío
- **Acción:** Guardar
- **Esperado:** Error 'Especifique un notario...'

### Caso 6: Valor transmisión cero
- **Entradas:** valortransm=0
- **Acción:** Guardar
- **Esperado:** Error 'Especifique el valor de la transmisión...'

### Caso 7: Carga de avaluos externos filtrados
- **Entradas:** axoefec=2022
- **Acción:** Cambiar año de efectos
- **Esperado:** Solo se muestran avaluos externos con axofolio >= 2022

### Caso 8: Carga de valores referenciados
- **Entradas:** cveavaext, axoefec, bimefec válidos
- **Acción:** Cambiar bimestre
- **Esperado:** Se muestra el valor referenciado correspondiente
