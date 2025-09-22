# Casos de Prueba PasoEne

## 1. Carga Correcta de Archivo TXT
- **Entrada:** Archivo TXT con 5 líneas válidas.
- **Acción:** Cargar y ejecutar actualización.
- **Esperado:** 5 registros insertados, sin errores.

## 2. Archivo con Fechas Malformadas
- **Entrada:** Archivo TXT con 3 líneas, una con fecha '32/13/2022'.
- **Acción:** Cargar y ejecutar actualización.
- **Esperado:** 2 registros insertados, 1 error reportado por formato de fecha.

## 3. Archivo con Registros Duplicados
- **Entrada:** Archivo TXT con 4 líneas, dos con el mismo id_energia, axo, periodo.
- **Acción:** Cargar y ejecutar actualización.
- **Esperado:** 2 registros insertados, 2 errores de duplicidad reportados.

## 4. Archivo con Claves Foráneas Inválidas
- **Entrada:** Archivo TXT con 3 líneas, una con id_energia inexistente.
- **Acción:** Cargar y ejecutar actualización.
- **Esperado:** 2 registros insertados, 1 error de integridad referencial.

## 5. Archivo Vacío
- **Entrada:** Archivo TXT vacío.
- **Acción:** Cargar y ejecutar actualización.
- **Esperado:** Mensaje de error 'No hay registros para procesar'.

## 6. Interrupción de Red
- **Entrada:** Archivo TXT válido.
- **Acción:** Simular desconexión de red durante la carga.
- **Esperado:** Mensaje de error de red, sin registros insertados.
