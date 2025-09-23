# Casos de Prueba PasoConvDiversos

## Caso 1: Carga exitosa de archivo con nuevos convenios
- **Entrada:** Archivo plano con 3 filas, todas nuevas
- **Acción:** Cargar y procesar
- **Esperado:** 3 filas insertadas en padron y detalle, mensaje de éxito

## Caso 2: Carga mixta (nuevos y existentes)
- **Entrada:** Archivo con 2 filas nuevas y 2 existentes
- **Acción:** Procesar
- **Esperado:** 2 filas insertadas, 2 filas actualizadas, mensaje de éxito

## Caso 3: Error en formato de archivo
- **Entrada:** Archivo con columnas incompletas
- **Acción:** Procesar
- **Esperado:** Mensaje de error indicando columnas faltantes

## Caso 4: Error de base de datos (por ejemplo, valor duplicado en clave única)
- **Entrada:** Archivo con fila que viola restricción única
- **Acción:** Procesar
- **Esperado:** Mensaje de error, rollback de la transacción, ningún cambio en la base

## Caso 5: Validación de campos obligatorios
- **Entrada:** Fila con campo 'tipo' vacío
- **Acción:** Procesar
- **Esperado:** Mensaje de error indicando campo obligatorio faltante
