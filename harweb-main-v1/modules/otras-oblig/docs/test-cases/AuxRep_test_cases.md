## Casos de Prueba AuxRep

### Caso 1: Consulta General
- **Entrada:** { "par_tabla": 3, "par_vigencia": "TODOS" }
- **Acción:** getPadron
- **Esperado:** Lista completa de concesionarios de la tabla 3.

### Caso 2: Consulta por Vigencia
- **Entrada:** { "par_tabla": 3, "par_vigencia": "VIGENTE" }
- **Acción:** getPadron
- **Esperado:** Solo concesionarios con vigencia 'VIGENTE'.

### Caso 3: Exportación CSV
- **Entrada:** { "par_tabla": 3, "par_vigencia": "TODOS" }
- **Acción:** printPadron
- **Esperado:** Descarga de archivo CSV con los datos del padrón.

### Caso 4: Error por tabla inexistente
- **Entrada:** { "par_tabla": 999, "par_vigencia": "TODOS" }
- **Acción:** getPadron
- **Esperado:** Respuesta vacía o error controlado.

### Caso 5: Error por vigencia inválida
- **Entrada:** { "par_tabla": 3, "par_vigencia": "NO_EXISTE" }
- **Acción:** getPadron
- **Esperado:** Respuesta vacía.

### Caso 6: Consulta de etiquetas
- **Entrada:** { "par_tab": 3 }
- **Acción:** getEtiquetas
- **Esperado:** Devuelve objeto con etiquetas de la tabla 3.

### Caso 7: Consulta de vigencias
- **Entrada:** { "par_tab": 3 }
- **Acción:** getVigencias
- **Esperado:** Devuelve lista de vigencias disponibles para la tabla 3.
