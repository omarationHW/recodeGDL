# Casos de Prueba para Cancelación Masiva de Convenios

## Caso 1: Cancelación estándar (2 parcialidades vencidas)
- **Precondición:** Existen convenios con 2 o más parcialidades vencidas.
- **Acción:** Ejecutar cancelación con parámetro vencidas=2.
- **Esperado:** Se cancelan los convenios correctos, mensaje de éxito, lista actualizada.

## Caso 2: Cancelación personalizada (3 parcialidades vencidas)
- **Precondición:** Existen convenios con 3 o más parcialidades vencidas.
- **Acción:** Ejecutar cancelación con parámetro vencidas=3.
- **Esperado:** Solo se cancelan convenios con 3 o más vencidas.

## Caso 3: Sin convenios a cancelar
- **Precondición:** No existen convenios con el número de parcialidades vencidas requerido.
- **Acción:** Ejecutar cancelación.
- **Esperado:** Mensaje 'SE CANCELARON 0 CONVENIOS', lista vacía.

## Caso 4: Visualización de convenios cancelados
- **Precondición:** Existen convenios cancelados hoy.
- **Acción:** Consultar lista.
- **Esperado:** Tabla muestra los convenios cancelados hoy.

## Caso 5: Error de parámetros
- **Precondición:** Usuario envía parámetro vencidas inválido (ej: string, negativo).
- **Acción:** Ejecutar cancelación.
- **Esperado:** Mensaje de error de validación.

## Caso 6: Seguridad
- **Precondición:** Usuario no autenticado.
- **Acción:** Ejecutar cancelación.
- **Esperado:** Error de autenticación (401).
