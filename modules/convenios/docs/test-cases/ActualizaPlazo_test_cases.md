# Casos de Prueba: ActualizaPlazo

## Caso 1: Carga y actualización exitosa
- **Entrada:** Archivo con 2 filas válidas, todas las columnas completas.
- **Acción:** Importar, previsualizar, ejecutar actualización.
- **Esperado:** Ambas filas insertadas en ta_17_amp_plazo, sin errores.

## Caso 2: Fila incompleta
- **Entrada:** Archivo con una fila de solo 10 columnas.
- **Acción:** Importar, previsualizar, ejecutar actualización.
- **Esperado:** Error reportado en esa fila, no se inserta.

## Caso 3: Convenio inexistente
- **Entrada:** Archivo con colonia/calle/folio que no existen en ta_17_convenios.
- **Acción:** Importar, previsualizar, ejecutar actualización.
- **Esperado:** Error reportado en esa fila, no se inserta.

## Caso 4: Archivo vacío
- **Entrada:** Archivo vacío.
- **Acción:** Importar, previsualizar.
- **Esperado:** Grilla vacía, no se permite ejecutar actualización.

## Caso 5: Error de base de datos
- **Simulación:** Se desconecta la base de datos antes de ejecutar.
- **Acción:** Ejecutar actualización.
- **Esperado:** Error global, rollback, ningún registro insertado.
