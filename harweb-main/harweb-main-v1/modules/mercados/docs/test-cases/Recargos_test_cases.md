# Casos de Prueba: Módulo Recargos

## 1. Alta de Recargo Válido
- **Entrada:** Año=2024, Mes=7, Porcentaje=2.5, Usuario=1
- **Acción:** POST /api/execute con action=recargos.create
- **Esperado:** Código 200, success=true, recargo aparece en listado

## 2. Alta de Recargo con Mes Inválido
- **Entrada:** Año=2024, Mes=13, Porcentaje=2.5, Usuario=1
- **Acción:** POST /api/execute con action=recargos.create
- **Esperado:** Código 200, success=false, mensaje de error "periodo debe ser entre 1 y 12"

## 3. Modificación de Recargo Existente
- **Entrada:** Año=2024, Mes=7, Porcentaje=3.0, Usuario=1
- **Acción:** POST /api/execute con action=recargos.update
- **Esperado:** Código 200, success=true, porcentaje actualizado

## 4. Eliminación de Recargo Existente
- **Entrada:** Año=2023, Mes=6
- **Acción:** POST /api/execute con action=recargos.delete
- **Esperado:** Código 200, success=true, recargo eliminado

## 5. Consulta de Recargos
- **Acción:** POST /api/execute con action=recargos.list
- **Esperado:** Código 200, success=true, lista de recargos

## 6. Alta de Recargo Duplicado
- **Entrada:** Año=2024, Mes=7, Porcentaje=2.5, Usuario=1 (ya existe)
- **Acción:** POST /api/execute con action=recargos.create
- **Esperado:** Código 200, success=false, mensaje de error de clave duplicada
