# Casos de Prueba: Consulta de Ejecutores

## Caso 1: Consulta general de ejecutores
- **Precondición:** Existen ejecutores activos en la base de datos.
- **Acción:** Acceder a la página sin ingresar filtros.
- **Esperado:** Se muestran todos los ejecutores activos ordenados por clave.

## Caso 2: Búsqueda por nombre parcial
- **Precondición:** Existen ejecutores con nombre que contiene 'MARIA'.
- **Acción:** Ingresar 'MARIA' en el campo Nombre.
- **Esperado:** Solo se muestran ejecutores cuyo nombre contiene 'MARIA' (insensible a mayúsculas/minúsculas y acentos).

## Caso 3: Búsqueda por clave parcial
- **Precondición:** Existen ejecutores con cve_eje que inicia con '45'.
- **Acción:** Ingresar '45' en el campo Cve Ejecutor.
- **Esperado:** Solo se muestran ejecutores cuya clave inicia con '45'.

## Caso 4: Filtro sin resultados
- **Precondición:** No existen ejecutores con nombre 'ZZZZZ'.
- **Acción:** Ingresar 'ZZZZZ' en el campo Nombre.
- **Esperado:** La tabla muestra el mensaje 'No se encontraron ejecutores'.

## Caso 5: Validación de campo clave
- **Precondición:** El usuario intenta ingresar letras en el campo Cve Ejecutor.
- **Acción:** Teclear 'A' en el campo Cve Ejecutor.
- **Esperado:** El campo no acepta el carácter y solo permite números.

## Caso 6: Cancelar
- **Acción:** Hacer clic en el botón Cancelar.
- **Esperado:** El sistema regresa a la página anterior.