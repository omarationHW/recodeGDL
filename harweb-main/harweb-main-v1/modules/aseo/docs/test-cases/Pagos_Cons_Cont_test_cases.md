# Casos de Prueba: Pagos_Cons_Cont

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC1  | Consulta exitosa de pagos | contrato=1803, ctrol_aseo=8 | Tabla con pagos, sin errores |
| TC2  | Contrato inexistente | contrato=999999, ctrol_aseo=8 | Mensaje de error: 'No existe contrato, intenta con otro.' |
| TC3  | Descarga de Edo. de Cuenta | contrato=1803, ctrol_aseo=8 | Se abre PDF del Edo. de Cuenta |
| TC4  | Validación de campos vacíos | contrato='', ctrol_aseo='' | Mensaje de error de campos requeridos |
| TC5  | Contrato sin pagos | contrato=1234, ctrol_aseo=8 (sin pagos 'P') | Mensaje: 'No existen pagos para este contrato.' |
