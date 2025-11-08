# Casos de Prueba: Dscto_p_pago

## 1. Alta de descuento válido
- **Entrada:** fecha_inicio=2024-07-01, fecha_fin=2024-07-31, porc_dscto=10.5, usuario_mov=admin
- **Acción:** create
- **Esperado:** success=true, message contiene 'creado', registro aparece en list

## 2. Alta con porcentaje inválido
- **Entrada:** fecha_inicio=2024-07-01, fecha_fin=2024-07-31, porc_dscto=150, usuario_mov=admin
- **Acción:** create
- **Esperado:** success=false, message contiene 'porcentaje'

## 3. Cancelar descuento vigente
- **Precondición:** existe registro con id=1 y status='V'
- **Entrada:** id=1, usuario_mov=admin
- **Acción:** delete
- **Esperado:** success=true, registro con id=1 cambia a status='C'

## 4. Cancelar descuento ya cancelado
- **Precondición:** registro con id=1 y status='C'
- **Entrada:** id=1, usuario_mov=admin
- **Acción:** delete
- **Esperado:** success=true (no error), pero status permanece 'C'

## 5. Listar descuentos
- **Acción:** list
- **Esperado:** success=true, data es array de registros

## 6. Validación de campos obligatorios
- **Entrada:** fecha_inicio=2024-07-01, fecha_fin=2024-07-31, usuario_mov=admin (falta porc_dscto)
- **Acción:** create
- **Esperado:** success=false, message contiene 'porc_dscto'
