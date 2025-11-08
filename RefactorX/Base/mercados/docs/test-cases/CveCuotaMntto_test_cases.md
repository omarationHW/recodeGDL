# Casos de Prueba para CveCuotaMntto

## 1. Alta de clave de cuota válida
- **Entrada:** clave_cuota=20, descripcion="CUOTA TEMPORAL"
- **Acción:** create_cve_cuota
- **Resultado esperado:** success=true, mensaje de éxito, la clave aparece en el listado.

## 2. Alta de clave de cuota duplicada
- **Entrada:** clave_cuota=20, descripcion="CUOTA DUPLICADA"
- **Acción:** create_cve_cuota
- **Resultado esperado:** success=false, mensaje de error "La clave de cuota ya existe."

## 3. Edición de clave de cuota existente
- **Entrada:** clave_cuota=20, descripcion="CUOTA ACTUALIZADA"
- **Acción:** update_cve_cuota
- **Resultado esperado:** success=true, mensaje de éxito, descripción actualizada.

## 4. Eliminación de clave de cuota existente
- **Entrada:** clave_cuota=20
- **Acción:** delete_cve_cuota
- **Resultado esperado:** success=true, mensaje de éxito, la clave ya no aparece en el listado.

## 5. Eliminación de clave de cuota inexistente
- **Entrada:** clave_cuota=9999
- **Acción:** delete_cve_cuota
- **Resultado esperado:** success=true (o false si se valida existencia), mensaje de éxito o advertencia.

## 6. Listado de claves de cuota
- **Acción:** list_cve_cuota
- **Resultado esperado:** success=true, data es un array de claves de cuota.

## 7. Validación de campos obligatorios
- **Entrada:** clave_cuota vacío o descripcion vacío
- **Acción:** create_cve_cuota
- **Resultado esperado:** success=false, mensaje de error de validación.
