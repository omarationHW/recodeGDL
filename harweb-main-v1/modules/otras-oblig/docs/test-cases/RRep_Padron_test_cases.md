## Casos de Prueba para RRep_Padron

### Caso 1: Consulta de concesiones vigentes con adeudos vencidos
- **Entrada:**
  - Vigencia: VIGENTES
  - Adeudo: Periodos Vencidos
  - Año: 2024
  - Mes: 06
- **Acción:** Click en 'Previa'
- **Esperado:**
  - Tabla con concesiones vigentes y sus adeudos/recargos del mes actual.
  - Totales correctos por concesión.

### Caso 2: Consulta de concesiones canceladas para periodo específico
- **Entrada:**
  - Vigencia: CANCELADOS
  - Adeudo: Otro Periodo
  - Año: 2023
  - Mes: 03
- **Acción:** Click en 'Previa'
- **Esperado:**
  - Tabla con concesiones canceladas y sus adeudos/recargos de marzo 2023.

### Caso 3: Validación de año obligatorio
- **Entrada:**
  - Vigencia: cualquiera
  - Adeudo: Otro Periodo
  - Año: (vacío)
  - Mes: cualquiera
- **Acción:** Click en 'Previa'
- **Esperado:**
  - Mensaje de error: 'Falta el dato del AÑO a consultar, intentalo de nuevo'.
  - No se realiza consulta al backend.

### Caso 4: Consulta sin resultados
- **Entrada:**
  - Vigencia: VIGENTES
  - Adeudo: Otro Periodo
  - Año: 1999
  - Mes: 01
- **Acción:** Click en 'Previa'
- **Esperado:**
  - Tabla vacía o mensaje de "No hay datos".

### Caso 5: Error de backend
- **Simulación:** El stored procedure lanza excepción o la base de datos está caída.
- **Acción:** Click en 'Previa'
- **Esperado:**
  - Mensaje de error visible para el usuario.
