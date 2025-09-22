# Casos de Prueba para CuotasMdo

## 1. Alta de cuota válida
- **Entrada:** Todos los campos requeridos completos y válidos.
- **Acción:** Enviar acción `create_cuota`.
- **Esperado:** Respuesta `success: true`, la cuota aparece en el listado.

## 2. Alta de cuota con importe cero
- **Entrada:** Importe = 0
- **Acción:** Enviar acción `create_cuota`.
- **Esperado:** Respuesta `success: false`, mensaje de error de validación.

## 3. Edición de cuota existente
- **Entrada:** Modificar importe de cuota existente.
- **Acción:** Enviar acción `update_cuota`.
- **Esperado:** Respuesta `success: true`, importe actualizado en el listado.

## 4. Eliminación de cuota
- **Entrada:** ID de cuota existente.
- **Acción:** Enviar acción `delete_cuota`.
- **Esperado:** Respuesta `success: true`, cuota ya no aparece en el listado.

## 5. Listado de cuotas por año
- **Entrada:** Año específico.
- **Acción:** Enviar acción `list_cuotas`.
- **Esperado:** Respuesta `success: true`, lista de cuotas del año solicitado.

## 6. Listado de catálogos
- **Entrada:** Ninguna.
- **Acción:** Enviar acción `get_categorias`, `get_secciones`, `get_claves_cuota`.
- **Esperado:** Respuesta `success: true`, datos de catálogo correspondientes.

## 7. Error de parámetros faltantes
- **Entrada:** Falta campo requerido (ej: sin 'categoria').
- **Acción:** Enviar acción `create_cuota`.
- **Esperado:** Respuesta `success: false`, mensaje de error de validación.
