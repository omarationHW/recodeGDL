# Casos de Prueba para Rep_AdeudCond

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|--------------------|
| TC01 | Consulta exitosa de reporte | num_contrato=10001, ctrol_aseo=1, opcion=1 | Tabla con datos de adeudos condonados |
| TC02 | Contrato inexistente | num_contrato=99999, ctrol_aseo=1 | Mensaje de error: 'No existe el contrato o tipo de aseo seleccionado.' |
| TC03 | Contrato sin adeudos condonados | num_contrato=10002, ctrol_aseo=1 | Mensaje de error: 'No existen adeudos condonados para este contrato.' |
| TC04 | Validación de campo obligatorio | num_contrato='', ctrol_aseo=1 | Mensaje de error: 'El No. de Contrato debe ser mayor a cero, intenta con otro.' |
| TC05 | Consulta con ordenamiento por operación | num_contrato=10001, ctrol_aseo=1, opcion=2 | Tabla con datos ordenados por operación |
