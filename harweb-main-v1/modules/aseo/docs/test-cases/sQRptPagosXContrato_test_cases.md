# Casos de Prueba: Pagos por Contrato

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Consulta exitosa con pagos hospitalarios | control: 1001, contrato: 1001, ctrol_aseo: 4 | Tabla con pagos, sumatorias correctas, etiqueta 'HOSPITALARIO' |
| 2 | Consulta sin resultados | control: 9999, contrato: 9999, ctrol_aseo: 8 | Mensaje 'No se encontraron registros' |
| 3 | Consulta con varios tipos de adeudo | control: 2002, contrato: 2002, ctrol_aseo: 9 | Tabla con pagos de CUOTA NORMAL, EXCEDENTE y CONTENEDORES, sumatorias correctas, etiqueta 'ZONA CENTRO' |
| 4 | Parámetros faltantes | control: null, contrato: 1001, ctrol_aseo: 4 | Error 422, mensaje de parámetros faltantes |
| 5 | Parámetro ctrol_aseo inválido | control: 1001, contrato: 1001, ctrol_aseo: 99 | Tabla vacía o etiqueta de aseo vacía |
| 6 | Consulta con contrato con pagos solo de un tipo | control: 3003, contrato: 3003, ctrol_aseo: 8 | Tabla con pagos solo de CUOTA NORMAL, sumatorias correctas |
