# Casos de Prueba CatastroDM

## Caso 1: Alta de Descuento Predial
- **Entrada:** Clave catastral válida, datos de descuento completos
- **Acción:** Alta de descuento
- **Esperado:** Descuento insertado y visible en la lista

## Caso 2: Cancelación de Descuento Predial
- **Entrada:** ID de descuento vigente, usuario autorizado
- **Acción:** Cancelar descuento
- **Esperado:** Descuento marcado como cancelado

## Caso 3: Consulta de Adeudos y Descuentos
- **Entrada:** Clave catastral válida
- **Acción:** Consultar cuenta
- **Esperado:** Se muestran adeudos y descuentos

## Caso 4: Validación de Parámetros
- **Entrada:** Clave catastral vacía
- **Acción:** Buscar cuenta
- **Esperado:** Error de validación

## Caso 5: Permisos de Usuario
- **Entrada:** Usuario sin permisos de alta
- **Acción:** Intentar alta de descuento
- **Esperado:** Error de permisos
