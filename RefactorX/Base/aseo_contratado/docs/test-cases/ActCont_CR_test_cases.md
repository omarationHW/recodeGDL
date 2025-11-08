# Casos de Prueba: Formulario ActCont_CR

| ID | Descripción | Precondiciones | Pasos | Resultado Esperado |
|----|-------------|----------------|-------|-------------------|
| TC01 | Consulta contratos Zona Centro | Existen contratos con tipo_aseo=9 | 1. Acceder a la página. 2. Seleccionar '9 .- Zona Centro'. 3. Consultar. | Se muestran los contratos con tipo_aseo=9. |
| TC02 | Consulta contratos Ordinarios | Existen contratos con tipo_aseo=8 | 1. Acceder a la página. 2. Seleccionar '8 .- Ordinarios'. 3. Consultar. | Se muestran los contratos con tipo_aseo=8. |
| TC03 | Consulta contratos Hospitalarios sin resultados | No existen contratos con tipo_aseo=4 | 1. Acceder a la página. 2. Seleccionar '4 .- Hospitalarios'. 3. Consultar. | Se muestra mensaje de 'No se encontraron contratos'. |
| TC04 | Error de conexión API | API no disponible | 1. Acceder a la página. 2. Seleccionar cualquier tipo. 3. Consultar. | Se muestra mensaje de error de red. |
| TC05 | Validación de selección obligatoria | No seleccionar tipo de aseo | 1. Acceder a la página. 2. Intentar consultar sin seleccionar tipo. | El formulario no permite enviar y muestra validación. |
