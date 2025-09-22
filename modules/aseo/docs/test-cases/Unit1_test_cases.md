# Casos de Prueba: Formulario Unit1

| #  | Escenario                                 | Entrada                                      | Resultado Esperado                                                                 |
|----|--------------------------------------------|----------------------------------------------|------------------------------------------------------------------------------------|
| 1  | Carga exitosa del formulario              | eRequest: 'unit1_get_form_data'              | success: true, message: 'Formulario Unit1 cargado correctamente.'                   |
| 2  | eRequest inválido                         | eRequest: 'unit1_invalid_request'            | success: false, message: 'eRequest no reconocido: unit1_invalid_request'            |
| 3  | Error de red/servidor                     | (Servidor caído)                             | Error de red en frontend, mensaje: 'Error de red o del servidor.'                   |
| 4  | Petición sin eRequest                     | (Falta eRequest en el body)                  | success: false, message: 'eRequest no reconocido: '                                 |
| 5  | Petición con parámetros extra             | eRequest: 'unit1_get_form_data', params: {x:1}| success: true, message: 'Formulario Unit1 cargado correctamente.'                   |
