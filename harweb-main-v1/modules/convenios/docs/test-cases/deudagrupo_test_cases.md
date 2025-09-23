## Casos de Prueba para Deuda Grupo

### 1. Consulta exitosa de deuda de grupo
- **Entrada:** { "action": "getDeudaGrupo", "params": { "axo": 2023, "fecha_recargo": "2024-06-01" } }
- **Esperado:** Respuesta JSON con success=true y al menos un registro en data, campos: id_convenio, obra, colonia, calle, folio, nombre, pago_total, fecha_vencimiento, numpagos, pagos, cve_descuento, desc_calle, descripcion, devolucion, recargos, recar_conv, total, deuda.

### 2. Exportación de resultados
- **Entrada:** { "action": "exportDeudaGrupo", "params": { "axo": 2022, "fecha_recargo": "2024-06-01" } }
- **Esperado:** Respuesta JSON con success=true, data.exported=true, y data.data contiene los registros exportados.

### 3. Consulta sin resultados
- **Entrada:** { "action": "getDeudaGrupo", "params": { "axo": 1990, "fecha_recargo": "2024-06-01" } }
- **Esperado:** Respuesta JSON con success=true, data es un array vacío.

### 4. Consulta con parámetros inválidos
- **Entrada:** { "action": "getDeudaGrupo", "params": { "axo": "abc", "fecha_recargo": "not-a-date" } }
- **Esperado:** Respuesta JSON con success=false, message indica error de parámetros.

### 5. Exportación con error de backend
- **Simulación:** Forzar error en el método exportDeudaGrupo (por ejemplo, excepción en generación de archivo).
- **Esperado:** Respuesta JSON con success=false, message indica error interno.
