# Casos de Prueba para Alta de Ubicaciones

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| 1 | Alta exitosa de ubicación tipo Cordon | Ver Use Case 1 | Mensaje de éxito y registro insertado |
| 2 | Alta exitosa de ubicación tipo Bateria | Ver Use Case 2 | Mensaje de éxito y registro insertado |
| 3 | Alta fallida por campos obligatorios vacíos | Ver Use Case 3 | Mensaje de error de validación |
| 4 | Alta fallida por medida negativa | extencion = -5 | Mensaje de error de validación |
| 5 | Alta fallida por usuario inexistente | usuario = 99999 | Mensaje de error de integridad referencial |
| 6 | Alta fallida por contrato inexistente | contrato_id = 99999 | Mensaje de error de integridad referencial |
| 7 | Alta fallida por tipo_esta inválido | tipo_esta = 'X' | Mensaje de error de validación |
| 8 | Alta exitosa con inter2 vacío | inter2 = '' | Mensaje de éxito y registro insertado |

**Notas:**
- Todos los campos deben validarse en frontend y backend.
- El ID de usuario debe ser válido y corresponder a un usuario autenticado.
- El campo 'tipo_esta' solo acepta 'C' o 'B'.
- El campo 'acera' y 'hacia' solo aceptan 'N', 'S', 'O', 'P'.
