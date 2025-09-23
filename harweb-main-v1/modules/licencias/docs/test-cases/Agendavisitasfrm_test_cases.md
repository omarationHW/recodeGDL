## Casos de Prueba: Agenda de Visitas

### Caso 1: Consulta exitosa de visitas agendadas
- **Precondición:** Existen visitas agendadas para la dependencia 1 entre 2024-06-01 y 2024-06-30.
- **Acción:**
  - Enviar POST a `/api/execute` con:
    ```json
    {
      "eRequest": "get_agenda_visitas",
      "params": {
        "id_dependencia": 1,
        "fechaini": "2024-06-01",
        "fechafin": "2024-06-30"
      }
    }
    ```
- **Resultado esperado:**
  - `eResponse.success` es `true`.
  - `eResponse.data` contiene al menos una fila con los campos esperados.

### Caso 2: Consulta sin resultados
- **Precondición:** No existen visitas agendadas para la dependencia 99 en el rango dado.
- **Acción:**
  - Enviar POST a `/api/execute` con:
    ```json
    {
      "eRequest": "get_agenda_visitas",
      "params": {
        "id_dependencia": 99,
        "fechaini": "2024-01-01",
        "fechafin": "2024-01-31"
      }
    }
    ```
- **Resultado esperado:**
  - `eResponse.success` es `true`.
  - `eResponse.data` es un arreglo vacío.

### Caso 3: Exportación de resultados
- **Precondición:** Hay resultados en la tabla de visitas.
- **Acción:**
  - El usuario presiona 'Exportar a Excel'.
- **Resultado esperado:**
  - Se descarga un archivo CSV con los datos actuales.

### Caso 4: Impresión del reporte
- **Precondición:** Hay resultados en la tabla de visitas.
- **Acción:**
  - El usuario presiona 'Imprimir'.
- **Resultado esperado:**
  - Se abre una ventana de impresión con el reporte formateado.

### Caso 5: Parámetros faltantes
- **Acción:**
  - Enviar POST a `/api/execute` con:
    ```json
    {
      "eRequest": "get_agenda_visitas",
      "params": {
        "id_dependencia": 1
      }
    }
    ```
- **Resultado esperado:**
  - `eResponse.success` es `false`.
  - `eResponse.message` indica los parámetros faltantes.
