# Casos de Prueba FrmEje

## 1. Alta de ejecutor exitoso
- **Entrada:** Todos los campos válidos
- **Acción:** createEjecutor
- **Resultado esperado:** status=ok, ejecutor creado

## 2. Alta de ejecutor con campos faltantes
- **Entrada:** Falta 'paterno'
- **Acción:** createEjecutor
- **Resultado esperado:** status=error, mensaje de validación

## 3. Edición de ejecutor exitoso
- **Entrada:** cveejecutor existente, RFC modificado
- **Acción:** updateEjecutor
- **Resultado esperado:** status=ok, ejecutor actualizado

## 4. Eliminación de ejecutor
- **Entrada:** cveejecutor existente
- **Acción:** deleteEjecutor
- **Resultado esperado:** status=ok, ejecutor dado de baja lógica

## 5. Consulta de ejecutores
- **Entrada:** Sin parámetros
- **Acción:** listEjecutores
- **Resultado esperado:** status=ok, lista de ejecutores

## 6. Reporte filtrado
- **Entrada:** Fechas y recaudadora
- **Acción:** reportEjecutores
- **Resultado esperado:** status=ok, datos del reporte

## 7. Error de base de datos
- **Entrada:** Parám. inválidos
- **Acción:** createEjecutor
- **Resultado esperado:** status=error, mensaje de error SQL
