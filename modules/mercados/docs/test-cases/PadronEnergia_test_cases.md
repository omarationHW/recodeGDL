# Casos de Prueba para PadronEnergia

## 1. Consulta Exitosa
- **Entrada:** id_rec=2, num_mercado_nvo=10
- **Acción:** Buscar
- **Esperado:** Se muestra la tabla con datos del padrón de energía para el mercado 10 de la recaudadora 2.

## 2. Validación de Parámetros Vacíos
- **Entrada:** id_rec=, num_mercado_nvo=
- **Acción:** Buscar
- **Esperado:** Se muestra mensaje de error 'Seleccione oficina y mercado'.

## 3. Exportar Excel sin Datos
- **Entrada:** No hay datos en pantalla
- **Acción:** Exportar Excel
- **Esperado:** Botón deshabilitado o mensaje de error.

## 4. Exportar Excel con Datos
- **Entrada:** id_rec=3, num_mercado_nvo=7
- **Acción:** Buscar, luego Exportar Excel
- **Esperado:** Se descarga archivo Excel con los datos correctos.

## 5. Imprimir PDF sin Datos
- **Entrada:** No hay datos en pantalla
- **Acción:** Imprimir PDF
- **Esperado:** Botón deshabilitado o mensaje de error.

## 6. Imprimir PDF con Datos
- **Entrada:** id_rec=1, num_mercado_nvo=5
- **Acción:** Buscar, luego Imprimir PDF
- **Esperado:** Se abre PDF con los datos correctos.

## 7. Consulta con Mercado sin Energía
- **Entrada:** id_rec=2, num_mercado_nvo=99 (sin energía)
- **Acción:** Buscar
- **Esperado:** Mensaje 'No hay datos para mostrar.'
