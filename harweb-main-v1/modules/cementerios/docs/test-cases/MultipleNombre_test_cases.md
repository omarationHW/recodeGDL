# Casos de Prueba: Consulta Múltiple por Nombre

## Caso 1: Búsqueda exitosa en todos los cementerios
- **Entrada:** Nombre = 'JUAN', Cementerio = 'Todos'
- **Acción:** Buscar
- **Esperado:** Tabla con registros cuyo nombre contiene 'JUAN', hasta 100 filas, botón 'Continuar búsqueda' visible si hay más de 100.

## Caso 2: Búsqueda exitosa en cementerio específico
- **Entrada:** Nombre = 'MARIA', Cementerio = 'B'
- **Acción:** Buscar
- **Esperado:** Tabla con registros de 'MARIA' solo del cementerio 'B'.

## Caso 3: Sin resultados
- **Entrada:** Nombre = 'ZZZZZZ', Cementerio = 'Todos'
- **Acción:** Buscar
- **Esperado:** Mensaje 'No existe Registro con esos Datos', tabla vacía.

## Caso 4: Paginación
- **Entrada:** Nombre = 'ANA', Cementerio = 'Todos'
- **Acción:** Buscar, luego 'Continuar búsqueda'
- **Esperado:** Se agregan los siguientes 100 registros a la tabla.

## Caso 5: Error de backend
- **Simulación:** API responde error
- **Esperado:** Mensaje de error visible en pantalla.
